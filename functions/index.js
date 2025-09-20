//const {onValueCreated} = require("firebase-functions/v2/database");
//const admin = require("firebase-admin");
//const geolib = require("geolib");
//
//admin.initializeApp();
//
//// This is the new syntax for the trigger
//exports.notifyRidersOnNewOrder = onValueCreated("/orders/{orderId}", async (event) => {
//  // The snapshot of the data is now inside event.data
//  const snapshot = event.data;
//  const orderData = snapshot.val();
//
//  // Only proceed if the order status is 'pending'
//  if (orderData.status !== "pending") {
//    console.log("Order is not pending, no notification sent.");
//    return null;
//  }
//
//  const restaurantLocation = orderData.restaurantLocation;
//  console.log(`New order for restaurant at:`, restaurantLocation);
//
//  // 1. Get all riders from the database
//  const ridersSnapshot = await admin.database().ref("/riders").once("value");
//  const riders = ridersSnapshot.val();
//  const tokensToSend = [];
//
//  // 2. Find nearby, available riders
//  for (const riderId in riders) {
//    // A quick check to make sure we're not iterating over prototype properties
//    if (Object.prototype.hasOwnProperty.call(riders, riderId)) {
//      const rider = riders[riderId];
//      if (rider.isAvailable && rider.location && rider.fcmToken) {
//        const distance = geolib.getDistance(
//            {
//              latitude: restaurantLocation.latitude,
//              longitude: restaurantLocation.longitude,
//            },
//            {
//              latitude: rider.location.latitude,
//              longitude: rider.location.longitude,
//            },
//        );
//
//        // Notify riders within a 5km radius (5000 meters)
//        if (distance <= 5000) {
//          console.log(`Found nearby rider: ${riderId}, dist: ${distance}m`);
//          tokensToSend.push(rider.fcmToken);
//        }
//      }
//    }
//  }
//
//  if (tokensToSend.length === 0) {
//    console.log("No nearby riders found to notify.");
//    return null;
//  }
//
//  // 3. Create the notification message
//  const payload = {
//    notification: {
//      title: "New Ride Request! 🛵",
//      body: `A new order is available from ${orderData.restaurantName || "a restaurant"}.`,
//      sound: "default",
//    },
//    data: {
//      orderId: event.params.orderId,
//    },
//  };
//
//  // 4. Send the notification to all found rider tokens
//  console.log(`Sending notification to ${tokensToSend.length} riders.`);
//  return admin.messaging().sendToDevice(tokensToSend, payload);
//});
const {onValueCreated} = require("firebase-functions/v2/database");
const admin = require("firebase-admin");
const geolib = require("geolib");

// --- THIS IS THE ONLY CHANGE ---
admin.initializeApp({
  databaseURL: "https://arun-bc25d-default-rtdb.firebaseio.com",
});
// --- END OF CHANGE ---

exports.notifyRidersOnNewOrder = onValueCreated("/orders/{orderId}", async (event) => {
  console.log("--- Function Execution Started ---");

  const snapshot = event.data;
  const orderData = snapshot.val();

  if (!orderData) {
    console.log("Order data is null. Exiting.");
    return null;
  }
  console.log("Received order data:", JSON.stringify(orderData, null, 2));


  if (orderData.status !== "pending") {
    console.log(`Order status is '${orderData.status}', not 'pending'. Exiting.`);
    return null;
  }

  const restaurantLocation = orderData.restaurantLocation;
  if (!restaurantLocation || !restaurantLocation.latitude || !restaurantLocation.longitude) {
    console.error("Error: Restaurant location is missing or malformed in the order data.");
    return null;
  }
  console.log(`Restaurant Location: Lat ${restaurantLocation.latitude}, Lng ${restaurantLocation.longitude}`);


  const ridersSnapshot = await admin.database().ref("/riders").once("value");
  const riders = ridersSnapshot.val();
  if (!riders) {
    console.log("No riders found in the database. Exiting.");
    return null;
  }
  console.log(`Found ${Object.keys(riders).length} total riders in the database.`);

  const tokensToSend = [];

  for (const riderId in riders) {
    if (Object.prototype.hasOwnProperty.call(riders, riderId)) {
      const rider = riders[riderId];
      console.log(`\nChecking Rider ID: ${riderId}`);

      if (!rider.isAvailable) {
        console.log("-> Rider is not available.");
        continue;
      }
      if (!rider.location || !rider.location.latitude || !rider.location.longitude) {
        console.log("-> Rider location is missing or malformed.");
        continue;
      }
      if (!rider.fcmToken) {
        console.log("-> Rider fcmToken is missing.");
        continue;
      }

      console.log(`-> Rider is available with token and location.`);
      const distance = geolib.getDistance(
          restaurantLocation,
          rider.location,
      );
      console.log(`-> Calculated distance to restaurant: ${distance} meters.`);

      if (distance <= 5000) {
        console.log("--> SUCCESS: Rider is within 5km range. Adding token to list.");
        tokensToSend.push(rider.fcmToken);
      } else {
        console.log("--> Rider is too far away.");
      }
    }
  }

  if (tokensToSend.length === 0) {
    console.log("\nNo nearby and available riders found to notify. Exiting.");
    return null;
  }

  console.log(`\nPreparing to send notification to ${tokensToSend.length} tokens:`, tokensToSend);
  const payload = {
    notification: {
      title: "New Ride Request! 🛵",
      body: `A new order is available from ${orderData.restaurantName || "a restaurant"}.`,
      sound: "default",
    },
    data: {
      orderId: event.params.orderId,
    },
  };

  try {
    const response = await admin.messaging().sendToDevice(tokensToSend, payload);
    console.log("Successfully sent message:", response);
    console.log("--- Function Execution Finished ---");
    return response;
  } catch (error) {
    console.error("Error sending notification:", error);
    console.log("--- Function Execution Finished with ERROR ---");
    return null;
  }
});