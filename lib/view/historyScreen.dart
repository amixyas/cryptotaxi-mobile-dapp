import 'package:auto_size_text/auto_size_text.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/rideHistory_Controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:date_checker/date_checker.dart';
import 'package:duration/duration.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:one_context/one_context.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({Key? key}) : super(key: key);
  var myGroup = AutoSizeGroup();

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.bottom,
          width: MediaQuery.of(context).size.width,
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text('My Trips',
                                  style: GoogleFonts.ubuntu(
                                    textStyle: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(0.0, 1.0),
                                            blurRadius: 1.0,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          // Shadow(
                                          //   offset: Offset(0.0, 2.0),
                                          //   blurRadius: 8.0,
                                          //   color: Color.fromARGB(125, 0, 0, 255),
                                          // ),
                                        ],
                                        color: textcolor),
                                  ))),
                          if (RideHistoryController
                              .controller.rideHistoryList.isNotEmpty)
                            IconButton(
                                onPressed: () async {
                                  if (await confirm(OneContext().context!,
                                      title: Text("Delete Confirmation"),
                                      content: Text(
                                          "Are you sure you want to delete all the ride history!"))) {
                                    await FirebaseDatabase.instance
                                        .ref()
                                        .child("users")
                                        .child(AuthController
                                            .controller.auth!.currentUser!.uid)
                                        .child("history")
                                        .remove();
                                  }
                                },
                                icon: Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.red,
                                ))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      RideHistoryController.controller.rideHistoryList.isEmpty
                          ? Container(
                              padding: EdgeInsets.all(16),
                              height: 500,
                              width: double.infinity,
                              child: Center(
                                  child: Text(
                                "No records found",
                                style: GoogleFonts.roboto(
                                    fontSize: 26,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              )),
                            )
                          : SizedBox(
                              height:
                                  OneContext().mediaQuery.size.height * 0.75,
                              child: ListView.separated(
                                physics: BouncingScrollPhysics(),
                                itemCount: RideHistoryController
                                    .controller.rideHistoryList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            RideHistoryController
                                                    .controller
                                                    .rideHistoryList[index]
                                                    .time
                                                    .isToday
                                                ? "Today"
                                                : RideHistoryController
                                                        .controller
                                                        .rideHistoryList[index]
                                                        .time
                                                        .isYesterday
                                                    ? "Yesterday"
                                                    : DateFormat('yyyy-MM-dd')
                                                        .format(
                                                            RideHistoryController
                                                                .controller
                                                                .rideHistoryList[
                                                                    index]
                                                                .time),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: textcolor),
                                          )),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        elevation: 10,
                                        child: InkWell(
                                          onLongPress: () async {
                                            if (await confirm(
                                                OneContext().context!,
                                                title:
                                                    Text("Delete Confirmation"),
                                                content: Text(
                                                    "Are you sure you want to delete this ride from history!"))) {
                                              await FirebaseDatabase.instance
                                                  .ref()
                                                  .child("users")
                                                  .child(AuthController
                                                      .controller
                                                      .auth!
                                                      .currentUser!
                                                      .uid)
                                                  .child("history")
                                                  .child(RideHistoryController
                                                      .controller
                                                      .rideHistoryList[index]
                                                      .id)
                                                  .remove();
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  FontAwesomeIcons.locationDot,
                                                  color: Colors.blueAccent,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                title: AutoSizeText(
                                                  "${RideHistoryController.controller.rideHistoryList[index].pickUpAddress}",
                                                  style: TextStyle(
                                                      color: textcolor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  group: myGroup,
                                                ),
                                                trailing: Text(DateFormat.Hm()
                                                    .format(
                                                        RideHistoryController
                                                            .controller
                                                            .rideHistoryList[
                                                                index]
                                                            .time)),
                                              ),
                                              ListTile(
                                                leading: Icon(
                                                  FontAwesomeIcons
                                                      .locationCrosshairs,
                                                  color: Colors.green,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                title: AutoSizeText(
                                                  "${RideHistoryController.controller.rideHistoryList[index].dropOffAddress}",
                                                  style: TextStyle(
                                                      color: textcolor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  group: myGroup,
                                                ),
                                                trailing: Text(DateFormat.Hm()
                                                    .format(
                                                        RideHistoryController
                                                            .controller
                                                            .rideHistoryList[
                                                                index]
                                                            .neTime!)),
                                              ),
                                              Divider(),
                                              Padding(
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
                                                        "${RideHistoryController.controller.rideHistoryList[index].driver!.profileImage}",
                                                        fit: BoxFit.fill,
                                                        height: 40,
                                                        width: 40,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 6,
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        // height: 50,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            AutoSizeText(
                                                              "${RideHistoryController.controller.rideHistoryList[index].driver!.name}",
                                                              style: TextStyle(
                                                                  color:
                                                                      textcolor,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Row(
                                                              children: [
                                                                AutoSizeText(
                                                                  "${RideHistoryController.controller.rideHistoryList[index].driver!.rating!.toStringAsFixed(2)}",
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
                                                                  color: Colors
                                                                      .amber,
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Final cost",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    textcolor),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            "DA ${RideHistoryController.controller.rideHistoryList[index].cost}",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Time",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    textcolor),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            "${format(Duration(seconds: int.parse(RideHistoryController.controller.rideHistoryList[index].duration)))}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                    height: 12,
                                  );
                                },
                              ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
