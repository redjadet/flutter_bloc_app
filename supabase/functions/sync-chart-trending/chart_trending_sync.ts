export type PriceEntry = [number, number];

type RawPriceEntry = readonly [unknown, unknown];

export type ChartTrendingUpsertRow = {
  date_utc: string;
  value: number;
  updated_at: string;
};

type ChartTrendingRowCandidate = {
  sourceTsMs: number;
  row: ChartTrendingUpsertRow;
};

/** Start of day UTC for a given timestamp (ms). */
export function toDateUtcIso(tsMs: number): string {
  const d = new Date(tsMs);
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, "0");
  const day = String(d.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${day}T00:00:00.000Z`;
}

function isValidPriceEntry(entry: unknown): entry is RawPriceEntry {
  return (
    Array.isArray(entry) &&
    entry.length >= 2 &&
    typeof entry[0] === "number" &&
    Number.isFinite(entry[0]) &&
    typeof entry[1] === "number" &&
    Number.isFinite(entry[1])
  );
}

export function normalizePriceRows(
  prices: readonly unknown[],
  syncedAtIso = new Date().toISOString(),
): ChartTrendingUpsertRow[] {
  const byDate = new Map<string, ChartTrendingRowCandidate>();

  for (const entry of prices) {
    if (!isValidPriceEntry(entry)) {
      continue;
    }

    const [sourceTsMs, value] = entry;
    const dateUtc = toDateUtcIso(sourceTsMs);
    const existing = byDate.get(dateUtc);
    if (existing && existing.sourceTsMs > sourceTsMs) {
      continue;
    }

    byDate.set(dateUtc, {
      sourceTsMs,
      row: {
        date_utc: dateUtc,
        value: Number(value),
        updated_at: syncedAtIso,
      },
    });
  }

  return Array.from(byDate.values(), (candidate) => candidate.row).sort(
    (a, b) => a.date_utc.localeCompare(b.date_utc),
  );
}
