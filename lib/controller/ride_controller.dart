import 'dart:async';

import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/driver_controller.dart';
import 'package:cryptotaxi/controller/wallet_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/driver.dart';
import 'navigation_controller.dart';
import 'rideHistory_Controller.dart';

class RideController extends GetxController {
  static RideController controller = Get.find();
  TextEditingController name = TextEditingController();
  RxList<String> carImg = <String>[].obs;
  RxList<Widget> imageSliders = <Widget>[].obs;
  DatabaseReference rideRequestRef =
      FirebaseDatabase.instance.ref().child("riderequests").push();
  DatabaseReference rideRequest =
      FirebaseDatabase.instance.ref().child("riderequests");
  DatabaseReference? favorite;

  late String idRide;
  Set<Circle> circls = <Circle>{}.obs;
  var polylines = <Polyline>{}.obs;
  var markers = <Marker>{}.obs;
  late Driver driver;
  late GoogleMapController clientRideController;
  var remainingTime = " ".obs;
  var remainingDistance = " ".obs;
  var status = "".obs;
  var loading = true.obs;
  var isCompleted = false.obs;
  var rideKey="".obs;
  double rating = 3;
  TextEditingController review = TextEditingController();
   StreamSubscription? subscription;
   StreamSubscription? subscription1;
   StreamSubscription? rideStatus;
  var addFav = true.obs;
  var strictMode = false.obs;
  var liveLocation = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void listten() async {
    subscription = RideController.controller.rideRequest
        .child(RideController.controller.idRide)
        .child("remainingtime")
        .onValue
        .listen((event) async {
      var snapshot = event.snapshot;
      remainingTime.value = snapshot.value.toString();
      print("THIS IS remainingtime ${snapshot.value}");
    });
    subscription1 = RideController.controller.rideRequest
        .child(RideController.controller.idRide)
        .child("remainingdistance")
        .onValue
        .listen((eventt) async {
      var snapshot = eventt.snapshot;
      remainingDistance.value = snapshot.value.toString();
      print("THIS IS remainingdistance ${snapshot.value}");
    });
    rideStatus = RideController.controller.rideRequest
        .child(RideController.controller.idRide)
        .child("status")
        .onValue
        .listen((event) {
      print(event.snapshot.value);
      status.value = event.snapshot.value.toString();

    });
  }

  Future getImages(Driver driver) async {
    print('getin gaznd,azd imagze');

    await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(driver.id!)
        .child("imgs")
        .onValue
        .forEach((element) async {
      loading.value = true;
      carImg.clear();
      print("THIS IS ELEMENT ${element.snapshot.value.toString()}");

      for (final child in element.snapshot.children) {
        print("THIS IS TIOMGGGGGGGG ${child.value.toString()}");
        carImg.add(child.value.toString());
      }
      loading.value = false;
    });
    imageSliders.value = carImg
        .map((item) => Container(
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item.toString(),
                            fit: BoxFit.cover, width: 1000.0),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Text(
                              'No. ${carImg.indexOf(item)} image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();
  }

  Future<void> endRide() async {
    //to do implement rating and comment upload and calculate new rating
    var response = await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(driver.id!)
        .child("rating")
        .get();
    var totalrating = double.parse(response.value.toString());
    var responsee = await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(driver.id!)
        .child("totalRides")
        .get();
    var totalrides = int.parse(responsee.value.toString());
    var newRating = (((totalrides * totalrating) + rating) / (totalrides + 1));
    var newtotalrides = totalrides + 1;
    print(
        'total rides $totalrides total rating $totalrating rating $rating new Rating $newRating newtotakrating $newtotalrides ');
    Map<String, dynamic> map = {
      'rating': newRating,
      'totalRides': newtotalrides
    };
    await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(driver.id!)
        .update(map);
    await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(AuthController.controller.auth!.currentUser!.uid)
        .child("currentRide")
        .set("none");
    favorite?.onDisconnect();

    favorite = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(AuthController.controller.auth!.currentUser!.uid)
        .child("favoritePlaces")
        .push();
    rideRequestRef.onDisconnect();
    rideRequestRef =
        FirebaseDatabase.instance.ref().child("riderequests").push();
    NavigationController.controller.circls.clear();
    NavigationController.controller.polylines.clear();
    NavigationController.controller.markers.clear();
    NavigationController.controller.polylinescordinates = [];
    NavigationController.controller.dropOffAddress.value =
        "Search your destination";
    NavigationController.controller.dropOffLatitude.value = 0.0;
    NavigationController.controller.dropOffLongitude.value = 0.0;
    NavigationController.controller.currentIndex.value = 0;
    NavigationController.controller.distance.value = "";
    NavigationController.controller.duration.value = "";
    NavigationController.controller.subscription?.pause();
    rating = 3;
    review.clear();
    remainingTime.value = " ";
    remainingDistance.value = " ";
    subscription?.cancel();
    isCompleted.value = false;
    name.clear();
    imageSliders.clear();
    carImg.clear();
    WalletController.controller.updateBalance();

    circls.clear();
    polylines.clear();
    markers.clear();
    NavigationController.controller.cost.value=0;
    NavigationController.controller.ETHCost=BigInt.zero;
    status = "".obs;
    loading = true.obs;
    rideKey="".obs;
    rideStatus?.cancel();
    addFav = false.obs;
    strictMode = false.obs;
    subscription1?.cancel();
    idRide = "";
    DriverController.controller.isOnline.value=false;
    RideHistoryController.controller.commentsStream?.cancel();
    RideHistoryController.controller.commentsRef?.onDisconnect();
    RideHistoryController.controller.already=false;
    RideHistoryController.controller.commentsRef=null;
    RideHistoryController.controller.getData();
  }
}
