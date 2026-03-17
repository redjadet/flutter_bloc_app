import { execSync } from "node:child_process";

function runAuditJson() {
  try {
    const output = execSync("npm audit --json", {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    });
    return JSON.parse(output);
  } catch (e) {
    // npm audit returns non-zero when vulns exist; still emits JSON.
    const stdout = e?.stdout?.toString?.() ?? "";
    if (stdout.trim().startsWith("{")) {
      return JSON.parse(stdout);
    }
    throw e;
  }
}

function summarizeVulns(report) {
  const meta = report?.metadata?.vulnerabilities;
  if (!meta || typeof meta !== "object") {
    return { info: 0, low: 0, moderate: 0, high: 0, critical: 0, total: 0 };
  }
  const info = Number(meta.info ?? 0);
  const low = Number(meta.low ?? 0);
  const moderate = Number(meta.moderate ?? 0);
  const high = Number(meta.high ?? 0);
  const critical = Number(meta.critical ?? 0);
  const total = info + low + moderate + high + critical;
  return { info, low, moderate, high, critical, total };
}

try {
  const report = runAuditJson();
  const { info, low, moderate, high, critical, total } = summarizeVulns(report);

  if (moderate > 0 || high > 0 || critical > 0) {
    console.error(
      `npm audit: ${total} vulnerabilities (info=${info}, low=${low}, moderate=${moderate}, high=${high}, critical=${critical})`,
    );
    console.error("Failing because moderate+ vulnerabilities exist.");
    process.exit(1);
  }

  if (total === 0) {
    console.log("npm audit: no vulnerabilities.");
    process.exit(0);
  }

  console.log(
    `npm audit: ${total} vulnerabilities (info=${info}, low=${low}).`,
  );
  console.log("Passing because only info/low vulnerabilities exist.");
  process.exit(0);
} catch (e) {
  console.error("Failed to run npm audit safely.");
  console.error(e?.message ?? String(e));
  process.exit(2);
}

