/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-var-requires */

const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

function requiredEnv(name) {
  const v = process.env[name];
  if (!v || String(v).trim().length === 0) {
    throw new Error(`Missing env var: ${name}`);
  }
  return String(v).trim();
}

function loadServiceAccountJson(serviceAccountPath) {
  const abs = path.isAbsolute(serviceAccountPath)
    ? serviceAccountPath
    : path.join(process.cwd(), "..", serviceAccountPath);
  const raw = fs.readFileSync(abs, "utf8");
  return JSON.parse(raw);
}

function resolveContentDir() {
  const raw = (process.env.STAFF_DEMO_CONTENT_DIR ?? "").trim();
  const defaultRel = path.join("tool", "staff_demo_content");

  const p = raw.length > 0 ? raw : defaultRel;
  if (path.isAbsolute(p)) return p;

  // We run from `functions/`, so relative paths are relative to CWD.
  return path.join(process.cwd(), p);
}

function titleFromFilename(filename) {
  const base = filename.replace(path.extname(filename), "");
  return base.replace(/[-_]+/g, " ").trim();
}

function contentIdFromFilename(filename) {
  const base = filename.replace(path.extname(filename), "").toLowerCase();
  const normalized = base
    .trim()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
  return normalized.length > 0 ? normalized : "content";
}

function detectContentTypeAndKind(filename) {
  const ext = path.extname(filename).toLowerCase();
  if (ext === ".pdf") {
    return { kind: "pdf", contentType: "application/pdf" };
  }
  if (ext === ".mp4") {
    return { kind: "video", contentType: "video/mp4" };
  }
  if (ext === ".mov") {
    // Most iOS exports are .mov; Storage can still serve it fine.
    return { kind: "video", contentType: "video/quicktime" };
  }
  return null;
}

async function uploadAlways({ bucket, storagePath, bytes, contentType }) {
  const file = bucket.file(storagePath);
  await file.save(Buffer.from(bytes), {
    resumable: false,
    contentType,
    metadata: { cacheControl: "public, max-age=3600" },
  });
}

async function main() {
  const projectId = requiredEnv("STAFF_DEMO_PROJECT_ID");
  const serviceAccountPath = requiredEnv("STAFF_DEMO_SERVICE_ACCOUNT_JSON");
  const storageBucket =
    (process.env.STAFF_DEMO_STORAGE_BUCKET ?? "").trim() ||
    `${projectId}.firebasestorage.app`;

  const contentDir = resolveContentDir();
  if (!fs.existsSync(contentDir)) {
    throw new Error(
      `Content directory does not exist: ${contentDir}\n` +
        `Set STAFF_DEMO_CONTENT_DIR or create tool/staff_demo_content/ under functions/.`
    );
  }

  const serviceAccount = loadServiceAccountJson(serviceAccountPath);
  if (admin.apps.length === 0) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId,
      storageBucket,
    });
  }

  const firestore = admin.firestore();
  const bucket = admin.storage().bucket();

  const entries = fs
    .readdirSync(contentDir, { withFileTypes: true })
    .filter((e) => e.isFile())
    .map((e) => e.name)
    .filter((name) => !name.startsWith("."))
    .sort((a, b) => a.localeCompare(b));

  if (entries.length === 0) {
    console.log(
      `ℹ️ No files found in ${contentDir}. Nothing to upload.\n` +
        `Drop PDFs/videos there (e.g. demo.pdf, intro.mp4) and rerun.`
    );
    return;
  }

  let uploaded = 0;
  let skipped = 0;

  for (const filename of entries) {
    const detected = detectContentTypeAndKind(filename);
    if (!detected) {
      skipped += 1;
      console.log(`- skip (unsupported): ${filename}`);
      continue;
    }

    const abs = path.join(contentDir, filename);
    const bytes = fs.readFileSync(abs);

    const contentId = contentIdFromFilename(filename);
    const title = titleFromFilename(filename);
    const storagePath = `staff-app-demo/content/${filename}`;

    await uploadAlways({
      bucket,
      storagePath,
      bytes,
      contentType: detected.contentType,
    });

    await firestore.collection("staffDemoContent").doc(contentId).set(
      {
        title,
        type: detected.kind,
        storagePath,
        isPublished: true,
        seededAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    uploaded += 1;
    console.log(`+ uploaded: ${filename} -> ${contentId}`);
  }

  console.log("");
  console.log(
    `✅ Staff demo content setup complete. Uploaded: ${uploaded}, skipped: ${skipped}`
  );
}

main().catch((err) => {
  console.error("❌ Failed to setup staff demo content");
  console.error(err);
  process.exitCode = 1;
});

