#!/usr/bin/env node
// set-admin.js
// Usage: node set-admin.js <UID> [path/to/service-account.json]
// This script sets the custom claim { admin: true } for the given UID

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

async function main() {
  const uid = process.argv[2];
  const saArg = process.argv[3];

  if (!uid) {
    console.error('Usage: node set-admin.js <UID> [path/to/service-account.json]');
    process.exit(1);
  }

  const fallbackCandidates = [
    'assets/service-account.json',
    'assets/service-account.json',
    'service-account.json',
  ];

  let saPath = saArg ? path.resolve(process.cwd(), saArg) : null;
  if (!saPath) {
    for (const p of fallbackCandidates) {
      const full = path.resolve(process.cwd(), p);
      if (fs.existsSync(full)) {
        saPath = full;
        break;
      }
    }
  }

  if (!saPath || !fs.existsSync(saPath)) {
    console.error('Service account JSON not found. Expected one of:', fallbackCandidates.join(', '));
    console.error('Or pass path as second argument: node set-admin.js <UID> path/to/service-account.json');
    process.exit(2);
  }

  const serviceAccount = require(saPath);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  try {
    await admin.auth().setCustomUserClaims(uid, { admin: true });
    console.log(`Set custom claim { admin: true } for UID ${uid}`);

    // Optional: print the current custom claims from the server
    const user = await admin.auth().getUser(uid);
    console.log('User claims after update:', user.customClaims);
    process.exit(0);
  } catch (err) {
    console.error('Error setting custom claim:', err);
    process.exit(3);
  }
}

main();
