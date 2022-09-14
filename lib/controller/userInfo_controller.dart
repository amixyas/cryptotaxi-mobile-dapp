import 'dart:io';

import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/profile_controller.dart';
import 'package:cryptotaxi/view/homePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class UserInfoController extends GetxController {
  var currentIndex = 0.obs;
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController car = TextEditingController();
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  var selectedDate = DateFormat.yMd().format(DateTime.now().subtract(Duration(days: 6570))).obs;
  var phonenumber = ''.obs;
  var selectedGender = "Male".obs;
  var country = "Algeria".obs;
  var client = true.obs;
  var progress = 0.0.obs;
  var index = 0.obs;
  List<String> imgUrl = [];
  List<String> documentsUrl = [];
  RxList<XFile>? images = <XFile>[].obs;
  RxList<XFile>? documents = <XFile>[].obs;

  Rx<bool> isLoading = Rx<bool>(false);

  Future uploadImages(int a, File file) async {
    index.value = a;
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child(AuthController.controller.auth!.currentUser!.uid)
        .child("car")
        .child(a.toString())
        .putFile(file);
    task.snapshotEvents.listen((event) {
      progress.value =
          ((event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
      print(progress.value);
    });
    await task.whenComplete(() async {
      var s = await task.storage
          .ref()
          .child(AuthController.controller.auth!.currentUser!.uid)
          .child("car")
          .child(a.toString())
          .getDownloadURL();
      print("This is Img Url $s");
      imgUrl.add(s);
    });
  }

  Future uploadDocuments(int a, File file) async {
    index.value = a + images!.length;
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child(AuthController.controller.auth!.currentUser!.uid)
        .child("documents")
        .child(a.toString())
        .putFile(file);
    task.snapshotEvents.listen((event) {
      progress.value =
          ((event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
      print(progress.value);
    });
    await task.whenComplete(() async {
      var s = await task.storage
          .ref()
          .child(AuthController.controller.auth!.currentUser!.uid)
          .child("documents")
          .child(a.toString())
          .getDownloadURL();
      print("This is Img Url $s");
      documentsUrl.add(s);
    });
  }

  Future<void> saveData() async {
    // isLoading.value=true;
    await Future.delayed(Duration(seconds: 2));
    var s = "";
    if (client.value) {
      s = "client";
    } else {
      s = "driver";
    }
    var map = {
      'name': name.text.trim(),
      'firstUse': false,
      'birthdate': selectedDate.value,
      'phone': phonenumber.value,
      'role': s,
      'gender': selectedGender.value,
      'country': country.value,
      'address': address.text.trim(),
      'totalRides': 0,
      'rating': 0.0,
      'currentRide': 'none'
    };
    var mapD = {
      'name': name.text.trim(),
      'firstUse': false,
      'birthdate': selectedDate.value,
      'phone': phonenumber.value,
      'role': s,
      'gender': selectedGender.value,
      'country': country.value,
      'address': address.text.trim(),
      'imgs': imgUrl,
      'docs': documentsUrl,
      'totalRides': 0,
      'rating': 0.0,
      'currentRide': 'none',
      'car': car.text,
      'motif': ''
    };
    if (AuthController.controller.auth!.currentUser!.photoURL == null) {
      await FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(AuthController.controller.auth!.currentUser!.uid)
          .child("profileImg")
          .set("https://cdn-icons-png.flaticon.com/512/219/219983.png");
    }else
    {
      await FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(AuthController.controller.auth!.currentUser!.uid)
          .child("profileImg")
          .set(AuthController.controller.auth!.currentUser!.photoURL);
    }
    if (s == "client") {
      await ref
          .child("users")
          .child(AuthController.controller.firebaseUser.value!.uid)
          .update(map);
    } else {
      await ref
          .child("users")
          .child(AuthController.controller.firebaseUser.value!.uid)
          .update(mapD);
      var docMap = {
        'driverID': AuthController.controller.firebaseUser.value!.uid,
        'address': address.text.trim(),
        'car': car.text
      };

      var refPush =
          FirebaseDatabase.instance.ref().child("driversConfirmation").push();
      await refPush.update(docMap);
    }

    // isLoading.value=false;
    ProfileController.controller.getImages();
    currentIndex.value = 0;
    name.clear();
    phonenumber.value = "";
    phone.clear();
    address.clear();
    images?.clear();
    documents?.clear();
    documentsUrl.clear();
    imgUrl.clear();
    AuthController.controller
        .initialScreen(AuthController.controller.auth!.currentUser);
  }
}
