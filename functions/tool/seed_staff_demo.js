/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-var-requires */
//
// Firestore document shapes here must stay aligned with Dart mappers + tests:
// - lib/features/staff_app_demo/data/staff_demo_*_firestore_map.dart
// - test/features/staff_app_demo/data/staff_demo_seed_document_fixtures.dart (canonical payloads)
// - test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart
//

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

async function getOrCreateUser({ email, password, displayName }) {
  try {
    const existing = await admin.auth().getUserByEmail(email);
    // Keep password aligned for repeatable demos.
    await admin.auth().updateUser(existing.uid, { password, displayName });
    return existing.uid;
  } catch (e) {
    const created = await admin.auth().createUser({
      email,
      password,
      displayName,
      emailVerified: true,
      disabled: false,
    });
    return created.uid;
  }
}

async function ensureStorageObject({ bucket, storagePath, bytes, contentType }) {
  const file = bucket.file(storagePath);
  try {
    await file.getMetadata();
    return;
  } catch (_) {
    // not found -> upload
  }
  await file.save(Buffer.from(bytes), {
    resumable: false,
    contentType,
    metadata: { cacheControl: "public, max-age=3600" },
  });
}

function minimalPdfBytes({ title }) {
  // Small, valid PDF (enough for mobile PDF viewers).
  const body = `%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>
endobj
4 0 obj
<< /Length 74 >>
stream
BT
/F1 24 Tf
72 720 Td
(${title}) Tj
ET
endstream
endobj
5 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
endobj
xref
0 6
0000000000 65535 f
0000000010 00000 n
0000000061 00000 n
0000000116 00000 n
0000000241 00000 n
0000000366 00000 n
trailer
<< /Size 6 /Root 1 0 R >>
startxref
436
%%EOF
`;
  return Buffer.from(body, "utf8");
}

async function main() {
  const projectId = requiredEnv("STAFF_DEMO_PROJECT_ID");
  const serviceAccountPath = requiredEnv("STAFF_DEMO_SERVICE_ACCOUNT_JSON");
  const storageBucket =
    (process.env.STAFF_DEMO_STORAGE_BUCKET ?? "").trim() ||
    `${projectId}.firebasestorage.app`;
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

  const password = "StaffDemo!234";
  const employeeEmail = "staffdemo.employee@example.com";
  const managerEmail = "staffdemo.manager@example.com";
  const accountantEmail = "staffdemo.accountant@example.com";

  const [employeeUid, managerUid, accountantUid] = await Promise.all([
    getOrCreateUser({
      email: employeeEmail,
      password,
      displayName: "Staff Demo Employee",
    }),
    getOrCreateUser({
      email: managerEmail,
      password,
      displayName: "Staff Demo Manager",
    }),
    getOrCreateUser({
      email: accountantEmail,
      password,
      displayName: "Staff Demo Accountant",
    }),
  ]);

  const profiles = [
    {
      uid: employeeUid,
      email: employeeEmail,
      displayName: "Staff Demo Employee",
      role: "employee",
      isActive: true,
    },
    {
      uid: managerUid,
      email: managerEmail,
      displayName: "Staff Demo Manager",
      role: "manager",
      isActive: true,
    },
    {
      uid: accountantUid,
      email: accountantEmail,
      displayName: "Staff Demo Accountant",
      role: "accountant",
      isActive: true,
    },
  ];

  for (const p of profiles) {
    await firestore
      .collection("staffDemoProfiles")
      .doc(p.uid)
      .set(
        {
          displayName: p.displayName,
          email: p.email,
          role: p.role,
          isActive: p.isActive,
          // phoneE164 intentionally omitted by default
          seededAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
  }

  const siteId = "site1";
  const centerLat = 43.6532;
  const centerLng = -79.3832;
  const radiusMeters = 250;
  await firestore.collection("staffDemoSites").doc(siteId).set(
    {
      name: "Demo Warehouse",
      // Downtown Toronto-ish defaults; update for your real geofence.
      // Flat fields (historical) + nested geofence (matches app parser docs).
      centerLat,
      centerLng,
      radiusMeters,
      geofenceCenter: { lat: centerLat, lng: centerLng },
      geofenceRadiusMeters: radiusMeters,
      seededAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  const now = new Date();
  const startAt = new Date(now.getTime() - 30 * 60 * 1000);
  const endAt = new Date(now.getTime() + 4 * 60 * 60 * 1000);

  const shiftId = "shift1";
  await firestore.collection("staffDemoShifts").doc(shiftId).set(
    {
      userId: employeeUid,
      siteId,
      startAt: admin.firestore.Timestamp.fromDate(startAt),
      endAt: admin.firestore.Timestamp.fromDate(endAt),
      timezoneName: "UTC",
      status: "assigned",
      seededAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  const contentId = "welcome_pdf";
  const storagePath = "staff-app-demo/content/welcome.pdf";
  await ensureStorageObject({
    bucket,
    storagePath,
    bytes: minimalPdfBytes({ title: "Staff App Demo - Welcome" }),
    contentType: "application/pdf",
  });

  await firestore.collection("staffDemoContent").doc(contentId).set(
    {
      title: "Welcome (PDF)",
      type: "pdf",
      storagePath,
      isPublished: true,
      seededAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  console.log("✅ Staff demo seeded.");
  console.log("");
  console.log("Sign-in credentials (all users share same password):");
  console.log(`- employee:   ${employeeEmail}  (${employeeUid})`);
  console.log(`- manager:    ${managerEmail}  (${managerUid})`);
  console.log(`- accountant: ${accountantEmail}  (${accountantUid})`);
  console.log(`- password:   ${password}`);
  console.log("");
  console.log("Seeded docs:");
  console.log(`- staffDemoSites/${siteId}`);
  console.log(`- staffDemoShifts/${shiftId} (for employee uid)`);
  console.log(`- staffDemoContent/${contentId} -> gs://${bucket.name}/${storagePath}`);
}

main().catch((e) => {
  console.error("❌ Seed failed:", e);
  process.exit(1);
});

