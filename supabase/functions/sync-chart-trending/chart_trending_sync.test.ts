import test from "node:test";
import assert from "node:assert/strict";

import { normalizePriceRows, toDateUtcIso } from "./chart_trending_sync.ts";

test("toDateUtcIso normalizes to UTC start of day", () => {
  assert.equal(
    toDateUtcIso(Date.UTC(2026, 2, 10, 14, 32, 5)),
    "2026-03-10T00:00:00.000Z",
  );
});

test("normalizePriceRows deduplicates per UTC day and keeps latest sample", () => {
  const rows = normalizePriceRows(
    [
      [Date.UTC(2026, 2, 10, 1), 100],
      [Date.UTC(2026, 2, 10, 22), 125],
      [Date.UTC(2026, 2, 11, 8), 150],
    ],
    "2026-03-12T09:00:00.000Z",
  );

  assert.deepEqual(rows, [
    {
      date_utc: "2026-03-10T00:00:00.000Z",
      value: 125,
      updated_at: "2026-03-12T09:00:00.000Z",
    },
    {
      date_utc: "2026-03-11T00:00:00.000Z",
      value: 150,
      updated_at: "2026-03-12T09:00:00.000Z",
    },
  ]);
});

test("normalizePriceRows ignores invalid entries and sorts ascending by day", () => {
  const rows = normalizePriceRows(
    [
      ["bad", 1],
      [Date.UTC(2026, 2, 12, 12), Number.NaN],
      [Date.UTC(2026, 2, 11, 12), 110],
      [Date.UTC(2026, 2, 10, 12), 90],
    ],
    "2026-03-12T09:00:00.000Z",
  );

  assert.deepEqual(
    rows.map((row) => ({
      date_utc: row.date_utc,
      value: row.value,
    })),
    [
      { date_utc: "2026-03-10T00:00:00.000Z", value: 90 },
      { date_utc: "2026-03-11T00:00:00.000Z", value: 110 },
    ],
  );
});
