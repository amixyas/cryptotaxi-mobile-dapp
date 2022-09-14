import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/navigation_controller.dart';
import 'package:cryptotaxi/controller/notification_controller.dart';
import 'package:cryptotaxi/controller/rideHistory_Controller.dart';
import 'package:cryptotaxi/controller/wallet_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

import '../model/Ride.dart';
import '../model/directionDetails.dart';

class DriverController extends GetxController {
  static DriverController controller = Get.find();
  var isOnline = false.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late GoogleMapController driverRideMapController;
  late Ride ride;
  var liveLocation = true.obs;
  final geo = GeoFlutterFire();
  late SharedPreferences prefs ;
  StreamSubscription<Position>? homesteamsub;
  var pickupLatitude = 0.0.obs;
  var pickupLongitude = 0.0.obs;
  var dropOffLatitude = 0.0.obs;
  var dropOffLongitude = 0.0.obs;
  double rating = 3;
  TextEditingController review = TextEditingController();
  var isCompleted = false.obs;
  var arrived = false.obs;
  var distance = "".obs;
  var duration = "".obs;
   EtherAmount fees = EtherAmount.fromUnitAndValue(EtherUnit.ether,0);
  List<LatLng> polylinescordinates = [];
  late DirectionDetails directionDetails;
  var circls = <Circle>{}.obs;
  var polylines = <Polyline>{}.obs;
  var markers = <Marker>{}.obs;
  var driverstatus = "".obs;
  var remainingTime = "".obs;
  var remainingDistance = "".obs;
  var strictMode = false.obs;
  FirebaseDatabase database = FirebaseDatabase.instance;

  Future<void> updateRemaining(LatLng destination) async {
    Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    var details = await NavigationController.obtainPlaceDirectionDetails(
        LatLng(p.latitude, p.longitude), destination);
    remainingTime.value = details!.durationText!;
    remainingDistance.value = details.distanceText!;
    Map<String, String> map = {
      'remainingtime': remainingTime.value,
      'remainingdistance': remainingDistance.value
    };
    await database
        .ref()
        .child("riderequests")
        .child(DriverController.controller.ride.id)
        .update(map);
  }

  Future<void> getPlaceDirectoin(LatLng pickup, LatLng dropoff) async {
    // var pickuplatlng = LatLng(currentLatitude.value, currentLongitude.value);
    // var droplatlng = LatLng(dropOffLatitude.value, dropOffLongitude.value);

    EasyLoading.show(status: "Please wait ");
    var details =
        await NavigationController.obtainPlaceDirectionDetails(pickup, dropoff);

    directionDetails = details!;
    duration.value = directionDetails.durationText!;
    distance.value = directionDetails.distanceText!;
    EasyLoading.dismiss(animation: true);
    print(details.encodedPoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedpolylinepoints =
        polylinePoints.decodePolyline(details.encodedPoints!);
    polylinescordinates.clear();
    if (decodedpolylinepoints.isNotEmpty) {
      decodedpolylinepoints.forEach((PointLatLng pointLatLng) {
        polylinescordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylines.clear();
    Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("PolylineID"),
        points: polylinescordinates,
        jointType: JointType.round,
        width: 2,
        startCap: Cap.roundCap,
        endCap: Cap.squareCap,
        geodesic: true);
    polylines.add(polyline);

    LatLngBounds latlngbounds;
    List<LatLng> list = [
      LatLng(pickup.latitude, pickup.longitude),
      LatLng(dropoff.latitude, dropoff.longitude),
    ];
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    latlngbounds =
        LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));

    // if (pickuplatlng.latitude > droplatlng.latitude &&
    //     pickuplatlng.longitude > pickuplatlng.longitude) {
    //   latlngbounds =
    //       LatLngBounds(southwest: droplatlng, northeast: pickuplatlng);
    // } else if (pickuplatlng.longitude > droplatlng.longitude) {
    //   latlngbounds = LatLngBounds(
    //       southwest: LatLng(pickuplatlng.latitude, droplatlng.longitude),
    //       northeast: LatLng(droplatlng.latitude, pickuplatlng.longitude));
    // } else if (pickuplatlng.latitude > droplatlng.latitude) {
    //   latlngbounds = LatLngBounds(
    //       southwest: LatLng(droplatlng.latitude, pickuplatlng.longitude),
    //       northeast: LatLng(pickuplatlng.latitude, droplatlng.longitude));
    // } else {
    //   latlngbounds =
    //       LatLngBounds(southwest: pickuplatlng, northeast: droplatlng);
    // }

    Marker pickupMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(snippet: "My Location"),
        position: LatLng(pickupLatitude.value, pickupLongitude.value),
        markerId: MarkerId("pickUpId"));
    Marker dropOffMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(snippet: "Destination"),
        position: LatLng(dropOffLatitude.value, dropOffLongitude.value),
        markerId: MarkerId("dropOffId"));
    markers.clear();
    markers.add(pickupMarker);
    markers.add(dropOffMarker);
    print('MARKERS ${markers.length}');
    Circle pickupcircle = Circle(
        fillColor: Colors.yellow,
        center: LatLng(pickupLatitude.value, pickupLongitude.value),
        radius: 12,
        strokeColor: Colors.yellowAccent,
        strokeWidth: 4,
        circleId: CircleId("pickUpId"));
    Circle dropOffCircle = Circle(
        fillColor: Colors.green,
        center: LatLng(dropOffLatitude.value, dropOffLongitude.value),
        radius: 12,
        strokeColor: Colors.greenAccent,
        strokeWidth: 4,
        circleId: CircleId("dropOffId"));

    circls.add(pickupcircle);
    circls.add(dropOffCircle);
    controller.driverRideMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latlngbounds, 70));
  }

  Future<void> makeDriverOnlineNow() async {

     await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");
    print("testing ${NavigationController.controller.currentLatitude.value}");
    GeoFirePoint point = geo.point(
        latitude: NavigationController.controller.currentLatitude.value,
        longitude: NavigationController.controller.currentLongitude.value);
    String name = AuthController.controller.appUser!.value.fullname!;
    String address = NavigationController.controller.currentAddress.value;
    double rating = AuthController.controller.appUser!.value.rating!;
    String phone = AuthController.controller.appUser!.value.phone!;
    String token = NotificationController.controller.fcmToken;
    var img = await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("profileImg").get();
    firestore
        .collection("freeDrivers")
        .doc(AuthController.controller.auth?.currentUser!.uid)
        .set({
      'name': name,
      'token': token,
      'address': address,
      'rating': rating,
      'phone': phone,
      'car':AuthController.controller.appUser?.value.car,
      'totalRides':AuthController.controller.appUser?.value.totalRides,
      'position': point.data,
      'profileImage':img.value.toString()
    });
    // Geofire.initialize("freeDrivers");
    // Geofire.setLocation(_firebaseAuth.currentUser.uid, currentpoisition.latitude, currentpoisition.longitude);
  }

  void getLocationLiveUpdate()async {
    await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("available");

    homesteamsub = Geolocator.getPositionStream(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.best))
        .listen((Position position) async {
      NavigationController.controller.currentLatitude.value = position.latitude;
      NavigationController.controller.currentLongitude.value =
          position.longitude;
      print("Getting location");
      await prefs.setBool("online", true);
try {
  if (isOnline.value == true) {
    GeoFirePoint point = geo.point(
        latitude: NavigationController.controller.currentLatitude.value,
        longitude: NavigationController.controller.currentLongitude.value);
    firestore
        .collection("freeDrivers")
        .doc(AuthController.controller.auth?.currentUser!.uid)
        .update({
      'position': point.data,
    });
  }
  LatLng l = LatLng(position.latitude, position.longitude);
  NavigationController.controller.drivermapcontroller?.animateCamera(CameraUpdate.newLatLng(l));
}catch (error){
  homesteamsub?.cancel();
}

    });
  }

  Future makeDriverOffline() async {
    await FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("available").set("offline");

    await firestore
        .collection("freeDrivers")
        .doc(AuthController.controller.auth?.currentUser!.uid)
        .delete();
    await prefs.setBool("online", false);
    homesteamsub?.cancel();
    isOnline.value = false;
  }

  Future<void> endRide() async {
    var response = await FirebaseDatabase.instance.ref().child("users").child(ride.client!.id).child("rating").get();
    var totalrating=double.parse(response.value.toString());
    var responsee = await FirebaseDatabase.instance.ref().child("users").child(ride.client!.id).child("totalRides").get();
    var totalrides=int.parse(responsee.value.toString());
    var newRating =(((totalrides * totalrating)+rating)/(totalrides+1));
    var newtotalrides = totalrides+1;
    print('total rides $totalrides total rating $totalrating rating $rating new Rating $newRating newtotakrating $newtotalrides ');

    Map <String,dynamic> map =
    {
      'rating':newRating,
      'totalRides':newtotalrides
    };
    await  FirebaseDatabase.instance.ref().child("users").child(ride.client!.id).update(map);
    await  FirebaseDatabase.instance.ref().child("users").child(AuthController.controller.auth!.currentUser!.uid).child("currentRide").set("none");

    isCompleted.value = false;
    arrived.value = false;
    distance.value = "";
    duration.value = "";
    polylinescordinates = [];
    circls.clear();
    polylines.clear();
    markers.clear();
    driverstatus.value = "";
    remainingTime.value = "";
    remainingDistance.value = "";
     pickupLatitude.value = 0.0;
     pickupLongitude.value = 0.0;
     dropOffLatitude.value = 0.0;
     dropOffLongitude.value = 0.0;
    rating=3;
    review.clear();
    NavigationController.controller.circls.clear();
    NavigationController.controller.polylines.clear();
    NavigationController.controller.markers.clear();
    NavigationController.controller.polylinescordinates=[];
    fees = EtherAmount.fromUnitAndValue(EtherUnit.ether,0);
    strictMode = false.obs;
    isOnline.value = false;
    RideHistoryController.controller.commentsStream?.cancel();
    RideHistoryController.controller.commentsRef?.onDisconnect();
    RideHistoryController.controller.already=false;
    RideHistoryController.controller.commentsRef=null;
    RideHistoryController.controller.getData();
    WalletController.controller.updateBalance();
  }  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

  }
  @override
  void onReady() async {
    // TODO: implement onReady
    prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("online")) {
      var s = prefs.getBool("online");
      print("bool onlin is $s");
      if(s==true){
        DriverController.controller.isOnline.value=true;
        DriverController.controller.getLocationLiveUpdate();}
      else{
        DriverController.controller.isOnline.value=false;
      }
    }
    super.onReady();

  }
}
