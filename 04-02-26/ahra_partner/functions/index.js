/**
 * Firebase Cloud Functions – FINAL SETUP
 * Region: asia-south1
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

// 🔴 VERY IMPORTANT – keep everything in same region
setGlobalOptions({ region: "asia-south1" });

/* =====================================================
   1️⃣ LEDGER CREATE → WALLET + EARNINGS UPDATE
   Trigger: wallet_ledger document created
===================================================== */
exports.onLedgerCreate = onDocumentCreated(
  "wallet_ledger/{docId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    if (!data) return;

    const partnerId = data.partnerId;
    const amount = Number(data.amount || 0);
    const direction = data.direction; // credit | debit

    if (!partnerId || amount <= 0) return;

    const partnerRef = admin.firestore()
      .collection("partners")
      .doc(partnerId);

    console.log("🔥 LEDGER:", partnerId, direction, amount);

    // ✅ CREDIT → add wallet + earnings
    if (direction === "credit") {
      await partnerRef.set(
        {
          walletBalance: admin.firestore.FieldValue.increment(amount),
          todayEarnings: admin.firestore.FieldValue.increment(amount),
          weekEarnings: admin.firestore.FieldValue.increment(amount),
          monthEarnings: admin.firestore.FieldValue.increment(amount),
        },
        { merge: true }
      );
    }

    // ✅ DEBIT → subtract wallet only
    if (direction === "debit") {
      await partnerRef.set(
        {
          walletBalance: admin.firestore.FieldValue.increment(-amount),
        },
        { merge: true }
      );
    }
  }
);

/* =====================================================
   2️⃣ WITHDRAW APPROVED → CREATE DEBIT LEDGER
   Trigger: withdraw_requests document created
===================================================== */
exports.onWithdrawApproved = onDocumentCreated(
  "withdraw_requests/{docId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    if (!data || data.status !== "approved") return;

    const { partnerId, amount } = data;
    if (!partnerId || !amount) return;

    console.log("💸 WITHDRAW APPROVED:", partnerId, amount);

    await admin.firestore().collection("wallet_ledger").add({
      partnerId,
      amount,
      direction: "debit",
      type: "withdraw",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
);

/* =====================================================
   3️⃣ DAILY RESET – Today Earnings
   Runs every day at 12:00 AM IST
===================================================== */
exports.resetTodayEarnings = onSchedule(
  {
    schedule: "0 0 * * *",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const db = admin.firestore();
    const snap = await db.collection("partners").get();

    const batch = db.batch();
    snap.forEach((doc) => {
      batch.update(doc.ref, { todayEarnings: 0 });
    });

    await batch.commit();
    console.log("✅ Daily reset done (todayEarnings)");
  }
);

/* =====================================================
   4️⃣ WEEKLY RESET – Week Earnings
   Runs every Sunday at 12:00 AM IST
===================================================== */
exports.resetWeekEarnings = onSchedule(
  {
    schedule: "0 0 * * 0",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const db = admin.firestore();
    const snap = await db.collection("partners").get();

    const batch = db.batch();
    snap.forEach((doc) => {
      batch.update(doc.ref, { weekEarnings: 0 });
    });

    await batch.commit();
    console.log("✅ Weekly reset done (weekEarnings)");
  }
);

/* =====================================================
   5️⃣ MONTHLY RESET – Month Earnings
   Runs on 1st day of every month at 12:00 AM IST
===================================================== */
exports.resetMonthEarnings = onSchedule(
  {
    schedule: "0 0 1 * *",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const db = admin.firestore();
    const snap = await db.collection("partners").get();

    const batch = db.batch();
    snap.forEach((doc) => {
      batch.update(doc.ref, { monthEarnings: 0 });
    });

    await batch.commit();
    console.log("✅ Monthly reset done (monthEarnings)");
  }
);

/* =====================================================
   6️⃣ DAILY STATS SNAPSHOT (FOR DAILY CHART)
   Runs every day at 12:05 AM IST
===================================================== */
exports.collectDailyStats = onSchedule(
  {
    schedule: "5 0 * * *",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const db = admin.firestore();
    const partnersSnap = await db.collection("partners").get();

    let total = 0;
    partnersSnap.forEach((doc) => {
      total += doc.data().todayEarnings || 0;
    });

    const today = new Date().toISOString().slice(0, 10);

    await db.collection("daily_stats").doc(today).set({
      totalEarnings: total,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log("📊 Daily stats saved:", today, total);
  }
);

/* =====================================================
   7️⃣ MONTHLY STATS SNAPSHOT (FOR MONTHLY CHART)
   Runs on 1st day of every month – 12:10 AM IST
===================================================== */
exports.collectMonthlyStats = onSchedule(
  {
    schedule: "10 0 1 * *",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const db = admin.firestore();
    const partnersSnap = await db.collection("partners").get();

    let total = 0;
    partnersSnap.forEach((doc) => {
      total += doc.data().monthEarnings || 0;
    });

    const now = new Date();
    const monthKey = `${now.getFullYear()}-${String(
      now.getMonth() + 1
    ).padStart(2, "0")}`;

    await db.collection("monthly_stats").doc(monthKey).set({
      month: monthKey,
      totalEarnings: total,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log("📊 Monthly stats saved:", monthKey, total);
  }
);
