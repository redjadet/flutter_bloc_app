const assert = require("node:assert/strict");
const test = require("node:test");

const functions = require("../lib/index.js");

function ts(ms) {
  return {
    toMillis: () => ms,
  };
}

test("shouldRefreshChartTrending respects cache freshness and refresh leases", () => {
  const nowMs = Date.UTC(2026, 3, 10, 12, 0, 0);

  const fresh = functions.shouldRefreshChartTrending({
    cachedPoints: [{date_utc: "2026-04-10T10:00:00.000Z", value: 1}],
    updatedAt: ts(nowMs - 60_000),
    nowMs,
  });
  assert.equal(fresh.shouldRefresh, false);
  assert.equal(fresh.shouldServeCache, true);

  const leased = functions.shouldRefreshChartTrending({
    cachedPoints: [],
    refreshInProgress: true,
    refreshStartedAt: ts(nowMs - 30_000),
    updatedAt: null,
    nowMs,
  });
  assert.equal(leased.shouldRefresh, false);
  assert.equal(leased.shouldServeCache, true);

  const stale = functions.shouldRefreshChartTrending({
    cachedPoints: [],
    refreshInProgress: false,
    updatedAt: null,
    nowMs,
  });
  assert.equal(stale.shouldRefresh, true);
  assert.equal(stale.shouldServeCache, false);
});

test("sheets quota detection and backoff are bounded", () => {
  assert.equal(
    functions.isSheetsQuotaExceeded({
      code: 429,
      message: "Quota exceeded for quota metric 'Write requests'",
    }),
    true
  );
  assert.equal(
    functions.isSheetsQuotaExceeded({
      code: 500,
      message: "Something else",
    }),
    false
  );

  const backoff0 = functions.backoffMsForAttempt(0);
  const backoff8 = functions.backoffMsForAttempt(8);
  assert.ok(backoff0 >= 1000 && backoff0 <= 1750);
  assert.ok(backoff8 >= 256000 && backoff8 <= 256750);
});

test("retry scheduler only claims closed, non-terminal export entries", () => {
  assert.equal(
    functions.isStaffDemoTimeEntryExportClaimable({
      entryState: "closed",
      exportStatus: "none",
    }),
    true
  );
  assert.equal(
    functions.isStaffDemoTimeEntryExportClaimable({
      entryState: "open",
      exportStatus: "none",
    }),
    false
  );
  assert.equal(
    functions.isStaffDemoTimeEntryExportClaimable({
      entryState: "closed",
      exportStatus: "in_progress",
    }),
    false
  );
  assert.equal(
    functions.isStaffDemoTimeEntryExportClaimable({
      entryState: "closed",
      exportStatus: "rate_limited",
    }),
    false
  );
  assert.equal(
    functions.isStaffDemoTimeEntryExportClaimable({
      entryState: "closed",
      exportStatus: "exported",
    }),
    false
  );
});

test("message delivery claim logic prevents duplicate in-flight sends", () => {
  const nowMs = Date.UTC(2026, 3, 10, 12, 0, 0);

  assert.equal(
    functions.shouldClaimStaffDemoMessageDelivery(
      {deliveredAt: ts(nowMs - 10_000)},
      nowMs
    ),
    false
  );
  assert.equal(
    functions.shouldClaimStaffDemoMessageDelivery(
      {
        deliveryStatus: "in_progress",
        deliveryLeaseStartedAt: ts(nowMs - 30_000),
      },
      nowMs
    ),
    false
  );
  assert.equal(
    functions.shouldClaimStaffDemoMessageDelivery(
      {
        deliveryStatus: "in_progress",
        deliveryLeaseStartedAt: ts(nowMs - 5 * 60_000),
      },
      nowMs
    ),
    true
  );
  assert.equal(functions.shouldClaimStaffDemoMessageDelivery({}, nowMs), true);
});

test("weekly reminder token collection deduplicates and filters invalid profiles", () => {
  const tokens = functions.collectWeeklyReminderTokens([
    {isActive: true, role: "manager", fcmToken: "tok-1"},
    {isActive: true, role: "accountant", fcmToken: "tok-1"},
    {isActive: false, role: "manager", fcmToken: "tok-2"},
    {isActive: true, role: "", fcmToken: "tok-3"},
    {isActive: true, role: "employee", fcmToken: " "},
    {isActive: true, role: "employee", fcmToken: "tok-4"},
  ]);

  assert.deepEqual(tokens.sort(), ["tok-1", "tok-4"]);
  assert.deepEqual(functions.chunkArray(tokens, 1), [["tok-1"], ["tok-4"]]);
});

test("staff demo external config predicates match missing-config fallbacks", () => {
  assert.equal(
    functions.hasStaffDemoSheetsConfig({
      spreadsheetId: "sheet-123",
      credentialsJson: '{"type":"service_account"}',
    }),
    true
  );
  assert.equal(
    functions.hasStaffDemoSheetsConfig({
      spreadsheetId: "",
      credentialsJson: '{"type":"service_account"}',
    }),
    false
  );
  assert.equal(
    functions.hasStaffDemoTwilioConfig({
      accountSid: "AC123",
      authToken: "token",
      fromNumber: "+15551234567",
    }),
    true
  );
  assert.equal(
    functions.hasStaffDemoTwilioConfig({
      accountSid: "AC123",
      authToken: "",
      fromNumber: "+15551234567",
    }),
    false
  );
});
