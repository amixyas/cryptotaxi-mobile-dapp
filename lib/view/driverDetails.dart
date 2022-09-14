import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:cryptotaxi/controller/driver_controller.dart';
import 'package:cryptotaxi/controller/navigation_controller.dart';
import 'package:cryptotaxi/controller/notification_controller.dart';
import 'package:cryptotaxi/controller/ride_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:one_context/one_context.dart';

import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'package:show_up_animation/show_up_animation.dart';

import '../main.dart';
import '../model/driver.dart';
import 'TimeOut.dart';

class DriverDetails extends StatefulWidget {
  Driver driver;

  DriverDetails({Key? key, required this.driver}) : super(key: key);

  @override
  State<DriverDetails> createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  String? _imageUrl;

  late StreamSubscription subscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // toolbarHeight: MediaQuery.of(context).size.height*0.08,

          title: Text(
            "Driver information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.bottom -
                MediaQuery.of(context).padding.top -
                AppBar().preferredSize.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyan,
                Colors.indigo,
              ],
            )),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShowUpAnimation(
                  delayStart: Duration(seconds: 0),
                  animationDuration: Duration(seconds: 1),
                  curve: Curves.decelerate,
                  direction: Direction.vertical,
                  offset: 0.5,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.network(
                          widget.driver.profileImage!,
                          height: 120,
                          width: 120,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Obx(
                  () => ShowUpAnimation( delayStart: Duration( milliseconds: 300),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: Card(
                      elevation: 15,
                      // color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: DefaultTextStyle(
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Theme.of(context).accentColor,
                              fontFamily: "QuickSand"),
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ShowUpAnimation(
                                  delayStart: Duration( milliseconds: 600),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  offset: 0.5,
                                  child: Text("${widget.driver.name}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.robotoMono(
                                          fontSize: 20, color: textcolor)),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                ShowUpAnimation(
                                  delayStart: Duration( milliseconds: 700),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  offset: 0.5,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("${widget.driver.car}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              color: Colors.blueAccent)),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                              "${widget.driver.rating!.toStringAsFixed(2)}",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(color: textcolor)),
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ), SizedBox(
                                  height: 8,
                                ),
                                ShowUpAnimation(
                                  delayStart: Duration( milliseconds: 800),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  offset: 0.5,
                                  child: Row(
                                    children: [
                                      Text("Total Rides : ${widget.driver.totalRides} ",
                                          style: TextStyle(
                                              color: textcolor,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                ShowUpAnimation(
                                  delayStart: Duration( milliseconds: 800),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  offset: 0.5,
                                  child: Row(
                                    children: [
                                      Text("Phone Number: ${widget.driver.phone} ",
                                          style: TextStyle(
                                              color: textcolor,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                ShowUpAnimation(
                                  delayStart: Duration( milliseconds: 900),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  offset: 0.5,
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          "Distance : ${widget.driver.distance?.toStringAsFixed(2)} Km",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textcolor))),
                                ),

                                // Center(
                                //   child: RatingBarIndicator(
                                //     rating: rating,
                                //     itemBuilder: (context, index) => Icon(
                                //       Icons.star,
                                //       color: Colors.amber,
                                //     ),
                                //     itemCount: 5,
                                //     itemSize: 50.0,
                                //     direction: Axis.horizontal,
                                //   ),
                                // ),
                                SizedBox(
                                  height: 10,
                                ),

                                ShowUpAnimation(
                                  delayStart: Duration( seconds: 1),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  offset: 0.5,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Car images:",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: textcolor,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ShowUpAnimation(
                                  delayStart: Duration( seconds: 1,milliseconds: 300),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  offset: 0.5,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: RideController.controller.loading.value
                                          ? Center(
                                              child: CircularProgressIndicator(),
                                            )
                                          : CarouselSlider(
                                              options: CarouselOptions(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.30),
                                              items: RideController
                                                  .controller.carImg
                                                  .map((item) => Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                                vertical: 0.0,
                                                                horizontal: 10.0),
                                                        child: Center(
                                                            child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  20),
                                                          child: Image.network(item,
                                                              fit: BoxFit.fill,
                                                              width: OneContext()
                                                                  .mediaQuery
                                                                  .size
                                                                  .width,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.25),
                                                        )),
                                                      ))
                                                  .toList(),
                                            )),
                                ),
                                ShowUpAnimation(
                                  delayStart: Duration( seconds: 1,milliseconds: 400),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  offset: 0.5,
                                  child: Center(
                                    child: Container(
                                      height: 40,
                                      margin: EdgeInsets.all(10),
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                        ),
                                        color: Colors.green,
                                        onPressed: () async {
                                          if (await confirm(
                                            OneContext().context!,
                                            title: const Text(
                                              'Confirm',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textcolor),
                                            ),
                                            content: const Text(
                                                'When the driver accept the request u have to pay the ride. would you like to continue?'),
                                            textOK: const Text('Yes'),
                                            textCancel: const Text('No'),
                                          )) {
                                            EasyLoading.show(status:"Loading",dismissOnTap: true);
                                            var reply = await FirebaseDatabase
                                                .instance
                                                .ref()
                                                .child("users")
                                                .child(widget.driver.id!)
                                                .child("available")
                                                .get();

                                            if (reply.value.toString() ==
                                                "available") {
                                              print('DRIVER AVAILABLE SENDING NOTIFICATION');
                                              var response =
                                              await NotificationController
                                                  .controller
                                                  .sendnotification(
                                                  widget.driver.token!);
                                              print(response);
                                              EasyLoading.dismiss();
                                              if (response) {
                                                var res = await showDialog(
                                                    context: context,
                                                    useRootNavigator: false,
                                                    builder: (_) => TimeOut());
                                                print("res from driverdetails $res");
                                                if (res == "ridescreen") {
                                                  Get.rawSnackbar(
                                                      message:
                                                      "Request Accepted Please wait!",
                                                      borderRadius: 20,
                                                      margin: EdgeInsets.all(5),
                                                      backgroundColor: Colors.green);
                                                  // _showToast("${AppLocalizations.of(context).request_accepted}",Colors.green);
                                                  // driverobject=widget.driver;

                                                  // Get.back(result: "ridescreen");
                                                  print('done waiting');
                                                  Get.back(
                                                      result: "ridescreen",
                                                      closeOverlays: true);
                                                } else if (res == "refused") {
                                                  print("refused");
                                                  Get.rawSnackbar(
                                                      message:
                                                      "Driver refused your request , Please choose another driver",
                                                      borderRadius: 20,
                                                      margin: EdgeInsets.all(5),
                                                      backgroundColor: Colors.red);
                                                } else if (res == "paimentError") {
                                                  Get.rawSnackbar(
                                                      message:
                                                      "Driver accepted but u failed to pay ",
                                                      borderRadius: 20,
                                                      duration: Duration(seconds: 5),
                                                      margin: EdgeInsets.all(5),
                                                      backgroundColor: Colors.red);
                                                } else if (res == "driverNotPay") {
                                                  Get.rawSnackbar(
                                                      message:
                                                      "Driver did not pay the confirmation fee , You will be refunded shortly ",
                                                      borderRadius: 20,
                                                      duration: Duration(seconds: 5),
                                                      margin: EdgeInsets.all(5),
                                                      backgroundColor: Colors.green);
                                                }
                                              }else{
                                                Get.rawSnackbar(
                                                    message:
                                                    "Could not send a request to the driver ",
                                                    borderRadius: 20,
                                                    duration: Duration(seconds: 5),
                                                    margin: EdgeInsets.all(5),
                                                    backgroundColor: Colors.red);
                                              }
                                            } else {
                                              Get.rawSnackbar(
                                                  message:
                                                  "Driver you requested already have a ride request on hold. Try again in minute or change the driver ",
                                                  borderRadius: 20,
                                                  duration: Duration(seconds: 5),
                                                  margin: EdgeInsets.all(5),
                                                  backgroundColor: Colors.red);
                                            }
                                            return print('pressedOK');
                                          } else {
                                            return print('pressedCancel');
                                          }

                                          // Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Send Request",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              // color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                // Obx(()=> SizedBox(
                //   height: OneContext().mediaQuery.size.height * 0.28,
                //   width: double.infinity,
                //   child: GridView.count(
                //       crossAxisCount: 1,
                //       children: List.generate(
                //         RideController.controller.carImg.length,
                //             (index) {
                //           return Stack(
                //             children: [
                //               Container(
                //                 width: double.infinity,
                //                 padding: EdgeInsets.all(5),
                //                 child: ClipRRect(
                //                   borderRadius: BorderRadius.circular(5),
                //                   child: Image.network(
                //                     RideController.controller.carImg[index],
                //                     fit: BoxFit.fitWidth,
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           );
                //         },
                //       )),
                // ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
