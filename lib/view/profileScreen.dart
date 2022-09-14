import 'dart:io';
import 'dart:ui';

import 'package:cryptotaxi/controller/profile_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/view/loginScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:one_context/one_context.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:uuid/uuid.dart';

import '../controller/auth_controller.dart';
import '../controller/navigation_controller.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? image;

  XFile? carImage;

  var uuid = Uuid();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ProfileController.controller.detector.startListening();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    ProfileController.controller.detector.stopListening();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Row(
              children: [
                Text(
                  "Sign out",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.arrowRightFromBracket),
                  onPressed: () async {

                    // Get.offAll(LoginScreen());
                    await AuthController.controller.logout();
                    // await Get.deleteAll(force: true);
                    //
                    // ///You can use normal context here within widget.
                    // Phoenix.rebirth(Get.context!);
                    // Get.reset();

                  },
                )
              ],
            )
          ],
        ),
        body: Container(
          padding:
              const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 0),
          width: OneContext().mediaQuery.size.width,
          height: OneContext().mediaQuery.size.height,
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: Obx(() => Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ShowUpAnimation(
                            delayStart: Duration(milliseconds: 0),
                            animationDuration: Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: SizedBox(
                              height: 130,
                              width: 130,
                              child: Stack(children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: (AuthController.controller.auth!
                                                .currentUser!.photoURL !=
                                            null)
                                        ? Image.network(
                                            AuthController.controller.auth!
                                                .currentUser!.photoURL!,
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.fill,
                                          )
                                        : Image.network(
                                            'https://cdn-icons-png.flaticon.com/512/219/219983.png',
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.fill,
                                          )),
                                Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                        height: 36,
                                        width: 36,
                                        decoration: BoxDecoration(
                                            color: Colors.blueAccent,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                            borderRadius:
                                                BorderRadius.circular(80)),
                                        child: Center(
                                          child: IconButton(
                                              onPressed: () async {
                                                image = await _picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);

                                                if (image != null) {
                                                  EasyLoading.show(
                                                      dismissOnTap: false,
                                                      status:
                                                          "Uploading image Please wait");
                                                  UploadTask task =
                                                      FirebaseStorage.instance
                                                          .ref()
                                                          .child(AuthController
                                                              .controller
                                                              .auth!
                                                              .currentUser!
                                                              .uid)
                                                          .child("image")
                                                          .putFile(File(
                                                              image!.path));
                                                  await task
                                                      .whenComplete(() async {
                                                    var s = await task.storage
                                                        .ref()
                                                        .child(AuthController
                                                            .controller
                                                            .auth!
                                                            .currentUser!
                                                            .uid)
                                                        .child("image")
                                                        .getDownloadURL();
                                                    print("This is Img Url $s");
                                                    await AuthController
                                                        .controller
                                                        .auth!
                                                        .currentUser!
                                                        .updatePhotoURL(s);
                                                    await FirebaseDatabase
                                                        .instance
                                                        .ref()
                                                        .child("users")
                                                        .child(AuthController
                                                            .controller
                                                            .auth!
                                                            .currentUser!
                                                            .uid)
                                                        .child("profileImg")
                                                        .set(s);
                                                  });
                                                  EasyLoading.dismiss();
                                                }
                                              },
                                              icon: Icon(
                                                Icons.edit_rounded,
                                                size: 18,
                                                color: Colors.white,
                                              )),
                                        ))),
                              ]),
                            ),
                          ),
                          ShowUpAnimation(
                            delayStart: Duration(milliseconds: 200),
                            animationDuration: Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: Text(
                              "${AuthController.controller.appUser!.value.fullname}",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
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
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 23, 43, 77)),
                            ),
                          ),
                          ProfileController.controller.phoneEdit.value
                              ? Form(
                                  child: ShowUpAnimation(
                                    delayStart: Duration(seconds: 0),
                                    animationDuration: Duration(seconds: 1),
                                    curve: Curves.decelerate,
                                    direction: Direction.vertical,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            width: double.infinity,
                                            child:
                                                InternationalPhoneNumberInput(
                                              spaceBetweenSelectorAndTextField:
                                                  0,
                                              onInputChanged:
                                                  (PhoneNumber number) {
                                                ProfileController.controller
                                                        .phonenumber =
                                                    number.phoneNumber!;

                                                print(number.phoneNumber);
                                              },
                                              onInputValidated: (bool value) {
                                                print(value);
                                              },
                                              selectorConfig: SelectorConfig(
                                                selectorType:
                                                    PhoneInputSelectorType
                                                        .BOTTOM_SHEET,
                                              ),
                                              ignoreBlank: false,
                                              autoValidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              selectorTextStyle: TextStyle(
                                                  color: Colors.black),
                                              initialValue: PhoneNumber(
                                                  isoCode: 'DZ',
                                                  phoneNumber: ProfileController
                                                      .controller.phonenumber),
                                              textFieldController:
                                                  ProfileController
                                                      .controller.phone,
                                              formatInput: false,
                                              inputDecoration: InputDecoration(
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  )),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true,
                                                      decimal: true),
                                              inputBorder: OutlineInputBorder(),
                                              onSaved: (PhoneNumber number) {
                                                print('On Saved: $number');
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            height: 60,
                                            child: IconButton(
                                              onPressed: () async {
                                                var map = {
                                                  'phone': ProfileController
                                                      .controller.phonenumber,
                                                };
                                                await FirebaseDatabase.instance
                                                    .ref()
                                                    .child("users")
                                                    .child(AuthController
                                                        .controller
                                                        .auth!
                                                        .currentUser!
                                                        .uid)
                                                    .update(map);
                                                AuthController.controller.appUser!.value
                                                        .phone =
                                                    ProfileController
                                                        .controller.phonenumber;
                                                Get.rawSnackbar(
                                                    message:
                                                        "Phone Number successfully updated",
                                                    borderRadius: 20,
                                                    margin: EdgeInsets.all(5),
                                                    backgroundColor:
                                                        Colors.green);
                                                ProfileController.controller
                                                    .phoneEdit.value = false;
                                              },
                                              icon: SizedBox(
                                                height: 60,
                                                width: 60,
                                                child: Material(
                                                  elevation: 10,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Icon(
                                                    Icons.check,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ShowUpAnimation(
                                  delayStart: Duration(milliseconds: 400),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 40,
                                      ),
                                      Text(
                                        "${AuthController.controller.appUser!.value.phone}",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
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
                                            letterSpacing: 2,
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 23, 43, 77)),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          elevation: 10,
                                          child: IconButton(
                                              onPressed: () {
                                                ProfileController.controller
                                                        .phonenumber =
                                                    AuthController.controller
                                                        .appUser!.value.phone;
                                                ProfileController.controller
                                                    .phoneEdit.value = true;
                                              },
                                              icon: Icon(
                                                Icons.edit_rounded,
                                                color: textcolor,
                                                size: 18,
                                              )),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          ShowUpAnimation(
                            delayStart: Duration(milliseconds: 600),
                            animationDuration: Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child:Obx(()=> Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "Rating",
                                      style: GoogleFonts.montserratAlternates(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: textcolor),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${AuthController.controller.userRating.value.toStringAsFixed(2)}",
                                          style: GoogleFonts.montserratAlternates(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("Total rides",
                                        style: GoogleFonts.montserratAlternates(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: textcolor)),
                                    Text(
                                      "${AuthController.controller.userTotalRides.value}",
                                      style: GoogleFonts.montserratAlternates(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ],
                            ),)
                          ),
                          AuthController.controller.role.value == "client"
                              ? Container()
                              : ShowUpAnimation(
                                  delayStart: Duration(milliseconds: 600),
                                  animationDuration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                  direction: Direction.vertical,
                                  child: AnimatedContainer(
                                    padding: ProfileController
                                            .controller.carExpanded.value
                                        ? EdgeInsets.symmetric(horizontal: 10)
                                        : EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: ProfileController
                                                .controller.carExpanded.value
                                            ? Color.fromRGBO(26, 43, 107, 1)
                                            : null),
                                    duration: Duration(milliseconds: 500),
                                    child: Column(
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AuthController
                                                    .controller.appUser!.value.car!,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: ProfileController
                                                            .controller
                                                            .carExpanded
                                                            .value
                                                        ? Colors.white
                                                        : textcolor),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    ProfileController.controller
                                                            .carExpanded.value =
                                                        !ProfileController
                                                            .controller
                                                            .carExpanded
                                                            .value;
                                                  },
                                                  icon: ProfileController
                                                          .controller
                                                          .carExpanded
                                                          .value
                                                      ? Icon(
                                                          FontAwesomeIcons
                                                              .arrowUp,
                                                          color: Colors.white,
                                                          size: 20,
                                                        )
                                                      : Icon(
                                                          FontAwesomeIcons
                                                              .arrowDown,
                                                          color: textcolor,
                                                          size: 20,
                                                        ))
                                            ]),
                                        if (ProfileController
                                            .controller.carExpanded.value)
                                          Obx(() => SizedBox(
                                                height: OneContext()
                                                        .mediaQuery
                                                        .size
                                                        .height *
                                                    0.28,
                                                width: double.infinity,
                                                child: GridView.count(
                                                    crossAxisCount: 1,
                                                    children: List.generate(
                                                      ProfileController
                                                          .controller
                                                          .carImg
                                                          .length,
                                                      (index) {
                                                        return Stack(
                                                          children: [
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                child: Image
                                                                    .network(
                                                                  ProfileController
                                                                      .controller
                                                                      .carImg[index],
                                                                  fit: BoxFit
                                                                      .fitWidth,
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 10,
                                                              right: 10,
                                                              child: Container(
                                                                height: 36,
                                                                width: 36,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30)),
                                                                child:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () async {
                                                                    if (ProfileController
                                                                            .controller
                                                                            .carImg
                                                                            .length >
                                                                        1) {
                                                                      await FirebaseDatabase
                                                                          .instance
                                                                          .ref()
                                                                          .child(
                                                                              "users")
                                                                          .child(AuthController
                                                                              .controller
                                                                              .auth!
                                                                              .currentUser!
                                                                              .uid)
                                                                          .child(
                                                                              "imgs")
                                                                          .child(ProfileController
                                                                              .controller
                                                                              .carint[index]
                                                                              .toString())
                                                                          .remove();
                                                                      Get.rawSnackbar(
                                                                          message:
                                                                              "Image deleted successfully",
                                                                          borderRadius:
                                                                              20,
                                                                          margin: EdgeInsets.all(
                                                                              5),
                                                                          backgroundColor:
                                                                              Colors.green);
                                                                    } else {
                                                                      Get.rawSnackbar(
                                                                          message:
                                                                              "You must have at least one picture of your car",
                                                                          borderRadius:
                                                                              20,
                                                                          margin: EdgeInsets.all(
                                                                              5),
                                                                          backgroundColor:
                                                                              Colors.red);
                                                                    }
                                                                  },
                                                                  icon: Icon(
                                                                    FontAwesomeIcons
                                                                        .x,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    )),
                                              )),
                                        if (ProfileController
                                            .controller.carExpanded.value)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Center(
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color: Colors.green),
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      var id = uuid.v1();
                                                      carImage = await _picker
                                                          .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery);

                                                      if (carImage != null) {
                                                        EasyLoading.show(
                                                            dismissOnTap: false,
                                                            status:
                                                                "Uploading image Please wait");
                                                        UploadTask
                                                            task =
                                                            FirebaseStorage
                                                                .instance
                                                                .ref()
                                                                .child(AuthController
                                                                    .controller
                                                                    .auth!
                                                                    .currentUser!
                                                                    .uid)
                                                                .child("car")
                                                                .child(id)
                                                                .putFile(File(
                                                                    carImage!
                                                                        .path));
                                                        await task.whenComplete(
                                                            () async {
                                                          var s = await task
                                                              .storage
                                                              .ref()
                                                              .child(AuthController
                                                                  .controller
                                                                  .auth!
                                                                  .currentUser!
                                                                  .uid)
                                                              .child("car")
                                                              .child(id)
                                                              .getDownloadURL();
                                                          print(
                                                              "This is Img Url $s");

                                                          await FirebaseDatabase
                                                              .instance
                                                              .ref()
                                                              .child("users")
                                                              .child(AuthController
                                                                  .controller
                                                                  .auth!
                                                                  .currentUser!
                                                                  .uid)
                                                              .child("imgs")
                                                              .child(id)
                                                              .set(s);
                                                        });
                                                        EasyLoading.dismiss();
                                                      }
                                                    },
                                                    icon: Icon(
                                                      FontAwesomeIcons.add,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                          ShowUpAnimation(
                            delayStart: Duration(milliseconds: 800),
                            animationDuration: Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: Obx(
                              () => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Your personal information",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textcolor),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Edit",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textcolor),
                                      ),
                                      Switch(
                                          value: ProfileController
                                              .controller.canEdit.value,
                                          onChanged: (value) {
                                            ProfileController.controller.canEdit
                                                .value = value;
                                          })
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          ShowUpAnimation(
                            delayStart: Duration(milliseconds: 1000),
                            animationDuration: Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.horizontal,
                            child: Column(
                              children: [
                                Container(
                                    margin: EdgeInsets.all(10),
                                    child: TextField(
                                      controller:
                                          ProfileController.controller.name,
                                      enabled: ProfileController
                                          .controller.canEdit.value,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textcolor),
                                      decoration: InputDecoration(
                                          disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.5)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.green,
                                                  width: 2.5)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 2.5)),
                                          isDense: true,
                                          labelText: 'Full Name',
                                          labelStyle:
                                              TextStyle(color: textcolor),
                                          hintStyle:
                                              TextStyle(color: Colors.red)),
                                      onChanged: (text) {
                                        ProfileController
                                            .controller.canSubmit.value = true;
                                      },
                                    )),
                                Container(
                                    margin: EdgeInsets.all(10),
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          ProfileController.controller.email,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textcolor),
                                      decoration: InputDecoration(
                                          disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.5)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.green,
                                                  width: 2.5)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 2.5)),
                                          isDense: true,
                                          labelText: 'Email',
                                          labelStyle:
                                              TextStyle(color: textcolor),
                                          hintStyle:
                                              TextStyle(color: Colors.red)),
                                      onChanged: (text) {
                                        ProfileController
                                            .controller.canSubmit.value = true;
                                      },
                                    )),
                                Container(
                                    margin: EdgeInsets.all(10),
                                    child: TextField(
                                      controller:
                                          ProfileController.controller.address,
                                      enabled: ProfileController
                                          .controller.canEdit.value,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textcolor),
                                      decoration: InputDecoration(
                                          disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.5)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.green,
                                                  width: 2.5)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 2.5)),
                                          isDense: true,
                                          labelText: 'Address',
                                          labelStyle:
                                              TextStyle(color: textcolor),
                                          hintStyle:
                                              TextStyle(color: Colors.red)),
                                      onChanged: (text) {
                                        ProfileController
                                            .controller.canSubmit.value = true;
                                      },
                                    )),
                                AuthController.controller.role.value == "client"
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.all(10),
                                        child: TextField(
                                          controller:
                                              ProfileController.controller.car,
                                          enabled: ProfileController
                                              .controller.canEdit.value,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textcolor),
                                          decoration: InputDecoration(
                                              disabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue,
                                                      width: 2.5)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: BorderSide(
                                                      color: Colors.green,
                                                      width: 2.5)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: BorderSide(
                                                      color: Colors.black,
                                                      width: 2.5)),
                                              isDense: true,
                                              labelText: 'Car info',
                                              labelStyle:
                                                  TextStyle(color: textcolor),
                                              hintStyle:
                                                  TextStyle(color: Colors.red)),
                                          onChanged: (text) {
                                            ProfileController.controller
                                                .canSubmit.value = true;
                                          },
                                        )),
                                ProfileController.controller.canSubmit.value
                                    ? ElevatedButton(
                                        onPressed: () async {
                                          var map = {
                                            'name': ProfileController
                                                .controller.name.text
                                                .trim(),
                                            'email': ProfileController
                                                .controller.email.text
                                                .trim(),
                                            'address': ProfileController
                                                .controller.address.text
                                                .trim(),
                                          };
                                          var mapdriver = {
                                            'name': ProfileController
                                                .controller.name.text
                                                .trim(),
                                            'email': ProfileController
                                                .controller.email.text
                                                .trim(),
                                            'address': ProfileController
                                                .controller.address.text
                                                .trim(),
                                            'car': ProfileController
                                                .controller.car?.text
                                                .trim()
                                          };

                                          AuthController
                                              .controller.appUser!.value.fullname=ProfileController
                                              .controller.name.text
                                              .trim();

                                          if (AuthController
                                                  .controller.role.value ==
                                              "client") {



                                            await FirebaseDatabase.instance
                                                .ref()
                                                .child("users")
                                                .child(AuthController.controller
                                                    .auth!.currentUser!.uid)
                                                .update(map);
                                          } else {
                                            AuthController
                                                .controller.appUser!.value.car=ProfileController
                                                .controller.car?.text
                                                .trim();
                                            await FirebaseDatabase.instance
                                                .ref()
                                                .child("users")
                                                .child(AuthController.controller
                                                    .auth!.currentUser!.uid)
                                                .update(mapdriver);
                                          }
                                          await FirebaseDatabase.instance
                                              .ref()
                                              .child("users")
                                              .child(AuthController.controller
                                                  .auth!.currentUser!.uid)
                                              .update(map);
                                          ProfileController.controller.canSubmit
                                              .value = false;
                                          ProfileController
                                              .controller.canEdit.value = false;

                                          Get.rawSnackbar(
                                              message:
                                                  "Information successfully updated",
                                              borderRadius: 20,
                                              margin: EdgeInsets.all(5),
                                              backgroundColor: Colors.green);
                                        },
                                        child: AnimatedContainer(
                                          duration: Duration(seconds: 1),
                                          // width: OneContext()
                                          //         .mediaQuery
                                          //         .size
                                          //         .width *
                                          //     0.5,
                                          padding: const EdgeInsets.all(10.0),
                                          child: Center(
                                              child: Text(
                                            "Submit changes",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          )),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            primary: Colors.blueAccent),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}
