import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:cryptotaxi/controller/navigation_controller.dart';
import 'package:cryptotaxi/controller/wallet_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:one_context/one_context.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:web3dart/web3dart.dart';

import '../main.dart';

class MapScreen extends StatelessWidget {
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  double mapHeight = OneContext().mediaQuery.size.height * 0.50;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) async {
    // mapController = controller;
    NavigationController.controller.gmapcontroller = controller;
    var result = await NavigationController.controller.locateposition();
    var address =
        await placemarkFromCoordinates(result.latitude, result.longitude);
    print(address.first.toString());
    var s =
        "${address[0].street ?? ""}  ${address.first.subAdministrativeArea ?? ""} ,${address[0].locality ?? ""} ";
    NavigationController.controller
        .updateLocation(result.latitude, result.longitude, s);
  }

  var myGroup = AutoSizeGroup();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  late MediaQueryData size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context);
    return Stack(
      children: [
        Obx(
          () => SizedBox(
            height: mapHeight,
            child: GoogleMap(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.10),
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                polylines: NavigationController.controller.polylines.value,
                markers: NavigationController.controller.markers.value,
                onMapCreated: _onMapCreated),
          ),
        ),
        Positioned(
            child: Obx(
          () => ShowUpAnimation(
            delayStart: Duration(milliseconds: 500),
            animationDuration: Duration(seconds: 2),
            curve: Curves.bounceIn,
            direction: Direction.vertical,
            offset: 0.5,
            child: SlidingUpPanel(
              defaultPanelState: PanelState.OPEN,
              minHeight: MediaQuery.of(context).size.height * 0.08,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(40),
                topLeft: Radius.circular(40),
              ),
              color: Colors.white,
              maxHeight: MediaQuery.of(context).size.height * 0.45,
              onPanelOpened: () {
                mapHeight = OneContext().mediaQuery.size.height * 0.55;
              },
              onPanelClosed: () {
                mapHeight = OneContext().mediaQuery.size.height * 0.92;
              },
              panelSnapping: false,
              isDraggable: false,
              panel: Container(
                  padding: EdgeInsets.all(16),
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Trip informations ",
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
                            color: textcolor,
                            fontSize: 20),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Icon(
                                FontAwesomeIcons.locationCrosshairs,
                                color: Colors.blue,
                              ),
                              visualDensity: VisualDensity.compact,
                              title: AutoSizeText(
                                NavigationController
                                    .controller.currentAddress.value,
                                maxLines: 1,
                                group: myGroup,
                                style: TextStyle(
                                    color: textcolor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Divider(
                                color: Colors.black,
                                thickness: 0.45,
                                height: 0),
                            ListTile(
                              leading: const Icon(
                                FontAwesomeIcons.mapLocationDot,
                                color: Colors.red,
                              ),
                              visualDensity: VisualDensity.compact,
                              title: AutoSizeText(
                                NavigationController
                                    .controller.dropOffAddress.value,
                                group: myGroup,
                                maxLines: 1,
                                style: TextStyle(
                                    color: textcolor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider(
                      //   color: Colors.black,
                      //   thickness: 1,
                      // ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                        child: Container(
                          padding: EdgeInsets.all(10),

                          // height: 10,
                          // width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Column(

                                  children: [
                                    AutoSizeText(
                                      "Time:",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textcolor),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    AutoSizeText(
                                      NavigationController
                                          .controller.duration.value,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    AutoSizeText(
                                      "Distance:",
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      NavigationController
                                          .controller.distance.value,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(

                                  children: [
                                    AutoSizeText(
                                      "Cost:",
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${NavigationController.controller.cost.value.toString()} DA ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    AutoSizeText(
                                      "Cost in ETH:",
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    AutoSizeText(
                                      "${EtherAmount.fromUnitAndValue(EtherUnit.wei, NavigationController.controller.ETHCost.toString()).getValueInUnit(EtherUnit.szabo)/1000000}",maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    primary: Colors.red),
                                onPressed: () async {
                                  if (await confirm(OneContext().context!)) {
                                    await NavigationController.controller
                                        .cancelRide();
                                    NavigationController
                                        .controller.currentIndex.value = 0;
                                    return print('pressedOK');

                                  }
                                  return print('pressedCancel');

                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Cancel",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(FontAwesomeIcons.cancel)
                                    ],
                                  ),
                                )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    primary: Colors.green),
                                onPressed: () async {
                                  if (NavigationController
                                      .controller.dropOffLatitude.value ==
                                      0 || NavigationController
                                      .controller.currentLatitude.value ==
                                      0) {
                                    Get.rawSnackbar(
                                        message: "Make sure you selected the pickup and dropoff location",
                                        borderRadius: 20,
                                        margin: EdgeInsets.all(5),
                                        backgroundColor: Colors.red);
                                    NavigationController
                                        .controller.currentIndex.value = 0;
                                  } else {
                                     if (NavigationController.controller.cost.value==0){
                                       Get.rawSnackbar(
                                           message: "Book ride first",
                                           borderRadius: 20,
                                           margin: EdgeInsets.all(5),
                                           backgroundColor: Colors.red);
                                       NavigationController.controller.currentIndex.value=0;
                                     }else{
                                       if (WalletController
                                           .controller.connected.value) {

                                         if (WalletController
                                             .controller.balance.value *
                                             NavigationController.controller.DZDTOETH! <
                                             NavigationController
                                                 .controller.cost.value
                                                 .toDouble()) {
                                           Get.rawSnackbar(
                                               message:
                                               "Not enough balance to pay the ride",
                                               borderRadius: 20,
                                               margin: EdgeInsets.all(5),
                                               backgroundColor: Colors.red);
                                         } else {
                                           // NavigationController
                                           //     .controller.subscription
                                           //     ?.resume();

                                           NavigationController.controller
                                               .currentIndex.value = 2;
                                           NavigationController
                                               .controller.confirmed = true;

                                         }

                                       } else {
                                         Get.rawSnackbar(
                                             message:
                                             "Connect your MetaMask wallet first",
                                             borderRadius: 20,
                                             margin: EdgeInsets.all(5),
                                             backgroundColor: Colors.red);
                                       }
                                     }


                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Confirm",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(FontAwesomeIcons.check)
                                    ],
                                  ),
                                )),
                          )
                        ],
                      )
                    ],
                  )),
            ),
          ),
        ))
        // Positioned(
        //     bottom: 50,
        //     right: 50,
        //     child: FloatingActionButton(onPressed: () async {},child: Icon(Icons.location_searching_sharp),))
      ],
    );
  }
}
