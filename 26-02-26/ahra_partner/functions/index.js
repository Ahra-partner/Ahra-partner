/**
 * Firebase Cloud Functions – FINAL SETUP
 * Region: asia-south1
 */

const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

// 🔴 VERY IMPORTANT – keep everything in same region
setGlobalOptions({ region: "asia-south1" });

/* =====================================================
   1️⃣ LEDGER CREATE → WALLET + EARNINGS UPDATE
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
    const direction = data.direction;

    if (!partnerId || amount <= 0) return;

    const partnerRef = admin
      .firestore()
      .collection("partners")
      .doc(partnerId);

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
   3️⃣ WITHDRAW STATUS NOTIFICATION
===================================================== */
exports.notifyWithdrawStatus = onDocumentUpdated(
  "withdraw_requests/{requestId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!before || !after) return;
    if (before.status === after.status) return;

    const status = after.status;
    if (status !== "approved" && status !== "rejected") return;

    const partnerId = after.partnerId;
    if (!partnerId) return;

    const partnerSnap = await admin
      .firestore()
      .collection("partners")
      .doc(partnerId)
      .get();

    if (!partnerSnap.exists) return;

    const token = partnerSnap.data().fcmToken;
    if (!token) return;

    const payload = {
      notification: {
        title:
          status === "approved"
            ? "Withdraw Approved ✅"
            : "Withdraw Rejected ❌",
        body: `₹${after.amount} status updated`,
      },
    };

    await admin.messaging().sendToDevice(token, payload);
  }
);

/* =====================================================
   9️⃣ 🔔 SUPPORT TICKET REPLY NOTIFICATION (NEW)
===================================================== */
exports.notifyTicketReply = onDocumentUpdated(
  "support_tickets/{ticketId}",
  async (event) => {

    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!before || !after) return;

    // ✅ Trigger only if adminReply changed
    if (before.adminReply === after.adminReply) return;

    const partnerId = after.partnerId;
    if (!partnerId) return;

    const partnerSnap = await admin
      .firestore()
      .collection("partners")
      .doc(partnerId)
      .get();

    if (!partnerSnap.exists) return;

    const token = partnerSnap.data().fcmToken;
    if (!token) return;

    const payload = {
      notification: {
        title: "Support Ticket Updated 🎫",
        body: "Admin has replied to your ticket.",
      },
    };

    console.log("🔔 Sending Ticket Reply Notification to:", partnerId);

    await admin.messaging().sendToDevice(token, payload);
  }
);

/* =====================================================
   4️⃣ DAILY RESET
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
  }
);

/* =====================================================
   5️⃣ WEEKLY RESET
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
  }
);

/* =====================================================
   6️⃣ MONTHLY RESET
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
  }
);
