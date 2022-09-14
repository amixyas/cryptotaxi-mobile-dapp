import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/driver_controller.dart';
import 'package:cryptotaxi/controller/navigation_controller.dart';
import 'package:cryptotaxi/controller/rideHistory_Controller.dart';
import 'package:cryptotaxi/controller/ride_controller.dart';
import 'package:cryptotaxi/controller/wallet_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/view/earningScreen.dart';
import 'package:cryptotaxi/view/historyScreen.dart';
import 'package:cryptotaxi/view/mapScreen.dart';
import 'package:cryptotaxi/view/messages.dart';
import 'package:cryptotaxi/view/profileScreen.dart';
import 'package:cryptotaxi/view/rideScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:one_context/one_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:show_up_animation/show_up_animation.dart';
import '../controller/SC_controller.dart';
import '../navigation/custom_navigation_bar.dart';
import 'driverList.dart';
import 'feedbackScreen.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  static const String routename = "home";
  final _inactiveColor = Colors.grey;

  late MediaQueryData size;

  Widget HomePage() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
            child: Obx(
          () => SizedBox(
            height: AuthController.controller.role.value=="driver" ?size.size.height*0.8 - size.padding.top - size.padding.bottom :NavigationController.controller.listFavPlace.isNotEmpty
                ? size.size.height - size.padding.top - size.padding.bottom + OneContext().mediaQuery.size.height * 0.08                : size.size.height -
                    size.padding.top -
                    size.padding.bottom -
                    OneContext().mediaQuery.size.height * 0.20,
            width: size.size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ShowUpAnimation(
                  delayStart: Duration(seconds: 0),
                  animationDuration: Duration(seconds: 1),
                  curve: Curves.decelerate,
                  direction: Direction.vertical,
                  offset: 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Hello ${AuthController.controller.appUser?.value.fullname}!",
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(0.0, 0.5),
                                    blurRadius: 1,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  // Shadow(
                                  //   offset: Offset(0.0, 2.0),
                                  //   blurRadius: 8.0,
                                  //   color: Color.fromARGB(125, 0, 0, 255),
                                  // ),
                                ],
                                color: Color.fromARGB(255, 23, 43, 77)),
                          ),
                          if (AuthController.controller.role.value == "client")
                            SizedBox(
                              height: 10,
                            ),
                          if (AuthController.controller.role.value == "client")
                            Text(
                              "Where do you wanna go today ?",
                            )
                        ],
                      ),
                      BouncingWidget(
                        duration: Duration(milliseconds: 200),
                        scaleFactor: 2,
                        stayOnBottom: false,
                        onPressed: () async {
                          await Future.delayed(Duration(milliseconds: 300));
                          Get.to(() => ProfileScreen(),
                              transition: Transition.cupertino,
                              duration: Duration(milliseconds: 400));
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(30)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: (AuthController.controller.auth!
                                          .currentUser!.photoURL !=
                                      null)
                                  ? Image.network(
                                      AuthController.controller.auth!
                                          .currentUser!.photoURL!,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.fill,
                                    )
                                  : Image.network(
                                      'https://cdn-icons-png.flaticon.com/512/219/219983.png',
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.fill,
                                    )),
                        ),
                      ),
                    ],
                  ),
                ),
                if (AuthController.controller.role.value == "driver")
                  Column(
                    children: [
                      Text("Total earnings",style: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold,color: textcolor, fontSize: 30),),
                      Text("${RideHistoryController.controller.total.value} DA",style: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold,color: Colors.green, fontSize: 30),)
                    ],
                  ),

                if (AuthController.controller.role.value == "driver") Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Rating",
                          style: GoogleFonts.montserratAlternates(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textcolor),
                        ),
                        Row(
                          children: [
                            Text(
                              "${AuthController.controller.userRating.value.toStringAsFixed(2)}",
                              style: GoogleFonts.montserratAlternates(
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                            )
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Text("Total rides",
                            style: GoogleFonts.montserratAlternates(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: textcolor)),
                        Text(
                          "${AuthController.controller.userTotalRides.value}",
                          style: GoogleFonts.montserratAlternates(
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
                ShowUpAnimation(
                  delayStart: Duration(milliseconds: 500),
                  animationDuration: Duration(seconds: 1),
                  curve: Curves.decelerate,
                  direction: Direction.horizontal,
                  offset: 0.5,
                  child: Obx(
                    () => WalletController.controller.connected.value
                        ? Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.7),
                                    spreadRadius: 0.5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        2, 1), // changes position of shadow
                                  ),
                                ],
                                color: Color.fromARGB(255, 150, 220, 250),
                                borderRadius: BorderRadius.circular(10)),

                            // margin: EdgeInsets.all(15),
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Your e-wallet balance",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textcolor),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "${WalletController.controller.balance.value.toStringAsFixed(4)} ETH",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                    BouncingWidget(
                                      duration: Duration(milliseconds: 200),
                                      scaleFactor: 5,
                                      onPressed: () async {
                                        print("killing session");
                                        if(AuthController.controller.role.value=="driver"){await DriverController.controller.makeDriverOffline();}
                                        WalletController.controller.connector
                                            .killSession();
                                        await Future.delayed(
                                            Duration(milliseconds: 200));
                                        WalletController
                                            .controller.connected.value = false;
                                        WalletController
                                            .controller.account.value = "";
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        prefs.remove("session");
                                      },
                                      child: Material(
                                        elevation: 5,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 87, 183, 235),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: EdgeInsets.all(15),
                                          child: Text(
                                            "Disconnect",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Connected Address:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textcolor),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                AutoSizeText(
                                  "${WalletController.controller.account.value}",
                                  maxLines: 1,
                                  minFontSize:8,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                )
                              ],
                            ))
                        : BouncingWidget(
                            duration: Duration(milliseconds: 200),
                            scaleFactor: 3,
                            onPressed: () async {
                              await Future.delayed(Duration(milliseconds: 200));

                              await WalletController.controller.onInit();
                              await WalletController.controller.main();
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.7),
                                      spreadRadius: 0.5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          2, 1), // changes position of shadow
                                    ),
                                  ],
                                  color: Color.fromARGB(255, 150, 220, 250),
                                  borderRadius: BorderRadius.circular(10)),

                              // margin: EdgeInsets.all(15),
                              padding: EdgeInsets.all(15),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      child: Text(
                                        "Connect with MetaMask",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 23, 43, 77)),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      "assets/images/metamask.svg",
                                      height: 40,
                                      width: 40,
                                    )
                                  ]),
                            ),
                          ),
                  ),
                ),
                // Text(
                //   WalletController.controller.account.value,
                //   style: TextStyle(fontSize: 13),
                // ),

                if (AuthController.controller.role.value == "driver")
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: BouncingWidget(
                            duration: Duration(milliseconds: 300),
                            scaleFactor: 2,
                            child: Material(
                                color: Colors.green.shade400,
                                elevation: 10,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Profile",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        FontAwesomeIcons.solidUser,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                )),
                            onPressed: () async {
                              await Future.delayed(Duration(milliseconds: 300));
                              Get.to(() => ProfileScreen(),
                                  transition: Transition.cupertino,
                                  duration: Duration(milliseconds: 400));
                            }),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      Expanded(
                        flex: 1,
                        child: BouncingWidget(
                            duration: Duration(milliseconds: 300),
                            scaleFactor: 2,
                            child: Material(
                                color: Colors.green.shade400,
                                elevation: 10,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Feedback",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        FontAwesomeIcons.solidAddressCard,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                )),
                            onPressed: () async {
                              await Future.delayed(Duration(milliseconds: 300));
                              Get.to(() => FeedBackScreen(),
                                  transition: Transition.cupertino,
                                  duration: Duration(milliseconds: 400));
                            }),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                if (AuthController.controller.role.value == "client")
                  ShowUpAnimation(
                    delayStart: Duration(seconds: 1),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.horizontal,
                    offset: 0.5,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick order",
                            style: TextStyle(
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(0.0, 0.5),
                                    blurRadius: 1,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  // Shadow(
                                  //   offset: Offset(0.0, 2.0),
                                  //   blurRadius: 8.0,
                                  //   color: Color.fromARGB(125, 0, 0, 255),
                                  // ),
                                ],
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color.fromARGB(255, 23, 43, 77)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Card(
                            elevation: 8,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                                height: size.size.height * 0.35,
                                padding: EdgeInsets.all(12),
                                child: Obx(
                                  () => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("Your current location",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 23, 43, 77))),
                                      ListTile(
                                          onTap: () async {
                                            Get.to(
                                              PlacePicker(
                                                apiKey: Platform.isAndroid
                                                    ? "AIzaSyDBUOXf8zTb24XGmhF5tlBaDV27uYF7170"
                                                    : "YOUR IOS API KEY",
                                                onPlacePicked: (result) {
                                                  NavigationController
                                                      .controller
                                                      .updateLocation(
                                                          result.geometry!
                                                              .location.lat,
                                                          result.geometry!
                                                              .location.lng,
                                                          result
                                                              .formattedAddress!);
                                                  print(
                                                      result.formattedAddress);
                                                  Get.back(closeOverlays: true);
                                                },
                                                initialPosition: LatLng(
                                                    NavigationController
                                                        .controller
                                                        .currentLatitude
                                                        .value,
                                                    NavigationController
                                                        .controller
                                                        .currentLongitude
                                                        .value),
                                                useCurrentLocation: true,
                                              ),
                                            );
                                          },
                                          dense: true,
                                          horizontalTitleGap: 0,
                                          visualDensity:
                                              VisualDensity.comfortable,
                                          minVerticalPadding: 0,
                                          leading: Icon(
                                            Icons.location_pin,
                                            color: Colors.blueAccent,
                                          ),
                                          title: AutoSizeText(
                                            NavigationController.controller
                                                .currentAddress.value,
                                            maxLines: 2,
                                          ),
                                          trailing: BouncingWidget(
                                            scaleFactor: 1.5,
                                            onPressed: () async {
                                              var result =
                                                  await NavigationController
                                                      .controller
                                                      .locateposition();
                                              var address =
                                                  await placemarkFromCoordinates(
                                                      result.latitude,
                                                      result.longitude);
                                              var s =
                                                  "${address[0].street ?? ""}  ${address.first.subAdministrativeArea ?? ""} ,${address[0].administrativeArea ?? ""} ";
                                              NavigationController.controller
                                                  .updateLocation(
                                                      result.latitude,
                                                      result.longitude,
                                                      s);
                                            },
                                            duration:
                                                Duration(milliseconds: 200),
                                            child: Icon(
                                              FontAwesomeIcons.arrowsRotate,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          tileColor: Color.fromARGB(
                                              255, 220, 240, 250),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30))),
                                      Text("Where do you want to go?",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 23, 43, 77))),
                                      ListTile(
                                        onTap: () {
                                          Get.to(
                                            PlacePicker(
                                              apiKey: Platform.isAndroid
                                                  ? "AIzaSyDBUOXf8zTb24XGmhF5tlBaDV27uYF7170"
                                                  : "YOUR IOS API KEY",
                                              onPlacePicked: (result) {
                                                NavigationController.controller
                                                    .updateDropOffLocation(
                                                        result.geometry!
                                                            .location.lat,
                                                        result.geometry!
                                                            .location.lng,
                                                        result
                                                            .formattedAddress!);
                                                print(result.formattedAddress);
                                                Get.back(closeOverlays: true);
                                              },
                                              initialPosition: LatLng(
                                                  NavigationController
                                                      .controller
                                                      .currentLatitude
                                                      .value,
                                                  NavigationController
                                                      .controller
                                                      .currentLongitude
                                                      .value),
                                              useCurrentLocation: true,
                                            ),
                                          );
                                        },
                                        dense: true,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        horizontalTitleGap: 0,
                                        minVerticalPadding: 0,
                                        tileColor:
                                            Color.fromARGB(255, 220, 240, 250),
                                        leading: Icon(
                                          FontAwesomeIcons.locationCrosshairs,
                                          color: Colors.blueAccent,
                                        ),
                                        title: AutoSizeText(
                                            NavigationController.controller
                                                .dropOffAddress.value,
                                            maxLines: 2),
                                      ),
                                      SizedBox(
                                        width: size.size.width,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            BouncingWidget(
                                              duration:
                                                  Duration(milliseconds: 200),
                                              onPressed: () async {
                                                NavigationController
                                                    .controller.markers
                                                    .clear();
                                                NavigationController
                                                    .controller.polylines
                                                    .clear();
                                                await NavigationController
                                                    .controller
                                                    .cancelRide();
                                              },
                                              scaleFactor: 3,
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                elevation: 10,
                                                child: Container(
                                                  height: 50,
                                                  width: 65,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                          colors: [
                                                            Colors.cyan,
                                                            Colors.lightBlue
                                                          ]),

                                                      // color: Color.fromARGB(
                                                      //     255, 150, 220, 250),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  padding: EdgeInsets.all(15),
                                                  child: Center(
                                                    child: Center(
                                                        child: Icon(
                                                      Icons.refresh_rounded,
                                                      color: Colors.white,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: BouncingWidget(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                onPressed: () async {
                                                  if (NavigationController
                                                          .controller
                                                          .dropOffLatitude
                                                          .value ==
                                                      0) {
                                                    Get.rawSnackbar(
                                                        message:
                                                            "Select destination first!",
                                                        borderRadius: 20,
                                                        margin:
                                                            EdgeInsets.all(5),
                                                        backgroundColor:
                                                            Colors.red);
                                                  } else {
                                                    await NavigationController.controller.getPlaceDirectoin(
                                                        LatLng(
                                                            NavigationController
                                                                .controller
                                                                .currentLatitude
                                                                .value,
                                                            NavigationController
                                                                .controller
                                                                .currentLongitude
                                                                .value),
                                                        LatLng(
                                                            NavigationController
                                                                .controller
                                                                .dropOffLatitude
                                                                .value,
                                                            NavigationController
                                                                .controller
                                                                .dropOffLongitude
                                                                .value));
                                                    NavigationController.controller.getDrivers();
                                                    NavigationController
                                                            .controller
                                                            .cost
                                                            .value =
                                                        await NavigationController
                                                            .controller
                                                            .getRideCost();
                                                    NavigationController
                                                        .controller
                                                        .currentIndex
                                                        .value = 1;
                                                    var map = {
                                                      "client":
                                                          "${AuthController.controller.auth!.currentUser!.uid}",
                                                      "status": "searching",
                                                      "driver": "wait"
                                                    };
                                                    await RideController
                                                        .controller
                                                        .rideRequestRef
                                                        .set(map);
                                                    RideController
                                                            .controller.idRide =
                                                        RideController
                                                            .controller
                                                            .rideRequestRef
                                                            .key!;
                                                  }
                                                },
                                                child: Material(
                                                  elevation: 10,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                            begin:
                                                                Alignment
                                                                    .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                            colors: [
                                                              Colors.blueAccent,
                                                              Colors
                                                                  .lightBlueAccent
                                                            ]),
                                                        color: Color.fromARGB(
                                                            255, 87, 183, 235),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    padding: EdgeInsets.all(15),
                                                    child: Center(
                                                      child: Text(
                                                        "Book Now",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            shadows: <Shadow>[
                                                              Shadow(
                                                                offset: Offset(
                                                                    2.0, 2.0),
                                                                blurRadius: 5.0,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        0,
                                                                        0,
                                                                        0),
                                                              ),
                                                              // Shadow(
                                                              //   offset: Offset(0.0, 2.0),
                                                              //   blurRadius: 8.0,
                                                              //   color: Color.fromARGB(125, 0, 0, 255),
                                                              // ),
                                                            ],
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),

                Obx(
                  () => (NavigationController
                              .controller.listFavPlace.isNotEmpty &&
                          AuthController.controller.role.value == "client")
                      ? ShowUpAnimation(
                          delayStart: Duration(seconds: 1, milliseconds: 500),
                          animationDuration: Duration(seconds: 1),
                          curve: Curves.decelerate,
                          direction: Direction.vertical,
                          offset: 0.5,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Your Favorite Places",
                                    style: TextStyle(
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(0.0, 0.5),
                                            blurRadius: 1,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          // Shadow(
                                          //   offset: Offset(0.0, 2.0),
                                          //   blurRadius: 8.0,
                                          //   color: Color.fromARGB(125, 0, 0, 255),
                                          // ),
                                        ],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 23, 43, 77)),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                SizedBox(
                                  height:
                                      OneContext().mediaQuery.size.height * 0.2,
                                  child: ListView.separated(

                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return BouncingWidget(
                                          scaleFactor: 1.5,
                                          duration: Duration(milliseconds: 200),
                                          onPressed: () async {
                                          if(NavigationController.controller.currentLatitude.value==0){
                                            Get.rawSnackbar(
                                                message: "Select the pick up location first !",
                                                borderRadius: 20,
                                                margin: EdgeInsets.all(5),
                                                backgroundColor: Colors.red);
                                          }else{
                                            NavigationController.controller
                                                .dropOffLongitude.value =
                                            NavigationController
                                                .controller
                                                .listFavPlace[index]
                                                .longitude!;
                                            NavigationController.controller
                                                .dropOffLatitude.value =
                                            NavigationController
                                                .controller
                                                .listFavPlace[index]
                                                .latitude!;
                                            NavigationController.controller
                                                .dropOffAddress.value =
                                            NavigationController
                                                .controller
                                                .listFavPlace[index]
                                                .Address!;
                                            await NavigationController.controller
                                                .getPlaceDirectoin(
                                                LatLng(
                                                    NavigationController
                                                        .controller
                                                        .currentLatitude
                                                        .value,
                                                    NavigationController
                                                        .controller
                                                        .currentLongitude
                                                        .value),
                                                LatLng(
                                                    NavigationController
                                                        .controller
                                                        .dropOffLatitude
                                                        .value,
                                                    NavigationController
                                                        .controller
                                                        .dropOffLongitude
                                                        .value));
                                            NavigationController.controller.getDrivers();
                                            NavigationController
                                                .controller.cost.value =
                                            await NavigationController
                                                .controller
                                                .getRideCost();

                                            NavigationController.controller
                                                .currentIndex.value = 1;
                                            var map = {
                                              "client":
                                              "${AuthController.controller.auth!.currentUser!.uid}",
                                              "status": "searching",
                                              "driver": "wait"
                                            };
                                            await RideController
                                                .controller.rideRequestRef
                                                .set(map);
                                            RideController.controller.idRide =
                                            RideController.controller
                                                .rideRequestRef.key!;
                                          }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(8.0),
                                            child: Slidable(
                                              // key: UniqueKey(),
                                              endActionPane: ActionPane(
                                                  extentRatio: 0.3,
                                                  dragDismissible: true,
                                                  motion: ScrollMotion(),
                                                  children: [
                                                    SlidableAction(
                                                      onPressed: (BuildContext
                                                          context) async {
                                                        if (await confirm(
                                                            OneContext()
                                                                .context!)) {
                                                          FirebaseDatabase
                                                              .instance
                                                              .ref()
                                                              .child("users")
                                                              .child(AuthController
                                                                  .controller
                                                                  .auth!
                                                                  .currentUser!
                                                                  .uid)
                                                              .child(
                                                                  "favoritePlaces")
                                                              .child(
                                                                  NavigationController
                                                                      .controller
                                                                      .listFavPlace[
                                                                          index]
                                                                      .id!)
                                                              .remove();
                                                          NavigationController
                                                              .controller
                                                              .listFavPlace
                                                              .removeAt(index);
                                                          return print('pressedOK');
                                                        }
                                                        return print('pressedCancel');
                                                      },
                                                      icon: Icons.delete_forever,
                                                      foregroundColor: Colors.red,
                                                      flex: 1,
                                                      autoClose: true,

                                                    )
                                                  ]),
                                              child: ListTile(
                                                dense: true,
                                                leading: Icon(
                                                  Icons.location_pin,
                                                  color: Colors.blueAccent,
                                                ),
                                                title: Text(
                                                  NavigationController.controller
                                                      .listFavPlace[index].name!,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: textcolor,
                                                      fontSize: 16),
                                                ),
                                                subtitle: Text(
                                                  NavigationController
                                                      .controller
                                                      .listFavPlace[index]
                                                      .Address!,
                                                  style:
                                                      TextStyle(color: textcolor),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.blueAccent,
                                        );
                                      },
                                      itemCount: NavigationController
                                          .controller.listFavPlace.length),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget getBodydriver() {
    List<Widget> pages = [
      Messages(),
      EarningScreen(),
      HistoryScreen(),
      HomePage(),
      Center(
          child: Container(
        child: RaisedButton(
          onPressed: () async {
            await AuthController.controller.logout();
          },
          child: Text("Logout"),
        ),
      )),
      MapScreen(),
    ];
    return Obx(
      () => IndexedStack(
        index: NavigationController.controller.currentIndex.value,
        children: pages,
      ),
    );
  }

  Widget getBodyclient() {
    List<Widget> pages = [
      HomePage(),
      MapScreen(),
      DriverList(),
      HistoryScreen(),
      Center(
          child: Container(
        child: Column(
          children: [
            RaisedButton(
              onPressed: () async {
                await AuthController.controller.logout();
              },
              child: Text("Logout"),
            ),
            RaisedButton(
              onPressed: () async {
                // var result = await SC_Controller.controller.readContract(
                //     SC_Controller.controller.getBalanceAmount, []);
                // Get.to(RideScreen());
                Get.to(() => RideScreen());
                // print(
                //     "THIS IS THE RESULT OF SMART CONTRACT ${result.first.toString()}");
              },
              child: Text("TEST SMARTCONTRACT"),
            ),
            RaisedButton(
              onPressed: () async {
                await SC_Controller.controller.writeContract(
                    SC_Controller.controller.requestRide, [
                  BigInt.from(11),
                  "test",
                  "test",
                  "test",
                  "test",
                  BigInt.from(50)
                ]);
              },
              child: Text("THIS IS SECOND TEST"),
            ),
            RaisedButton(
              onPressed: () async {
                var result = await SC_Controller.controller.readContract(
                    SC_Controller.controller.getRideAddress, [BigInt.from(5)]);
                print(
                    "THIS IS THE test OF SMART CONTRACT ${result.first.toString()}");
              },
              child: Text("THIS IS SECOND TEST"),
            )
          ],
        ),
      )),
    ];
    return Obx(
      () => IndexedStack(
        index: NavigationController.controller.currentIndex.value,
        children: pages,
      ),
    );
  }

  Widget _buildBottomBarClient() {
    return Obx(() => CustomAnimatedBottomBar(
          containerHeight: 70,
          backgroundColor: Colors.white,
          selectedIndex: NavigationController.controller.currentIndex.value,
          showElevation: true,
          itemCornerRadius: 24,
          curve: Curves.easeIn,
          onItemSelected: (index) =>
              NavigationController.controller.currentIndex.value = index,
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              icon: Icon(Icons.local_taxi),
              title: Text('Home'),
              activeColor: Colors.blue,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.info),
              title: Text('Trip Info'),
              activeColor: Colors.blue,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.people),
              title: Text(
                'Drivers Nearby',
              ),
              activeColor: Colors.blue,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.history),
              title: Text('History'),
              activeColor: Colors.blue,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }

  Widget _buildBottomBarDriver() {
    return Obx(() => CustomAnimatedBottomBar(
          containerHeight: 70,
          backgroundColor: Colors.white,
          selectedIndex: NavigationController.controller.currentIndex.value,
          showElevation: true,
          itemCornerRadius: 24,
          curve: Curves.easeIn,
          onItemSelected: (index) =>
              NavigationController.controller.currentIndex.value = index,
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              icon: Icon(Icons.map_sharp),
              title: Text('Home'),
              activeColor: Colors.blue,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.monetization_on),
              title: Text('Earnings'),
              activeColor: Colors.blue,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.history),
              title: Text(
                'History',
              ),
              activeColor: Colors.blue,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile'),
              activeColor: Colors.blue,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
          bottomNavigationBar: AuthController.controller.role.value == "client"
              ? _buildBottomBarClient()
              : _buildBottomBarDriver(),
          body: AuthController.controller.role.value == "client"
              ? getBodyclient()
              : getBodydriver()),
    );
  }
}
