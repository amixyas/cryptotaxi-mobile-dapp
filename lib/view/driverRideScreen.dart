import 'dart:async';

import 'package:cryptotaxi/controller/driverRide_controller.dart';
import 'package:cryptotaxi/controller/driver_controller.dart';
import 'package:cryptotaxi/controller/navigation_controller.dart';
import 'package:cryptotaxi/view/qr_code_Screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:one_context/one_context.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as Loc;
import '../controller/SC_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/ride_controller.dart';
import '../main.dart';

class DriverRideScreen extends StatefulWidget {
  DriverRideScreen({Key? key}) : super(key: key);

  @override
  State<DriverRideScreen> createState() => _DriverRideScreenState();
}

class _DriverRideScreenState extends State<DriverRideScreen> {
  Timer? timer;
   StreamSubscription? subscription1;
  StreamSubscription? liveLocation;
  StreamSubscription? rideStatus;
  Loc.Location location = Loc.Location();
  bool loading = false;
  void getLocationLiveUpdate()async {
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
            message: "Location permission denied. Please grand the location permission and restard the app",
            borderRadius: 20,
            margin: EdgeInsets.all(5),
            backgroundColor: Colors.red);
        EasyLoading.dismiss();
        getLocationLiveUpdate();
        return;
      }
    }
    liveLocation = Geolocator.getPositionStream(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.best))
        .listen((Position position) async {
      print("LIVE LOCATION IS ACTIVE");

      try {
        LatLng l = LatLng(position.latitude, position.longitude);
        DriverController.controller.driverRideMapController.animateCamera(CameraUpdate.newLatLng(l));
      }catch (error){
        liveLocation?.cancel();
      }

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (DriverController.controller.arrived.value) {
        DriverController.controller
            .updateRemaining(DriverController.controller.ride.dropOff!);
      } else {
        DriverController.controller
            .updateRemaining(DriverController.controller.ride.pickup!);
      }


    });
    subscription1 = FirebaseDatabase.instance
        .ref()
        .child("riderequests")
        .child(DriverController.controller.ride.id)
        .child("strictMode")
        .onValue
        .listen((event) async {
      print(event.snapshot.value);
      bool b = event.snapshot.value.toString().toLowerCase() == 'true';
      DriverController.controller.strictMode.value = b;
      print("THIS IS ${DriverController.controller.strictMode.value}");
    });
    rideStatus = FirebaseDatabase.instance
        .ref()
        .child("riderequests")
        .child(DriverController.controller.ride.id)
        .child("status")
        .onValue
        .listen((event) async {
      print('test ${event.snapshot.value.toString()}');
      if(event.snapshot.value.toString()=="canceled")
      {


        await AuthController.controller.database
            .ref()
            .child("users")
            .child(AuthController
            .controller.auth!.currentUser!.uid)
            .child("history")
            .child(DriverController.controller.ride.id)
            .remove();
        await AuthController.controller.database
            .ref()
            .child("users")
            .child(AuthController
            .controller.auth!.currentUser!.uid)
            .child("currentRide")
            .set("none");
        DriverController.controller.isCompleted.value = false;
        DriverController.controller.arrived.value = false;
        DriverController.controller.distance.value = "";
        DriverController.controller.duration.value = "";
        DriverController.controller.polylinescordinates = [];
        DriverController.controller.circls.clear();
        DriverController.controller.polylines.clear();
        DriverController.controller.markers.clear();
        DriverController.controller.driverstatus.value = "";
        DriverController.controller.remainingTime.value = "";
        DriverController.controller.remainingDistance.value = "";
        DriverController.controller.pickupLatitude.value = 0.0;
        DriverController.controller.pickupLongitude.value = 0.0;
        DriverController.controller.dropOffLatitude.value = 0.0;
        DriverController.controller.dropOffLongitude.value = 0.0;
        DriverController.controller.rating=3;
        DriverController.controller.review.clear();
        NavigationController.controller.circls.clear();
        NavigationController.controller.polylines.clear();
        NavigationController.controller.markers.clear();
        NavigationController.controller.polylinescordinates=[];
        Get.back(closeOverlays: true);
        Get.rawSnackbar(
            message: "You were late to pickup the client. Ride has been canceled ",
            borderRadius: 20,
            margin: EdgeInsets.all(5),
            backgroundColor: Colors.red);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    subscription1?.cancel();
    liveLocation?.cancel();
    rideStatus?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) async {
    // mapController = controller;
    DriverController.controller.driverRideMapController = controller;
    // DriverController.controller.getPlaceDirectoin(
    //     LatLng(NavigationController.controller.currentLatitude.value,
    //         NavigationController.controller.currentLongitude.value),
    //     LatLng(DriverController.controller.pickupLatitude.value,
    //         DriverController.controller.pickupLongitude.value));
    getLocationLiveUpdate();
  }

  Future<bool> backbutton() async {
    Get.rawSnackbar(
        message: "You must complete the ride first",
        borderRadius: 20,
        margin: EdgeInsets.all(5),
        backgroundColor: Colors.red);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backbutton,
      child: SafeArea(
        child: Stack(
          children: [
            Obx(
              () => GoogleMap(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.10),
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        NavigationController.controller.currentLatitude.value,
                        NavigationController.controller.currentLongitude.value),
                    zoom: 14.4746,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  polylines: DriverController.controller.polylines.value,
                  markers: DriverController.controller.markers.value,
                  circles: DriverController.controller.circls.value,
                  onMapCreated: _onMapCreated),
            ),
            Obx(() => Positioned(
                  child: ShowUpAnimation(
                    delayStart: Duration(seconds: 0),
                    animationDuration: Duration(seconds: 1),
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
                      maxHeight: MediaQuery.of(context).size.height * 0.50,
                      panel: Container(
                          padding: EdgeInsets.all(16),
                          height: MediaQuery.of(context).size.height * 0.50,
                          width: MediaQuery.of(context).size.width,
                          child: DriverController.controller.isCompleted.value
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
                                        delayStart: Duration( milliseconds: 200),
                                        animationDuration: Duration(seconds: 1),
                                        curve: Curves.decelerate,
                                        direction: Direction.vertical,
                                        offset: 0.5,
                                        child: Text(
                                          "How was your trip with ${DriverController.controller.ride.client?.fullname}?",
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textcolor),
                                        ),
                                      ),
                                      ShowUpAnimation(
                                        delayStart: Duration( milliseconds: 400),
                                        animationDuration: Duration(seconds: 1),
                                        curve: Curves.decelerate,
                                        direction: Direction.vertical,
                                        offset: 0.5,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(80),
                                          child: Image.network(
                                            DriverController.controller.ride.client!.profileImage!,
                                            fit: BoxFit.fill,
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                      ),
                                      ShowUpAnimation(
                                        delayStart: Duration( milliseconds: 600),
                                        animationDuration: Duration(seconds: 1),
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
                                      ShowUpAnimation(delayStart: Duration( milliseconds: 800),
                                        animationDuration: Duration(seconds: 1),
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
                                            DriverController.controller.rating =
                                                rating;
                                          },
                                        ),
                                      ),
                                      ShowUpAnimation(delayStart: Duration( seconds: 1),
                                        animationDuration: Duration(seconds: 1),
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
                                              controller: DriverController
                                                  .controller.review,
                                              maxLines: null,
                                              minLines: 3,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(16),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                  hintText:
                                                      "Leave review for ${DriverController.controller.ride.client?.fullname}",
                                                  hintStyle: TextStyle(
                                                      color: textcolor)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ShowUpAnimation(delayStart: Duration( seconds: 1,milliseconds: 200),
                                        animationDuration: Duration(seconds: 1),
                                        curve: Curves.decelerate,
                                        direction: Direction.vertical,
                                        offset: 0.5,
                                        child:  loading
                                            ? Center(
                                          child:
                                          CircularProgressIndicator(),
                                        )
                                            : ElevatedButton(
                                          onPressed: () async {
                                            setState(() {
                                              loading=true;
                                            });
                                            EasyLoading.show(
                                                dismissOnTap: false,
                                                status:
                                                    "Ending ride. Please wait");
                                            liveLocation!.cancel();
                                            subscription1!.cancel();
                                            await FirebaseDatabase.instance
                                                .ref()
                                                .child("riderequests")
                                                .child(DriverController
                                                    .controller.ride.id)
                                                .child("clientComment")
                                                .set(RideController
                                                    .controller.review.text
                                                    .trim());
                                            await DriverController.controller
                                                .endRide();
                                           var tx =  await SC_Controller.controller
                                                .writeContract(
                                                    SC_Controller.controller
                                                        .passengerArrivation,
                                                    [
                                                  DriverController
                                                      .controller.ride.id
                                                ]);
                                           print("THIS IS TX : $tx");
                                            Get.back(closeOverlays: true);
                                            EasyLoading.dismiss();
                                          },
                                          child: Container(
                                            width: OneContext()
                                                    .mediaQuery
                                                    .size
                                                    .width *
                                                0.5,
                                            padding: const EdgeInsets.all(10.0),
                                            child: Center(
                                                child: Text(
                                              "Submit",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            )),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30)),
                                              primary: Colors.blueAccent),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    DriverController.controller.arrived.value
                                        ? ShowUpAnimation(
                                      delayStart: Duration( seconds: 0),
                                      animationDuration: Duration(seconds: 1),
                                      curve: Curves.decelerate,
                                      direction: Direction.vertical,
                                      offset: 0.5,
                                          child: Text(
                                              "Go to the destination ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textcolor,
                                                  fontSize: 20),
                                            ),
                                        )
                                        : ShowUpAnimation(
                                            delayStart:
                                                Duration(milliseconds: 300),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            curve: Curves.decelerate,
                                            direction: Direction.vertical,
                                            offset: 0.5,
                                            child: Text(
                                              "Go to pickup the client ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textcolor,
                                                  fontSize: 20),
                                            ),
                                          ),
                                    ShowUpAnimation(
                                      delayStart: Duration(milliseconds: 500),
                                      animationDuration: Duration(seconds: 1),
                                      curve: Curves.decelerate,
                                      direction: Direction.vertical,
                                      offset: 0.5,
                                      child: Text(
                                        "You will arrive in :${DriverController.controller.remainingTime.value}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textcolor),
                                      ),
                                    ),
                                    ShowUpAnimation(
                                      delayStart: Duration(milliseconds: 700),
                                      animationDuration: Duration(seconds: 1),
                                      curve: Curves.decelerate,
                                      direction: Direction.vertical,
                                      offset: 0.5,
                                      child: Text(
                                        "Remaining Distance: ${DriverController.controller.remainingDistance.value}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textcolor),
                                      ),
                                    ),
                                    Obx(
                                      () => ShowUpAnimation(
                                        delayStart: Duration(milliseconds: 900),
                                        animationDuration: Duration(seconds: 1),
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
                                                  inactiveThumbColor: Colors.blue,
                                                  value: DriverController
                                                      .controller
                                                      .strictMode
                                                      .value,
                                                  onChanged: null),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    ShowUpAnimation(
                                      delayStart:
                                      Duration(milliseconds: 1000),
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
                                                value: DriverController
                                                    .controller
                                                    .liveLocation
                                                    .value,
                                                onChanged: (value) {
                                                  DriverController
                                                      .controller
                                                      .liveLocation
                                                      .value = value;
                                                  if (value) {
                                                    liveLocation
                                                        ?.resume();
                                                  } else {
                                                    liveLocation?.pause();
                                                  }
                                                }),
                                          )
                                        ],
                                      ),
                                    ),
                                    ShowUpAnimation(
                                      delayStart: Duration(milliseconds: 1100),
                                      animationDuration: Duration(seconds: 1),
                                      curve: Curves.decelerate,
                                      direction: Direction.vertical,
                                      offset: 0.5,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: Image.network(
                                                    DriverController.controller.ride.client!.profileImage!,
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
                                                        "${DriverController.controller.ride.client!.fullname}",
                                                        style: TextStyle(
                                                            color: textcolor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Rating: ${DriverController.controller.ride.client!.rating!.toStringAsFixed(2)}",
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
                                                    style: ElevatedButton.styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        primary:
                                                            Colors.black87),
                                                    onPressed: () {
                                                      launch(
                                                          "tel:${DriverController.controller.ride.client!.phone}");
                                                    },
                                                    child: Container(
                                                      height: 40,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10),
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
                                                          //       fontSize: 18),
                                                          // ),
                                                          // SizedBox(
                                                          //   width: 10,
                                                          // ),
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .phone,
                                                            color: Colors.green,
                                                            size: 18,
                                                          )
                                                        ],
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.black,
                                      thickness: 1,
                                    ),
                                    ShowUpAnimation(
                                      delayStart: Duration(milliseconds: 1300),
                                      animationDuration: Duration(seconds: 1),
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
                                                MainAxisAlignment.spaceEvenly,
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
                                                    DriverController.controller
                                                        .duration.value,
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
                                                    DriverController.controller
                                                        .distance.value,
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
                                    (DriverController
                                                .controller.arrived.value ==
                                            true)
                                        ? ShowUpAnimation(
                                      delayStart: Duration( seconds: 0),
                                      animationDuration: Duration(seconds: 1),
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
                                                //to do Implement Condition if the DRiver Reached the destination
                                                if (DriverController.controller
                                                    .strictMode.value) {
                                                  var g = await Geolocator
                                                      .getCurrentPosition(
                                                          desiredAccuracy:
                                                              LocationAccuracy
                                                                  .best);
                                                  var distance =
                                                      Geolocator.distanceBetween(
                                                          g.latitude,
                                                          g.longitude,
                                                          DriverController
                                                              .controller
                                                              .dropOffLatitude
                                                              .value,
                                                          DriverController
                                                              .controller
                                                              .dropOffLongitude
                                                              .value);
                                                  print("Distance is $distance");
                                                  if (distance < 2000) {
                                                    DriverController.controller
                                                        .isCompleted.value = true;
                                                    await FirebaseDatabase
                                                        .instance
                                                        .ref()
                                                        .child("riderequests")
                                                        .child(DriverController
                                                            .controller.ride.id)
                                                        .child("status")
                                                        .set("ended");
                                                  } else {
                                                    Get.rawSnackbar(
                                                        message:
                                                            "Strict mode is enable you must take the client to the final destination or ask the client to disable strict mode",
                                                        borderRadius: 20,
                                                        duration:
                                                            Duration(seconds: 4),
                                                        margin: EdgeInsets.all(5),
                                                        backgroundColor:
                                                            Colors.red);
                                                  }
                                                } else {
                                                  DriverController.controller
                                                      .isCompleted.value = true;
                                                  await FirebaseDatabase.instance
                                                      .ref()
                                                      .child("riderequests")
                                                      .child(DriverController
                                                          .controller.ride.id)
                                                      .child("status")
                                                      .set("ended");
                                                }
                                                // var res = await Get.to(QR_CodeScreen());
                                                // print("result from qr code is $res");
                                                // if (res != null) {
                                                //   DriverController.controller.isCompleted
                                                //       .value = true;
                                                // }
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
                                                  children: [
                                                    Text(
                                                      "Arrived to destination",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Icon(FontAwesomeIcons.flagCheckered)
                                                  ],
                                                ),
                                              )),
                                        )
                                        : ShowUpAnimation(
                                            delayStart:
                                                Duration(milliseconds: 1300),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            curve: Curves.decelerate,
                                            direction: Direction.vertical,
                                            offset: 0.5,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                    primary: Colors.blue),
                                                onPressed: () async {
                                                  var result = await SC_Controller.controller
                                                      .readContract(SC_Controller.controller.getRideAddress, [DriverController.controller.ride.id]);
                                                  var res = await Get.to(
                                                      QR_CodeScreen(),
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      transition: Transition
                                                          .cupertinoDialog);
                                                  print(
                                                      "result from qr code is $res");
                                                  if (res == result.first[8].toString()) {
                                                    await FirebaseDatabase
                                                        .instance
                                                        .ref()
                                                        .child("riderequests")
                                                        .child(DriverController
                                                            .controller.ride.id)
                                                        .child("status")
                                                        .set("arrived");
                                                    DriverController.controller
                                                        .arrived.value = true;
                                                    DriverController.controller.getPlaceDirectoin(
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
                                                            DriverController
                                                                .controller
                                                                .dropOffLatitude
                                                                .value,
                                                            DriverController
                                                                .controller
                                                                .dropOffLongitude
                                                                .value));
                                                  }else{
                                                    Get.rawSnackbar(
                                                        message: "Incorrect QR CODE !",
                                                        borderRadius: 20,
                                                        margin: EdgeInsets.all(5),
                                                        backgroundColor: Colors.red);
                                                  }
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
                                                    children: [
                                                      Text(
                                                        "Arrived to client",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Icon(FontAwesomeIcons
                                                          .person)
                                                    ],
                                                  ),
                                                )),
                                          )
                                  ],
                                )),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
