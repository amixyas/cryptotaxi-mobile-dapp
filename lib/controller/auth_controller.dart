import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cryptotaxi/controller/SC_controller.dart';
import 'package:cryptotaxi/controller/profile_controller.dart';
import 'package:cryptotaxi/controller/qr_controller.dart';
import 'package:cryptotaxi/controller/rideHistory_Controller.dart';
import 'package:cryptotaxi/controller/wallet_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/model/driver.dart';
import 'package:cryptotaxi/view/firstUseScreen.dart';
import 'package:cryptotaxi/view/loginScreen.dart';
import 'package:cryptotaxi/view/onBoardingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gps_connectivity/gps_connectivity.dart';
import 'package:one_context/one_context.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:twitter_login/twitter_login.dart';
import '../model/Ride.dart';
import '../model/User.dart';
import '../view/driverRideScreen.dart';
import '../view/homePage.dart';
import '../view/rideScreen.dart';
import 'package:location/location.dart' as Loc;
import '../view/waitingForConfirmationScreen.dart';
import 'driverRide_controller.dart';
import 'driver_controller.dart';
import 'navigation_controller.dart';
import 'notification_controller.dart';
import 'ride_controller.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  static AuthController controller = Get.find();
  final FirebaseAuth? auth = FirebaseAuth.instance;
  late Rx<User?> firebaseUser;
  Rx<bool> isLoading = Rx<bool>(false);
  Rx<bool> isLoadingPhone = Rx<bool>(false);
  Rx<bool> smsSent = Rx<bool>(false);
  Rx<bool> wait = Rx<bool>(false);
  late String client;
  Loc.Location location = Loc.Location();
  Rx<AppUser>? appUser = AppUser.empty("test").obs;
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  TextEditingController phone = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController textEditingController = TextEditingController();
  var userRating = 0.0.obs;
  var userTotalRides = 0.obs;
  Timer? timer;
  var start = 60.obs;
  var phonenumber = ''.obs;
  var verId = '';
  var authStatus = ''.obs;
  var smsCode = ''.obs;
  late SharedPreferences prefs;
  bool gpsShowed = false;
  var role = 'client'.obs;
  late StreamSubscription subscription;

  // late StreamSubscription gpsStatus;
  GlobalKey<FormState> formKey =
      GlobalKey<FormState>(debugLabel: '_signupScreenkey');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: implement didChangeAppLifecycleState
    print('AppLifecycleState CHANGED1');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (state == AppLifecycleState.detached) {
      print('detached');
      if (AuthController.controller.auth != null) {
        if (AuthController.controller.role.value == "driver") {
          if (DriverController.controller.isOnline.value) {
            await DriverController.controller.makeDriverOffline();
          }
        } else if (AuthController.controller.role.value == "client") {}
      }
    }
    if (state == AppLifecycleState.paused) {
      print('PAUSED');
      NavigationController.controller.subscription?.pause();
    }
    if (state == AppLifecycleState.resumed) {
      print('RESUMED');
      NavigationController.controller.subscription?.resume();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();
    bool t = false;
    bool isGpsEnabled = await (GpsConnectivity().checkGpsConnectivity());
    if (isGpsEnabled) {
      // GPS is ON.
    } else {
      gpsShowed = true;
      Get.defaultDialog(
        content: SizedBox(
          width: OneContext().mediaQuery.size.width * 0.9,
          // height: 100,
          child: Center(
              child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    // width: OneContext().mediaQuery.size.width * 0.5,
                    child: Text(
                      "Please turn ON the GPS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textcolor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
        barrierDismissible: true,
      );
    }
    // gpsStatus = GpsConnectivity().onGpsConnectivityChanged.listen((bool result) {
    //   print("GPS STATUS CHJANGE $result");
    //   if (result){
    //     if (gpsShowed){
    //       Navigator.of(OneContext().context!, rootNavigator: true).pop();
    //       gpsShowed=false;
    //       EasyLoading.dismiss();
    //     }
    //   }else{
    //     if(gpsShowed==false){
    //       Get.defaultDialog( content :SizedBox(
    //         width: OneContext().mediaQuery.size.width * 0.9,
    //         // height: 100,
    //         child: Center(
    //             child: Container(
    //               child: Padding(
    //                 padding: const EdgeInsets.all(16.0),
    //                 child: Column(
    //                   children: [
    //                     SizedBox(
    //                       // width: OneContext().mediaQuery.size.width * 0.5,
    //                       child: Text(
    //                         "Location is require for the app to work correctly. Turn on the gps",textAlign: TextAlign.center,
    //                         style:
    //                         TextStyle(color: textcolor, fontWeight: FontWeight.bold),
    //                       ),
    //
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             )),
    //       ), barrierDismissible: false,);
    //     }
    //     gpsShowed=true;
    //     EasyLoading.dismiss();
    //   }
    // });
    SimpleConnectionChecker _simpleConnectionChecker = SimpleConnectionChecker()
      ..setLookUpAddress('google.com');
    // ConnectivityResult res = await Connectivity().checkConnectivity();
    // if (res == ConnectivityResult.none || res == ConnectivityResult.bluetooth) {
    //   t = true;
    //   Get.defaultDialog(
    //     content: SizedBox(
    //       width: OneContext().mediaQuery.size.width * 0.9,
    //       height: 100,
    //       child: Center(
    //           child: Container(
    //         child: Padding(
    //           padding: const EdgeInsets.all(16.0),
    //           child: SizedBox(
    //             // width: OneContext().mediaQuery.size.width * 0.5,
    //             child: Text(
    //               "No internet connection ,Please turn on your wifi or mobile data",
    //               textAlign: TextAlign.center,
    //               style:
    //                   TextStyle(color: textcolor, fontWeight: FontWeight.bold),
    //             ),
    //           ),
    //         ),
    //       )),
    //     ),
    //     barrierDismissible: false,
    //   );
    // }
    subscription =
        _simpleConnectionChecker.onConnectionChange.listen((connected) {
      print('internet status changed');
      if (connected == false) {
        t = true;
        Get.defaultDialog(
          content: SizedBox(
            width: OneContext().mediaQuery.size.width * 0.9,
            height: 100,
            child: Center(
                child: Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  // width: OneContext().mediaQuery.size.width * 0.5,
                  child: Text(
                    "No internet connection ,Please turn on your wifi or mobile data",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: textcolor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )),
          ),
          barrierDismissible: false,
        );
        EasyLoading.dismiss();
      } else {
        // if(Get.isDialogOpen!){
        //   Get.back();
        // }
        if (t) {
          print('going back');
          t = false;
          Navigator.of(OneContext().context!, rootNavigator: true).pop();
          // Get.back(closeOverlays: true,);
        }
      }
      print(connected);
    });
    prefs = await SharedPreferences.getInstance();
    firebaseUser = Rx<User?>(auth!.currentUser);
    firebaseUser.bindStream(auth!.userChanges());
    ever(firebaseUser, initialScreen);
  }

  initialScreen(User? user) async {
    print("Initial screen called ");
    if (user == null) {
      Get.offAllNamed(LoginScreen.routename);
    } else {
      //  Get.reload();
      EasyLoading.show(status: "Loading");

      await ref
          .child("users")
          .child(firebaseUser.value!.uid)
          .once()
          .then((DatabaseEvent dataSnapshot) async {
        if (dataSnapshot.snapshot.value == null) {
          await Future.delayed(Duration(seconds: 2));
          initialScreen(firebaseUser.value);
        } else {
          print("THIS IS PROFILE PICTURE ${firebaseUser.value!.photoURL}");
          var response =
              await ref.child("users").child(user.uid).child("firstUse").get();
          if (response.value == true) {
            Get.offAll(() => OnBoardingScreen());
            EasyLoading.dismiss();
          } else {
            RideHistoryController.controller.getData();
            var response =
                await ref.child("users").child(user.uid).child("role").get();
            role.value = response.value.toString();
            if (role.value == "client") {
              RideController.controller.favorite = FirebaseDatabase.instance
                  .ref()
                  .child("users")
                  .child(AuthController.controller.auth!.currentUser!.uid)
                  .child("favoritePlaces")
                  .push();
              NavigationController.controller.getDrivers();
            } else {
              ProfileController.controller.getImages();
            }

            var s = await ref.child("users").child(user.uid).get();
            // Map<String,dynamic> map = s.value as Map<String,dynamic>;
            print("THIS IS AAAAAAAAAAA : ${s.child("name").value.toString()}");
            print("THIS IS AAAAAAAAAAA : ${s.child("email").value.toString()}");
            print(
                "THIS IS AAAAAAAAAAA : ${s.child("address").value.toString()}");
            ProfileController.controller.email =
                TextEditingController(text: s.child("email").value.toString());
            ProfileController.controller.name =
                TextEditingController(text: s.child("name").value.toString());
            ProfileController.controller.address = TextEditingController(
                text: s.child("address").value.toString());
            ProfileController.controller.phone =
                TextEditingController(text: s.child("phone").value.toString());
            if (role.value == "driver") {
              ProfileController.controller.car =
                  TextEditingController(text: s.child("car").value.toString());
            }
            appUser?.value = AppUser.name(
                auth!.currentUser!.uid,
                s.child("name").value.toString(),
                s.child("phone").value.toString(),
                double.parse(s.child("rating").value.toString()),
                s.child("birthdate").value.toString(),
                s.child("gender").value.toString(),
                int.parse(s.child("totalRides").value.toString()),
                s.child("profileImg").value.toString());

            DatabaseReference ratingRef = FirebaseDatabase.instance
                .ref()
                .child("users")
                .child(AuthController.controller.auth!.currentUser!.uid)
                .child("rating");
            ratingRef.onValue.listen((DatabaseEvent event) {
              final data = event.snapshot.value;

              appUser!.value.rating = double.parse(data.toString());
              userRating.value = double.parse(data.toString());
            });
            DatabaseReference totalRidesRef = FirebaseDatabase.instance
                .ref()
                .child("users")
                .child(AuthController.controller.auth!.currentUser!.uid)
                .child("totalRides");
            totalRidesRef.onValue.listen((DatabaseEvent event) {
              final data = event.snapshot.value;
              appUser!.value.totalRides = int.parse(data.toString());

              userTotalRides.value = int.parse(data.toString());
            });
            if (response.value.toString() == "driver") {
              appUser?.value.car = s.child("car").value.toString();
            }
            print(
                "${appUser?.value.fullname} ${appUser?.value.birthdate} ${appUser?.value.phone} ${appUser?.value.rating} ${appUser?.value.gender}");
            print(appUser.toString());
            var status = await ref
                .child("users")
                .child(user.uid)
                .child("currentRide")
                .get();
            if (status.value == "none") {
              if (response.value.toString() == "driver") {
                var s = await ref
                    .child("users")
                    .child(user.uid)
                    .child("confirmed")
                    .get();
                if (s.value == true) {

                  Get.offAllNamed(Home.routename);
                } else {
                  Get.offAll(() => WaitingForConfirmationScreen());
                }
              } else {
                NavigationController.controller.onReady();

                Get.offAllNamed(Home.routename);
              }
            } else {
              if (response.value.toString() == "driver") {
                bool _serviceEnabled;
                Loc.PermissionStatus _permissionGranted;
                Loc.LocationData _locationData;

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
                    initialScreen(AuthController.controller.auth!.currentUser!);
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
                    return;
                  }
                }

                print(
                    "This is the Driver but its not implement Yet PUSHING TO HOME");
                print('DETECTED PREVIOUS RIDE ${status.value.toString()}');
                var statss = await FirebaseDatabase.instance
                    .ref()
                    .child("riderequests")
                    .child(status.value.toString())
                    .child("status")
                    .get();
                if (statss.value.toString() == "arrived") {
                  var result = await SC_Controller.controller.readContract(
                      SC_Controller.controller.getRideAddress,
                      [status.value.toString()]);
                  print(result.first.toString());
                  DriverController.controller.pickupLatitude.value =
                      double.parse(result.first[5][0]);
                  DriverController.controller.pickupLongitude.value =
                      double.parse(result.first[5][1]);
                  DriverController.controller.dropOffLatitude.value =
                      double.parse(result.first[6][0]);
                  DriverController.controller.dropOffLongitude.value =
                      double.parse(result.first[6][1]);
                  print(
                      '${DriverController.controller.pickupLatitude.value} ${DriverController.controller.pickupLongitude.value} ${DriverController.controller.dropOffLatitude.value} ${DriverController.controller.dropOffLongitude.value}');
                  print(
                      '${NavigationController.controller.currentLatitude.value} ${NavigationController.controller.currentLongitude.value}');
                  Position p = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.bestForNavigation);
                  var address =
                      await placemarkFromCoordinates(p.latitude, p.longitude);
                  var ss =
                      "${address[0].street ?? ""}  ${address.first.subAdministrativeArea ?? ""} ,${address[0].administrativeArea ?? ""} ";
                  NavigationController.controller
                      .updateLocation(p.latitude, p.longitude, ss);
                  DriverController.controller.getPlaceDirectoin(
                      LatLng(p.latitude, p.longitude),
                      LatLng(DriverController.controller.dropOffLatitude.value,
                          DriverController.controller.dropOffLongitude.value));
                  // DriverController.controller.makeDriverOffline();
                  var s = await FirebaseDatabase.instance
                      .ref()
                      .child("users")
                      .child(result.first[1])
                      .get();
                  // Map<String,dynamic> map = s.value as Map<String,dynamic>;
                  ProfileController.controller.email = TextEditingController(
                      text: s.child("email").value.toString());
                  ProfileController.controller.name = TextEditingController(
                      text: s.child("name").value.toString());
                  ProfileController.controller.address = TextEditingController(
                      text: s.child("address").value.toString());
                  ProfileController.controller.phone = TextEditingController(
                      text: s.child("phone").value.toString());

                  AppUser client = AppUser.name(
                      result.first[1].toString(),
                      s.child("name").value.toString(),
                      s.child("phone").value.toString(),
                      double.parse(s.child("rating").value.toString()),
                      s.child("birthdate").value.toString(),
                      s.child("gender").value.toString(),
                      int.parse(s.child("totalRides").value.toString()),
                      s.child("profileImg").value.toString());

                  var a = await placemarkFromCoordinates(
                      DriverController.controller.pickupLatitude.value,
                      DriverController.controller.pickupLongitude.value);
                  var aa = await placemarkFromCoordinates(
                      DriverController.controller.dropOffLatitude.value,
                      DriverController.controller.dropOffLongitude.value);
                  var pickupad =
                      "${a[0].street ?? ""}  ${a.first.subAdministrativeArea ?? ""} ,${a[0].locality ?? ""} ";
                  var dropoffad =
                      "${aa[0].street ?? ""}  ${aa.first.subAdministrativeArea ?? ""} ,${aa[0].locality ?? ""} ";
                  DriverController.controller.arrived.value = true;
                  Ride r = Ride(
                      status.value.toString(),
                      client,
                      AuthController.controller.appUser?.value,
                      LatLng(DriverController.controller.pickupLatitude.value,
                          DriverController.controller.pickupLongitude.value),
                      LatLng(DriverController.controller.dropOffLatitude.value,
                          DriverController.controller.pickupLongitude.value),
                      "data['createdat']",
                      double.parse(s.child("rating").value.toString()),
                      pickupad,
                      dropoffad);
                  DriverController.controller.ride = r;
                  DriverController.controller.updateRemaining(
                      DriverController.controller.ride.pickup!);


                  Get.offAllNamed(Home.routename);
                  Get.to(() => DriverRideScreen());
                  print(result.first.toString());
                } else if (statss.value.toString() == "ended") {
                  DriverController.controller.isCompleted.value = true;
                  DriverController.controller.isCompleted.value = true;
                  var result = await SC_Controller.controller.readContract(
                      SC_Controller.controller.getRideAddress,
                      [status.value.toString()]);
                  print(result.first.toString());
                  DriverController.controller.pickupLatitude.value =
                      double.parse(result.first[5][0]);
                  DriverController.controller.pickupLongitude.value =
                      double.parse(result.first[5][1]);
                  DriverController.controller.dropOffLatitude.value =
                      double.parse(result.first[6][0]);
                  DriverController.controller.dropOffLongitude.value =
                      double.parse(result.first[6][1]);
                  print(
                      '${DriverController.controller.pickupLatitude.value} ${DriverController.controller.pickupLongitude.value} ${DriverController.controller.dropOffLatitude.value} ${DriverController.controller.dropOffLongitude.value}');
                  print(
                      '${NavigationController.controller.currentLatitude.value} ${NavigationController.controller.currentLongitude.value}');
                  Position p = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.bestForNavigation);
                  var address =
                      await placemarkFromCoordinates(p.latitude, p.longitude);
                  var ss =
                      "${address[0].street ?? ""}  ${address.first.subAdministrativeArea ?? ""} ,${address[0].administrativeArea ?? ""} ";
                  NavigationController.controller
                      .updateLocation(p.latitude, p.longitude, ss);
                  DriverController.controller.getPlaceDirectoin(
                      LatLng(p.latitude, p.longitude),
                      LatLng(DriverController.controller.dropOffLatitude.value,
                          DriverController.controller.dropOffLongitude.value));
                  // DriverController.controller.makeDriverOffline();
                  var s = await FirebaseDatabase.instance
                      .ref()
                      .child("users")
                      .child(result.first[1])
                      .get();
                  // Map<String,dynamic> map = s.value as Map<String,dynamic>;
                  ProfileController.controller.email = TextEditingController(
                      text: s.child("email").value.toString());
                  ProfileController.controller.name = TextEditingController(
                      text: s.child("name").value.toString());
                  ProfileController.controller.address = TextEditingController(
                      text: s.child("address").value.toString());
                  ProfileController.controller.phone = TextEditingController(
                      text: s.child("phone").value.toString());

                  AppUser client = AppUser.name(
                      result.first[1].toString(),
                      s.child("name").value.toString(),
                      s.child("phone").value.toString(),
                      double.parse(s.child("rating").value.toString()),
                      s.child("birthdate").value.toString(),
                      s.child("gender").value.toString(),
                      int.parse(s.child("totalRides").value.toString()),
                      s.child("profileImg").value.toString());

                  var a = await placemarkFromCoordinates(
                      DriverController.controller.pickupLatitude.value,
                      DriverController.controller.pickupLongitude.value);
                  var aa = await placemarkFromCoordinates(
                      DriverController.controller.dropOffLatitude.value,
                      DriverController.controller.dropOffLongitude.value);
                  var pickupad =
                      "${a[0].street ?? ""}  ${a.first.subAdministrativeArea ?? ""} ,${a[0].locality ?? ""} ";
                  var dropoffad =
                      "${aa[0].street ?? ""}  ${aa.first.subAdministrativeArea ?? ""} ,${aa[0].locality ?? ""} ";
                  Ride r = Ride(
                      status.value.toString(),
                      client,
                      AuthController.controller.appUser?.value,
                      LatLng(DriverController.controller.pickupLatitude.value,
                          DriverController.controller.pickupLongitude.value),
                      LatLng(DriverController.controller.dropOffLatitude.value,
                          DriverController.controller.pickupLongitude.value),
                      "data['createdat']",
                      double.parse(s.child("rating").value.toString()),
                      pickupad,
                      dropoffad);
                  DriverController.controller.ride = r;
                  DriverController.controller.updateRemaining(
                      DriverController.controller.ride.pickup!);


                  Get.offAllNamed(Home.routename);
                  Get.to(() => DriverRideScreen());
                  print(result.first.toString());
                } else {
                  var result = await SC_Controller.controller.readContract(
                      SC_Controller.controller.getRideAddress,
                      [status.value.toString()]);
                  print(result.first.toString());
                  DriverController.controller.pickupLatitude.value =
                      double.parse(result.first[5][0]);
                  DriverController.controller.pickupLongitude.value =
                      double.parse(result.first[5][1]);
                  DriverController.controller.dropOffLatitude.value =
                      double.parse(result.first[6][0]);
                  DriverController.controller.dropOffLongitude.value =
                      double.parse(result.first[6][1]);
                  print(
                      '${DriverController.controller.pickupLatitude.value} ${DriverController.controller.pickupLongitude.value} ${DriverController.controller.dropOffLatitude.value} ${DriverController.controller.dropOffLongitude.value}');
                  print(
                      '${NavigationController.controller.currentLatitude.value} ${NavigationController.controller.currentLongitude.value}');
                  Position p = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.bestForNavigation);
                  var address =
                      await placemarkFromCoordinates(p.latitude, p.longitude);
                  var ss =
                      "${address[0].street ?? ""}  ${address.first.subAdministrativeArea ?? ""} ,${address[0].administrativeArea ?? ""} ";
                  NavigationController.controller
                      .updateLocation(p.latitude, p.longitude, ss);
                  DriverController.controller.getPlaceDirectoin(
                      LatLng(
                          NavigationController.controller.currentLatitude.value,
                          NavigationController
                              .controller.currentLongitude.value),
                      LatLng(DriverController.controller.pickupLatitude.value,
                          DriverController.controller.pickupLongitude.value));
                  // DriverController.controller.makeDriverOffline();
                  var s = await FirebaseDatabase.instance
                      .ref()
                      .child("users")
                      .child(result.first[1])
                      .get();
                  // Map<String,dynamic> map = s.value as Map<String,dynamic>;
                  ProfileController.controller.email = TextEditingController(
                      text: s.child("email").value.toString());
                  ProfileController.controller.name = TextEditingController(
                      text: s.child("name").value.toString());
                  ProfileController.controller.address = TextEditingController(
                      text: s.child("address").value.toString());
                  ProfileController.controller.phone = TextEditingController(
                      text: s.child("phone").value.toString());

                  AppUser client = AppUser.name(
                      result.first[1].toString(),
                      s.child("name").value.toString(),
                      s.child("phone").value.toString(),
                      double.parse(s.child("rating").value.toString()),
                      s.child("birthdate").value.toString(),
                      s.child("gender").value.toString(),
                      int.parse(s.child("totalRides").value.toString()),
                      s.child("profileImg").value.toString());
                  await FirebaseDatabase.instance
                      .ref()
                      .child("users")
                      .child(AuthController.controller.auth!.currentUser!.uid)
                      .child("currentRide")
                      .set(status.value.toString());
                  await DriverController.controller.prefs
                      .setString("currentRide", result.first[0]);
                  var a = await placemarkFromCoordinates(
                      DriverController.controller.pickupLatitude.value,
                      DriverController.controller.pickupLongitude.value);
                  var aa = await placemarkFromCoordinates(
                      DriverController.controller.dropOffLatitude.value,
                      DriverController.controller.dropOffLongitude.value);
                  var pickupad =
                      "${a[0].street ?? ""}  ${a.first.subAdministrativeArea ?? ""} ,${a[0].locality ?? ""} ";
                  var dropoffad =
                      "${aa[0].street ?? ""}  ${aa.first.subAdministrativeArea ?? ""} ,${aa[0].locality ?? ""} ";

                  Ride r = Ride(
                      status.value.toString(),
                      client,
                      AuthController.controller.appUser?.value,
                      LatLng(DriverController.controller.pickupLatitude.value,
                          DriverController.controller.pickupLongitude.value),
                      LatLng(DriverController.controller.dropOffLatitude.value,
                          DriverController.controller.pickupLongitude.value),
                      "data['createdat']",
                      double.parse(s.child("rating").value.toString()),
                      pickupad,
                      dropoffad);
                  DriverController.controller.ride = r;
                  DriverController.controller.updateRemaining(
                      DriverController.controller.ride.pickup!);


                  Get.offAllNamed(Home.routename);
                  Get.to(() => DriverRideScreen());
                  print(result.first.toString());
                }
              } else {
                bool _serviceEnabled;
                Loc.PermissionStatus _permissionGranted;
                Loc.LocationData _locationData;

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
                    initialScreen(AuthController.controller.auth!.currentUser!);
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
                    return;
                  }
                }
                var strict = await FirebaseDatabase.instance
                    .ref()
                    .child("riderequests")
                    .child(status.value.toString())
                    .child("strictMode")
                    .get();

                RideController.controller.strictMode.value =
                    strict.value as bool;
                var statss = await FirebaseDatabase.instance
                    .ref()
                    .child("riderequests")
                    .child(status.value.toString())
                    .child("status")
                    .get();
                if (statss.value.toString() == "ended") {
                  RideController.controller.isCompleted.value = true;


                  Get.offAllNamed(Home.routename);
                  print('DETECTED PREVIOUS RIDE ${status.value.toString()}');
                  var result = await SC_Controller.controller.readContract(
                      SC_Controller.controller.getRideAddress,
                      [status.value.toString()]);
                  RideController.controller.rideKey.value = result.first[8];
                  RideController.controller.driver = Driver();
                  print(result.first);
                  print(result.first[0]);
                  RideController.controller.idRide = result.first[0];

                  NavigationController.controller.currentLatitude.value =
                      double.parse(result.first[5][0]);
                  NavigationController.controller.currentLongitude.value =
                      double.parse(result.first[5][1]);
                  var a = await placemarkFromCoordinates(
                      NavigationController.controller.currentLatitude.value,
                      NavigationController.controller.currentLongitude.value);
                  var pick =
                      "${a[0].street ?? ""}  ${a.first.subAdministrativeArea ?? ""} ,${a[0].locality ?? ""} ";

                  NavigationController.controller.currentAddress.value = pick;
                  NavigationController.controller.dropOffLatitude.value =
                      double.parse(result.first[6][0]);
                  NavigationController.controller.dropOffLongitude.value =
                      double.parse(result.first[6][1]);
                  var aa = await placemarkFromCoordinates(
                      NavigationController.controller.dropOffLatitude.value,
                      NavigationController.controller.dropOffLongitude.value);
                  var drop =
                      "${aa[0].street ?? ""}  ${aa.first.subAdministrativeArea ?? ""} ,${aa[0].locality ?? ""} ";

                  NavigationController.controller.dropOffAddress.value = drop;
                  await Future.delayed(Duration(seconds: 1));
                  await NavigationController.controller.getPlaceDirectoin(
                      LatLng(
                          NavigationController.controller.currentLatitude.value,
                          NavigationController
                              .controller.currentLongitude.value),
                      LatLng(
                          NavigationController.controller.dropOffLatitude.value,
                          NavigationController
                              .controller.dropOffLongitude.value));
                  var s = await ref.child("users").child(result.first[2]).get();
                  // Map<String,dynamic> map = s.value as Map<String,dynamic>;

                  RideController.controller.driver = Driver(
                      id: result.first[2],
                      phone: s.child("phone").value.toString(),
                      rating: double.parse(s.child("rating").value.toString()),
                      name: s.child("name").value.toString(),
                      profileImage: s.child("profileImg").value.toString());
                  // AppUser driver= AppUser.name(result.first[2].toString(),s.child("name").value.toString(), s.child("phone").value.toString(), 5.0, s.child("birthdate").value.toString(), s.child("gender").value.toString());
                  RideController.controller.listten();

                  Get.to(() => RideScreen());
                }
                if (statss.value.toString() == "arrived") {
                  print(
                      "This is the clieent but its not implementted Yet PUSHING TO HOME");

                  Get.offAllNamed(Home.routename);
                  print('DETECTED PREVIOUS RIDE ${status.value.toString()}');
                  var result = await SC_Controller.controller.readContract(
                      SC_Controller.controller.getRideAddress,
                      [status.value.toString()]);
                  RideController.controller.rideKey.value = result.first[8];
                  RideController.controller.driver = Driver();
                  print(result.first);
                  print(result.first[0]);
                  RideController.controller.idRide = result.first[0];

                  NavigationController.controller.currentLatitude.value =
                      double.parse(result.first[5][0]);
                  NavigationController.controller.currentLongitude.value =
                      double.parse(result.first[5][1]);
                  var a = await placemarkFromCoordinates(
                      NavigationController.controller.currentLatitude.value,
                      NavigationController.controller.currentLongitude.value);
                  var pick =
                      "${a[0].street ?? ""}  ${a.first.subAdministrativeArea ?? ""} ,${a[0].locality ?? ""} ";

                  NavigationController.controller.currentAddress.value = pick;
                  NavigationController.controller.dropOffLatitude.value =
                      double.parse(result.first[6][0]);
                  NavigationController.controller.dropOffLongitude.value =
                      double.parse(result.first[6][1]);
                  var aa = await placemarkFromCoordinates(
                      NavigationController.controller.dropOffLatitude.value,
                      NavigationController.controller.dropOffLongitude.value);
                  var drop =
                      "${aa[0].street ?? ""}  ${aa.first.subAdministrativeArea ?? ""} ,${aa[0].locality ?? ""} ";

                  NavigationController.controller.dropOffAddress.value = drop;
                  await Future.delayed(Duration(seconds: 1));
                  await NavigationController.controller.getPlaceDirectoin(
                      LatLng(
                          NavigationController.controller.currentLatitude.value,
                          NavigationController
                              .controller.currentLongitude.value),
                      LatLng(
                          NavigationController.controller.dropOffLatitude.value,
                          NavigationController
                              .controller.dropOffLongitude.value));
                  var s = await ref.child("users").child(result.first[2]).get();
                  // Map<String,dynamic> map = s.value as Map<String,dynamic>;

                  RideController.controller.driver = Driver(
                      id: result.first[2],
                      phone: s.child("phone").value.toString(),
                      rating: double.parse(s.child("rating").value.toString()),
                      name: s.child("name").value.toString(),
                      profileImage: s.child("profileImg").value.toString());
                  RideController.controller.status.value = "arrived";
                  // AppUser driver= AppUser.name(result.first[2].toString(),s.child("name").value.toString(), s.child("phone").value.toString(), 5.0, s.child("birthdate").value.toString(), s.child("gender").value.toString());
                  RideController.controller.listten();

                  Get.to(() => RideScreen());
                } else {
                  print(
                      "This is the clieent but its not implementted Yet PUSHING TO HOME");
                  Get.offAllNamed(Home.routename);
                  print('DETECTED PREVIOUS RIDE ${status.value.toString()}');
                  var result = await SC_Controller.controller.readContract(
                      SC_Controller.controller.getRideAddress,
                      [status.value.toString()]);
                  RideController.controller.rideKey.value = result.first[8];
                  RideController.controller.driver = Driver();
                  print(result.first);
                  print(result.first[0]);
                  RideController.controller.idRide = result.first[0];

                  NavigationController.controller.currentLatitude.value =
                      double.parse(result.first[5][0]);
                  NavigationController.controller.currentLongitude.value =
                      double.parse(result.first[5][1]);
                  var a = await placemarkFromCoordinates(
                      NavigationController.controller.currentLatitude.value,
                      NavigationController.controller.currentLongitude.value);
                  var pick =
                      "${a[0].street ?? ""}  ${a.first.subAdministrativeArea ?? ""} ,${a[0].locality ?? ""} ";

                  NavigationController.controller.currentAddress.value = pick;
                  NavigationController.controller.dropOffLatitude.value =
                      double.parse(result.first[6][0]);
                  NavigationController.controller.dropOffLongitude.value =
                      double.parse(result.first[6][1]);
                  var aa = await placemarkFromCoordinates(
                      NavigationController.controller.dropOffLatitude.value,
                      NavigationController.controller.dropOffLongitude.value);
                  var drop =
                      "${aa[0].street ?? ""}  ${aa.first.subAdministrativeArea ?? ""} ,${aa[0].locality ?? ""} ";

                  NavigationController.controller.dropOffAddress.value = drop;
                  await Future.delayed(Duration(seconds: 1));
                  await NavigationController.controller.getPlaceDirectoin(
                      LatLng(
                          NavigationController.controller.currentLatitude.value,
                          NavigationController
                              .controller.currentLongitude.value),
                      LatLng(
                          NavigationController.controller.dropOffLatitude.value,
                          NavigationController
                              .controller.dropOffLongitude.value));
                  var s = await ref.child("users").child(result.first[2]).get();
                  // Map<String,dynamic> map = s.value as Map<String,dynamic>;

                  RideController.controller.driver = Driver(
                      id: result.first[2],
                      phone: s.child("phone").value.toString(),
                      rating: double.parse(s.child("rating").value.toString()),
                      name: s.child("name").value.toString(),
                      profileImage: s.child("profileImg").value.toString());
                  // AppUser driver= AppUser.name(result.first[2].toString(),s.child("name").value.toString(), s.child("phone").value.toString(), 5.0, s.child("birthdate").value.toString(), s.child("gender").value.toString());
                  RideController.controller.listten();

                  Get.to(() => RideScreen());
                }
              }
            }
            EasyLoading.dismiss();
          }
        }
      });
    }
  }

  Future<void> singup(String email, String password) async {
    isLoading.value = true;
    try {
      await auth!.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      await firebaseUser.value?.sendEmailVerification();

      var map = {
        'email': emailController.text,
        'name': nameController.text,
        'firstUse': true,
        'confirmed': false
      };
      await ref.child("users").child(firebaseUser.value!.uid).update(map);
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      Get.rawSnackbar(
          message: "User created successfully",
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.green);

      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      String getMessageFromErrorCode() {
        switch (e.code) {
          case "ERROR_EMAIL_ALREADY_IN_USE":
          case "account-exists-with-different-credential":
          case "email-already-in-use":
            return "Email already used. Go to login page.";
            break;
          case "ERROR_WRONG_PASSWORD":
          case "wrong-password":
            return "Wrong email/password combination.";
            break;
          case "ERROR_USER_NOT_FOUND":
          case "user-not-found":
            return "No user found with this email.";
            break;
          case "ERROR_USER_DISABLED":
          case "user-disabled":
            return "User disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
          case "operation-not-allowed":
            return "Too many requests to log into this account.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
          case "operation-not-allowed":
            return "Server error, please try again later.";
            break;
          case "ERROR_INVALID_EMAIL":
          case "invalid-email":
            return "Email address is invalid.";
            break;
          default:
            return "Login failed. Please try again.";
            break;
        }
      }

      print('Failed with error code: ${e.code}');
      print(e.message);
      isLoading.value = false;
      Get.snackbar(
        "CryptoTaxi",
        getMessageFromErrorCode(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      Get.rawSnackbar(
          message: "Error occurred while signing up",
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.red);
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await auth!.signInWithEmailAndPassword(email: email, password: password);

      Get.rawSnackbar(
          message: "Login successfully",
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.green);
      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      String getMessageFromErrorCode() {
        switch (e.code) {
          case "ERROR_EMAIL_ALREADY_IN_USE":
          case "account-exists-with-different-credential":
          case "email-already-in-use":
            return "Email already used. Go to login page.";
            break;
          case "ERROR_WRONG_PASSWORD":
          case "wrong-password":
            return "Wrong email/password combination.";
            break;
          case "ERROR_USER_NOT_FOUND":
          case "user-not-found":
            return "No user found with this email.";
            break;
          case "ERROR_USER_DISABLED":
          case "user-disabled":
            return "User disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
          case "operation-not-allowed":
            return "Too many requests to log into this account.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
          case "operation-not-allowed":
            return "Server error, please try again later.";
            break;
          case "ERROR_INVALID_EMAIL":
          case "invalid-email":
            return "Email address is invalid.";
            break;
          default:
            return "Login failed. Please try again.";
            break;
        }
      }

      print('Failed with error code: ${e.code}');
      print(e.message);
      isLoading.value = false;

      Get.snackbar(
        "CryptoTaxi",
        getMessageFromErrorCode(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      Get.rawSnackbar(
          message: "Account creation failed",
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.red);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    timer = Timer.periodic(onsec, (timer) {
      if (start.value == 0) {
        timer.cancel();
      } else {
        start.value--;
      }
    });
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth!.sendPasswordResetEmail(email: email);

      Get.rawSnackbar(
          message: "Check your email for password reset link",
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.green);
    } on FirebaseAuthException catch (e) {
      String getMessageFromErrorCode() {
        switch (e.code) {
          case "ERROR_EMAIL_ALREADY_IN_USE":
          case "account-exists-with-different-credential":
          case "email-already-in-use":
            return "Email already used. Go to login page.";
            break;
          case "ERROR_WRONG_PASSWORD":
          case "wrong-password":
            return "Wrong email/password combination.";
            break;
          case "ERROR_USER_NOT_FOUND":
          case "user-not-found":
            return "No user found with this email.";
            break;
          case "ERROR_USER_DISABLED":
          case "user-disabled":
            return "User disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
          case "operation-not-allowed":
            return "Too many requests to log into this account.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
          case "operation-not-allowed":
            return "Server error, please try again later.";
            break;
          case "ERROR_INVALID_EMAIL":
          case "invalid-email":
            return "Email address is invalid.";
            break;
          default:
            return "Login failed. Please try again.";
            break;
        }
      }

      // isLoading.value = false;
      Get.snackbar(
        "CryptoTaxi",
        getMessageFromErrorCode(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      print(e);
    }
  }

  verifyPhone(String phone) async {
    isLoadingPhone.value = true;

    await auth?.verifyPhoneNumber(
        timeout: Duration(seconds: 60),
        phoneNumber: phone,
        verificationCompleted: (AuthCredential authCredential) {
          if (auth?.currentUser != null) {
            isLoadingPhone.value = false;
            authStatus.value = "login successfully";
          }
        },
        verificationFailed: (authException) {
          Get.rawSnackbar(
              message: "Could not send SMS code",
              borderRadius: 20,
              margin: EdgeInsets.all(5),
              backgroundColor: Colors.red);

          isLoadingPhone.value = false;
        },
        codeSent: (String id, [int? forceResent]) {
          isLoadingPhone.value = false;
          this.verId = id;
          authStatus.value = "login successfully";

          smsSent.value = true;
          start.value = 60;
          startTimer();
        },
        codeAutoRetrievalTimeout: (String id) {
          isLoadingPhone.value = false;
          this.verId = id;
        });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> loginGoogle() async {
    final user = await signInWithGoogle();
    print(user.user!.email);
    print(user.user!.displayName);
    if (user == null) {
      Get.rawSnackbar(
          message: "Error while login",
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.red);
      // _showToast("${AppLocalizations.of(context).login_err}", Colors.red);

    } else {
      await ref
          .child("users")
          .child(firebaseUser.value!.uid)
          .once()
          .then((DatabaseEvent dataSnapshot) async {
        if (dataSnapshot.snapshot.value == null) {
          var userData = {
            'email': user.user?.email,
            'name': user.user?.displayName,
            'firstUse': true,
            'confirmed': false
          };
          await ref
              .child("users")
              .child(firebaseUser.value!.uid)
              .update(userData);
        }
      });
    }
  }

  Future<void> signInWithTwitter() async {
    // Create a TwitterLogin instance
    final twitterLogin = new TwitterLogin(
        apiKey: 'yDpehjGL5VtQ0F1L3IE6yYPAM',
        apiSecretKey: 'Z8qHe4t4dsf8raKrI5M0BAYp27BTXeKe0BeYeo6NstIiX3HsT2',
        redirectURI: 'cryptotaxi://');

    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();

    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );

    // Once signed in, return the UserCredential

    final user =
        await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
    print(user.user?.email);
    print(user.user?.displayName);
    if (user == null) {
      Get.rawSnackbar(
          message: "Error while login",
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.red);
      // _showToast("${AppLocalizations.of(context).login_err}", Colors.red);

    } else {
      await ref
          .child("users")
          .child(firebaseUser.value!.uid)
          .once()
          .then((DatabaseEvent dataSnapshot) async {
        if (dataSnapshot.snapshot.value == null) {
          var userData = {
            'email': user.user?.email,
            'name': user.user?.displayName,
            'firstUse': true,
            'confirmed': false
          };
          await ref
              .child("users")
              .child(firebaseUser.value!.uid)
              .update(userData);
        }
      });
    }
  }

  otpVerify(String otp) async {
    isLoadingPhone.value = true;
    try {
      UserCredential userCredential = await auth!.signInWithCredential(
          PhoneAuthProvider.credential(
              verificationId: this.verId, smsCode: otp));
      if (userCredential.user != null) {
        await ref
            .child("users")
            .child(userCredential.user!.uid)
            .once()
            .then((DatabaseEvent dataSnapshot) async {
          if (dataSnapshot.snapshot.value == null) {
            var map = {
              'email': 'null',
              'name': phonenumber.value,
              'firstUse': true,
              'confirmed': false
            };
            await ref.child("users").child(firebaseUser.value!.uid).update(map);
            start.value = 60;
            isLoadingPhone.value = false;
            smsSent.value = false;
            textEditingController.clear();
            smsCode.value = '';
            EasyLoading.dismiss();
          } else {
            start.value = 60;
            isLoadingPhone.value = false;
            smsSent.value = false;
            textEditingController.clear();
            smsCode.value = '';
            EasyLoading.dismiss();
          }
        });
      }
    } on Exception catch (e) {
      Get.rawSnackbar(
          message: "SMS code incorrect",
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.red);
      textEditingController.clear();
      smsCode.value = '';
      EasyLoading.dismiss();
    }
  }

  Future<void> resetDate() async {
    isLoading.value = false;
    isLoadingPhone.value = false;
    smsSent.value = false;
    wait.value = false;
    client = "";
    timer?.cancel();
    start = 60.obs;
    phonenumber = ''.obs;
    verId = '';
    authStatus = ''.obs;
    smsCode = ''.obs;
    role = 'client'.obs;
    subscription.cancel();
    phone.clear();
    nameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    isLoading.value = false;
    start.value = 60;
    isLoadingPhone.value = false;
    smsSent.value = false;
    smsCode.value = '';
    phonenumber.value = '';
    // gpsStatus.cancel();
    ProfileController.controller.imgRef?.onDisconnect();
    RideHistoryController.controller.rideHistoryList.clear();
    RideHistoryController.controller.total.value = 0;
    WalletController.controller.connector.killSession();
    WalletController.controller.connected.value = false;
    WalletController.controller.account.value = "";
    WalletController.controller.balance.value = 0.0;
    DriverController.controller.homesteamsub?.cancel();
    WalletController.controller.account.value = "";
    // Get.delete<RideController>();
    // Get.delete<RideHistoryController>();
    NavigationController.controller.currentIndex.value = 0;
    // Get.delete<ProfileController>();
    NavigationController.controller.subscription?.cancel();
    NavigationController.controller.ETHCost = BigInt.zero;
    NavigationController.controller.cost.value = 0;
    NavigationController.controller.polylines.clear();
    NavigationController.controller.dropOffAddress.value =
        "Search your destination";

    NavigationController.controller.duration.value = "";
    NavigationController.controller.distance.value = "";
    NavigationController.controller.dropOffLatitude.value = 0;
    NavigationController.controller.dropOffLongitude.value = 0;
    RideHistoryController.controller.commentsRef?.onDisconnect();
    print(
        "THIS IS THE LENGH ON HISTORY ${RideHistoryController.controller.rideHistoryList.length}");
    RideHistoryController.controller.already = false;
    // Restart.restartApp();

    // Get.lazyPut(() => RideController());

    // Phoenix.rebirth(OneContext().context!); // Restarting app
    // Get.reset();
    //driver Controller
  }

  Future<void> logout() async {
    try {
      if (AuthController.controller.role.value == "driver") {
        await DriverController.controller.makeDriverOffline();
      }
      resetDate();
      await auth?.signOut();
      await GoogleSignIn().signOut();

      Get.rawSnackbar(
          messageText: Text(
            "User Log out successfully",
            style: TextStyle(color: Colors.black),
          ),
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.rawSnackbar(
          message: e.toString(),
          borderRadius: 20,
          margin: EdgeInsets.all(5),
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
