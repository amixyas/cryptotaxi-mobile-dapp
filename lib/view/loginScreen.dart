import 'dart:async';

import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/view/SignupScreen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  static const String routename = "login";
  GlobalKey<FormState> formKeyLogin =
      GlobalKey<FormState>(debugLabel: '_loginScreenkey');
  GlobalKey<FormState> formkeyphone = GlobalKey<FormState>();
  TextEditingController emailreset = TextEditingController();

  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();

  late MediaQueryData size;

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

  void _resetpassworddialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: const Text('Password reset '),
        content: Container(
          width: MediaQuery.of(context).size.width,
          decoration:  const BoxDecoration(
            shape: BoxShape.rectangle,
            color:  Color(0xFFFFFF),
            borderRadius:  BorderRadius.all( Radius.circular(32.0)),
          ),
          child: Container(
            // padding: EdgeInsets.all(0),

            child: TextFormField(
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle:  TextStyle(
                      color:  Color.fromARGB(255, 134, 145, 163)),
                  prefixIcon: Icon(FontAwesomeIcons.at,
                      color:  Color.fromARGB(255, 134, 145, 163))),
              controller: emailreset,
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Okay'),
            onPressed: () async {
              if (EmailValidator.validate(emailreset.text)) {
                AuthController.controller.resetPassword(emailreset.text);
              } else {
                Get.snackbar("CryptoTaxi", "Invalid email address",
                    padding: const EdgeInsets.all(8),
                    backgroundColor: Colors.red,
                    snackPosition: SnackPosition.BOTTOM);
              }

              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Widget IconCard(IconData icon, Color color, BuildContext context) {
    return Card(
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black26, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        // color: Colors.red,
        width: size.size.width * 0.2,
        height: 50,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black26, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          onTap: () async {
            if (icon == FontAwesomeIcons.phone) {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  shape: const RoundedRectangleBorder(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(35))),
                  isDismissible: false,
                  builder: (BuildContext context) {
                    return Obx(() => Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: Form(
                            key: formkeyphone,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              // width: double.infinity,
                              height: (size.size.height * 0.4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ShowUpAnimation(
                                    delayStart:
                                        const Duration(milliseconds: 200),
                                    animationDuration:
                                        const Duration(seconds: 1),
                                    curve: Curves.decelerate,
                                    direction: Direction.vertical,
                                    offset: 0.5,
                                    child: const Text(
                                      "Login with phone number",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 23, 43, 77),
                                          fontSize: 18),
                                    ),
                                  ),
                                  AuthController.controller.smsSent.value
                                      ? ShowUpAnimation(
                                          delayStart:
                                              const Duration(milliseconds: 0),
                                          animationDuration:
                                              const Duration(seconds: 1),
                                          curve: Curves.decelerate,
                                          direction: Direction.vertical,
                                          offset: 0.5,
                                          child: Container(
                                            height: size.size.height * 0.3,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                ShowUpAnimation(
                                                  delayStart: const Duration(
                                                      milliseconds: 200),
                                                  animationDuration:
                                                      const Duration(
                                                          seconds: 1),
                                                  curve: Curves.decelerate,
                                                  direction: Direction.vertical,
                                                  offset: 0.5,
                                                  child: const Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child:  Text(
                                                      "Enter the SMS code :",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                ),
                                                ShowUpAnimation(
                                                  delayStart: const Duration(
                                                      milliseconds: 400),
                                                  animationDuration:
                                                      const Duration(
                                                          seconds: 1),
                                                  curve: Curves.decelerate,
                                                  direction: Direction.vertical,
                                                  offset: 0.5,
                                                  child: SizedBox(
                                                    width:
                                                        size.size.width * 0.8,
                                                    height: 60,
                                                    child: PinCodeTextField(
                                                      errorTextMargin:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      validator: (v) {
                                                        if (v!.length < 6) {
                                                          return "SMS code is 6 characters";
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      autoDisposeControllers:
                                                          false,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      length: 6,
                                                      obscureText: false,
                                                      animationType:
                                                          AnimationType.fade,
                                                      pinTheme: PinTheme(
                                                        inactiveColor:
                                                            Colors.blue,
                                                        shape: PinCodeFieldShape
                                                            .underline,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        fieldHeight: 45,
                                                        fieldWidth: 37,
                                                        activeFillColor:
                                                            Colors.white,
                                                      ),
                                                      animationDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  300),
                                                      // backgroundColor: Colors.blue.shade50,
                                                      enableActiveFill: false,
                                                      // errorAnimationController:
                                                      //     errorController,
                                                      //
                                                      controller: AuthController
                                                          .controller
                                                          .textEditingController,

                                                      onChanged: (value) {
                                                        print(value);

                                                        AuthController
                                                            .controller
                                                            .smsCode
                                                            .value = value;
                                                      },
                                                      beforeTextPaste: (text) {
                                                        print(
                                                            "Allowing to paste $text");
                                                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                                        return true;
                                                      },
                                                      appContext: context,
                                                    ),
                                                  ),
                                                ),
                                                ShowUpAnimation(
                                                  delayStart: const Duration(
                                                      milliseconds: 600),
                                                  animationDuration:
                                                      const Duration(
                                                          seconds: 1),
                                                  curve: Curves.decelerate,
                                                  direction: Direction.vertical,
                                                  offset: 0.5,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      RichText(
                                                          text: TextSpan(
                                                        style: const TextStyle(
                                                          color: const Color
                                                                  .fromARGB(
                                                              255, 23, 43, 77),
                                                        ),
                                                        children: [
                                                          const TextSpan(
                                                            text:
                                                                "Send OTP again in ",
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                "0:${AuthController.controller.start.value}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                          ),
                                                          const TextSpan(
                                                            text: " seconds",
                                                          ),
                                                        ],
                                                      )),
                                                      AuthController
                                                                  .controller
                                                                  .start
                                                                  .value ==
                                                              0
                                                          ? InkWell(
                                                              onTap: () async {
                                                                await AuthController
                                                                    .controller
                                                                    .verifyPhone(AuthController
                                                                        .controller
                                                                        .phonenumber
                                                                        .value);
                                                                // sent=false;
                                                              },
                                                              child: const Text(
                                                                "Resend SMS code",
                                                                style:  TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .green,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline),
                                                              ),
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 12,
                                                ),
                                                ShowUpAnimation(
                                                  delayStart: const Duration(
                                                      milliseconds: 800),
                                                  animationDuration:
                                                      const Duration(
                                                          seconds: 1),
                                                  curve: Curves.decelerate,
                                                  direction: Direction.vertical,
                                                  offset: 0.5,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                          height: 50,
                                                          width:
                                                              size.size.width *
                                                                  0.42,
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  10, 0, 10, 0),
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all(Colors
                                                                            .red),
                                                                shape: MaterialStateProperty.all<
                                                                        RoundedRectangleBorder>(
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0),
                                                                ))),
                                                            child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    3,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              AuthController
                                                                  .controller
                                                                  .resetDate();
                                                            },
                                                          )),
                                                      Container(
                                                          height: 50,
                                                          width:
                                                              size.size.width *
                                                                  0.42,
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  10, 0, 10, 0),
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        const Color.fromARGB(
                                                                            255,
                                                                            0,
                                                                            101,
                                                                            255)),
                                                                shape: MaterialStateProperty.all<
                                                                        RoundedRectangleBorder>(
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0),
                                                                ))),
                                                            child: const Text(
                                                              'Submit',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    2,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              if (formkeyphone
                                                                  .currentState!
                                                                  .validate()) {
                                                                print(
                                                                    "form valid");
                                                                AuthController
                                                                    .controller
                                                                    .otpVerify(AuthController
                                                                        .controller
                                                                        .smsCode
                                                                        .value);
                                                                EasyLoading.show(
                                                                    status:
                                                                        'Please wait ');
                                                              } else {
                                                                print(
                                                                    "invalid form");
                                                              }
                                                            },
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: size.size.height * 0.3,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              ShowUpAnimation(
                                                delayStart: const Duration(
                                                    milliseconds: 200),
                                                animationDuration:
                                                    const Duration(seconds: 1),
                                                curve: Curves.decelerate,
                                                direction: Direction.vertical,
                                                offset: 0.5,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child:
                                                      InternationalPhoneNumberInput(
                                                    onInputChanged:
                                                        (PhoneNumber number) {
                                                      AuthController
                                                              .controller
                                                              .phonenumber
                                                              .value =
                                                          number.phoneNumber!;

                                                      print(number.phoneNumber);
                                                    },
                                                    onInputValidated:
                                                        (bool value) {
                                                      print(value);
                                                    },
                                                    selectorConfig:
                                                        const SelectorConfig(
                                                      selectorType:
                                                          PhoneInputSelectorType
                                                              .BOTTOM_SHEET,
                                                    ),
                                                    ignoreBlank: false,
                                                    autoValidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    selectorTextStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.black),
                                                    initialValue: PhoneNumber(
                                                        isoCode: 'DZ',
                                                        phoneNumber:
                                                            AuthController
                                                                .controller
                                                                .phonenumber
                                                                .value),
                                                    textFieldController:
                                                        AuthController
                                                            .controller.phone,
                                                    formatInput: false,
                                                    keyboardType:
                                                        const TextInputType
                                                                .numberWithOptions(
                                                            signed: true,
                                                            decimal: true),
                                                    inputBorder:
                                                        const OutlineInputBorder(),
                                                    onSaved:
                                                        (PhoneNumber number) {
                                                      print(
                                                          'On Saved: $number');
                                                    },
                                                  ),
                                                ),
                                              ),
                                              ShowUpAnimation(
                                                delayStart: const Duration(
                                                    milliseconds: 400),
                                                animationDuration:
                                                    const Duration(seconds: 1),
                                                curve: Curves.decelerate,
                                                direction: Direction.vertical,
                                                offset: 0.5,
                                                child: const Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child:  Text(
                                                    "SMS code will be sent to your phone number",
                                                    style: TextStyle(
                                                        color: textcolor),
                                                  ),
                                                ),
                                              ),
                                              (AuthController.controller
                                                      .isLoadingPhone.value)
                                                  ? ShowUpAnimation(
                                                      delayStart:
                                                          const Duration(
                                                              milliseconds: 0),
                                                      animationDuration:
                                                          const Duration(
                                                              seconds: 1),
                                                      curve: Curves.decelerate,
                                                      direction:
                                                          Direction.vertical,
                                                      offset: 0.5,
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    )
                                                  : ShowUpAnimation(
                                                      delayStart:
                                                          const Duration(
                                                              milliseconds:
                                                                  600),
                                                      animationDuration:
                                                          const Duration(
                                                              seconds: 1),
                                                      curve: Curves.decelerate,
                                                      direction:
                                                          Direction.vertical,
                                                      offset: 0.5,
                                                      child: Container(
                                                          height: 50,
                                                          width:
                                                              size.size.width,
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  10, 0, 10, 0),
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        const Color.fromARGB(
                                                                            255,
                                                                            0,
                                                                            101,
                                                                            255)),
                                                                shape: MaterialStateProperty.all<
                                                                        RoundedRectangleBorder>(
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0),
                                                                ))),
                                                            child: const Text(
                                                              'Login',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    3,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              if (formkeyphone
                                                                  .currentState!
                                                                  .validate()) {
                                                                AuthController
                                                                    .controller
                                                                    .verifyPhone(AuthController
                                                                        .controller
                                                                        .phonenumber
                                                                        .value);
                                                              } else {}
                                                            },
                                                          )),
                                                    ),
                                            ],
                                          ),
                                        )
                                ],
                              ),
                            ),
                          ),
                        ));
                  });
            } else if (icon == FontAwesomeIcons.google) {
              await AuthController.controller.loginGoogle();
            } else if (icon == FontAwesomeIcons.twitter) {
              await AuthController.controller.signInWithTwitter();
              // Get.rawSnackbar(
              //     message: "Twitter login will be implemented soon",
              //     borderRadius: 20,
              //     margin: EdgeInsets.all(5),
              //     backgroundColor: Colors.blue);
            }
          },
          child: Center(
              child: FaIcon(
            icon,
            color: color,
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text("CryptoTaxi Login"),
        // ),
        body: Form(
          key: formKeyLogin,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
                // color: Colors.red,
                height: size.size.height - size.padding.top,
                child: CustomScrollView(
                  scrollDirection: Axis.vertical,
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(seconds: 0),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: Image.asset(
                              "assets/images/logoApp.png",
                              width: size.size.width,
                              height: size.size.height * 0.2,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 100),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child:  Text(
                                "Welcome To CryptoTaxi",
                                style: TextStyle(
                                  fontSize: 22,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset:  Offset(0.0, 1.0),
                                      blurRadius: 1.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    // Shadow(
                                    //   offset: Offset(0.0, 2.0),
                                    //   blurRadius: 8.0,
                                    //   color: Color.fromARGB(125, 0, 0, 255),
                                    // ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 200),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Login ",
                                style: TextStyle(
                                  fontSize: 40,
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
                                  color: Color.fromARGB(255, 23, 43, 77),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 300),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (EmailValidator.validate(AuthController
                                      .controller.emailController.text)) {
                                    return null;
                                  } else {
                                    return 'Email address not valid ';
                                  }
                                },
                                controller:
                                    AuthController.controller.emailController,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                    labelText: "Email",
                                    labelStyle: TextStyle(
                                      color:  Color.fromARGB(
                                          255, 134, 145, 163),
                                    ),
                                    prefixIcon: Icon(
                                        FontAwesomeIcons.solidEnvelope,
                                        color:  Color.fromARGB(
                                            255, 134, 145, 163)))),
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 400),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: TextFormField(
                                style: const TextStyle(color: Colors.black),
                                obscureText: true,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) => (value!.isEmpty ||
                                        value.length < 6)
                                    ? 'Password must be at least 6 characters '
                                    : null,
                                controller: AuthController
                                    .controller.passwordController,
                                decoration: const InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 134, 145, 163)),
                                    prefixIcon: Icon(FontAwesomeIcons.lock,
                                        color: Color.fromARGB(
                                            255, 134, 145, 163)))),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 500),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: Obx(
                              () => AuthController.controller.isLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Container(
                                      height: 50,
                                      width: size.size.width,
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    const Color.fromARGB(
                                                        255, 0, 101, 255)),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ))),
                                        child: const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 3,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () async {
                                          final FormState? form =
                                              formKeyLogin.currentState;
                                          if (form!.validate()) {
                                            await AuthController.controller
                                                .login(
                                                    AuthController.controller
                                                        .emailController.text,
                                                    AuthController
                                                        .controller
                                                        .passwordController
                                                        .text);
                                          } else {
                                            print('Form is invalid');
                                          }
                                        },
                                      )),
                            ),
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 600),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Forgot your password ? ",
                                  style:  TextStyle(color: textcolor),
                                ),
                                TextButton(
                                    onPressed: () {
                                      _resetpassworddialog(context);
                                    },
                                    child: const Text("Reset now",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)))
                              ],
                            ),
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 700),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: const Text(
                              "Or Login with",
                              style:  TextStyle(color: textcolor),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 800),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconCard(FontAwesomeIcons.phone, Colors.green,
                                    context),
                                // SizedBox(width: 50,),
                                IconCard(FontAwesomeIcons.google, Colors.red,
                                    context),
                                IconCard(FontAwesomeIcons.twitter, Colors.blue,
                                    context),
                              ],
                            ),
                          ),
                          ShowUpAnimation(
                            delayStart: const Duration(milliseconds: 900),
                            animationDuration: const Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "New to CryptoTaxi ? ",
                                  style: TextStyle(color: textcolor),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Get.toNamed(SignupScreen.routename);
                                    },
                                    child: const Text("Register",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
