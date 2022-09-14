import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/userInfo_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:gender_picker/source/gender_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:one_context/one_context.dart';
import 'package:show_up_animation/show_up_animation.dart';

class FirstUse extends GetView<UserInfoController> {
  FirstUse({Key? key}) : super(key: key);
  static const String routename = "firstuse";
  String initialCountry = 'DZ';
  late MediaQueryData size;
  final ImagePicker _picker = ImagePicker();
  XFile? image;
  final TextEditingController phone = TextEditingController();
  final userController = Get.put(UserInfoController());
  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  String? validateMobile(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return 'Enter phone number';
    } else if (!regExp.hasMatch(value)) {
      return 'Enter valid phone number';
    }
    return null;
  }

  List<Step> buildStep(BuildContext context) {
    return [
      Step(
          state: userController.currentIndex.value > 0
              ? StepState.complete
              : StepState.indexed,
          isActive: userController.currentIndex.value >= 0,
          title: ShowUpAnimation(
              delayStart: Duration(milliseconds: 0),
              animationDuration: Duration(seconds: 1),
              curve: Curves.decelerate,
              direction: Direction.vertical,
              offset: 0.5,
              child: Text("Personel Infomration")),
          content: Form(
            key: formKeys[0],
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 130,
                      width: 130,
                      child: ShowUpAnimation(
                        delayStart: Duration(seconds: 0),
                        animationDuration: Duration(seconds: 1),
                        curve: Curves.decelerate,
                        direction: Direction.vertical,
                        offset: 0.5,
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
                                  : ShowUpAnimation(
                                      delayStart: Duration(milliseconds: 100),
                                      animationDuration: Duration(seconds: 1),
                                      curve: Curves.decelerate,
                                      direction: Direction.vertical,
                                      offset: 0.5,
                                      child: Image.network(
                                        'https://cdn-icons-png.flaticon.com/512/219/219983.png',
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.fill,
                                      ),
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
                                      borderRadius: BorderRadius.circular(80)),
                                  child: Center(
                                    child: IconButton(
                                        onPressed: () async {
                                          image = await _picker.pickImage(
                                              source: ImageSource.gallery);
                                          if (image != null) {
                                            UploadTask task = FirebaseStorage
                                                .instance
                                                .ref()
                                                .child(AuthController.controller
                                                    .auth!.currentUser!.uid)
                                                .child("image")
                                                .putFile(File(image!.path));
                                            await task.whenComplete(() async {
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
                                                  .controller.auth!.currentUser!
                                                  .updatePhotoURL(s);
                                              await FirebaseDatabase.instance
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
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(milliseconds: 200),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Enter your information :",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(milliseconds: 400),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: TextFormField(
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: Colors.black),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: userController.name,
                      validator: (value) =>
                          value!.isEmpty ? 'Name cannot be blank' : null,
                      decoration: InputDecoration(label: Text("Full name")),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(milliseconds: 600),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(1900, 3, 5),
                                maxTime: DateTime.now()
                                    .subtract(Duration(days: 6570)),
                                theme: DatePickerTheme(
                                    // headerColor: Colors.black,
                                    // backgroundColor: Colors.white,
                                    itemStyle: TextStyle(
                                        // color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                    doneStyle: TextStyle(
                                        // color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)), onChanged: (date) {
                              print('change $date in time zone ' +
                                  date.timeZoneOffset.inHours.toString());
                            }, onConfirm: (date) {
                              print('confirm $date');

                              userController.selectedDate.value =
                                  DateFormat.yMd().format(date);
                            },
                                currentTime: DateTime.now()
                                    .subtract(Duration(days: 6570)),
                                locale: LocaleType.en);
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          child: Text(
                            "Select your birthdate",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (userController.selectedDate.value.toString() == null)
                            ? Text('No date chosen!')
                            : Text(
                                userController.selectedDate.value.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(milliseconds: 600),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: Text(
                      "Enter your phone number :",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(milliseconds: 800),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: Container(
                      width: double.infinity,
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          userController.phonenumber.value =
                              number.phoneNumber!;

                          print(number.phoneNumber);
                        },
                        onInputValidated: (bool value) {
                          print(value);
                        },
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        selectorTextStyle: TextStyle(color: Colors.black),
                        initialValue: PhoneNumber(
                            isoCode: 'DZ',
                            phoneNumber: userController.phonenumber.value),
                        textFieldController: userController.phone,
                        formatInput: false,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputBorder: OutlineInputBorder(),
                        onSaved: (PhoneNumber number) {
                          print('On Saved: $number');
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(seconds: 1),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: Text(
                      "Select your gender :",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(milliseconds: 200, seconds: 1),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: GenderPickerWithImage(
                      showOtherGender: false,
                      verticalAlignedText: false,
                      selectedGender: Gender.Male,
                      selectedGenderTextStyle: TextStyle(
                          // color: Color(0xFF8b32a8),
                          fontWeight: FontWeight.bold),
                      unSelectedGenderTextStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal),
                      onChanged: (Gender? gender) {
                        print(gender);
                        if (gender == Gender.Male) {
                          userController.selectedGender.value = "Male";
                        } else {
                          userController.selectedGender.value = "Female";
                        }
                      },
                      equallyAligned: true,
                      animationDuration: Duration(milliseconds: 300),
                      isCircular: true,
                      // default : true,
                      opacityOfGradient: 0.28,
                      padding: const EdgeInsets.all(3),
                      size: 60, //default : 40
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(milliseconds: 400, seconds: 1),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: Text(
                      "Select your role :",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ShowUpAnimation(
                    delayStart: Duration(milliseconds: 600, seconds: 1),
                    animationDuration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    direction: Direction.vertical,
                    offset: 0.5,
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              controller.client.value = true;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  // color: controller.client.value
                                  //     ? Colors.green
                                  //     : Colors.black12,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    width: 2,
                                    style: BorderStyle.solid,
                                    color: controller.client.value
                                        ? Colors.green
                                        : Colors.black12,
                                  )),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text("Client",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              controller.client.value = false;
                            },
                            child: Container(
                              decoration: BoxDecoration(

                                  // color: controller.client.value
                                  //     ? Colors.black12
                                  //     : Colors.green,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    width: 2,
                                    style: BorderStyle.solid,
                                    color: controller.client.value
                                        ? Colors.black12
                                        : Colors.green,
                                  )),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text(
                                "Driver",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
      Step(
          state: userController.currentIndex.value > 1
              ? StepState.complete
              : StepState.indexed,
          isActive: userController.currentIndex.value >= 1,
          title: Text("Address"),
          content: Form(
            key: formKeys[1],
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Enter your address :",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      // style: TextStyle(color: Colors.black),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: userController.address,
                      validator: (value) =>
                          value!.isEmpty ? 'Address can not be blank' : null,
                      // Added this

                      decoration: InputDecoration(
                          isDense: true, // Added this

                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25)),
                          hintText: "Ex: Haboucha 97 Mazouna Relizane"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    controller.client.value
                        ? const SizedBox()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Enter your car informtions :",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )),
                    controller.client.value
                        ? const SizedBox()
                        : SizedBox(
                            height: 20,
                          ),
                    controller.client.value
                        ? const SizedBox()
                        : TextFormField(
                            textCapitalization: TextCapitalization.words,
                            // style: TextStyle(color: Colors.black),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: userController.car,
                            validator: (value) => value!.isEmpty
                                ? 'Car informations can not be blank'
                                : null,
                            // Added this

                            decoration: InputDecoration(
                              isDense: true, // Added this

                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              hintText: "Ex: Renault Clio 4 2013 Black",
                              // label: Text("Car Informations")
                            ),
                          ),
                    SizedBox(
                      height: 15,
                    ),
                    controller.client.value
                        ? const SizedBox()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Car pictures :",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )),
                    controller.client.value
                        ? const SizedBox()
                        : SizedBox(
                            height: 15,
                          ),
                    controller.client.value
                        ? const SizedBox()
                        : ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () async {
                              controller.images!.value =
                                  (await _picker.pickMultiImage())!;
                            },
                            child: Text(
                              "Select 4 images",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                    (controller.client.value || controller.images!.isEmpty)
                        ? SizedBox()
                        : Text(
                            "Preview car images",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textcolor),
                          ),
                    (controller.client.value || controller.images!.isEmpty)
                        ? const SizedBox()
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: double.infinity,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                  height: MediaQuery.of(context).size.height *
                                      0.30),
                              items: controller.images
                                  ?.map((item) => Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.0, horizontal: 10.0),
                                        child: Center(
                                            child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.file(File(item.path),
                                              fit: BoxFit.fill,
                                              width: OneContext()
                                                  .mediaQuery
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.25),
                                        )),
                                      ))
                                  .toList(),
                            )),
                    SizedBox(
                      height: 10,
                    ),
                    controller.client.value
                        ? SizedBox()
                        : AutoSizeText(
                            "You need to upload the following documents to continue: \n",
                            maxLines: 3,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textcolor),
                          ),
                    controller.client.value
                        ? SizedBox()
                        : Text(
                            "- Driver Licence ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textcolor),
                          ),
                    controller.client.value
                        ? SizedBox()
                        : Text(
                            "- Proof of residency",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textcolor),
                          ),
                    controller.client.value
                        ? SizedBox()
                        : Text(
                            "- Proof of auto insurance and car registration",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textcolor),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    controller.client.value
                        ? const SizedBox()
                        : ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () async {
                              controller.documents!.value =
                                  (await _picker.pickMultiImage( ))!;
                            },
                            child: Text(
                              "Select Document",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    (controller.client.value || controller.documents!.isEmpty)
                        ? SizedBox()
                        : Text(
                            "Preview documents",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textcolor),
                          ),
                    (controller.client.value || controller.documents!.isEmpty)
                        ? const SizedBox()
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: double.infinity,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                  height: MediaQuery.of(context).size.height *
                                      0.30),
                              items: controller.documents
                                  ?.map((item) => Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.0, horizontal: 10.0),
                                        child: Center(
                                            child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.file(File(item.path),
                                              fit: BoxFit.fill,
                                              width: OneContext()
                                                  .mediaQuery
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.25),
                                        )),
                                      ))
                                  .toList(),
                            )),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Country :",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userController.country.value),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              // optional. Shows phone code before the country name.
                              onSelect: (Country country) {
                                print('Select country: ${country.displayName}');
                                userController.country.value = country.name;
                              },
                            );
                          },
                          child: Text(
                            "Select country",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          )),
      Step(
          isActive: userController.currentIndex.value >= 2,
          title: const Text("Review your information"),
          content: Form(
            key: formKeys[2],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Full name :",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(userController.name.text)
                  ],
                ),
                Row(
                  children: [
                    Text("Birthdate :",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(userController.selectedDate.value)
                  ],
                ),
                Row(
                  children: [
                    Text("Phone number :",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(userController.phonenumber.value)
                  ],
                ),
                Row(
                  children: [
                    Text("Gender :",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(userController.selectedGender.value)
                  ],
                ),
                Row(
                  children: [
                    Text("Address :",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                        "${userController.country}, ${userController.address.text}")
                  ],
                ),
                controller.client.value
                    ? SizedBox()
                    : Row(
                        children: [
                          Text("Car :",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          SizedBox(
                            width: 10,
                          ),
                          Text("${userController.car.text}")
                        ],
                      ),
              ],
            ),
          )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Personal Informations"),
        ),
        body: Container(
            height: size.size.height - size.padding.top,
            child: SingleChildScrollView(
                child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stepper(
                    onStepContinue: () async {
                      print("Continue Clicked");
                      if (formKeys[userController.currentIndex.value]
                          .currentState!
                          .validate()) {
                        if (userController.currentIndex.value ==
                            buildStep(context).length - 1) {
                          controller.isLoading.value = true;
                          if (controller.images!.length==4) {
                            print("not empty uploading ");
                            for (int i = 1;
                                i <= controller.images!.length;
                                i++) {
                              await controller.uploadImages(
                                  i, File(controller.images![i - 1].path));
                            }
                          } else {
                            if (controller.client.value == false) {
                              Get.rawSnackbar(
                                  message: "You must select 4 car images!",
                                  borderRadius: 20,
                                  margin: EdgeInsets.all(5),
                                  backgroundColor: Colors.red);
                              controller.isLoading.value = false;
                              return;
                            }
                          }
                          if (controller.documents!.length==4) {
                            print("not empty uploading ");
                            for (int i = 1;
                                i <= controller.documents!.length;
                                i++) {
                              await controller.uploadDocuments(
                                  i, File(controller.documents![i - 1].path));
                            }
                          } else {
                            if (controller.client.value == false) {
                              Get.rawSnackbar(
                                  message: "You must select the 4 documents required!",
                                  borderRadius: 20,
                                  margin: EdgeInsets.all(5),
                                  backgroundColor: Colors.red);
                              controller.isLoading.value = false;
                              return;
                            }
                          }

                          await userController.saveData();
                          controller.isLoading.value = false;
                          print("last step");
                        } else {
                          userController.currentIndex.value++;
                        }
                      }
                      print("Continue finishe");
                    },
                    onStepCancel: () {
                      if (userController.currentIndex.value > 0) {
                        userController.currentIndex.value--;
                      }
                    },
                    physics: BouncingScrollPhysics(),
                    currentStep: userController.currentIndex.value,
                    type: StepperType.vertical,
                    steps: buildStep(context),
                  ),
                  userController.isLoading.value
                      ? controller.client.value
                          ? CircularProgressIndicator()
                          : ShowUpAnimation(
                              delayStart: Duration(seconds: 0),
                              animationDuration: Duration(seconds: 1),
                              curve: Curves.decelerate,
                              direction: Direction.vertical,
                              offset: 0.5,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: LiquidCircularProgressIndicator(
                                      value: controller.progress.value / 100,
                                      // Defaults to 0.5.
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.blue),
                                      // Defaults to the current Theme's accentColor.
                                      backgroundColor: Colors.white,
                                      // Defaults to the current Theme's backgroundColor.
                                      borderColor: Colors.green,
                                      borderWidth: 5.0,
                                      direction: Axis.vertical,
                                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                                      center: Text(
                                          "${controller.progress.value} %",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Uploading Images ${controller.index.value}/${controller.images!.length + controller.documents!.length}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textcolor),
                                  )
                                ],
                              ),
                            )
                      : Container()
                ],
              ),
            ))),
      ),
    );
  }
}
