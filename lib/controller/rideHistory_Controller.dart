import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:core';

import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/model/rideHistory.dart';
import 'package:duration/duration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../model/driver.dart';
import 'SC_controller.dart';

class RideHistoryController extends GetxController {
  static RideHistoryController controller = Get.find();
  RxList<History> rideHistoryList = <History>[].obs;
  RxMap<String, int> days = <String, int>{}.obs;
  DatabaseReference? commentsRef;
  Stream<DatabaseEvent>? stream;
  StreamSubscription? commentsStream;
  var total = 0.0.obs;
  var t1 = 0.0.obs;
  var t2 = 0.0.obs;
  var t3 = 0.0.obs;
  var t4 = 0.0.obs;
  var t5 = 0.0.obs;
  var t6 = 0.0.obs;
  var t7 = 0.0.obs;
  var d1 = 0.obs;
  var d2 = 0.obs;
  var d3 = 0.obs;
  var d4 = 0.obs;
  var d5 = 0.obs;
  var d6 = 0.obs;
  var d7 = 0.obs;
  late double rate;
  var already= false;
  Future getData() async {
    if (already) return ;
    else{
      commentsRef?.onDisconnect();
      commentsRef=null;
      already=true;
      var request = await http.get(Uri.parse(
          'https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=DZD'));
      commentsRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(AuthController.controller.auth!.currentUser!.uid)
          .child("history")
          .ref;
      if (request.statusCode == 200) {
        print(request);
      }
      final data = jsonDecode(request.body);
      print(data['DZD']);
      rate = double.parse(data['DZD'].toString());

      commentsRef?.onChildAdded.listen((event) {
        // A new comment has been added, so add it to the displayed list.
        print("CHILD ADDDDDED");
        print(event.snapshot.value.toString());
      });
      commentsRef?.onChildChanged.listen((event) {
        // A comment has changed; use the key to determine if we are displaying this
        // comment and if so displayed the changed comment.
      });
      commentsRef?.onChildRemoved.listen((event) {
        // A comment has been removed; use the key to determine if we are displaying
        // this comment and if so remove it.
      });
      stream =commentsRef?.onValue;

      commentsStream =  stream?.listen((element) async {
        rideHistoryList.clear();
        total.value = 0;
        t1 = 0.0.obs;
        t2 = 0.0.obs;
        t3 = 0.0.obs;
        t4 = 0.0.obs;
        t5 = 0.0.obs;
        t6 = 0.0.obs;
        t7 = 0.0.obs;
        d1 = 0.obs;
        d2 = 0.obs;
        d3 = 0.obs;
        d4 = 0.obs;
        d5 = 0.obs;
        d6 = 0.obs;
        d7 = 0.obs;
        for (final child in element.snapshot.children) {
          print(RideHistoryController.controller.rideHistoryList.length);
          print('test');
          print(child.value);
          print(child.key);
          print('end test');
          var res = child.value as Map;
          print(child.key);
          var result = await SC_Controller.controller
              .readContract(SC_Controller.controller.getRideAddress, [child.key]);
          print(result.first);
          DataSnapshot es;
          History? h;
          try{
            if (AuthController.controller.role.value == "client") {
              es = await FirebaseDatabase.instance
                  .ref()
                  .child("users")
                  .child(result.first[2])
                  .get();
            } else {
              es = await FirebaseDatabase.instance
                  .ref()
                  .child("users")
                  .child(result.first[1])
                  .get();
            }

            // Map<String,dynamic> map = s.value as Map<String,dynamic>;
            Driver d;
            print('${es.key}');
            if (AuthController.controller.role.value == "client") {
              d = Driver(
                  id: result.first[2],
                  profileImage: es.child("profileImg").value.toString(),
                  phone: es.child("phone").value.toString(),
                  rating: double.parse(es.child("rating").value.toString()),
                  name: es.child("name").value.toString(),totalRides: es.child("totalRides").value.toString());
            } else {
              d = Driver(
                  id: result.first[1],
                  profileImage: es.child("profileImg").value.toString(),
                  phone: es.child("phone").value.toString(),
                  rating: double.parse(es.child("rating").value.toString()),
                  name: es.child("name").value.toString(),totalRides: es.child("totalRides").value.toString());
            }
            // var r=  parseDuration(res["duration"].toString());
            var aa = await placemarkFromCoordinates(
                double.parse(result.first[5][0]), double.parse(result.first[5][1]));
            var pick =
                "${aa[0].street ?? ""}  ${aa.first.subAdministrativeArea ?? ""} ,${aa[0].locality ?? ""} ";
            var aaa = await placemarkFromCoordinates(
                double.parse(result.first[6][0]), double.parse(result.first[6][1]));
            var picka =
                "${aaa[0].street ?? ""}  ${aaa.first.subAdministrativeArea ?? ""} ,${aaa[0].locality ?? ""} ";
            var s = (EtherAmount.fromUnitAndValue(EtherUnit.wei,
                BigInt.from(int.parse(result.first[7].toString())))
                .getValueInUnit(EtherUnit.ether)) *
                rate;

             h = History(
                child.key!,
                res["duration"].toString(),
                DateTime.parse(res["dateTime"].toString()),
                pick,
                picka,
                d,
                s.truncate().toString(),
                DateTime.parse(res["dateTime"].toString())
                    .add(Duration(seconds: int.parse(res["duration"].toString()))));

            print("HEY ${h.time} ${h.duration}${h.id} ${h.driver!.id}");
            rideHistoryList.add(h);
          } catch (er){
             print(er);
          }

        }

        rideHistoryList.sort(
              (a, b) {
            return b.time.compareTo(a.time);
          },
        );

        print("GETTING HISTORY DONE lengh is ${rideHistoryList.length}");
        if (AuthController.controller.role.value == "driver") {
          if (rideHistoryList.length > 0) {
            d1.value = DateTime.now().weekday;
            d2.value = d1.value - 1;
            if (d2.value == 0) {
              d2.value = 7;
            }
            d3.value = d2.value - 1;
            if (d3.value == 0) {
              d3.value = 7;
            }
            d4.value = d3.value - 1;
            if (d4.value == 0) {
              d4.value = 7;
            }
            d5.value = d4.value - 1;
            if (d5.value == 0) {
              d5.value = 7;
            }
            d6.value = d5.value - 1;
            if (d6.value == 0) {
              d6.value = 7;
            }
            d7.value = d6.value - 1;
            if (d7.value == 0) {
              d7.value = 7;
            }
            print(d1.value);
            print(d2.value);
            print(d3.value);
            print(d4.value);
            print(d5.value);
            print(d6.value);
            print(d7.value);
            for (var a in rideHistoryList) {
              total.value = total.value + double.parse(a.cost.toString());
              print("TOTAL VALUE IS ${total.value}");
              print(a.time.toString());
              DateTime date = a.time;
              print("KHalil Ali ${a.time} ${a.time.weekday}");

              if (DateTime.now().difference(date) <= Duration(days: 1) &&
                  (date.weekday == d1.value)) {
                print('DAY 1 FOUND');
                double t = double.parse(a.cost.toString());
                t1.value = t1.value + t;
              }
              if ((DateTime.now().difference(date) <= Duration(days: 2)) &&
                  (date.weekday == d2.value)) {
                print('DAY 2 FOUND');
                double t = double.parse(a.cost.toString());
                t2.value = t2.value + t;
              }
              if ((DateTime.now().difference(date) <= Duration(days: 3)) &&
                  (date.weekday == d3.value)) {
                print('DAY 3 FOUND');
                double t = double.parse(a.cost.toString());
                t3.value = t3.value + t;
              }
              if ((DateTime.now().difference(date) <= Duration(days: 4)) &&
                  (date.weekday == d4.value)) {
                print('DAY 4 FOUND');
                double t = double.parse(a.cost.toString());
                t4.value = t4.value + t;
              }
              if ((DateTime.now().difference(date) <= Duration(days: 5)) &&
                  (date.weekday == d5.value)) {
                print('DAY 5 FOUND');
                double t = double.parse(a.cost.toString());
                t5.value = t5.value + t;
              }
              if ((DateTime.now().difference(date) <= Duration(days: 6)) &&
                  (date.weekday == d6.value)) {
                print('DAY 6 FOUND');
                double t = double.parse(a.cost.toString());
                t6.value = t6.value + t;
              }
              if ((DateTime.now().difference(date) <= Duration(days: 7)) &&
                  (date.weekday == d7.value)) {
                print('DAY 7 FOUND');
                double t = double.parse(a.cost.toString());
                t7.value = t7.value + t;
              }
            }
            print('print T1 T7');
            print("T1 ${t1.value}");
            print("T2 ${t2.value}");
            print("T3 ${t3.value}");
            print("T4 ${t4.value}");
            print("T5 ${t5.value}");
            print("T6 ${t6.value}");
            print("T7 ${t7.value}");
          }
        }
      });

    }


  }
  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();

  }
  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    commentsRef?.onDisconnect();
  }
}
