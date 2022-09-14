import 'dart:async';
import 'dart:convert';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cryptotaxi/controller/SC_controller.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/driver_controller.dart';
import 'package:cryptotaxi/controller/navigation_controller.dart';
import 'package:cryptotaxi/controller/ride_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/model/Ride.dart';
import 'package:cryptotaxi/model/User.dart';
import 'package:cryptotaxi/view/driverRideScreen.dart';
import 'package:etherscan_api/etherscan_api.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart'as message ;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:one_context/one_context.dart';
import 'package:web3dart/web3dart.dart';

import '../model/driver.dart';
import 'driverRide_controller.dart';
import 'wallet_controller.dart';

class NotificationController extends GetxController {
  var clientrequestTimer = 60.obs;
  late StreamSubscription subscription;
  late String fcmToken;
  message.FirebaseMessaging messaging = message.FirebaseMessaging.instance;
  static NotificationController controller = Get.find();
  late String tx;
  bool clientPaid = false;
  RxInt timeOut = 40.obs;
  bool dialogOpen = false;
  bool dialogOpen1 = false;
  late Timer newTimer;
  late Timer cancelTimer;
  late Timer requestTimer;
  RxInt cancelTimeOut = 50.obs;
  RxInt requestTimeOut = 50.obs;
  final assetsAudioPlayer = AssetsAudioPlayer();
  var loading= false.obs;
  Future<bool> sendnotification(String token) async {
    print("THIS IS THE SENT DURATION");
    String constructFCMPayload() {
      return jsonEncode({
        'to': token,
        'data': {
          'via': 'FlutterFire Cloud Messaging!!!',
          'requestid': RideController.controller.idRide,
          'clientid': AuthController.controller.auth!.currentUser!.uid,
          'name': AuthController.controller.appUser!.value.fullname,
          'current': NavigationController.controller.currentAddress.value,
          'to': NavigationController.controller.dropOffAddress.value,
          'phone': AuthController.controller.appUser!.value.phone,
          'rating': AuthController.controller.appUser!.value.rating,
          'pickuplat': NavigationController.controller.currentLatitude.value,
          'pickuplng': NavigationController.controller.currentLongitude.value,
          'dropofflat': NavigationController.controller.dropOffLatitude.value,
          'dropofflng': NavigationController.controller.dropOffLongitude.value,
          'price': NavigationController.controller.cost.value,
          'duration': NavigationController.controller.directionDetails.durationValue,
          'dur':NavigationController.controller.directionDetails.durationText,
          'distance': NavigationController.controller.directionDetails.distanceText,
          'totalRides': AuthController.controller.appUser!.value.totalRides
        },
        'notification': {
          'title': 'New Ride Requetst!',
          'body': 'To Mazouna From sidi bel abbes!',
        },
      });
    }

    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              "key=AAAAtzk8kF0:APA91bFCemvYPv5e7XuYAhN5YpX-PFGOtugh47iJaJK93XhfOgP5UZd63o6kiBt1_CCo9pJ8zCDHIc88uNfEWekwSr0mGizj8US9u9J6U6qG6VszfGtn5qp1FhuJJNN5PuHcduqZzCJP"
        },
        body: constructFCMPayload(),
      );
      print(response.body);
      print('FCM request for device sent!');

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> backbutton() async {
    Get.rawSnackbar(
        message: "You must respond to the ride request ",
        borderRadius: 20,
        margin: EdgeInsets.all(5),
        backgroundColor: Colors.red);
    return false;
  }
  Future<bool> backbutton1() async {
    Get.rawSnackbar(
        message: "You must wait the payment ",
        borderRadius: 20,
        margin: EdgeInsets.all(5),
        backgroundColor: Colors.red);
    return false;
  }
  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    fcmToken = (await message.FirebaseMessaging.instance.getToken())!;
    print(" TOKEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE N$fcmToken");
    message.FirebaseMessaging.instance.onTokenRefresh.listen((fcmtoken) {
      // TODO: If necessary send token to application server.
      fcmToken = fcmtoken;
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
    message.NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    message.FirebaseMessaging.onMessage.listen((message.RemoteMessage message)async {
      await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("offline");

      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      final Map<String, dynamic> data = message.data;
      print(data);
      assetsAudioPlayer.open(Audio("assets/sounds/notification.wav"),
          loopMode: LoopMode.single);
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        loading.value=false;
        cancelTimeOut.value=50;
        requestTimeOut.value=60;
        requestTimer = Timer.periodic(Duration(seconds: 1), (timer)async {
          if(requestTimeOut.value==0){
            await FirebaseDatabase
                .instance
                .ref()
                .child("users")
                .child(AuthController.controller.auth!.currentUser!.uid)
                .child("available").set("available");
            Get.back(closeOverlays: true);
          } else{
            requestTimeOut.value--;
          }
        });
       Get.bottomSheet(
           WillPopScope(
             onWillPop:backbutton,
             child: Obx(()=>Container(
               padding: EdgeInsets.all(20),
               decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.only(
                       topLeft: Radius.circular(30),
                       topRight: Radius.circular(30))),
               // height: OneContext().mediaQuery.size.height * 0.7,
               // width: OneContext().mediaQuery.size.height * 0.5,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   SizedBox(
                     height: 10,
                   ),
                   Text(
                     "New Ride request",
                     style: TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                         color: textcolor
                       // color: Colors.black
                     ),
                   ),
                   SizedBox(
                     height: 15,
                   ),
                   Row(
                     children: [
                       Text(
                         "Name : ",
                         style: TextStyle(
                             fontWeight: FontWeight.bold, color: textcolor),maxLines: 1,
                       ),
                       SizedBox(
                         width: 10,
                       ),
                       AutoSizeText(
                         "${data["name"]}",maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       )
                     ],
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Row(
                     children: [
                       Text(
                         "From : ",
                         style: TextStyle(
                             fontWeight: FontWeight.bold, color: textcolor),
                       ),
                       Expanded(
                         child: SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: Text(
                             "${data["current"]}",
                           ),
                         ),
                       ),
                       SizedBox(
                         width: 5,
                       )
                     ],
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Row(
                     mainAxisSize: MainAxisSize.max,
                     children: [
                       Text(
                         "Destination : ",
                         style: TextStyle(
                             fontWeight: FontWeight.bold, color: textcolor),
                       ),
                       SizedBox(
                         width: 5,
                       ),
                       Expanded(
                         child: SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: Text(
                             "${data["to"]}",
                           ),
                         ),
                       )
                     ],
                   ),
                   SizedBox(
                     height: 10,
                   ),Row(
                     mainAxisSize: MainAxisSize.max,
                     children: [
                       Text(
                         "Distance : ",
                         style: TextStyle(
                             fontWeight: FontWeight.bold, color: textcolor),
                       ),
                       SizedBox(
                         width: 5,
                       ),
                       Expanded(
                         child: SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: Text(
                             "${data["distance"]}",
                           ),
                         ),
                       )
                     ],
                   ),
                   SizedBox(
                     height: 10,
                   ),Row(
                     mainAxisSize: MainAxisSize.max,
                     children: [
                       Text(
                         "Duration : ",
                         style: TextStyle(
                             fontWeight: FontWeight.bold, color: textcolor),
                       ),
                       SizedBox(
                         width: 5,
                       ),
                       Expanded(
                         child: SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: Text(
                             "${data["dur"]}",
                           ),
                         ),
                       )
                     ],
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Row(
                     children: [
                       Text(
                         "rating : ",
                         style: TextStyle(
                             fontWeight: FontWeight.bold, color: textcolor),
                       ),
                       SizedBox(
                         width: 10,
                       ),
                       Text(
                         "${double.parse(data["rating"]).toStringAsFixed(2)}",
                         overflow: TextOverflow.ellipsis,
                       ),
                       Icon(
                         Icons.star,
                         color: Colors.orange,
                       ),SizedBox(
                         width: 10,
                       ),Text("/ ${data['totalRides']} total rides")
                     ],
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Row(
                     children: [
                       Text(
                         "Price : ",
                         style: TextStyle(
                             fontWeight: FontWeight.bold, color: textcolor),
                       ),
                       SizedBox(
                         width: 10,
                       ),
                       Text(
                         "${data['price']} DA",
                         style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),
                         overflow: TextOverflow.ellipsis,

                       )
                     ],
                   ),
                   SizedBox(
                     height: 15,
                   ),
                   // Divider(
                   //   thickness: 2,
                   // ),
                   loading.value ? Center(child: CircularProgressIndicator(),): Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       SizedBox(
                         width: OneContext().mediaQuery.size.width * 0.4,
                         child: Center(
                           child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                                 shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(30))),
                             onPressed: () async {
                               loading.value=true;
                               requestTimer.cancel();
                               var price =   data['price'];
                               var request = await  http.get(Uri.parse('https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=DZD'));


                               if (request.statusCode == 200) {
                                 print( request);
                               }
                               assetsAudioPlayer.stop();
                               final response = jsonDecode( request.body);
                               double Ethamout = (double.parse(data['price'].toString()) / double.parse(response['DZD'].toString()))*1000000;
                               var f = (Ethamout/10).truncate();
                               var cost = EtherAmount.fromUnitAndValue(EtherUnit.szabo, Ethamout.truncate());
                               print("RIDE COST IS ${
                                   cost.getInWei

                               }");
                               DriverController.controller.fees=EtherAmount.fromUnitAndValue(EtherUnit.szabo, f);
                               dialogOpen = true;
                               cancelTimer = Timer.periodic( Duration(seconds: 1), (timer) {
                                 if (cancelTimeOut.value==0){
                                   cancelTimeOut.value=50;
                                   cancelTimer.cancel();
                                   subscription.cancel();
                                   Navigator.of(OneContext().context!)
                                       .pop();
                                   if (Get.isBottomSheetOpen!) {
                                     Get.back(closeOverlays: true);
                                   }
                                   Get.rawSnackbar(
                                       message:
                                       "Payment timeout, the trip has been canceled",
                                       borderRadius: 20,
                                       margin: EdgeInsets.all(5),
                                       backgroundColor: Colors.red);
                                 } else{
                                   cancelTimeOut.value--;
                                   print("cancelTimeOut  ${cancelTimeOut.value}");
                                                }
                               });
                               showDialog(
                                   context: OneContext().context!,
                                   useRootNavigator: false,
                                   barrierDismissible: false,
                                   builder: (_) {
                                     return WillPopScope(
                                       onWillPop: backbutton1,
                                       child: AlertDialog(
                                         title: Text("Waiting"),
                                         content:
                                         Text("Waiting for client payment"),
                                       ),
                                     );
                                   }).then((value) {
                                 dialogOpen = false;
                                 cancelTimeOut.value=50;
                                 cancelTimer.cancel();

                               });

                               print("continue");
                               FirebaseDatabase.instance
                                   .ref()
                                   .child("riderequests")
                                   .child(data["requestid"])
                                   .child("status")
                                   .set("accepted");
                               FirebaseDatabase.instance
                                   .ref()
                                   .child("riderequests")
                                   .child(data["requestid"])
                                   .child("driverPaid")
                                   .set("");

                               subscription = FirebaseDatabase.instance
                                   .ref()
                                   .child("riderequests")
                                   .child(data["requestid"])
                                   .child("clientPaid")
                                   .onValue
                                   .listen((event) async {
                                 print("Value changed");
                                 print(event.snapshot.value);
                                 var snapshot = event.snapshot;
                                 if (snapshot.value == false) {
                                   cancelTimer.cancel();
                                   Navigator.of(OneContext().context!).pop();

                                   Get.back(closeOverlays: true);
                                   Get.rawSnackbar(
                                       message: "Client did not pay the cost",
                                       borderRadius: 20,
                                       margin: EdgeInsets.all(5),
                                       backgroundColor: Colors.red);
                                   subscription.cancel();
                                   await FirebaseDatabase.instance
                                       .ref()
                                       .child("riderequests")
                                       .child(data["requestid"])
                                       .child("clientPaid")
                                       .set("");
                                   await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");

                                 } else if (snapshot.value == true) {
                                   cancelTimer.cancel();
                                   Navigator.of(OneContext().context!).pop();

                                   print("GOING TO PAIMENT");
                                   await FirebaseDatabase.instance
                                       .ref()
                                       .child("riderequests")
                                       .child(data["requestid"])
                                       .child("driverAddress")
                                       .set(WalletController
                                       .controller.account.value);
                                   clientPaid = true;
                                   subscription.cancel();
                                   print("dialogOpen  $dialogOpen");
                                   showDialog(
                                       context: OneContext().context!,
                                       useRootNavigator: false,
                                       barrierDismissible: false,
                                       builder: (_) {
                                         dialogOpen1 = true;

                                         return WillPopScope(
                                           onWillPop: backbutton1,
                                           child: Obx(() => AlertDialog(
                                             title: Text("Waiting"),
                                             content: Text(
                                                 "Go to MetaMask App and pay the confirmation fee \n Payment will timeout if u don't pay in ${timeOut.value}"),
                                           )),
                                         );
                                       }).then((value) {
                                     dialogOpen1 = false;
                                   });

                                   try {
                                     timeOut.value=40;
                                     newTimer = Timer.periodic(
                                         Duration(seconds: 1), (timer) async {
                                       if (timeOut.value == 0) {
                                         FirebaseDatabase.instance
                                             .ref()
                                             .child("riderequests")
                                             .child(data["requestid"])
                                             .child("driverPaid")
                                             .set(false);

                                         Get.rawSnackbar(
                                             message:
                                             "Payment timeout, the trip has been canceled",
                                             borderRadius: 20,
                                             margin: EdgeInsets.all(5),
                                             backgroundColor: Colors.red);
                                         timer.cancel();
                                         FirebaseDatabase.instance
                                             .ref()
                                             .child("riderequests")
                                             .child(data["requestid"])
                                             .child("driverPaid")
                                             .set("");
                                         FirebaseDatabase.instance
                                             .ref()
                                             .child("riderequests")
                                             .child(data["requestid"])
                                             .child("status")
                                             .set("searching");
                                         await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");

                                         timeOut.value = 40;
                                         newTimer.cancel();
                                         Navigator.of(OneContext().context!)
                                             .pop();
                                         if (Get.isBottomSheetOpen!) {
                                           Get.back(closeOverlays: true);
                                         }

                                         // to do cancel the ride
                                       } else {
                                         print(timeOut.value);

                                         timeOut.value--;
                                       }
                                     });

                                     await LaunchApp.openApp(
                                         androidPackageName: 'io.metamask',
                                         openStore: false);
                                     WalletController.controller.connector.reconnect();
                                     await Future.delayed(Duration(seconds: 3,milliseconds: 500));

                                     tx = await WalletController.controller
                                         .sendTransaction(
                                         DriverController.controller.fees);
                                   } catch (e) {
                                     print("PAIMENT ERROR");

                                     print(e);
                                     if (dialogOpen) {
                                       print('DIALOG IS OPEN');
                                       Navigator.of(OneContext().context!).pop();
                                     }
                                     if (dialogOpen1) {
                                       print('DIALOG IS OPEN');
                                       Navigator.of(OneContext().context!).pop();
                                     }
                                     FirebaseDatabase.instance
                                         .ref()
                                         .child("riderequests")
                                         .child(data["requestid"])
                                         .child("driverPaid")
                                         .set(false);
                                     FirebaseDatabase.instance
                                         .ref()
                                         .child("riderequests")
                                         .child(data["requestid"])
                                         .child("driverPaid")
                                         .set("");
                                     FirebaseDatabase.instance
                                         .ref()
                                         .child("riderequests")
                                         .child(data["requestid"])
                                         .child("status")
                                         .set("searching");
                                     if (Get.isBottomSheetOpen!) {
                                       print(' GET DIALOG IS OPEN');

                                       Get.back(closeOverlays: true);
                                     }
                                     await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");

                                     newTimer.cancel();
                                     // Get.back(
                                     //     closeOverlays: true);

                                     return;
                                   }

                                   final eth = EtherscanAPI(
                                       apiKey:
                                       'S35NXF866GPA55XUWUH1AH7NTV7ST33QM5',
                                       // Api key
                                       chain: EthChain.rinkeby,
                                       // Network/chain
                                       enableLogs: true // Enable Logging
                                   );
                                   final bal = await eth.getStatus(txhash: tx);
                                   if (bal.message == "OK") {
                                     if (Get.isBottomSheetOpen==false)
                                     {
                                       print('Ride canceled but driver PAID TO RETURN MONEY');
                                       Get.rawSnackbar(
                                           message:
                                           "You paid after the ride is canceled you will be refunded soon",
                                           borderRadius: 20,
                                           margin: EdgeInsets.all(5),
                                           backgroundColor: Colors.red);
                                       String ss="";
                                       try {
                                         ss =   await SC_Controller.controller.writeContract(SC_Controller.controller.refund, [EthereumAddress.fromHex(WalletController.controller.account.value),DriverController.controller.fees.getInWei]);

                                         print(ss);
                                       } catch (error)
                                       {
                                         Get.defaultDialog(title: "CRITICAL ERROR OCCURED",middleText:  "TX: $ss Take screenshot and submit a ticket to admin ! \n After take screenshot restart the application");

                                       }
                                       return;
                                     }
                                     EasyLoading.show(dismissOnTap: false,status: "Starting ride. Please wait");

                                     newTimer.cancel();
                                     FirebaseDatabase.instance
                                         .ref()
                                         .child("riderequests")
                                         .child(data["requestid"])
                                         .child("driverPaid")
                                         .set(true);

                                     Map<String, dynamic> ss = {
                                       'duration': data['duration'],
                                       'dateTime': DateTime.now().toIso8601String(),
                                     };
                                     Navigator.of(OneContext().context!).pop();
                                     AuthController.controller.database
                                         .ref()
                                         .child("users")
                                         .child(AuthController
                                         .controller.auth!.currentUser!.uid)
                                         .child("history")
                                         .child(data['requestid'])
                                         .update(ss);
                                     DriverController
                                         .controller.pickupLatitude.value =
                                         double.parse(
                                             data['pickuplat'].toString());
                                     DriverController
                                         .controller.pickupLongitude.value =
                                         double.parse(
                                             data['pickuplng'].toString());
                                     DriverController
                                         .controller.dropOffLatitude.value =
                                         double.parse(
                                             data['dropofflat'].toString());
                                     DriverController
                                         .controller.dropOffLongitude.value =
                                         double.parse(
                                             data['dropofflng'].toString());
                                     DriverController.controller
                                         .getPlaceDirectoin(
                                         LatLng(
                                             NavigationController.controller
                                                 .currentLatitude.value,
                                             NavigationController.controller
                                                 .currentLongitude.value),
                                         LatLng(
                                             DriverController.controller
                                                 .pickupLatitude.value,
                                             DriverController.controller
                                                 .pickupLongitude.value));
                                     DriverController.controller
                                         .makeDriverOffline();
                                     var s = await FirebaseDatabase.instance
                                         .ref()
                                         .child("users")
                                         .child(data['clientid'])
                                         .get();
                                     // Map<String,dynamic> map = s.value as Map<String,dynamic>;
                                     AppUser client = AppUser.name(
                                         data['clientid'],
                                         s.child("name").value.toString(),
                                         s.child("phone").value.toString(),
                                         double.parse(
                                             s.child("rating").value.toString()),
                                         s.child("birthdate").value.toString(),
                                         s.child("gender").value.toString(),
                                         int.parse(s
                                             .child("totalRides")
                                             .value
                                             .toString()),
                                         s.child("profileImg").value.toString()
                                     );
                                     await FirebaseDatabase.instance
                                         .ref()
                                         .child("users")
                                         .child(AuthController
                                         .controller.auth!.currentUser!.uid)
                                         .child("currentRide")
                                         .set(data['requestid']);
                                     await FirebaseDatabase.instance
                                         .ref()
                                         .child("users")
                                         .child(data['clientid'])
                                         .child("currentRide")
                                         .set(data['requestid']);
                                     await DriverController.controller.prefs
                                         .setString(
                                         "currentRide", data['requestid']);
                                     if(Get.isBottomSheetOpen!){ Get.back(closeOverlays: true);}
                                     Ride r = Ride(
                                         data['requestid'],
                                         client,
                                         AuthController.controller.appUser!.value,
                                         LatLng(
                                             double.parse(
                                                 data['pickuplat'].toString()),
                                             double.parse(
                                                 data['pickuplng'].toString())),
                                         LatLng(
                                             double.parse(
                                                 data['dropofflat'].toString()),
                                             double.parse(
                                                 data['dropofflng'].toString())),
                                         data['createdat'],
                                         double.parse(data['price'].toString()),
                                         data['current'],
                                         data['to']);
                                     DriverController.controller.ride = r;
                                     Position p = await Geolocator.getCurrentPosition(
                                         desiredAccuracy: LocationAccuracy.bestForNavigation);
                                     var details = await NavigationController.obtainPlaceDirectionDetails(
                                         LatLng(p.latitude, p.longitude), DriverController
                                         .controller.ride.pickup!);

                                     await FirebaseDatabase.instance
                                         .ref()
                                         .child("riderequests")
                                         .child(DriverController.controller.ride.id)
                                         .child("driverTime").set(details?.durationValue.toString());
                                     DriverController.controller.updateRemaining(
                                         DriverController
                                             .controller.ride.pickup!);
                                     print("GOING TO DRIVERIDESCREEN");
                                     EasyLoading.dismiss(animation: true);

                                     Get.to(() => DriverRideScreen());
                                   }
                                 }
                               });

                               // acceptRideRequest();
                             },
                             child: SizedBox(
                               width: OneContext().mediaQuery.size.width * 0.4,
                               child: const Center(
                                 child: Text(
                                   "Accept",
                                   textAlign: TextAlign.center,
                                   style: TextStyle(fontWeight: FontWeight.bold),
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ),
                       SizedBox(
                         width: OneContext().mediaQuery.size.width * 0.4,
                         child: Center(
                           child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                                 primary: Colors.red,
                                 shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(30))),
                             onPressed: () async {
                               requestTimer.cancel();
                               FirebaseDatabase.instance
                                   .ref()
                                   .child("riderequests")
                                   .child(data["requestid"])
                                   .child("status")
                                   .set("refused");
                               FirebaseDatabase.instance
                                   .ref()
                                   .child("riderequests")
                                   .child(data["requestid"])
                                   .child("status")
                                   .set("searching");
                               await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");
                               Get.back(closeOverlays: true);
                               // await cancelRequest();
                             },
                             child: SizedBox(
                               width: OneContext().mediaQuery.size.width * 0.4,
                               child: const Center(
                                 child: Text(
                                   "Reject",
                                   textAlign: TextAlign.center,
                                   style: TextStyle(fontWeight: FontWeight.bold),
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ),
                     ],
                   ),
                   SizedBox(
                     height: 20,
                   )
                 ],
               ),
             )),
           ),
           isDismissible: false,
           enableDrag: false).then((value)  {assetsAudioPlayer.stop(); requestTimer.cancel();});
      }
    });
    message.FirebaseMessaging.onMessageOpenedApp.listen((message.RemoteMessage message)async {
      print('Got a message whilst in the background!');
      await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("offline");
      final Map<String, dynamic> data = message.data;
      print(data);
      assetsAudioPlayer.open(Audio("assets/sounds/notification.wav"),
          loopMode: LoopMode.single);
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        loading.value=false;
        cancelTimeOut.value=50;
        requestTimeOut.value=60;
        requestTimer = Timer.periodic(Duration(seconds: 1), (timer)async {
          if(requestTimeOut.value==0){
            await FirebaseDatabase
                .instance
                .ref()
                .child("users")
                .child(AuthController.controller.auth!.currentUser!.uid)
                .child("available").set("available");
            Get.back(closeOverlays: true);
          } else{
            requestTimeOut.value--;
          }
        });
        Get.bottomSheet(
            WillPopScope(
              onWillPop:backbutton,
              child: Obx(()=>Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                // height: OneContext().mediaQuery.size.height * 0.7,
                // width: OneContext().mediaQuery.size.height * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "New Ride request",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textcolor
                        // color: Colors.black
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Text(
                          "Name : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textcolor),maxLines: 1,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        AutoSizeText(
                          "${data["name"]}",maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "From : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textcolor),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "${data["current"]}",
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Destination : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textcolor),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "${data["to"]}",
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Distance : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textcolor),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "${data["distance"]}",
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Duration : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textcolor),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "${data["dur"]}",
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "rating : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textcolor),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${double.parse(data["rating"]).toStringAsFixed(2)}",
                          overflow: TextOverflow.ellipsis,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.orange,
                        ),SizedBox(
                          width: 10,
                        ),Text("/ ${data['totalRides']} total rides")
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Price : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textcolor),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${data['price']} DA",
                          style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,

                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    // Divider(
                    //   thickness: 2,
                    // ),
                    loading.value ? Center(child: CircularProgressIndicator(),): Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: OneContext().mediaQuery.size.width * 0.4,
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              onPressed: () async {
                                loading.value=true;
                                requestTimer.cancel();
                                var price =   data['price'];
                                var request = await  http.get(Uri.parse('https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=DZD'));


                                if (request.statusCode == 200) {
                                  print( request);
                                }
                                assetsAudioPlayer.stop();
                                final response = jsonDecode( request.body);
                                double Ethamout = (double.parse(data['price'].toString()) / double.parse(response['DZD'].toString()))*1000000;
                                var f = (Ethamout/10).truncate();
                                var cost = EtherAmount.fromUnitAndValue(EtherUnit.szabo, Ethamout.truncate());
                                print("RIDE COST IS ${
                                    cost.getInWei

                                }");
                                DriverController.controller.fees=EtherAmount.fromUnitAndValue(EtherUnit.szabo, f);
                                dialogOpen = true;
                                cancelTimer = Timer.periodic( Duration(seconds: 1), (timer) {
                                  if (cancelTimeOut.value==0){
                                    cancelTimeOut.value=50;
                                    cancelTimer.cancel();

                                    Navigator.of(OneContext().context!)
                                        .pop();
                                    if (Get.isBottomSheetOpen!) {
                                      Get.back(closeOverlays: true);
                                    }
                                    Get.rawSnackbar(
                                        message:
                                        "Payment timeout, the trip has been canceled",
                                        borderRadius: 20,
                                        margin: EdgeInsets.all(5),
                                        backgroundColor: Colors.red);
                                  } else{
                                    cancelTimeOut.value--;
                                    print("cancelTimeOut  ${cancelTimeOut.value}");
                                  }
                                });
                                showDialog(
                                    context: OneContext().context!,
                                    useRootNavigator: false,
                                    barrierDismissible: false,
                                    builder: (_) {
                                      return WillPopScope(
                                        onWillPop: backbutton1,
                                        child: AlertDialog(
                                          title: Text("Waiting"),
                                          content:
                                          Text("Waiting for client payment"),
                                        ),
                                      );
                                    }).then((value) {
                                  dialogOpen = false;
                                  cancelTimeOut.value=50;
                                  cancelTimer.cancel();
                                });

                                print("continue");
                                FirebaseDatabase.instance
                                    .ref()
                                    .child("riderequests")
                                    .child(data["requestid"])
                                    .child("status")
                                    .set("accepted");
                                FirebaseDatabase.instance
                                    .ref()
                                    .child("riderequests")
                                    .child(data["requestid"])
                                    .child("driverPaid")
                                    .set("");

                                subscription = FirebaseDatabase.instance
                                    .ref()
                                    .child("riderequests")
                                    .child(data["requestid"])
                                    .child("clientPaid")
                                    .onValue
                                    .listen((event) async {
                                  print("Value changed");
                                  print(event.snapshot.value);
                                  var snapshot = event.snapshot;
                                  if (snapshot.value == false) {
                                    cancelTimer.cancel();
                                    Navigator.of(OneContext().context!).pop();

                                    Get.back(closeOverlays: true);
                                    Get.rawSnackbar(
                                        message: "Client did not pay the cost",
                                        borderRadius: 20,
                                        margin: EdgeInsets.all(5),
                                        backgroundColor: Colors.red);
                                    subscription.cancel();
                                    await FirebaseDatabase.instance
                                        .ref()
                                        .child("riderequests")
                                        .child(data["requestid"])
                                        .child("clientPaid")
                                        .set("");
                                    await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");

                                  } else if (snapshot.value == true) {
                                    cancelTimer.cancel();
                                    Navigator.of(OneContext().context!).pop();

                                    print("GOING TO PAIMENT");
                                    await FirebaseDatabase.instance
                                        .ref()
                                        .child("riderequests")
                                        .child(data["requestid"])
                                        .child("driverAddress")
                                        .set(WalletController
                                        .controller.account.value);
                                    clientPaid = true;
                                    subscription.cancel();
                                    print("dialogOpen  $dialogOpen");
                                    showDialog(
                                        context: OneContext().context!,
                                        useRootNavigator: false,
                                        barrierDismissible: false,
                                        builder: (_) {
                                          dialogOpen1 = true;

                                          return WillPopScope(
                                            onWillPop: backbutton1,
                                            child: Obx(() => AlertDialog(
                                              title: Text("Waiting"),
                                              content: Text(
                                                  "Go to MetaMask App and pay the confirmation fee \n Payment will timeout if u don't pay in ${timeOut.value}"),
                                            )),
                                          );
                                        }).then((value) {
                                      dialogOpen1 = false;
                                    });

                                    try {
                                      timeOut.value=40;
                                      newTimer = Timer.periodic(
                                          Duration(seconds: 1), (timer) async {
                                        if (timeOut.value == 0) {
                                          FirebaseDatabase.instance
                                              .ref()
                                              .child("riderequests")
                                              .child(data["requestid"])
                                              .child("driverPaid")
                                              .set(false);

                                          Get.rawSnackbar(
                                              message:
                                              "Payment timeout, the trip has been canceled",
                                              borderRadius: 20,
                                              margin: EdgeInsets.all(5),
                                              backgroundColor: Colors.red);
                                          timer.cancel();
                                          FirebaseDatabase.instance
                                              .ref()
                                              .child("riderequests")
                                              .child(data["requestid"])
                                              .child("driverPaid")
                                              .set("");
                                          FirebaseDatabase.instance
                                              .ref()
                                              .child("riderequests")
                                              .child(data["requestid"])
                                              .child("status")
                                              .set("searching");
                                          await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");

                                          timeOut.value = 40;
                                          newTimer.cancel();
                                          Navigator.of(OneContext().context!)
                                              .pop();
                                          if (Get.isBottomSheetOpen!) {
                                            Get.back(closeOverlays: true);
                                          }

                                          // to do cancel the ride
                                        } else {
                                          print(timeOut.value);

                                          timeOut.value--;
                                        }
                                      });

                                      await LaunchApp.openApp(
                                          androidPackageName: 'io.metamask',
                                          openStore: false);
                                      WalletController.controller.connector.reconnect();
                                      await Future.delayed(Duration(seconds: 3,milliseconds: 500));

                                      tx = await WalletController.controller
                                          .sendTransaction(
                                          DriverController.controller.fees);
                                    } catch (e) {
                                      print("PAIMENT ERROR");

                                      print(e);
                                      if (dialogOpen) {
                                        print('DIALOG IS OPEN');
                                        Navigator.of(OneContext().context!).pop();
                                      }
                                      if (dialogOpen1) {
                                        print('DIALOG IS OPEN');
                                        Navigator.of(OneContext().context!).pop();
                                      }
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child("riderequests")
                                          .child(data["requestid"])
                                          .child("driverPaid")
                                          .set(false);
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child("riderequests")
                                          .child(data["requestid"])
                                          .child("driverPaid")
                                          .set("");
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child("riderequests")
                                          .child(data["requestid"])
                                          .child("status")
                                          .set("searching");
                                      if (Get.isBottomSheetOpen!) {
                                        print(' GET DIALOG IS OPEN');

                                        Get.back(closeOverlays: true);
                                      }
                                      await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");

                                      newTimer.cancel();
                                      // Get.back(
                                      //     closeOverlays: true);

                                      return;
                                    }

                                    final eth = EtherscanAPI(
                                        apiKey:
                                        'S35NXF866GPA55XUWUH1AH7NTV7ST33QM5',
                                        // Api key
                                        chain: EthChain.rinkeby,
                                        // Network/chain
                                        enableLogs: true // Enable Logging
                                    );
                                    final bal = await eth.getStatus(txhash: tx);
                                    if (bal.message == "OK") {
                                      if (Get.isBottomSheetOpen==false)
                                      {
                                        print('Ride canceled but driver PAID TO RETURN MONEY');
                                        Get.rawSnackbar(
                                            message:
                                            "You paid after the ride is canceled you will be refunded soon",
                                            borderRadius: 20,
                                            margin: EdgeInsets.all(5),
                                            backgroundColor: Colors.red);
                                        String ss="";
                                        try {
                                          ss =   await SC_Controller.controller.writeContract(SC_Controller.controller.refund, [EthereumAddress.fromHex(WalletController.controller.account.value),DriverController.controller.fees.getInWei]);

                                          print(ss);
                                        } catch (error)
                                        {
                                          Get.defaultDialog(title: "CRITICAL ERROR OCCURED",middleText:  "TX: $ss Take screenshot and submit a ticket to admin ! \n After take screenshot restart the application");

                                        }
                                        return;
                                      }
                                      EasyLoading.show(dismissOnTap: false,status: "Starting ride. Please wait");

                                      newTimer.cancel();
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child("riderequests")
                                          .child(data["requestid"])
                                          .child("driverPaid")
                                          .set(true);

                                      Map<String, dynamic> ss = {
                                        'duration': data['duration'],
                                        'dateTime': DateTime.now().toIso8601String(),
                                      };
                                      Navigator.of(OneContext().context!).pop();
                                      AuthController.controller.database
                                          .ref()
                                          .child("users")
                                          .child(AuthController
                                          .controller.auth!.currentUser!.uid)
                                          .child("history")
                                          .child(data['requestid'])
                                          .update(ss);
                                      DriverController
                                          .controller.pickupLatitude.value =
                                          double.parse(
                                              data['pickuplat'].toString());
                                      DriverController
                                          .controller.pickupLongitude.value =
                                          double.parse(
                                              data['pickuplng'].toString());
                                      DriverController
                                          .controller.dropOffLatitude.value =
                                          double.parse(
                                              data['dropofflat'].toString());
                                      DriverController
                                          .controller.dropOffLongitude.value =
                                          double.parse(
                                              data['dropofflng'].toString());
                                      DriverController.controller
                                          .getPlaceDirectoin(
                                          LatLng(
                                              NavigationController.controller
                                                  .currentLatitude.value,
                                              NavigationController.controller
                                                  .currentLongitude.value),
                                          LatLng(
                                              DriverController.controller
                                                  .pickupLatitude.value,
                                              DriverController.controller
                                                  .pickupLongitude.value));
                                      DriverController.controller
                                          .makeDriverOffline();
                                      var s = await FirebaseDatabase.instance
                                          .ref()
                                          .child("users")
                                          .child(data['clientid'])
                                          .get();
                                      // Map<String,dynamic> map = s.value as Map<String,dynamic>;
                                      AppUser client = AppUser.name(
                                          data['clientid'],
                                          s.child("name").value.toString(),
                                          s.child("phone").value.toString(),
                                          double.parse(
                                              s.child("rating").value.toString()),
                                          s.child("birthdate").value.toString(),
                                          s.child("gender").value.toString(),
                                          int.parse(s
                                              .child("totalRides")
                                              .value
                                              .toString()),
                                          s.child("profileImg").value.toString()
                                      );
                                      await FirebaseDatabase.instance
                                          .ref()
                                          .child("users")
                                          .child(AuthController
                                          .controller.auth!.currentUser!.uid)
                                          .child("currentRide")
                                          .set(data['requestid']);
                                      await FirebaseDatabase.instance
                                          .ref()
                                          .child("users")
                                          .child(data['clientid'])
                                          .child("currentRide")
                                          .set(data['requestid']);
                                      await DriverController.controller.prefs
                                          .setString(
                                          "currentRide", data['requestid']);
                                      if(Get.isBottomSheetOpen!){ Get.back(closeOverlays: true);}
                                      Ride r = Ride(
                                          data['requestid'],
                                          client,
                                          AuthController.controller.appUser!.value,
                                          LatLng(
                                              double.parse(
                                                  data['pickuplat'].toString()),
                                              double.parse(
                                                  data['pickuplng'].toString())),
                                          LatLng(
                                              double.parse(
                                                  data['dropofflat'].toString()),
                                              double.parse(
                                                  data['dropofflng'].toString())),
                                          data['createdat'],
                                          double.parse(data['price'].toString()),
                                          data['current'],
                                          data['to']);
                                      DriverController.controller.ride = r;
                                      Position p = await Geolocator.getCurrentPosition(
                                          desiredAccuracy: LocationAccuracy.bestForNavigation);
                                      var details = await NavigationController.obtainPlaceDirectionDetails(
                                          LatLng(p.latitude, p.longitude), DriverController
                                          .controller.ride.pickup!);

                                      await FirebaseDatabase.instance
                                          .ref()
                                          .child("riderequests")
                                          .child(DriverController.controller.ride.id)
                                          .child("driverTime").set(details?.durationValue.toString());
                                      DriverController.controller.updateRemaining(
                                          DriverController
                                              .controller.ride.pickup!);
                                      print("GOING TO DRIVERIDESCREEN");
                                      EasyLoading.dismiss(animation: true);

                                      Get.to(() => DriverRideScreen());
                                    }
                                  }
                                });

                                // acceptRideRequest();
                              },
                              child: SizedBox(
                                width: OneContext().mediaQuery.size.width * 0.4,
                                child: const Center(
                                  child: Text(
                                    "Accept",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: OneContext().mediaQuery.size.width * 0.4,
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              onPressed: () async {
                                requestTimer.cancel();
                                FirebaseDatabase.instance
                                    .ref()
                                    .child("riderequests")
                                    .child(data["requestid"])
                                    .child("status")
                                    .set("refused");
                                FirebaseDatabase.instance
                                    .ref()
                                    .child("riderequests")
                                    .child(data["requestid"])
                                    .child("status")
                                    .set("searching");
                                await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");
                                Get.back(closeOverlays: true);
                                // await cancelRequest();
                              },
                              child: SizedBox(
                                width: OneContext().mediaQuery.size.width * 0.4,
                                child: const Center(
                                  child: Text(
                                    "Reject",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              )),
            ),
            isDismissible: false,
            enableDrag: false).then((value)  {assetsAudioPlayer.stop(); requestTimer.cancel();});
      }
    });
    print('User granted permission: ${settings.authorizationStatus}');
  }
}
