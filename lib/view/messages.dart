import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/driver_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart' as Loc;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../controller/navigation_controller.dart';
import '../controller/wallet_controller.dart';
import '../main.dart';

class WalletConnectEthereumCredentials extends CustomTransactionSender {
  WalletConnectEthereumCredentials({required this.provider});

  final EthereumWalletConnectProvider provider;

  @override
  Future<EthereumAddress> extractAddress() async {
    // TODO: implement extractAddress
    return EthereumAddress.fromHex(
        WalletController.controller.connector.session.accounts[0]);
  }

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    final hash = await provider.sendTransaction(
      from: transaction.from!.hex,
      to: transaction.to?.hex,
      data: transaction.data,
      gas: transaction.maxGas,
      gasPrice: transaction.gasPrice?.getInWei,
      value: transaction.value?.getInWei,
      nonce: transaction.nonce,
    );

    return hash;
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToSignature
    throw UnimplementedError();
  }
}

class Messages extends StatefulWidget {
  Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Loc.Location location = Loc.Location();

  void _onMapCreated(GoogleMapController controller) async {
    // mapController = controller;
    NavigationController.controller.drivermapcontroller = controller;
    var result = await NavigationController.controller.locateposition();
    var address =
        await placemarkFromCoordinates(result.latitude, result.longitude);
    print("aaaaaaaaaaaaaaaaaaaaa $address");
    var s =
        "${address[0].street ?? ""}  ${address.first.subAdministrativeArea ?? ""} ,${address[0].administrativeArea ?? ""} ";

    NavigationController.controller
        .updateLocation(result.latitude, result.longitude, s);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              polylines: DriverController.controller.polylines.value,
              markers: DriverController.controller.markers.value,
              onMapCreated: _onMapCreated),
        ),
        Obx(() => Positioned(
              top: 20,
              left: 10,
              right: 10,
              child: ShowUpAnimation(
                delayStart: Duration(seconds: 0),
                animationDuration: Duration(seconds: 1),
                curve: Curves.decelerate,
                direction: Direction.vertical,
                offset: 0.5,
                child: AnimatedContainer(
                  height: MediaQuery.of(context).size.height * 0.20,
                  width: double.infinity,
                  duration: Duration(milliseconds: 800),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      color: Colors.white,
                      // gradient: DriverController.controller.isOnline.value
                      //     ? LinearGradient(
                      //         begin: Alignment.topCenter,
                      //         end: Alignment.bottomCenter,
                      //         colors: [
                      //           Colors.white,
                      //           Colors.white,
                      //         ],
                      //       )
                      //     : LinearGradient(
                      //         begin: Alignment.topCenter,
                      //         end: Alignment.bottomCenter,
                      //         colors: [
                      //           Colors.green.shade50,
                      //           Colors.green.shade700,
                      //         ],
                      //       ),
                      borderRadius: BorderRadius.circular(30)),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShowUpAnimation(
                          delayStart: Duration(seconds: 1),
                          animationDuration: Duration(seconds: 1),
                          curve: Curves.decelerate,
                          direction: Direction.vertical,
                          offset: 0.5,
                          child: Align(
                              alignment: Alignment.center,
                              child: AutoSizeText(
                                AuthController.controller.appUser!.value.fullname!,
                                minFontSize: 18,
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.blue),
                              )),
                        ),
                        ShowUpAnimation(
                          delayStart: Duration(seconds: 1, milliseconds: 300),
                          animationDuration: Duration(seconds: 1),
                          curve: Curves.decelerate,
                          direction: Direction.vertical,
                          offset: 0.5,
                          child: Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                                AuthController.controller.appUser!.value.car!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textcolor),
                                maxLines: 1,
                                minFontSize: 18),
                          ),
                        ),
                        ShowUpAnimation(
                            delayStart: Duration(seconds: 1, milliseconds: 600),
                            animationDuration: Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            offset: 0.5,
                            child: DriverController.controller.isOnline.value
                                ? BouncingWidget(
                                    duration: Duration(milliseconds: 400),
                                    scaleFactor: 2,
                                    onPressed: () async {
                                      print('going offline');
                                      // await Future.delayed(
                                      //     Duration(milliseconds: 400));
                                      await DriverController.controller
                                          .makeDriverOffline();
                                    },
                                    child: Material(
                                        color: Colors.green.shade400,
                                        elevation: 10,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("ONLINE",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                FontAwesomeIcons.carOn,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        )),
                                  )
                                : BouncingWidget(
                                    duration: Duration(milliseconds: 300),
                                    scaleFactor: 2,
                                    child: Material(
                                        color: Colors.red.shade400,
                                        elevation: 10,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("OFFLINE",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                FontAwesomeIcons.powerOff,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        )),
                                    onPressed: () async {
                                      print('going online');

                                      if (WalletController
                                          .controller.connected.value) {

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
                                            return;
                                          }
                                        }
                                        await DriverController.controller
                                            .makeDriverOnlineNow();
                                        DriverController.controller
                                            .getLocationLiveUpdate();
                                        DriverController
                                            .controller.isOnline.value = true;
                                      } else {
                                        Get.rawSnackbar(
                                            message:
                                                "Connect your MetaMask wallet first",
                                            borderRadius: 20,
                                            margin: EdgeInsets.all(5),
                                            backgroundColor: Colors.red);
                                      }
                                    })),
                        // Center(
                        //     child: Obx(
                        //   () => DriverController.controller.isOnline.value
                        //       ? ElevatedButton(
                        //           onPressed: () async {
                        //             await DriverController.controller
                        //                 .makeDriverOffline();
                        //
                        //             // DriverController.controller.homesteamsub.cancel();
                        //             // DriverController.controller.isonline.value=!DriverController.controller.isonline.value;
                        //           },
                        //           style: ElevatedButton.styleFrom(
                        //               primary: Colors.green,
                        //               padding: EdgeInsets.symmetric(
                        //                   horizontal: 20, vertical: 10),
                        //               textStyle: TextStyle(
                        //                   fontSize: 24,
                        //                   fontWeight: FontWeight.bold)),
                        //           child: Container(
                        //             width:
                        //                 MediaQuery.of(context).size.width * 0.5,
                        //             child: Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.spaceAround,
                        //               children: [
                        //                 Text("ONLINE"),
                        //                 Icon(Icons.phone_android)
                        //               ],
                        //             ),
                        //           ),
                        //         )
                        //       : ElevatedButton(
                        //           onPressed: () async {
                        //             await DriverController.controller
                        //                 .makeDriverOnlineNow();
                        //             DriverController.controller
                        //                 .getLocationLiveUpdate();
                        //             DriverController.controller.isOnline.value =
                        //                 !DriverController
                        //                     .controller.isOnline.value;
                        //           },
                        //           style: ElevatedButton.styleFrom(
                        //               primary: Colors.red,
                        //               padding: EdgeInsets.symmetric(
                        //                   horizontal: 20, vertical: 10),
                        //               textStyle: TextStyle(
                        //                   fontSize: 24,
                        //                   fontWeight: FontWeight.bold)),
                        //           child: Container(
                        //             width:
                        //                 MediaQuery.of(context).size.width * 0.5,
                        //             child: Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.spaceAround,
                        //               children: [
                        //                 Text("OFFLINE"),
                        //                 Icon(Icons.phone_android)
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        // )),
                      ],
                    ),
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
