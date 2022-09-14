import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/driver_controller.dart';
import 'package:cryptotaxi/controller/navigation_controller.dart';
import 'package:cryptotaxi/controller/ride_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/view/driverDetails.dart';
import 'package:cryptotaxi/view/rideScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:one_context/one_context.dart';
import 'package:sliding_switch/sliding_switch.dart';

import '../controller/notification_controller.dart';

class DriverList extends StatefulWidget {
  DriverList({Key? key}) : super(key: key);
  static String routename = "driverlist";

  @override
  State<DriverList> createState() => _DriverListState();
}

class _DriverListState extends State<DriverList> {
  late MediaQueryData size;
  var myGroup = AutoSizeGroup();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (AuthController.controller.role.value == "client") {
      get();
    }
  }

  void get() async {
    await Future.delayed(Duration(seconds: 2));
    await NavigationController.controller.getDrivers();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context);
    return Container(
        height: size.size.height - size.padding.top - size.padding.bottom,
        width: size.size.width,
        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Obx(
          () => Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: "Searching range : ",
                      children: [
                        TextSpan(
                            text:
                                "${NavigationController.controller.range.value.toStringAsFixed(2)} Km.",
                            style: TextStyle(fontSize: 20, color: Colors.green))
                      ],
                      style: TextStyle(
                        fontSize: 20,
                        shadows: <Shadow>[
                          Shadow(
                            offset:
                            Offset(0.0, 0.5),
                            blurRadius: 1,
                            color: Color.fromARGB(
                                255, 0, 0, 0),
                          ),
                          // Shadow(
                          //   offset: Offset(0.0, 2.0),
                          //   blurRadius: 8.0,
                          //   color: Color.fromARGB(125, 0, 0, 255),
                          // ),
                        ],
                        color: Color.fromARGB(255, 23, 43, 77),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              SizedBox(
                height: 15,
              ),
              Slider(
                label: "${NavigationController.controller.range.value.toStringAsFixed(2)} Km",
                divisions: 19,
                onChanged: (value) {
                  NavigationController.controller.range.value = value;
                },
                value: NavigationController.controller.range.value,
                onChangeEnd: (value) {
                  NavigationController.controller.getDrivers();
                  print(
                      "range is ${NavigationController.controller.range.value}");
                },


                min: 1,
                max: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sort by:",
                    style: TextStyle(
                      fontSize: 16,
                      shadows: <Shadow>[
                        Shadow(
                          offset:
                          Offset(0.0, 0.5),
                          blurRadius: 1,
                          color: Color.fromARGB(
                              255, 0, 0, 0),
                        ),
                        // Shadow(
                        //   offset: Offset(0.0, 2.0),
                        //   blurRadius: 8.0,
                        //   color: Color.fromARGB(125, 0, 0, 255),
                        // ),
                      ],
                      color: Color.fromARGB(255, 23, 43, 77),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SlidingSwitch(
                    value: NavigationController.controller.sortByDistance.value,
                    onChanged: (bool value) async {
                      print(value);

                      if (value) {
                        NavigationController.controller.sortByDistance.value =
                            value;
                        NavigationController.controller.listdriver.sort(
                          (a, b) {
                            return a.distance!.compareTo(b.distance!);
                          },
                        );
                      } else {
                        NavigationController.controller.sortByDistance.value =
                            value;
                        NavigationController.controller.listdriver.sort(
                          (a, b) {
                            return b.rating!.compareTo(a.rating!);
                          },
                        );
                      }

                      print(
                          NavigationController.controller.sortByDistance.value);
                    },
                    animationDuration: const Duration(milliseconds: 400),
                    onTap: () {},
                    onDoubleTap: () {},
                    onSwipe: () {},
                    height: 40,
                    textOff: "Rating",
                    textOn: "Distance",
                    colorOn: Colors.green,
                    colorOff: Colors.red,
                    background: const Color(0xffe4e5eb),
                    buttonColor: const Color(0xfff7f5f7),
                    inactiveColor: const Color(0xff636f7b),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Available drivers : ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 23, 43, 77),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (NavigationController.controller.listdriver.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 120,
                    ),
                    Container(
                      // height: MediaQuery.of(context).size.height,
                      // width: MediaQuery.of(context).size.width,

                      child: const Center(
                        child: Text(
                          "No available drivers at the moment",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                          maxLines: 3,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Expanded(
                  child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 20),
                      itemCount:
                          NavigationController.controller.listdriver.length,
                      separatorBuilder: (ctx, int) => Divider(
                            height: 5,
                          ),
                      itemBuilder: (ctx, index) {
                        return Card(
                          // margin: EdgeInsets.only(top: 20,bottom: 20),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: InkWell(
                            onTap: () async {
                              if (NavigationController.controller.confirmed) {
                                RideController.controller.carImg.clear();
                                RideController.controller.getImages(
                                    NavigationController
                                        .controller.listdriver[index]);
                                RideController.controller.driver =
                                    NavigationController
                                        .controller.listdriver[index];

                                var s = await Get.to(
                                    () => DriverDetails(
                                        driver: NavigationController
                                            .controller.listdriver[index]),
                                    duration: Duration(milliseconds: 500),
                                    transition: Transition.cupertino);
                                print("this is ridescreen $s");
                                if (s == "ridescreen") {
                                  EasyLoading.show(status: "Loading ...");
                                  RideController.controller.listten();
                                  await Future.delayed(Duration(seconds: 2));
                                  EasyLoading.dismiss();
                                  Get.to(() => RideScreen(),
                                      duration: Duration(milliseconds: 500),
                                      transition: Transition.cupertino);
                                }
                              } else {
                                Get.rawSnackbar(
                                    message: "Confirm the trip first!",
                                    borderRadius: 20,
                                    margin: EdgeInsets.all(5),
                                    backgroundColor: Colors.red);
                                NavigationController
                                    .controller.currentIndex.value = 1;
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5,left: 16,right: 0,bottom: 4,
                                  ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          NavigationController.controller
                                              .listdriver[index].profileImage!,
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Expanded(flex: 1, child: SizedBox()),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: Text(
                                                NavigationController.controller
                                                    .listdriver[index].name!,
                                                style: TextStyle(
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        offset:
                                                            Offset(0.0, 0.5),
                                                        blurRadius: 1,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                      ),
                                                      // Shadow(
                                                      //   offset: Offset(0.0, 2.0),
                                                      //   blurRadius: 8.0,
                                                      //   color: Color.fromARGB(125, 0, 0, 255),
                                                      // ),
                                                    ],
                                                    fontWeight: FontWeight.bold,letterSpacing: 1.2,
                                                    color: textcolor,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: Text(
                                                NavigationController.controller
                                                    .listdriver[index].car!,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: textcolor,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // Row(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Text(
                                  //       "Address",
                                  //       style: TextStyle(
                                  //           fontWeight: FontWeight.bold,
                                  //           color: textcolor),
                                  //     ),
                                  //     SizedBox(
                                  //       width: OneContext()
                                  //               .mediaQuery
                                  //               .size
                                  //               .width *
                                  //           0.6,
                                  //       child: Text(
                                  //         NavigationController
                                  //             .controller
                                  //             .listdriver[index]
                                  //             .placeFormattedAddress!,
                                  //         overflow: TextOverflow.ellipsis,
                                  //         maxLines: 1,
                                  //         // style: TextStyle(color: Colors.black),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          AutoSizeText(
                                            "Rating: ${NavigationController.controller.listdriver[index].rating!.toStringAsPrecision(2)}",group: myGroup,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: textcolor),maxLines: 1,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                          )
                                        ],
                                      ),SizedBox(width: 10,),
                                      Row(
                                        children: [
                                          AutoSizeText(
                                            "Total Rides",
                                            group: myGroup,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: textcolor),maxLines: 1,
                                          ),
                                          AutoSizeText(
                                            " ${NavigationController.controller.listdriver[index].totalRides}",
                                            group: myGroup,
                                            style:
                                                TextStyle(color: Colors.red),maxLines: 1,
                                          )
                                        ],
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            AutoSizeText(
                                              "Distance",
                                              group: myGroup,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textcolor),maxLines: 1,
                                            ),
                                            AutoSizeText(
                                              " ${NavigationController.controller.listdriver[index].distance!.toStringAsFixed(2)}Km",
                                              group: myGroup,
                                              style: TextStyle(color: Colors.red),maxLines: 1,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
            ],
          ),
        ));
  }
}
