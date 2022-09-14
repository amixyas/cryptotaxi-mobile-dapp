import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/ride_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/view/qr_code_Screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:one_context/one_context.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as Loc;
import 'package:web3dart/credentials.dart';

import '../controller/SC_controller.dart';
import '../controller/driver_controller.dart';
import '../controller/navigation_controller.dart';
import '../controller/wallet_controller.dart';

class RideScreen extends StatefulWidget {
  RideScreen({Key? key}) : super(key: key);

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  final LatLng _center = const LatLng(45.521563, -122.677433);
  RxInt timeOut = 10000.obs;
  StreamSubscription? liveLocationRide;
  Loc.Location location = Loc.Location();
  bool loading = false;
  bool loadingCancel = false;
  Timer? cancelTimer;
  var canCancel = false;

  void getLocationLiveUpdate() async {
    bool _serviceEnabled;
    Loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Get.rawSnackbar(
            message: "GPS is off. Please turn on the GPS",
            borderRadius: 20,
            margin: EdgeInsets.all(5),
            backgroundColor: Colors.red);
        EasyLoading.dismiss();
        getLocationLiveUpdate();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == Loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != Loc.PermissionStatus.granted) {
        Get.rawSnackbar(
            message:
                "Location permission denied. Please grand the location permission and restard the app",
            borderRadius: 20,
            margin: EdgeInsets.all(5),
            backgroundColor: Colors.red);
        EasyLoading.dismiss();
        getLocationLiveUpdate();
        return;
      }
    }
    liveLocationRide = Geolocator.getPositionStream(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.best))
        .listen((Position position) async {
      NavigationController.controller.currentLatitude.value = position.latitude;
      NavigationController.controller.currentLongitude.value =
          position.longitude;
      print("LIVE LOCATION IS ACTIVE");

      try {
        LatLng l = LatLng(position.latitude, position.longitude);
        RideController.controller.clientRideController
            .animateCamera(CameraUpdate.newLatLng(l));
      } catch (error) {
        liveLocationRide?.cancel();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    // mapController = controller;
    RideController.controller.clientRideController = controller;
    getLocationLiveUpdate();
    // var result = await NavigationController.controller.locateposition();
    // var address = await placemarkFromCoordinates(  result.latitude, result.longitude);
    // var s = "${address[0].street ?? ""}  ${address.first.subAdministrativeArea ?? ""} ,${address[0].administrativeArea ?? ""} ";
    // NavigationController.controller.updateLocation(result.latitude, result.longitude, s);
  }

  Future<bool> backbutton() async {
    Get.rawSnackbar(
        message: "You must complete the ride first",
        borderRadius: 20,
        margin: EdgeInsets.all(5),
        backgroundColor: Colors.red);
    return false;
  }

  void getTimer() async {
    if (RideController.controller.status.value == "arrived") {
      return;
    } else {
      var r = await FirebaseDatabase.instance
          .ref()
          .child("riderequests")
          .child(RideController.controller.idRide)
          .child("driverTime")
          .get();
      var s = int.parse(r.value.toString());
      if (s < 300) {
        timeOut.value = 600;
      } else {
        timeOut.value = s * 2;
      }

      cancelTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
        if (timeOut.value == 0) {
          setState(() {
            canCancel = true;
          });
          cancelTimer?.cancel();
        } else {
          setState(() {
            timeOut.value--;
          });
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    liveLocationRide?.cancel();
    cancelTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backbutton,
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Obx(
                  () => GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        zoom: 14,
                        target: LatLng(
                            NavigationController
                                .controller.currentLatitude.value,
                            NavigationController
                                .controller.currentLongitude.value),
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      polylines: NavigationController.controller.polylines,
                      markers: RideController.controller.markers,
                      onMapCreated: _onMapCreated),
                ),
                // Positioned(
                //     bottom: 50,
                //     right: 50,
                //     child: FloatingActionButton(onPressed: () async {},child: Icon(Icons.location_searching_sharp),))

                Obx(() => Positioned(
                      child: ShowUpAnimation(
                        delayStart: Duration(seconds: 0),
                        animationDuration: Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                        direction: Direction.vertical,
                        offset: 0.5,
                        child: SlidingUpPanel(
                          defaultPanelState: PanelState.OPEN,
                          minHeight: MediaQuery.of(context).size.height * 0.10,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                          ),
                          color: Colors.white,
                          maxHeight: MediaQuery.of(context).size.height * 0.53,
                          panel: Container(
                              padding: EdgeInsets.all(16),
                              height: MediaQuery.of(context).size.height * 0.53,
                              width: MediaQuery.of(context).size.width,
                              child: RideController.controller.isCompleted.value
                                  ? ShowUpAnimation(
                                      delayStart: Duration(seconds: 0),
                                      animationDuration: Duration(seconds: 1),
                                      curve: Curves.decelerate,
                                      direction: Direction.vertical,
                                      offset: 0.5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ShowUpAnimation(
                                            delayStart: Duration(seconds: 0),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            curve: Curves.decelerate,
                                            direction: Direction.vertical,
                                            offset: 0.5,
                                            child: Text(
                                              "How was your trip with ${RideController.controller.driver.name}?",
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textcolor),
                                            ),
                                          ),
                                          ShowUpAnimation(
                                            delayStart:
                                                Duration(milliseconds: 200),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            curve: Curves.decelerate,
                                            direction: Direction.vertical,
                                            offset: 0.5,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              child: Image.network(
                                                RideController.controller.driver
                                                    .profileImage!,
                                                fit: BoxFit.fill,
                                                height: 70,
                                                width: 70,
                                              ),
                                            ),
                                          ),
                                          ShowUpAnimation(
                                            delayStart:
                                                Duration(milliseconds: 400),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            curve: Curves.decelerate,
                                            direction: Direction.vertical,
                                            offset: 0.5,
                                            child: Text(
                                              "Rate the trip!",
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textcolor),
                                            ),
                                          ),
                                          ShowUpAnimation(
                                            delayStart:
                                                Duration(milliseconds: 600),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            curve: Curves.decelerate,
                                            direction: Direction.vertical,
                                            offset: 0.5,
                                            child: RatingBar.builder(
                                              initialRating: 3,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemPadding: EdgeInsets.symmetric(
                                                  horizontal: 4.0),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.lightBlue,
                                              ),
                                              onRatingUpdate: (rating) {
                                                print(rating);
                                                RideController
                                                    .controller.rating = rating;
                                              },
                                            ),
                                          ),
                                          ShowUpAnimation(
                                            delayStart:
                                                Duration(milliseconds: 800),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            curve: Curves.decelerate,
                                            direction: Direction.vertical,
                                            offset: 0.5,
                                            child: Container(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxHeight: OneContext()
                                                            .mediaQuery
                                                            .size
                                                            .height *
                                                        0.15),
                                                child: TextField(
                                                  controller: RideController
                                                      .controller.review,
                                                  maxLines: null,
                                                  minLines: 3,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(16),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      hintText:
                                                          "Leave review for ${RideController.controller.driver.name}",
                                                      hintStyle: TextStyle(
                                                          color: textcolor)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ShowUpAnimation(
                                            delayStart: Duration(seconds: 1),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            curve: Curves.decelerate,
                                            direction: Direction.vertical,
                                            offset: 0.5,
                                            child: loading
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : ElevatedButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      liveLocationRide
                                                          ?.cancel();
                                                      await FirebaseDatabase
                                                          .instance
                                                          .ref()
                                                          .child("riderequests")
                                                          .child(RideController
                                                              .controller
                                                              .idRide)
                                                          .child(
                                                              "clientComment")
                                                          .set(RideController
                                                              .controller
                                                              .review
                                                              .text
                                                              .trim());
                                                      await RideController
                                                          .controller
                                                          .endRide();
                                                      Get.back(
                                                          closeOverlays: true);
                                                    },
                                                    child: Container(
                                                      width: OneContext()
                                                              .mediaQuery
                                                              .size
                                                              .width *
                                                          0.5,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Center(
                                                          child: Text(
                                                        "Submit",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      )),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                        primary:
                                                            Colors.blueAccent),
                                                  ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        RideController
                                                    .controller.status.value ==
                                                "arrived"
                                            ? ShowUpAnimation(
                                                delayStart:
                                                    Duration(seconds: 0),
                                                animationDuration:
                                                    Duration(seconds: 1),
                                                curve: Curves.decelerate,
                                                direction: Direction.vertical,
                                                offset: 0.5,
                                                child: Text(
                                                  "Going to destination ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textcolor,
                                                      fontSize: 20),
                                                ),
                                              )
                                            : ShowUpAnimation(
                                                delayStart:
                                                    Duration(milliseconds: 500),
                                                animationDuration:
                                                    Duration(seconds: 1),
                                                curve: Curves.decelerate,
                                                direction: Direction.vertical,
                                                offset: 0.5,
                                                child: Text(
                                                  "Driver is on his way ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textcolor,
                                                      fontSize: 20),
                                                ),
                                              ),
                                        RideController
                                                    .controller.status.value ==
                                                "arrived"
                                            ? ShowUpAnimation(
                                                delayStart:
                                                    Duration(seconds: 0),
                                                animationDuration:
                                                    Duration(seconds: 1),
                                                curve: Curves.decelerate,
                                                direction: Direction.vertical,
                                                offset: 0.5,
                                                child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Arriving to destination in: ${RideController.controller.remainingTime.value}",
                                                      style: TextStyle(
                                                          color: textcolor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                              )
                                            : ShowUpAnimation(
                                                delayStart:
                                                    Duration(milliseconds: 600),
                                                animationDuration:
                                                    Duration(seconds: 1),
                                                curve: Curves.decelerate,
                                                direction: Direction.vertical,
                                                offset: 0.5,
                                                child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Driver will arrive in: ${RideController.controller.remainingTime.value}",
                                                      style: TextStyle(
                                                          color: textcolor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                              ),
                                        Align(
                                            alignment: Alignment.center,
                                            child: ShowUpAnimation(
                                              delayStart:
                                                  Duration(milliseconds: 700),
                                              animationDuration:
                                                  Duration(seconds: 1),
                                              curve: Curves.decelerate,
                                              direction: Direction.vertical,
                                              offset: 0.5,
                                              child: Text(
                                                "Remaining Distance: ${RideController.controller.remainingDistance.value}",
                                                style: TextStyle(
                                                    color: textcolor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )),
                                        ShowUpAnimation(
                                          delayStart:
                                              Duration(milliseconds: 800),
                                          animationDuration:
                                              Duration(seconds: 1),
                                          curve: Curves.decelerate,
                                          direction: Direction.vertical,
                                          offset: 0.5,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Strict Mode",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: textcolor),
                                              ),
                                              SizedBox(
                                                height: 25,
                                                child: Switch(
                                                    value: RideController
                                                        .controller
                                                        .strictMode
                                                        .value,
                                                    onChanged: (value) {
                                                      RideController
                                                          .controller
                                                          .strictMode
                                                          .value = value;
                                                      FirebaseDatabase.instance
                                                          .ref()
                                                          .child("riderequests")
                                                          .child(RideController
                                                              .controller
                                                              .idRide)
                                                          .child("strictMode")
                                                          .set(value);
                                                    }),
                                              )
                                            ],
                                          ),
                                        ),
                                        ShowUpAnimation(
                                          delayStart:
                                              Duration(milliseconds: 850),
                                          animationDuration:
                                              Duration(seconds: 1),
                                          curve: Curves.decelerate,
                                          direction: Direction.vertical,
                                          offset: 0.5,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Live Location",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: textcolor),
                                              ),
                                              SizedBox(
                                                height: 25,
                                                child: Switch(
                                                    value: RideController
                                                        .controller
                                                        .liveLocation
                                                        .value,
                                                    onChanged: (value) {
                                                      RideController
                                                          .controller
                                                          .liveLocation
                                                          .value = value;
                                                      if (value) {
                                                        liveLocationRide
                                                            ?.resume();
                                                      } else {
                                                        liveLocationRide
                                                            ?.pause();
                                                      }
                                                    }),
                                              )
                                            ],
                                          ),
                                        ),
                                        ShowUpAnimation(
                                          delayStart:
                                              Duration(milliseconds: 900),
                                          animationDuration:
                                              Duration(seconds: 1),
                                          curve: Curves.decelerate,
                                          direction: Direction.vertical,
                                          offset: 0.5,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            elevation: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Image.network(
                                                      RideController.controller
                                                          .driver.profileImage!,
                                                      fit: BoxFit.fill,
                                                      height: 50,
                                                      width: 50,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(2),
                                                    height: 50,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${RideController.controller.driver.name}",
                                                          style: TextStyle(
                                                              color: textcolor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Rating: ${RideController.controller.driver.rating!.toStringAsFixed(2)}",
                                                              style: TextStyle(
                                                                  color:
                                                                      textcolor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Icon(
                                                              FontAwesomeIcons
                                                                  .solidStar,
                                                              size: 15,
                                                              color:
                                                                  Colors.orange,
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        primary: Colors.black87,
                                                      ),
                                                      onPressed: () {
                                                        launch(
                                                            "tel:${RideController.controller.driver.phone}");
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            // Text(
                                                            //   "Call",
                                                            //   style: TextStyle(
                                                            //       fontWeight:
                                                            //           FontWeight.bold,
                                                            //       ),
                                                            // ),
                                                            // SizedBox(
                                                            //   width: 5,
                                                            // ),
                                                            Icon(
                                                              FontAwesomeIcons
                                                                  .phone,
                                                              size: 18,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Divider(
                                        //   color: Colors.black,
                                        //   thickness: 1,
                                        // ),
                                        ShowUpAnimation(
                                          delayStart: Duration(seconds: 1),
                                          animationDuration:
                                              Duration(seconds: 1),
                                          curve: Curves.decelerate,
                                          direction: Direction.vertical,
                                          offset: 0.5,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            elevation: 10,
                                            child: Container(
                                              padding: EdgeInsets.all(10),

                                              // height: 10,
                                              // width: double.infinity,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "Estimated Time:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: textcolor,
                                                            fontSize: 16),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        NavigationController
                                                            .controller
                                                            .duration
                                                            .value,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.green,
                                                            fontSize: 16),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "Total Distance:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: textcolor,
                                                            fontSize: 16),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        NavigationController
                                                            .controller
                                                            .distance
                                                            .value,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.red,
                                                            fontSize: 16),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        ShowUpAnimation(
                                          delayStart: Duration(
                                              seconds: 1, milliseconds: 100),
                                          animationDuration:
                                              Duration(seconds: 1),
                                          curve: Curves.decelerate,
                                          direction: Direction.vertical,
                                          offset: 0.5,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  primary: Colors.blue),
                                              onPressed: () async {
                                                var res = await showDialog(
                                                    useRootNavigator: false,
                                                    context: context,
                                                    barrierColor:
                                                        Color.fromRGBO(
                                                            0, 0, 0, 0.8),
                                                    builder: (_) {
                                                      return Dialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                        elevation: 10,
                                                        child: ShowUpAnimation(
                                                          delayStart: Duration(
                                                              seconds: 0),
                                                          animationDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          curve:
                                                              Curves.decelerate,
                                                          direction: Direction
                                                              .vertical,
                                                          offset: 0.5,
                                                          child: Container(
                                                            height: OneContext()
                                                                    .mediaQuery
                                                                    .size
                                                                    .height *
                                                                0.7,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16),
                                                            child:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  ShowUpAnimation(
                                                                    delayStart:
                                                                        Duration(
                                                                            seconds:
                                                                                0),
                                                                    animationDuration:
                                                                        Duration(
                                                                            seconds:
                                                                                1),
                                                                    curve: Curves
                                                                        .decelerate,
                                                                    direction:
                                                                        Direction
                                                                            .vertical,
                                                                    offset: 0.5,
                                                                    child:
                                                                        QrImage(
                                                                      data: RideController
                                                                          .controller
                                                                          .rideKey
                                                                          .value,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 50,
                                                                  ),
                                                                  ShowUpAnimation(
                                                                    delayStart: Duration(
                                                                        milliseconds:
                                                                            200),
                                                                    animationDuration:
                                                                        Duration(
                                                                            seconds:
                                                                                1),
                                                                    curve: Curves
                                                                        .decelerate,
                                                                    direction:
                                                                        Direction
                                                                            .vertical,
                                                                    offset: 0.5,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "Let the driver scan the QR code",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            textcolor,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  ShowUpAnimation(
                                                                    delayStart: Duration(
                                                                        milliseconds:
                                                                            400),
                                                                    animationDuration:
                                                                        Duration(
                                                                            seconds:
                                                                                1),
                                                                    curve: Curves
                                                                        .decelerate,
                                                                    direction:
                                                                        Direction
                                                                            .vertical,
                                                                    offset: 0.5,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "Click the Ride Completed button when the driver end the ride",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            textcolor,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  ShowUpAnimation(
                                                                    delayStart: Duration(
                                                                        milliseconds:
                                                                            600),
                                                                    animationDuration:
                                                                        Duration(
                                                                            seconds:
                                                                                1),
                                                                    curve: Curves
                                                                        .decelerate,
                                                                    direction:
                                                                        Direction
                                                                            .vertical,
                                                                    offset: 0.5,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), primary: Colors.lightBlueAccent),
                                                                          onPressed: () {
                                                                            if (RideController.controller.status ==
                                                                                "ended") {
                                                                              Get.back(closeOverlays: true);
                                                                              RideController.controller.isCompleted.value = true;
                                                                            } else {
                                                                              Get.rawSnackbar(message: "Driver didn\'t finish the ride yet", borderRadius: 20, margin: EdgeInsets.all(5), backgroundColor: Colors.red);
                                                                            }
                                                                          },
                                                                          child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              "Ride Completed",
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: textcolor,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                print(
                                                    "result from qr code is $res");
                                              },
                                              child: Container(
                                                width: OneContext()
                                                        .mediaQuery
                                                        .size
                                                        .width *
                                                    0.8,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: const [
                                                    Text(
                                                      "Driver Arrived",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Icon(FontAwesomeIcons
                                                        .flagCheckered)
                                                  ],
                                                ),
                                              )),
                                        ),
                                        RideController
                                                    .controller.status.value ==
                                                "accepted"
                                            ? canCancel
                                                ? loadingCancel ? CircularProgressIndicator(
                                          color: Colors.blue,
                                        ): ShowUpAnimation(
                                                    delayStart: Duration(
                                                      seconds: 0,
                                                    ),
                                                    animationDuration:
                                                        Duration(seconds: 1),
                                                    curve: Curves.decelerate,
                                                    direction:
                                                        Direction.vertical,
                                                    offset: 0.5,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30)),
                                                            primary:
                                                                Colors.red),
                                                        onPressed: () async {

                                                          if (await confirm(OneContext().context!)) {
                                                             setState(() {
                                                               loadingCancel=true;
                                                             });
                                                            await AuthController
                                                                .controller
                                                                .database
                                                                .ref()
                                                                .child("users")
                                                                .child(AuthController
                                                                .controller
                                                                .auth!
                                                                .currentUser!
                                                                .uid)
                                                                .child("history")
                                                                .child(
                                                                RideController
                                                                    .controller
                                                                    .idRide)
                                                                .remove();
                                                            await AuthController
                                                                .controller
                                                                .database
                                                                .ref()
                                                                .child("users")
                                                                .child(AuthController
                                                                .controller
                                                                .auth!
                                                                .currentUser!
                                                                .uid)
                                                                .child(
                                                                "currentRide")
                                                                .set("none");
                                                            NavigationController
                                                                .controller.circls
                                                                .clear();
                                                            NavigationController
                                                                .controller
                                                                .polylines
                                                                .clear();
                                                            NavigationController
                                                                .controller
                                                                .markers
                                                                .clear();
                                                            NavigationController
                                                                .controller
                                                                .polylinescordinates = [];
                                                            NavigationController
                                                                .controller
                                                                .dropOffAddress
                                                                .value =
                                                            "Search your destination";
                                                            NavigationController
                                                                .controller
                                                                .dropOffLatitude
                                                                .value = 0.0;
                                                            NavigationController
                                                                .controller
                                                                .dropOffLongitude
                                                                .value = 0.0;
                                                            NavigationController
                                                                .controller
                                                                .currentIndex
                                                                .value = 0;
                                                            NavigationController
                                                                .controller
                                                                .distance
                                                                .value = "";
                                                            NavigationController
                                                                .controller
                                                                .duration
                                                                .value = "";
                                                            Get.back(
                                                                closeOverlays:
                                                                true);
                                                            late String ss;
                                                            await FirebaseDatabase
                                                                .instance
                                                                .ref()
                                                                .child(
                                                                "riderequests")
                                                                .child(
                                                                RideController
                                                                    .controller
                                                                    .idRide)
                                                                .child("status")
                                                                .set("canceled");
                                                            double n =
                                                            (NavigationController
                                                                .controller
                                                                .ETHCost
                                                                .toDouble() *
                                                                1.10);
                                                            try {
                                                              ss = await SC_Controller
                                                                  .controller
                                                                  .writeContract(
                                                                  SC_Controller
                                                                      .controller
                                                                      .refund,
                                                                  [
                                                                    EthereumAddress.fromHex(
                                                                        WalletController
                                                                            .controller
                                                                            .account
                                                                            .value),
                                                                    BigInt.from(n
                                                                        .truncate())
                                                                  ]);
                                                              print(ss);
                                                              Get.rawSnackbar(
                                                                  message: "Ride Canceled you have been refunded + the driver confirmation!",
                                                                  borderRadius: 20,
                                                                  margin: EdgeInsets.all(5),
                                                                  backgroundColor: Colors.red);
                                                            } catch (error) {
                                                              print(
                                                                  'ERRRRRRRRRRRRRRRRRRRRRRRRRRRROR');
                                                              Get.defaultDialog(
                                                                  title:
                                                                  "CRITICAL ERROR OCCURED",
                                                                  middleText:
                                                                  "TX: $ss Take screenshot and submit a ticket to admin ! \n After take screenshot restart the application");
                                                            }
                                                             RideController.controller.rideRequestRef.onDisconnect();
                                                             RideController.controller.rideRequestRef =
                                                                 FirebaseDatabase.instance.ref().child("riderequests").push();
                                                             NavigationController.controller.cancelRide();
                                                            return print('pressedOK');
                                                          }
                                                          return print('pressedCancel');

                                                        },
                                                        child: Container(
                                                          width: OneContext()
                                                                  .mediaQuery
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: const [
                                                              Text(
                                                                "Cancel the ride ",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Icon(
                                                                  FontAwesomeIcons
                                                                      .x)
                                                            ],
                                                          ),
                                                        )),
                                                  )
                                                : ShowUpAnimation(
                                                    delayStart: Duration(
                                                      seconds: 0,
                                                    ),
                                                    animationDuration: Duration(
                                                        seconds: 1,
                                                        milliseconds: 200),
                                                    curve: Curves.decelerate,
                                                    direction:
                                                        Direction.vertical,
                                                    offset: 0.5,
                                                    child: Text(
                                                      "You can cancel the ride if the driver didn't come in ${Duration(seconds: timeOut.value).inMinutes} Minutes",
                                                      style: TextStyle(
                                                          color: textcolor),
                                                    ),
                                                  )
                                            : SizedBox()
                                      ],
                                    )),
                        ),
                      ),
                    )),
                Positioned(
                  top: 10,
                  child: Obx(() => ShowUpAnimation(
                        delayStart: Duration(seconds: 1, milliseconds: 300),
                        animationDuration: Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                        direction: Direction.vertical,
                        offset: 0.5,
                        child: SizedBox(
                          // height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: RideController.controller.isCompleted.value
                                ? Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    elevation: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 800),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Obx(
                                              () => Row(
                                                children: [
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: AutoSizeText(
                                                        "Do you want to add this location to favorite ?",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: textcolor,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                      onPressed: () {
                                                        print(RideController
                                                            .controller
                                                            .addFav
                                                            .value);
                                                        RideController
                                                                .controller
                                                                .addFav
                                                                .value =
                                                            !RideController
                                                                .controller
                                                                .addFav
                                                                .value;
                                                        print(RideController
                                                            .controller
                                                            .addFav
                                                            .value);
                                                      },
                                                      icon: RideController
                                                              .controller
                                                              .addFav
                                                              .value
                                                          ? Icon(
                                                              FontAwesomeIcons
                                                                  .arrowUp,
                                                              size: 20,
                                                            )
                                                          : Icon(
                                                              FontAwesomeIcons
                                                                  .arrowDown,
                                                              size: 20,
                                                            ))
                                                ],
                                              ),
                                            ),
                                            if (RideController
                                                .controller.addFav.value)
                                              ListTile(
                                                style: ListTileStyle.drawer,
                                                tileColor: Colors.black12,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                dense: true,
                                                leading: Icon(
                                                  FontAwesomeIcons
                                                      .locationCrosshairs,
                                                  color: Colors.blue,
                                                ),
                                                title: AutoSizeText(
                                                  NavigationController
                                                      .controller
                                                      .dropOffAddress
                                                      .value,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: textcolor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            if (RideController
                                                .controller.addFav.value)
                                              SizedBox(
                                                height: 8,
                                              ),
                                            if (RideController
                                                .controller.addFav.value)
                                              TextField(
                                                controller: RideController
                                                    .controller.name,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "Enter name of this address ex:Home",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    isDense: true,
                                                    hintStyle: TextStyle(
                                                        color: textcolor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)),
                                              ),
                                            if (RideController
                                                .controller.addFav.value)
                                              SizedBox(
                                                height: 8,
                                              ),
                                            if (RideController
                                                .controller.addFav.value)
                                              ElevatedButton(
                                                onPressed: () async {
                                                  if (RideController.controller
                                                          .name.text ==
                                                      "")
                                                    RideController.controller
                                                            .name.text =
                                                        "Favorite Place";
                                                  var map = {
                                                    'address':
                                                        NavigationController
                                                            .controller
                                                            .dropOffAddress
                                                            .value,
                                                    'lat': NavigationController
                                                        .controller
                                                        .dropOffLatitude
                                                        .value,
                                                    'lng': NavigationController
                                                        .controller
                                                        .dropOffLongitude
                                                        .value,
                                                    'name': RideController
                                                        .controller.name.text
                                                        .trim()
                                                  };
                                                  await RideController
                                                      .controller.favorite
                                                      ?.update(map);
                                                  Get.rawSnackbar(
                                                      message:
                                                          "Place successfully added to favorite",
                                                      borderRadius: 20,
                                                      margin: EdgeInsets.all(5),
                                                      backgroundColor:
                                                          Colors.green);
                                                  RideController.controller
                                                      .addFav.value = false;
                                                },
                                                child: Container(
                                                  // width: OneContext()
                                                  //         .mediaQuery
                                                  //         .size
                                                  //         .width *
                                                  //     0.5,
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Center(
                                                      child: Text(
                                                    "Add to favorite",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  )),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                    primary: Colors.blueAccent),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : ShowUpAnimation(
                                    offset: 0.5,
                                    direction: Direction.vertical,
                                    delayStart: Duration(seconds: 0),
                                    curve: Curves.decelerate,
                                    animationDuration: Duration(seconds: 1),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      elevation: 10,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            leading: Icon(
                                              FontAwesomeIcons
                                                  .locationCrosshairs,
                                              color: Colors.blue,
                                            ),
                                            dense: true,
                                            visualDensity:
                                                VisualDensity.compact,
                                            title: AutoSizeText(
                                              NavigationController.controller
                                                  .currentAddress.value,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: textcolor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Divider(
                                              color: Colors.black,
                                              thickness: 0.45,
                                              height: 0),
                                          ListTile(
                                            leading: Icon(
                                              FontAwesomeIcons.mapLocationDot,
                                              color: Colors.red,
                                            ),
                                            dense: true,
                                            visualDensity:
                                                VisualDensity.compact,
                                            title: AutoSizeText(
                                              NavigationController.controller
                                                  .dropOffAddress.value,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: textcolor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
