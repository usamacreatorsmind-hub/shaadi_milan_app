import { setGlobalOptions } from "firebase-functions/v2";
import { onDocumentCreated, onDocumentUpdated, onDocumentWritten } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { logger } from "firebase-functions";
import axios from "axios";

setGlobalOptions({ maxInstances: 10, region: "us-central1" });

admin.initializeApp();

// ============================================================
// HELPER FUNCTIONS
// ============================================================

// Helper function to send notification with error handling
async function sendNotification(
  message: admin.messaging.Message,
  context: string
): Promise<boolean> {
  try {
    await admin.messaging().send(message);
    logger.info(`Notification sent: ${context}`);
    return true;
  } catch (error: unknown) {
    const fcmError = error as { code?: string };
    if (
      fcmError.code === "messaging/invalid-registration-token" ||
      fcmError.code === "messaging/registration-token-not-registered"
    ) {
      logger.warn(`Invalid FCM token for ${context}`);
      return false;
    }
    logger.error(`Failed to send notification: ${context}`, { error });
    return false;
  }
}

// Helper to clean invalid token from collection
async function cleanInvalidToken(collection: string, docId: string) {
  try {
    await admin.firestore().collection(collection).doc(docId).update({
      fcmToken: admin.firestore.FieldValue.delete(),
      fcmTokenUpdatedAt: admin.firestore.FieldValue.delete(),
    });
    logger.info(`Cleaned invalid token from ${collection}/${docId}`);
  } catch (e) {
    logger.error(`Failed to clean token from ${collection}/${docId}`, { error: e });
  }
}

// ============================================================
// USER REGISTRATION - Notify Agent
// ============================================================
export const notifyAgentOnUserRegister = onDocumentCreated(
  "users/{userId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("No user snapshot");
      return;
    }

    const user = snapshot.data();
    const userId = event.params.userId;
    const agentId = user.agentId;

    // Check if agent already notified (prevents duplicate on retry)
    if (user.agentNotifiedOnRegister === true) {
      logger.info("Agent already notified for registration", { userId });
      return;
    }

    if (!agentId || agentId.trim() === "") {
      logger.info("User registered without Staff Id", { userId });
      return;
    }

    const agentSnap = await admin.firestore().collection("agents").doc(agentId).get();
    if (!agentSnap.exists) {
      logger.warn("Agent not found", { agentId });
      return;
    }

    const agent = agentSnap.data();
    const agentFcmToken = agent?.fcmToken;

    if (!agentFcmToken) {
      logger.warn("Agent FCM token missing", { agentId });
      return;
    }

    const message: admin.messaging.Message = {
      token: agentFcmToken,
      notification: {
        title: "New User Registered",
        body: `${user.fullName ?? "A new user"} registered with your Staff Id`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        screen: "view_user",
        userId: userId,
        agentId: agentId,
        type: "USER_REGISTERED",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "fcm_channel",
          priority: "high",
          sound: "default",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const success = await sendNotification(message, `user_register_${userId}`);

    // Mark as notified to prevent duplicates on retry
    await snapshot.ref.update({
      agentNotifiedOnRegister: true,
      agentNotifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (!success) {
      await cleanInvalidToken("agents", agentId);
    }
  }
);

// ============================================================
// PAYMENT INITIATED - Notify Agent
// ============================================================
export const notifyAgentOnPaymentInitiated = onDocumentCreated(
  "registrationPayments/{paymentId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("No payment snapshot");
      return;
    }

    const payment = snapshot.data();
    const paymentId = event.params.paymentId;
    const userId = payment?.userId;

    if (!userId) {
      logger.warn("Payment missing userId", { paymentId });
      return;
    }

    if (payment?.agentNotified === true) {
      logger.info("Agent already notified for payment", { paymentId });
      return;
    }

    const userSnap = await admin.firestore().collection("users").doc(userId).get();
    if (!userSnap.exists) {
      logger.warn("User not found for payment", { userId, paymentId });
      return;
    }

    const user = userSnap.data();
    const agentId = user?.agentId;

    if (!agentId) {
      logger.info("User has no agent assigned", { userId, paymentId });
      return;
    }

    const agentSnap = await admin.firestore().collection("agents").doc(agentId).get();
    if (!agentSnap.exists) {
      logger.warn("Agent not found", { agentId, userId, paymentId });
      return;
    }

    const agent = agentSnap.data();
    const agentFcmToken = agent?.fcmToken;

    if (!agentFcmToken) {
      logger.warn("Agent has no FCM token", { agentId });
      return;
    }

    const message: admin.messaging.Message = {
      token: agentFcmToken,
      notification: {
        title: "Payment Initiated",
        body: `${user?.fullName ?? "A user"} initiated a payment of ${payment?.amount ?? "N/A"} ${payment?.currency ?? "INR"}`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        screen: "view_payment_detail",
        paymentId: paymentId,
        userId: userId,
        agentId: agentId,
        amount: String(payment?.amount ?? ""),
        currency: payment?.currency ?? "INR",
        type: "PAYMENT_INITIATED",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "fcm_channel",
          priority: "high",
          sound: "default",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const success = await sendNotification(message, `payment_initiated_${paymentId}`);

    if (success) {
      await snapshot.ref.update({
        agentNotified: true,
        agentNotifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);

// ============================================================
// WISHLIST CREATED - Notify All Parties
// ============================================================
export const notifyOnWishlistCreated = onDocumentCreated(
  "wishlist/{wishlistId}",
  async (event) => {
    const wishlist = event.data?.data();
    if (!wishlist) return;

    const wishlistId = event.params.wishlistId;
    const senderId = wishlist.senderId;
    const receiverId = wishlist.receiverId;
    const senderAgentId = wishlist.senderAgent;
    const receiverAgentId = wishlist.receiverAgent;

    const [senderSnap, receiverSnap, senderAgentSnap, receiverAgentSnap] = await Promise.all([
      admin.firestore().collection("users").doc(senderId).get(),
      admin.firestore().collection("users").doc(receiverId).get(),
      senderAgentId ? admin.firestore().collection("agents").doc(senderAgentId).get() : null,
      receiverAgentId ? admin.firestore().collection("agents").doc(receiverAgentId).get() : null,
    ]);

    const senderName = senderSnap.data()?.fullName ?? "A user";
    const receiverName = receiverSnap.data()?.fullName ?? "A user";

    const notifications: Promise<void>[] = [];

    // Notify sender user - confirmation
    if (senderSnap.exists && senderSnap.data()?.fcmToken) {
      const msg: admin.messaging.Message = {
        token: senderSnap.data()!.fcmToken,
        notification: {
          title: "Interest Sent",
          body: `Your interest request to ${receiverName} was sent successfully`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "user_wishlist",
          wishlistId: wishlistId,
          senderId: senderId,
          receiverId: receiverId,
          type: "WISHLIST_SENT",
        },
        android: {
          priority: "high",
          notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      notifications.push(sendNotification(msg, `wishlist_sender_${senderId}`).then(() => {}));
    }

    // Notify receiver user - new request
    if (receiverSnap.exists && receiverSnap.data()?.fcmToken) {
      const msg: admin.messaging.Message = {
        token: receiverSnap.data()!.fcmToken,
        notification: {
          title: "New Interest Request",
          body: `${senderName} has shown interest in your profile`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "user_wishlist",
          wishlistId: wishlistId,
          senderId: senderId,
          receiverId: receiverId,
          type: "WISHLIST_RECEIVED",
        },
        android: {
          priority: "high",
          notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      notifications.push(sendNotification(msg, `wishlist_receiver_${receiverId}`).then(() => {}));
    }

    // Notify sender's agent
    if (senderAgentSnap?.exists && senderAgentSnap.data()?.fcmToken) {
      const msg: admin.messaging.Message = {
        token: senderAgentSnap.data()!.fcmToken,
        notification: {
          title: "Client Sent Interest",
          body: `${senderName} sent an interest request to ${receiverName}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "agent_wishlist",
          wishlistId: wishlistId,
          senderId: senderId,
          receiverId: receiverId,
          senderAgentId: senderAgentId || "",
          receiverAgentId: receiverAgentId || "",
          type: "AGENT_WISHLIST_CREATED",
        },
        android: {
          priority: "high",
          notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      notifications.push(sendNotification(msg, `wishlist_sender_agent_${senderAgentId}`).then(() => {}));
    }

    // Notify receiver's agent (only if different from sender's agent)
    if (receiverAgentSnap?.exists && receiverAgentSnap!.data()?.fcmToken && receiverAgentId !== senderAgentId) {
      const msg: admin.messaging.Message = {
        token: receiverAgentSnap!.data()!.fcmToken,
        notification: {
          title: "Client Received Interest",
          body: `${receiverName} received an interest request from ${senderName}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "agent_wishlist",
          wishlistId: wishlistId,
          senderId: senderId,
          receiverId: receiverId,
          senderAgentId: senderAgentId || "",
          receiverAgentId: receiverAgentId,
          type: "AGENT_WISHLIST_CREATED",
        },
        android: {
          priority: "high",
          notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      notifications.push(sendNotification(msg, `wishlist_receiver_agent_${receiverAgentId}`).then(() => {}));
    }

    await Promise.all(notifications);
  }
);

// ============================================================
// WISHLIST STATUS UPDATED - Notify All Parties
// ============================================================
export const notifyOnWishlistStatusUpdated = onDocumentUpdated(
  "wishlist/{wishlistId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    if (before.status === after.status) return;

    const wishlistId = event.params.wishlistId;
    const newStatus = after.status;
    const updatedBy = after.updatedBy;

    const senderId = after.senderId;
    const receiverId = after.receiverId;
    const senderAgentId = after.senderAgent;
    const receiverAgentId = after.receiverAgent;

    const [senderSnap, receiverSnap, senderAgentSnap, receiverAgentSnap] = await Promise.all([
      admin.firestore().collection("users").doc(senderId).get(),
      admin.firestore().collection("users").doc(receiverId).get(),
      senderAgentId ? admin.firestore().collection("agents").doc(senderAgentId).get() : null,
      receiverAgentId ? admin.firestore().collection("agents").doc(receiverAgentId).get() : null,
    ]);

    const senderName = senderSnap.data()?.fullName ?? "A user";
    const receiverName = receiverSnap.data()?.fullName ?? "A user";

    // Status display mapping
    const statusMessages: { [key: string]: { title: string; body: string } } = {
      pending: { title: "Interest Pending", body: "Interest request is pending response" },
      contacted: { title: "Agent Contacted", body: "Agent has contacted regarding the interest" },
      interested: { title: "Interest Accepted", body: "The interest request has been accepted" },
      notInterested: { title: "Interest Declined", body: "The interest request has been declined" },
      closed: { title: "Request Closed", body: "The interest request has been closed" },
    };

    const statusInfo = statusMessages[newStatus] || { title: "Status Updated", body: `Status changed to ${newStatus}` };

    const notifications: Promise<void>[] = [];

    // Notify sender user (if not the one who updated)
    if (senderSnap.exists && senderSnap.data()?.fcmToken && updatedBy !== senderId) {
      const msg: admin.messaging.Message = {
        token: senderSnap.data()!.fcmToken,
        notification: {
          title: statusInfo.title,
          body: `Your interest to ${receiverName}: ${statusInfo.body}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "user_wishlist",
          wishlistId: wishlistId,
          senderId: senderId,
          receiverId: receiverId,
          status: newStatus,
          type: "WISHLIST_STATUS_UPDATED",
        },
        android: {
          priority: "high",
          notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      notifications.push(sendNotification(msg, `wishlist_update_sender_${senderId}`).then(() => {}));
    }

    // Notify receiver user (if not the one who updated)
    if (receiverSnap.exists && receiverSnap.data()?.fcmToken && updatedBy !== receiverId) {
      const msg: admin.messaging.Message = {
        token: receiverSnap.data()!.fcmToken,
        notification: {
          title: statusInfo.title,
          body: `Interest from ${senderName}: ${statusInfo.body}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "user_wishlist",
          wishlistId: wishlistId,
          senderId: senderId,
          receiverId: receiverId,
          status: newStatus,
          type: "WISHLIST_STATUS_UPDATED",
        },
        android: {
          priority: "high",
          notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      notifications.push(sendNotification(msg, `wishlist_update_receiver_${receiverId}`).then(() => {}));
    }

    // Notify sender's agent (if not the one who updated)
    if (senderAgentSnap?.exists && senderAgentSnap.data()?.fcmToken && updatedBy !== senderAgentId) {
      const msg: admin.messaging.Message = {
        token: senderAgentSnap.data()!.fcmToken,
        notification: {
          title: "Wishlist Status Changed",
          body: `${senderName}'s interest to ${receiverName}: ${statusInfo.body}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "agent_wishlist",
          wishlistId: wishlistId,
          senderId: senderId,
          receiverId: receiverId,
          senderAgentId: senderAgentId || "",
          receiverAgentId: receiverAgentId || "",
          status: newStatus,
          type: "AGENT_WISHLIST_STATUS_UPDATED",
        },
        android: {
          priority: "high",
          notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      notifications.push(sendNotification(msg, `wishlist_update_sender_agent_${senderAgentId}`).then(() => {}));
    }

    // Notify receiver's agent (if not the one who updated and different from sender's agent)
    if (receiverAgentSnap?.exists && receiverAgentSnap!.data()?.fcmToken && updatedBy !== receiverAgentId && receiverAgentId !== senderAgentId) {
      const msg: admin.messaging.Message = {
        token: receiverAgentSnap!.data()!.fcmToken,
        notification: {
          title: "Wishlist Status Changed",
          body: `${receiverName}'s incoming interest from ${senderName}: ${statusInfo.body}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "agent_wishlist",
          wishlistId: wishlistId,
          senderId: senderId,
          receiverId: receiverId,
          senderAgentId: senderAgentId || "",
          receiverAgentId: receiverAgentId,
          status: newStatus,
          type: "AGENT_WISHLIST_STATUS_UPDATED",
        },
        android: {
          priority: "high",
          notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      notifications.push(sendNotification(msg, `wishlist_update_receiver_agent_${receiverAgentId}`).then(() => {}));
    }

    await Promise.all(notifications);
  }
);

// ============================================================
// USER PROFILE COMPLETED - Notify Agent
// ============================================================
export const notifyAgentOnUserProfileComplete = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    // Only notify if profile was just completed (isProfileCreated changed from false to true)
    if (before.isProfileCreated === after.isProfileCreated) return;
    if (!after.isProfileCreated) return;

    // Don't notify if already notified for profile completion
    if (after.agentNotifiedOnProfileComplete === true) return;

    const userId = event.params.userId;
    const agentId = after.agentId;

    if (!agentId) return;

    const agentSnap = await admin.firestore().collection("agents").doc(agentId).get();
    if (!agentSnap.exists) return;

    const agent = agentSnap.data();
    const agentFcmToken = agent?.fcmToken;

    if (!agentFcmToken) return;

    const message: admin.messaging.Message = {
      token: agentFcmToken,
      notification: {
        title: "Profile Completed",
        body: `${after.fullName ?? "A user"} has completed their matrimony profile`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        screen: "view_user",
        userId: userId,
        agentId: agentId,
        type: "PROFILE_COMPLETED",
      },
      android: {
        priority: "high",
        notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const success = await sendNotification(message, `profile_completed_${userId}`);

    // Mark as notified to prevent duplicates
    if (success) {
      await event.data?.after.ref.update({
        agentNotifiedOnProfileComplete: true,
        agentNotifiedOnProfileCompleteAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);

// ============================================================
// SUPPORT TICKET CREATED - Notify Agent
// ============================================================
export const notifyAgentOnSupportTicketCreated = onDocumentCreated(
  "support_tickets/{ticketId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const ticket = snapshot.data();
    const ticketId = event.params.ticketId;
    const userId = ticket?.userId;

    if (!userId) return;

    const userSnap = await admin.firestore().collection("users").doc(userId).get();
    if (!userSnap.exists) return;

    const user = userSnap.data();
    const agentId = user?.agentId;

    if (!agentId) return;

    const agentSnap = await admin.firestore().collection("agents").doc(agentId).get();
    if (!agentSnap.exists) return;

    const agent = agentSnap.data();
    const agentFcmToken = agent?.fcmToken;

    if (!agentFcmToken) return;

    const message: admin.messaging.Message = {
      token: agentFcmToken,
      notification: {
        title: "New Support Ticket",
        body: `${user?.fullName ?? "A user"} raised a support ticket: ${ticket?.subject ?? "No subject"}`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        screen: "agent_support",
        ticketId: ticketId,
        userId: userId,
        agentId: agentId,
        type: "SUPPORT_TICKET_CREATED",
      },
      android: {
        priority: "high",
        notification: { channelId: "fcm_channel", priority: "high", sound: "default", clickAction: "FLUTTER_NOTIFICATION_CLICK" },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    await sendNotification(message, `support_ticket_created_${ticketId}`);
  }
);

 
 


export const notifyUserOnProfileSuggestion = onDocumentWritten(
  "suggested_profiles/{userId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    
    // If document was deleted, do nothing
    if (!after) return;

    const userId = event.params.userId;
    const beforeIds: string[] = before?.ids || [];
    const afterIds: string[] = after.ids || [];

    // Detect newly added profile IDs in the suggested list
    const newlyAddedIds = afterIds.filter(id => !beforeIds.includes(id));
    if (newlyAddedIds.length === 0) return;

    // Process notifications for each newly suggested profile
    for (const suggestedUserId of newlyAddedIds) {
      const [userSnap, suggestedUserSnap] = await Promise.all([
        admin.firestore().collection("users").doc(userId).get(),
        admin.firestore().collection("users").doc(suggestedUserId).get(),
      ]);

      if (!userSnap.exists || !userSnap.data()?.fcmToken) {
        logger.warn("User not found or has no FCM token", { userId });
        continue;
      }

      const suggestedUserName = suggestedUserSnap.data()?.fullName ?? "a potential match";
      const userFcmToken = userSnap.data()!.fcmToken;

      const message: admin.messaging.Message = {
        token: userFcmToken,
        notification: {
          title: "New Profile Suggestion",
          body: `Your agent has suggested a new profile: ${suggestedUserName}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "view_user",
          userId: suggestedUserId,
          type: "PROFILE_SUGGESTION",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "fcm_channel",
            priority: "high",
            sound: "default",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      await sendNotification(message, `profile_suggestion_${userId}_${suggestedUserId}`);
    }
  }
);



// ============================================================
// MSG91 OTP AUTHENTICATION
// ============================================================

const MSG91_AUTH_KEY = "570093AlEWh3hjRs6ab21590P1";
const MSG91_TEMPLATE_ID = "6aa3ce6541f885b75c024db3";

/**
 * Sends OTP via MSG91
 */
export const sendMSG91OTP = onCall(async (request) => {
  const phoneNumber = request.data.phoneNumber;
  if (!phoneNumber) {
    throw new HttpsError("invalid-argument", "Phone number is required.");
  }

  // 🧪 Play Console Test Bypass for Male (9988998899) and Female (8877887788)
  const cleanPhone = String(phoneNumber).replace(/\D/g, "");
  if (cleanPhone.endsWith("9988998899") || cleanPhone.endsWith("8877887788")) {
    return { success: true, message: "OTP sent successfully (Test Bypass)" };
  }

  try {
    const response = await axios.get("https://control.msg91.com/api/v5/otp", {
      params: {
        template_id: MSG91_TEMPLATE_ID,
        mobile: phoneNumber,
        authkey: MSG91_AUTH_KEY,
      },
      validateStatus: () => true,
    });

    if (response.data.type === "success") {
      return { success: true, message: "OTP sent successfully" };
    } else {
      logger.error("MSG91 Send OTP Error", response.data);
      return { success: false, message: response.data.message || "Failed to send OTP" };
    }
  } catch (error) {
    logger.error("MSG91 API Connection Error", error);
    throw new HttpsError("internal", "Error connecting to OTP service");
  }
});

/**
 * Verifies OTP via MSG91 and returns Firebase Custom Token if user exists
 */
export const verifyMSG91OTP = onCall(async (request) => {
  const { phoneNumber, otp } = request.data;
  if (!phoneNumber || !otp) {
    throw new HttpsError("invalid-argument", "Phone number and OTP are required.");
  }

  const cleanPhone = String(phoneNumber).replace(/\D/g, "");
  const isMaleBypass = cleanPhone.endsWith("9988998899");
  const isFemaleBypass = cleanPhone.endsWith("8877887788");

  if (isMaleBypass || isFemaleBypass) {
    const expectedOtp = isMaleBypass ? "1234" : "4567";

    if (String(otp).trim() === expectedOtp) {
      const usersRef = admin.firestore().collection("users");
      let querySnapshot = await usersRef.where("phone", "==", phoneNumber).limit(1).get();

      if (querySnapshot.empty) {
        const last10Digits = cleanPhone.slice(-10);
        querySnapshot = await usersRef.where("phone", "==", last10Digits).limit(1).get();
      }

      if (querySnapshot.empty) {
        return { success: true, verified: true, registered: false, message: "Test number verified" };
      }

      const userDoc = querySnapshot.docs[0];
      const customToken = await admin.auth().createCustomToken(userDoc.id);

      return {
        success: true,
        verified: true,
        registered: true,
        customToken: customToken,
      };
    } else {
      return {
        success: true,
        verified: false,
        message: `Invalid OTP. Please enter ${expectedOtp} for test number.`,
      };
    }
  }

  try {
    const response = await axios.get("https://control.msg91.com/api/v5/otp/verify", {
      params: {
        mobile: phoneNumber,
        otp: otp,
        authkey: MSG91_AUTH_KEY,
      },
      validateStatus: () => true,
    });

    // MSG91 returns success type for verified OTP, or error message containing "already_verified" if retry occurs
    const isVerifiedOrAlreadyDone =
      response.data.type === "success" ||
      (response.data.message && response.data.message.toLowerCase().includes("already_verified"));

    if (isVerifiedOrAlreadyDone) {
      // Find user by phone in Firestore (handle both with and without 91 prefix)
      const usersRef = admin.firestore().collection("users");
      let querySnapshot = await usersRef.where("phone", "==", phoneNumber).limit(1).get();

      if (querySnapshot.empty) {
        const last10Digits = phoneNumber.slice(-10);
        querySnapshot = await usersRef.where("phone", "==", last10Digits).limit(1).get();
      }

      if (querySnapshot.empty) {
        return { success: true, verified: true, registered: false };
      }

      const userDoc = querySnapshot.docs[0];
      const customToken = await admin.auth().createCustomToken(userDoc.id);

      return {
        success: true,
        verified: true,
        registered: true,
        customToken: customToken,
      };
    } else {
      logger.warn("MSG91 Verify OTP Failure", response.data);
      return { success: true, verified: false, message: response.data.message || "Invalid OTP" };
    }
  } catch (error: any) {
    logger.error("MSG91 Verify API Connection Error", error);
    throw new HttpsError("internal", error.message || "Error connecting to verification service");
  }
});

export { transliterate } from "./transliterate";



// ============================================================
// Additional triggers can be added here following the same pattern
// ============================================================


// send notification on new profile suggestion (when agent adds a profile to suggested_profiles collection for a user)
// 1.
// Male Test Account:
// ◦
// Phone: 9988998899 (ya +919988998899)
// ◦
// OTP: 1234
// 2.
// Female Test Account:
// ◦
// Phone: 8877887788 (ya +918877887788)
// ◦
// OTP: 4567