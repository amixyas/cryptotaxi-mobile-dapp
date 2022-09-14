import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cryptotaxi/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:one_context/one_context.dart';

import '../controller/rideHistory_Controller.dart';

class EarningScreen extends StatefulWidget {
  EarningScreen({Key? key}) : super(key: key);
  final List<Color> availableColors = const [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.blueAccent,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? Colors.yellow : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.yellow, width: 1)
              : const BorderSide(color: Colors.blueAccent, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 1,
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(RideHistoryController.controller.d7.value,
                RideHistoryController.controller.t7.value,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(RideHistoryController.controller.d6.value,
                RideHistoryController.controller.t6.value,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(RideHistoryController.controller.d5.value,
                RideHistoryController.controller.t5.value,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(RideHistoryController.controller.d4.value,
                RideHistoryController.controller.t4.value,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(RideHistoryController.controller.d3.value,
                RideHistoryController.controller.t3.value,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(RideHistoryController.controller.d2.value,
                RideHistoryController.controller.t2.value,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(RideHistoryController.controller.d1.value,
                RideHistoryController.controller.t1.value,
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 1:
                  weekDay = 'Monday';
                  break;
                case 2:
                  weekDay = 'Tuesday';
                  break;
                case 3:
                  weekDay = 'Wednesday';
                  break;
                case 4:
                  weekDay = 'Thursday';
                  break;
                case 5:
                  weekDay = 'Friday';
                  break;
                case 6:
                  weekDay = 'Saturday';
                  break;
                case 7:
                  weekDay = 'Sunday';
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                weekDay + '\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY - 1).toString(),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
      ),
      minY: 0,
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('M', style: style);
        break;
      case 2:
        text = const Text('T', style: style);
        break;
      case 3:
        text = const Text('W', style: style);
        break;
      case 4:
        text = const Text('T', style: style);
        break;
      case 5:
        text = const Text('F', style: style);
        break;
      case 6:
        text = const Text('S', style: style);
        break;
      case 7:
        text = const Text('S', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return Padding(padding: const EdgeInsets.only(top: 16), child: text);
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
        animDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      await refreshState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.all(16),
      child: Obx(() => SingleChildScrollView(
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Statistics',
                    style: GoogleFonts.ubuntu(
                      textStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textcolor),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text(
                    "Total earnings: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textcolor,
                        fontSize: 22),
                  ),
                  Text(
                    'DA ${double.parse(RideHistoryController.controller.total.toString()).toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Stack(
                children: <Widget>[
                  Container(
                    height: OneContext().mediaQuery.size.height * 0.5,
                    width: OneContext().mediaQuery.size.width,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                        color: Color(0xff232d37)),
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: BarChart(
                          mainBarData(),
                          swapAnimationDuration: animDuration,
                        )),
                  ),

                  // SizedBox(
                  //   width: 60,
                  //   height: 34,
                  //   child: TextButton(
                  //     onPressed: () {
                  //
                  //     },
                  //     child: Text(
                  //       'avg',
                  //       style: TextStyle(
                  //           fontSize: 12,
                  //           color:
                  //        Colors.white.withOpacity(0.5)),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "History: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textcolor,
                      fontSize: 22),
                ),
              ),
              RideHistoryController.controller.rideHistoryList.isEmpty
                  ? Container(
                padding: EdgeInsets.all(16),
                height: 100,
                width: double.infinity,
                child: Center(child: Text("No records found",style: GoogleFonts.roboto(fontSize: 26,color: Colors.red,fontWeight: FontWeight.bold),)),
              ): SizedBox(
                  height: OneContext().mediaQuery.size.height * 0.3,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount:
                        RideHistoryController.controller.rideHistoryList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText(
                                    RideHistoryController.controller
                                        .rideHistoryList[index].driver!.name!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textcolor),
                                  ),
                                  AutoSizeText(
                                    "${RideHistoryController.controller.rideHistoryList[index].cost!} DA",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText(
                                    DateFormat('yyyy-MM-dd hh:mm').format(
                                        RideHistoryController.controller
                                            .rideHistoryList[index].time),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  AutoSizeText(
                                      "${format(Duration(seconds: int.parse(RideHistoryController.controller.rideHistoryList[index].duration)))}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent))
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ))
            ]),
          )),
    ));
  }
}
