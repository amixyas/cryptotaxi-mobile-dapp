import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/ride_controller.dart';
import 'package:cryptotaxi/model/favPlace.dart';
import 'package:cryptotaxi/view/homePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as Loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:one_context/one_context.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../main.dart';
import '../model/directionDetails.dart';
import '../model/driver.dart';
import '../model/requestAssistant.dart';

class NavigationController extends GetxController {
  static NavigationController controller = Get.find();
  var range = 20.0.obs;
  var currentIndex = 0.obs;
  var currentLatitude = 0.0.obs;
  var currentLongitude = 0.0.obs;
  var dropOffLatitude = 0.0.obs;
  var dropOffLongitude = 0.0.obs;
  var currentAddress = "Your current location".obs;
  var dropOffAddress = "Search your destination".obs;
  var distance = "".obs;
  var duration = "".obs;
  var cost = 0.obs;
  double? DZDTOETH;
  var sortByDistance = true.obs;
  bool confirmed = false;

  // late Position currentPosition ;
  // late Position destinationPosition ;
  late GoogleMapController gmapcontroller;
  GoogleMapController? drivermapcontroller;
  BigInt ETHCost = BigInt.zero;
  List<LatLng> polylinescordinates = [];
  late DirectionDetails directionDetails;
  Set<Circle> circls = <Circle>{}.obs;
  var polylines = <Polyline>{}.obs;
  var markers = <Marker>{}.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final geo = GeoFlutterFire();
  late Stream<dynamic> query;
  StreamSubscription? subscription;
  late Stream<List<DocumentSnapshot>> stream;
  var listdriver = <Driver>[].obs;
  var listFavPlace = <FavPlace>[].obs;

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPostition, LatLng destination) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPostition.latitude},${initialPostition.longitude}&destination=${destination.latitude},${destination.longitude}&key=AIzaSyDBUOXf8zTb24XGmhF5tlBaDV27uYF7170";
    Uri uri = Uri.parse(url);
    var response = await RequestAssistant.getRequest(uri);
    print(response);
    if (response == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.encodedPoints =
        response["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        response["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        response["routes"][0]["legs"][0]["distance"]["value"];
//
    directionDetails.durationText =
        response["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        response["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  void updateLocation(double lat, double lng, String address) {
    currentLatitude.value = lat;
    currentLongitude.value = lng;

    currentAddress.value = address;
  }

  Future cancelRide() async {
    NavigationController.controller.markers.removeWhere((element) =>
        element.markerId == MarkerId("pickup"));
    NavigationController.controller.markers.removeWhere((element) =>
        element.markerId == MarkerId("dropoff"));
    NavigationController.controller.polylines.clear();
    NavigationController.controller.circls.clear();
    dropOffAddress.value = "Search your destination";
    NavigationController.controller.confirmed = false;
    NavigationController.controller.dropOffLatitude.value = 0;
    NavigationController.controller.dropOffLongitude.value = 0;
    cost.value = 0;
    ETHCost = BigInt.zero;
    duration.value = "";
    distance.value = "";
    var result = await NavigationController.controller.locateposition();
    var address =
        await placemarkFromCoordinates(result.latitude, result.longitude);
    print("aaaaaaaaaaaaaaaaaaaaa $address");
    var s =
        "${address.first.subAdministrativeArea ?? ""} ,${address[0].administrativeArea ?? ""}";
    NavigationController.controller
        .updateLocation(result.latitude, result.longitude, s);
  }

  void updateDropOffLocation(double lat, double lng, String address) {
    dropOffLatitude.value = lat;
    dropOffLongitude.value = lng;
    // var addresss = await  geoCode.reverseGeocoding(latitude: position.latitude, longitude: position.longitude);

    dropOffAddress.value = address;
  }

  Future<Position> locateposition() async {
    bool serviceEnabled;
    LocationPermission permission;
    EasyLoading.show(status: "Getting location");
    // Test if location services are enabled.
    Loc.Location location = Loc.Location();
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
      }
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    LatLng latlanp = LatLng(p.latitude, p.longitude);
    // mapController.animateCamera(CameraUpdate.newLatLng(latlanp));
    NavigationController.controller.gmapcontroller
        .animateCamera(CameraUpdate.newLatLngZoom(latlanp, 14));
    // NavigationController.controller.gmapcontroller.animateCamera(CameraUpdate())
    if (AuthController.controller.role.value == "driver") {
      NavigationController.controller.drivermapcontroller
          ?.animateCamera(CameraUpdate.newLatLngZoom(latlanp, 14));
    }
    // print(NavigationController.controller.currentPosition.toString());

    CameraPosition cameraPosition =
        new CameraPosition(target: latlanp, zoom: 14);
    // gmapcontroller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    // String address = await AssistantMethods.searchCoordinateAddress(p, context);
    // String currentaddress = Provider.of<AppData>(context,listen: false).userPickupLocation.placename;
    // Map<String, dynamic> tokenmap = {
    //   "currentAddress": currentaddress,
    //
    // };
    // driverref.child(user.uid).update(tokenmap);
    EasyLoading.dismiss();
    return p;
  }

  Future<int> getRideCost() async {
    var request = await http.get(Uri.parse(
        'https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=DZD'));

    if (request.statusCode == 200) {
      print(request);
    }
    final data = jsonDecode(request.body);
    print(data['DZD']);
    DZDTOETH = double.parse(data['DZD'].toString());
    double timeTravalFares = (directionDetails.durationValue! / 60) * 5;
    double distanceTravledFares = (directionDetails.distanceValue! / 1000) * 5;
    double totalfair = 50 + timeTravalFares + distanceTravledFares;
    var t = (totalfair.truncate() / DZDTOETH!) * 1000000;
    ETHCost =
        EtherAmount.fromUnitAndValue(EtherUnit.szabo, t.truncate()).getInWei;
    // print(EtherAmount.fromUnitAndValue(EtherUnit.szabo, t.truncate()).getInWei);
    return totalfair.truncate();
  }

  Future<void> getPlaceDirectoin(LatLng pickup, LatLng dropoff) async {
    var pickuplatlng = LatLng(currentLatitude.value, currentLongitude.value);
    var droplatlng = LatLng(dropOffLatitude.value, dropOffLongitude.value);

    EasyLoading.show(status: "Please wait ");
    var details = await obtainPlaceDirectionDetails(pickup, dropoff);

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
    List<LatLng> list = [pickuplatlng, droplatlng];
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
    if (gmapcontroller == null) {
      Home().build(OneContext().context!);
    }
    gmapcontroller
        .animateCamera(CameraUpdate.newLatLngBounds(latlngbounds, 70));
    Marker pickupMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(snippet: "My Location"),
        position: pickuplatlng,
        markerId: MarkerId("pickup"));
    Marker dropOffMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(snippet: "Destination"),
        position: droplatlng,
        markerId: MarkerId("dropoff"));
    RideController.controller.markers.clear();
    RideController.controller.markers.add(pickupMarker);
    RideController.controller.markers.add(dropOffMarker);

    markers.removeWhere((element) => element.markerId == MarkerId("pickUpId"));
    markers.removeWhere((element) => element.markerId == MarkerId("dropOffId"));
    markers.add(pickupMarker);
    markers.add(dropOffMarker);

    Circle pickupcircle = Circle(
        fillColor: Colors.yellow,
        center: pickuplatlng,
        radius: 12,
        strokeColor: Colors.yellowAccent,
        strokeWidth: 4,
        circleId: CircleId("pickup"));
    Circle dropOffCircle = Circle(
        fillColor: Colors.green,
        center: droplatlng,
        radius: 12,
        strokeColor: Colors.greenAccent,
        strokeWidth: 4,
        circleId: CircleId("dropoff"));
    circls.add(pickupcircle);
    circls.add(dropOffCircle);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> getDrivers() async {
    listdriver.clear();
    subscription?.cancel();

    EasyLoading.show(status: "Getting available driver ");
    var ref = firestore.collection('freeDrivers');

    // Make a referece to firestore
    GeoFirePoint center = geo.point(
        latitude: currentLatitude.value, longitude: currentLongitude.value);
    String field = 'position';

    stream = geo.collection(collectionRef: ref).within(
        center: center, radius: range.value, field: field, strictMode: true);

    subscription = stream.listen((List<DocumentSnapshot> documentList) async {
      print("list changed");

      markers.clear();
      if (NavigationController.controller.dropOffLatitude.value != 0) {
        Marker currentMarker = Marker(
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(snippet: "Pickup"),
            position: LatLng(
                NavigationController.controller.currentLatitude.value,
                NavigationController.controller.currentLongitude.value),
            markerId: MarkerId("pickup"));
        markers.add(currentMarker);
        Marker currentMarker1 = Marker(
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(snippet: "Dropoff"),
            position: LatLng(
                NavigationController.controller.dropOffLatitude.value,
                NavigationController.controller.dropOffLongitude.value),
            markerId: MarkerId("dropoff"));
        markers.add(currentMarker1);

      }

      if (documentList.length == 0) {
        listdriver.clear();
        print("NO DRIVER AVAILABLE ");
        EasyLoading.dismiss();
        // return;
      } else {
        listdriver.clear();
        for (var d in documentList) {
          print(d.data().toString());

          Driver driver = new Driver();
          driver.token = d.get("token");
          driver.name = d.get("name");
          driver.profileImage = d.get("profileImage");
          driver.car = d.get("car");
          // var s = point.distance(currentLatitude.value, currentLongitude.value);
          driver.id = d.reference.id;
          driver.placeFormattedAddress = d.get("address");
          driver.phone = d.get("phone");
          driver.rating = double.parse(d.get("rating").toString());
          driver.totalRides = d.get("totalRides").toString();
          GeoPoint pos = d.get("position")['geopoint'];

          driver.latitude = pos.latitude;
          driver.longitude = pos.longitude;
          final Uint8List markerIcon =
              await getBytesFromAsset('assets/images/sport-car.png', 100);

          Marker driverMarker = Marker(
              icon: BitmapDescriptor.fromBytes(markerIcon),
              infoWindow: InfoWindow(snippet: d.get("name")),
              position: LatLng(pos.latitude, pos.longitude),
              markerId: MarkerId(d.reference.id));

          markers.add(driverMarker);
          print('MARKERS LENGH IS ${markers.length}');
          driver.distance =
              center.distance(lat: pos.latitude, lng: pos.longitude);
          driver.id = d.id;
          listdriver.add(driver);
          print(listdriver.length);
        }
        if (sortByDistance.value) {
          listdriver.sort(
            (a, b) {
              return a.distance!.compareTo(b.distance!);
            },
          );
        } else {
          listdriver.sort(
            (a, b) {
              return b.rating!.compareTo(a.rating!);
            },
          );
        }
        print("List Lengh is ${listdriver.length}");
        EasyLoading.dismiss();
      }
    });
  }

  Future getFavPlace() async {
    final userFavPlaceRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(AuthController.controller.auth!.currentUser!.uid)
        .child("favoritePlaces")
        .ref;
    userFavPlaceRef.onValue.forEach((element) async {
      listFavPlace.clear();

      for (final child in element.snapshot.children) {
        var res = child.value as Map;
        var favPlace = FavPlace(
            child.key,
            res["name"].toString(),
            res["address"].toString(),
            double.parse(res["lat"].toString()),
            double.parse(res["lng"].toString()));
        listFavPlace.add(favPlace);
      }
    });
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    if (AuthController.controller.auth?.currentUser != null &&
        AuthController.controller.role.value == "client") {
      getFavPlace();
    }
  }
}
