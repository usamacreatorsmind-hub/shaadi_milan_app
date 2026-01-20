import { setGlobalOptions } from "firebase-functions/v2";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

setGlobalOptions({ maxInstances: 10 });

admin.initializeApp();

// 🔔 Trigger when a new user is created
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

    // Check for missing or empty agentId
    if (!agentId || agentId.trim() === "") {
      logger.info("User registered without agent ID", { userId });
      return;
    }

    // 🔍 Fetch agent document
    const agentSnap = await admin
      .firestore()
      .collection("agents")
      .doc(agentId)
      .get();

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

    const message = {
      token: agentFcmToken,
      notification: {
        title: "👤 New User Registered",
        body: `${user.fullName ?? "A new user"} registered with your Agent ID`,
      },
      data: {
        type: "NEW_USER",
        userId,
        agentId,
      },
    };

    try {      await admin.messaging().send(message);
      logger.info("Notification sent to agent", { userId, agentId });
    } catch (error: unknown) {
      const fcmError = error as { code?: string };
      // Handle invalid/expired token
      if (
        fcmError.code === "messaging/invalid-registration-token" ||
        fcmError.code === "messaging/registration-token-not-registered"
      ) {
        logger.warn("Agent FCM token is invalid, removing from Firestore", {
          agentId,
        });
        // Remove invalid token from agent document
        await admin.firestore().collection("agents").doc(agentId).update({
          fcmToken: admin.firestore.FieldValue.delete(),
          fcmTokenUpdatedAt: admin.firestore.FieldValue.delete(),
        });
      } else {
        logger.error("Failed to send notification", { error, userId, agentId });
      }
    }
  }
);
