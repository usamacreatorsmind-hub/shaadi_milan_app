import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import axios from "axios";

const db = admin.firestore();

/**
 * Callable Cloud Function for transliteration
 */
export const transliterate = onCall(async (request) => {
  try {
    const text = request.data.text?.trim();
    const target = request.data.targetLanguage || "hi"; // 'hi' or 'en'

    if (!text) {
      throw new HttpsError("invalid-argument", "Text is required.");
    }

    // Cache Key includes target language
    const cacheKey = `${target}_${text.toLowerCase()}`;

    // Check Firestore cache
    const cacheRef = db.collection("transliteration_cache").doc(cacheKey);
    const cacheDoc = await cacheRef.get();

    if (cacheDoc.exists) {
      return {
        result: cacheDoc.data()?.result,
        cached: true,
      };
    }

    let result: string | undefined;

    if (target === "hi") {
      // Strategy 1: English -> Hindi (Phonetic Transliteration)
      const url = "https://inputtools.google.com/request";
      const response = await axios.get(url, {
        params: {
          itc: "hi-t-i0-und",
          num: 1,
          cp: 0,
          cs: 1,
          ie: "utf-8",
          oe: "utf-8",
          app: "demopage",
          text: text,
        },
      });

      if (
        response.data[0] === "SUCCESS" &&
        response.data[1] &&
        response.data[1][0] &&
        response.data[1][0][1]
      ) {
        result = response.data[1][0][1][0];
      }
    } else {
      // Strategy 2: Hindi -> English (Romanization)
      const url = "https://translate.googleapis.com/translate_a/single";
      const response = await axios.get(url, {
        params: {
          client: "gtx",
          sl: "hi",
          tl: "en",
          dt: "rm",
          q: text,
        },
      });

      // Response format for dt=rm: [[[null,null,null,"romanized"]],null,"hi",...]
      if (
        response.data &&
        response.data[0] &&
        response.data[0][0] &&
        response.data[0][0][3]
      ) {
        result = response.data[0][0][3];
      }
    }

    if (!result) {
      throw new HttpsError(
        "internal",
        `Transliteration failed for target: ${target}`
      );
    }

    // Save in Firestore cache
    await cacheRef.set({
      input: text,
      result: result,
      target: target,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      result: result,
      cached: false,
    };
  } catch (e: any) {
    console.error("Transliteration Error:", e);
    throw new HttpsError("internal", e.message ?? "Unknown Error");
  }
});
