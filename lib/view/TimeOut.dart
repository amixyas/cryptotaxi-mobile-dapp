import 'dart:async';

import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/navigation_controller.dart';
import 'package:cryptotaxi/controller/notification_controller.dart';
import 'package:cryptotaxi/controller/ride_controller.dart';
import 'package:cryptotaxi/controller/wallet_controller.dart';
import 'package:etherscan_api/etherscan_api.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import '../controller/SC_controller.dart';
import '../controller/driver_controller.dart';
import '../main.dart';

class TimeOut extends StatefulWidget {
  const TimeOut({Key? key}) : super(key: key);

  @override
  _TimeOutState createState() => _TimeOutState();
}

class _TimeOutState extends State<TimeOut> {
  late Timer timer;
  final onsecondpassed = Duration(seconds: 1);
  late StreamSubscription subscription;
  late StreamSubscription subscription1;
  bool waitDriver = false;
  bool accepted = false;
  int timeOut = 40;
  Timer? newTimer;
  bool error = false;
  late String tx;
  late Timer cancelTimer;
  RxInt cancelTimeOut = 50.obs;
  void initTimer() {
    NotificationController.controller.clientrequestTimer.value = 60;
    subscription = RideController.controller.rideRequest
        .child(RideController.controller.idRide)
        .child("status")
        .onValue
        .listen((event) async {
      var snapshot = event.snapshot;
      print("THIS IS SNAPSGHOT ${snapshot.value}");
      if (snapshot.value == "accepted") {

        timer.cancel();
        setState(() {
          accepted = true;
        });
        // SharedPreferences prefs = await SharedPreferences.getInstance();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("currentRide", RideController.controller.idRide);
        FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("strictMode").set(RideController.controller.strictMode.value);

        Map<String, dynamic> s = {
          'duration':
              NavigationController.controller.directionDetails.durationValue,
          'dateTime': DateTime.now().toIso8601String(),
        };
        FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("clientPaid").set("");

        try {
          newTimer = Timer.periodic(Duration(seconds: 1), (timer) {
            if(timeOut==0){
              FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("clientPaid").set(false);

              Get.rawSnackbar(
                  message:
                  "Payment timeout, the trip has been canceled",
                  borderRadius: 20,
                  margin: EdgeInsets.all(5),
                  backgroundColor: Colors.red);
              FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("clientPaid").set("");

              timer.cancel();
              setState(() {
                timeOut=40;
              });
              FirebaseDatabase.instance
                  .ref()
                  .child("riderequests")
                  .child(RideController.controller.idRide)
                  .child("status")
                  .set("searching");
              Get.back(result: "paimentError", closeOverlays: true);

              // to do cancel the ride
            }else{

              setState(() {
                timeOut--;
              });
              print(timeOut);

            }

          });
          await LaunchApp.openApp(
              androidPackageName: 'io.metamask',
          );
          await Future.delayed(Duration(seconds: 3,milliseconds: 500));
          tx = await WalletController.controller.sendTransaction(EtherAmount.fromUnitAndValue(EtherUnit.wei,NavigationController.controller.ETHCost));

        } catch (e) {
          print("PAIMENT ERROR ${e.toString()}");
          newTimer?.cancel();
       await  RideController.controller.rideRequest
              .child(RideController.controller.idRide)
              .child("status")
              .set("searching");
        await  FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("clientPaid").set(false);
          await  FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("clientPaid").set("");

          Get.back(result: "paimentError", closeOverlays: true);
          return;

          error = true;
        }

        final eth = EtherscanAPI(
            apiKey: 'S35NXF866GPA55XUWUH1AH7NTV7ST33QM5', // Api key
            chain: EthChain.rinkeby, // Network/chain
            enableLogs: true // Enable Logging
            );
        final bal = await eth.getStatus(txhash: tx);
        print(bal.message);
        if (bal.message == "OK") {
          if (this.mounted==false)
          {
            print('Ride canceled but user PAID TO RETURN MONEY');

            Get.rawSnackbar(
                message:
                "You paid after the ride is canceled you will be refunded soon",
                borderRadius: 20,
                margin: EdgeInsets.all(5),

                backgroundColor: Colors.red);
            String ss="";
            print("DRIVER REFUSED TO PAY CONFIRMATION FEE TO DO MUST REFUND THE CLIENT ");
            try {
              ss =  await SC_Controller.controller.writeContract(SC_Controller.controller.refund, [EthereumAddress.fromHex(WalletController.controller.account.value),NavigationController.controller.ETHCost]);
               print(ss);
            } catch (error)
            {
              Get.defaultDialog(title: "CRITICAL ERROR OCCURED",middleText:  "TX: $ss Take screenshot and submit a ticket to admin ! \n After take screenshot restart the application");

            }

            return;
          }
          newTimer?.cancel();
          setState(() {
            waitDriver=true;
          });
          FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("clientPaid").set(true);
          cancelTimer = Timer.periodic( Duration(seconds: 1), (timer) async {
            if (cancelTimeOut.value==0){
              cancelTimeOut.value=50;
              cancelTimer.cancel();
              String ss="";
              print("DRIVER REFUSED TO PAY CONFIRMATION FEE TO DO MUST REFUND THE CLIENT ");
              try {
                ss =  await SC_Controller.controller.writeContract(SC_Controller.controller.refund, [EthereumAddress.fromHex(WalletController.controller.account.value),NavigationController.controller.ETHCost]);
                print(ss);

              } catch (error)
              {
                print("CRITICAL ERROR OCCURED TX: $ss Take screenshot and submit a ticket to admin ! \n After take screenshot restart the application ");

                Get.defaultDialog(title: "CRITICAL ERROR OCCURED",middleText:  "TX: $ss Take screenshot and submit a ticket to admin ! \n After take screenshot restart the application");

              }

              FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("clientPaid").set("");
              subscription1.cancel();
              subscription.cancel();
              RideController.controller.rideRequest
                  .child(RideController.controller.idRide)
                  .child("status")
                  .set("searching");
              timer.cancel();
              FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("driverPaid").set("");

              Navigator.of(Get.overlayContext!).pop("driverNotPay");

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
          subscription1 =  FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide)
              .child("driverPaid")
              .onValue
              .listen((event) async {
            var snapshot = event.snapshot;
            if (snapshot.value==false){
              cancelTimer.cancel();
              String ss="";
              print("DRIVER REFUSED TO PAY CONFIRMATION FEE TO DO MUST REFUND THE CLIENT ");
              try {
               ss =  await SC_Controller.controller.writeContract(SC_Controller.controller.refund, [EthereumAddress.fromHex(WalletController.controller.account.value),NavigationController.controller.ETHCost]);
               print(ss);

              } catch (error)
              {
                print("CRITICAL ERROR OCCURED TX: $ss Take screenshot and submit a ticket to admin ! \n After take screenshot restart the application ");

                Get.defaultDialog(title: "CRITICAL ERROR OCCURED",middleText:  "TX: $ss Take screenshot and submit a ticket to admin ! \n After take screenshot restart the application");

              }

              FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("clientPaid").set("");
              subscription1.cancel();
              subscription.cancel();
              RideController.controller.rideRequest
                  .child(RideController.controller.idRide)
                  .child("status")
                  .set("searching");
              timer.cancel();
              FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide).child("driverPaid").set("");

              Navigator.of(Get.overlayContext!).pop("driverNotPay");

            }else
            if (snapshot.value == true) {
              cancelTimer.cancel();
              var resposnse = await  FirebaseDatabase.instance.ref().child("riderequests").child(RideController.controller.idRide)
                  .child("driverAddress").get();
               print(resposnse.value.toString());
              print("this is bal ${bal.message}");
              var uuid = Uuid();
              RideController.controller.rideKey.value=uuid.v4();
              await SC_Controller.controller
                  .writeContract(SC_Controller.controller.requestRide, [
                RideController.controller.idRide,
                NavigationController.controller.currentLatitude.toString(),
                NavigationController.controller.currentLongitude.toString(),
                NavigationController.controller.dropOffLatitude.toString(),
                NavigationController.controller.dropOffLongitude.toString(),
                AuthController.controller.auth!.currentUser!.uid,
                RideController.controller.driver.id,
                EthereumAddress.fromHex(WalletController.controller.account.value),
                EthereumAddress.fromHex(resposnse.value.toString()),
                NavigationController.controller.ETHCost,
                RideController.controller.rideKey.value
              ]);
              await FirebaseDatabase.instance
                  .ref()
                  .child("users")
                  .child(AuthController.controller.auth!.currentUser!.uid)
                  .child("currentRide")
                  .set(RideController.controller.idRide);
            await AuthController.controller.database
                  .ref()
                  .child("users")
                  .child(AuthController.controller.auth!.currentUser!.uid)
                  .child("history")
                  .child(RideController.controller.idRide)
                  .set(s);
              // await prefs.setString("ride", requestid);
              print("request id saved");
              Get.back(result: "ridescreen",closeOverlays: true);

              timer.cancel();
              subscription.cancel();
              NotificationController.controller.clientrequestTimer.value = 60;

              // Navigator.pushNamedAndRemoveUntil(context,Mainscreen.routeName,(r)=> false);
              print("Pushed to Mainscreen");
            }
          });
        }
      } else if (snapshot.value == "refused") {
        print("DRIVER REFUSED");

        RideController.controller.rideRequest
            .child(RideController.controller.idRide)
            .child("status")
            .set("searching");
        timer.cancel();
        subscription.cancel();
        Navigator.of(Get.overlayContext!).pop("refused");
        // Get.back(result: "refused");
      }
    });

    timer = Timer.periodic(onsecondpassed, (timer) async {
      if (NotificationController.controller.clientrequestTimer.value == 0) {
        timer.cancel();
        Get.rawSnackbar(
            message:
                "Request timeout , Please choose another driver or request the driver again!",
            borderRadius: 20,
            margin: EdgeInsets.all(5),
            backgroundColor: Colors.red);
        // await _showToast("${AppLocalizations.of(context).request_driver_timeout}",Colors.red);
        NotificationController.controller.clientrequestTimer.value = 60;
        Get.back(closeOverlays: true);
        subscription.cancel();
        return;
      }

      NotificationController.controller.clientrequestTimer.value =
          NotificationController.controller.clientrequestTimer.value - 1;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    // initTimer();
    super.initState();
    initTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    subscription.cancel();
    newTimer?.cancel();
    timeOut=40;
    super.dispose();
  }

  Future<bool> backbutton() async {
    Get.rawSnackbar(
        message: "Wait for driver response",
        borderRadius: 20,
        margin: EdgeInsets.all(5),
        backgroundColor: Colors.red);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: backbutton,
        child: Obx(
          () => AlertDialog(
            title: accepted
                ? ShowUpAnimation(
              delayStart: Duration(
                  milliseconds: 0),
              animationDuration:
              Duration(seconds: 1),
              curve: Curves.decelerate,
              direction: Direction.vertical,
              offset: 0.5,
              child: Text(
                      "Paiment process ! ",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                )
                : Text(
                    "Waiting for driver response ! ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            content: accepted
                ? waitDriver
                    ? ShowUpAnimation(
              delayStart: Duration(
                  milliseconds: 0),
              animationDuration:
              Duration(seconds: 1),
              curve: Curves.decelerate,
              direction: Direction.vertical,
              offset: 0.5,
                      child: ShowUpAnimation(
                        delayStart: Duration(
                            milliseconds: 0),
                        animationDuration:
                        Duration(seconds: 1),
                        curve: Curves.decelerate,
                        direction: Direction.vertical,
                        offset: 0.5,
                        child: Text(
                            "Waiting for driver to pay confirmation fee",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ),
                    )
                    : ShowUpAnimation(
              delayStart: Duration(
                  milliseconds: 0),
              animationDuration:
              Duration(seconds: 1),
              curve: Curves.decelerate,
              direction: Direction.vertical,
              offset: 0.5,
                      child: Text(
                          "Go to MetaMask app and approve the paiment \n\nPayment will timeout if u don't pay in $timeOut seconds",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                    )
                : Text(
                    "Please wait ${NotificationController.controller.clientrequestTimer.value} seconds !",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
            actions: error
                ? [
                    RaisedButton(onPressed: () {}, child: Text("Cancel Ride")),
                    RaisedButton(onPressed: () {}, child: Text("Retry"))
                  ]
                : null,
          ),
        ));
    //   StatefulBuilder(
    //     builder:(BuildContext context,StateSetter setState) { return Dialog(
    //
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(12),
    //
    //       ),
    //       backgroundColor: Colors.transparent,
    //       child: Container(
    //         margin: EdgeInsets.all(5.0),
    //         width: double.infinity,
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(5),
    //
    //         ),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             SizedBox(height: 22,),
    //             Padding(padding: EdgeInsets.symmetric(horizontal: 20),
    //               child: Text("Waiting for driver response .",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 20),textAlign: TextAlign.center ,),),
    //             SizedBox(height: 22,),
    //             Padding(padding: EdgeInsets.symmetric(horizontal: 20),
    //               child: Text("You have to wait $requestTimeOut seconds .}.",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 20),textAlign: TextAlign.center ,),),
    //             SizedBox(height: 30,),
    //             // Padding(
    //             //   padding: EdgeInsets.symmetric(horizontal: 16),
    //             //   child: ElevatedButton(
    //             //
    //             //     onPressed: () async {
    //             //       Navigator.pop(context);
    //             //       Navigator.pop(context);
    //             //
    //             //     },
    //             //
    //             //     child: Padding(
    //             //       padding: EdgeInsets.all(15,),
    //             //       child: Row(
    //             //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             //         children: [
    //             //
    //             //           Text("Collect Cash",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),)
    //             //           ,Icon(Icons.attach_money,color: Colors.white,size: 26,)
    //             //         ],
    //             //       ),
    //             //     ),
    //             //   ),
    //             // )
    //           ],
    //         ),
    //       ),
    //     );}
    // );
  }
}
