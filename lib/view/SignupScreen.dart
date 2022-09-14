import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/view/loginScreen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:show_up_animation/show_up_animation.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);
  static const String routename = "signup";
  late MediaQueryData size;

  Widget IconCard(IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black26, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        // color: Colors.red,
        width: size.size.width * 0.2,
        height: 50,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black26, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          onTap: () {},
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
          key: AuthController.controller.formKey,
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Container(
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
                          SizedBox(
                            height: 10,
                          ),
                          ShowUpAnimation(
                            delayStart: Duration(
                                seconds: 0),
                            animationDuration:
                            Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            offset: 0.5,
                            child: Image.asset(
                              "assets/images/logoApp.png",
                              width: size.size.width,
                              height: size.size.height * 0.2,
                            ),
                          ),
                          // SizedBox(height: 12,),
                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: Text(
                          //     "Welcome To CryptoTaxi",
                          //     style: TextStyle(
                          //       fontSize: 22,
                          //     ),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // ),
                          SizedBox(
                            height: 12,
                          ),
                          ShowUpAnimation(
                            delayStart: Duration(
                                milliseconds: 200),
                            animationDuration:
                            Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            offset: 0.5,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Sign up ",
                                style: TextStyle(
                                  fontSize: 32,
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
                          // SizedBox(
                          //   height: 15,
                          // ),
                          // ShowUpAnimation(
                          //   delayStart: Duration(
                          //     milliseconds: 600),
                          //   animationDuration:
                          //   Duration(seconds: 1),
                          //   curve: Curves.decelerate,
                          //   direction: Direction.vertical,
                          //   offset: 0.5,
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //     children: [
                          //       IconCard(FontAwesomeIcons.phone, Colors.green),
                          //       IconCard(FontAwesomeIcons.google, Colors.red),
                          //       IconCard(FontAwesomeIcons.facebook, Colors.blue),
                          //       IconCard(FontAwesomeIcons.apple, Colors.black)
                          //     ],
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 12,
                          // ),
                          // ShowUpAnimation(
                          //   delayStart: Duration(
                          //       milliseconds: 600),
                          //   animationDuration:
                          //   Duration(seconds: 1),
                          //   curve: Curves.decelerate,
                          //   direction: Direction.vertical,
                          //   offset: 0.5,
                          //   child: const Text(
                          //     "Or register with email",
                          //     style: TextStyle(color: textcolor),
                          //   ),
                          // ),
                          SizedBox(
                            height: 15,
                          ),
                          // ShowUpAnimation(
                          //   delayStart: Duration(
                          //       seconds: 1),
                          //   animationDuration:
                          //   Duration(seconds: 1),
                          //   curve: Curves.decelerate,
                          //   direction: Direction.vertical,
                          //   offset: 0.5,
                          //   child: TextFormField(
                          //       style: TextStyle(color: Colors.black),
                          //       textCapitalization: TextCapitalization.words,
                          //       autovalidateMode:
                          //           AutovalidateMode.onUserInteraction,
                          //       controller:
                          //           AuthController.controller.nameController,
                          //       validator: (value) => value!.isEmpty
                          //           ? 'Name cannot be blank'
                          //           : null,
                          //       decoration: InputDecoration(
                          //           labelText: "Full name",
                          //           labelStyle: TextStyle(
                          //               color:
                          //                   Color.fromARGB(255, 134, 145, 163)),
                          //           prefixIcon: Icon(FontAwesomeIcons.solidUser,
                          //               color:
                          //                   Color.fromARGB(255, 134, 145, 163)))),
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          ShowUpAnimation(
                            delayStart: Duration(
                                seconds: 0,milliseconds: 400),
                            animationDuration:
                            Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            offset: 0.5,
                            child: TextFormField(
                                style: TextStyle(color: Colors.black),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller:
                                    AuthController.controller.emailController,
                                validator: (value) {
                                  if (EmailValidator.validate(AuthController
                                      .controller.emailController.text)) {
                                    return null;
                                  } else {
                                    return 'Email address not valid ';
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: "Email ID",
                                    labelStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 134, 145, 163)),
                                    prefixIcon: Icon(FontAwesomeIcons.at,
                                        color:
                                            Color.fromARGB(255, 134, 145, 163)))),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ShowUpAnimation(delayStart: Duration(
                              milliseconds: 600),
                            animationDuration:
                            Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            offset: 0.5,
                            child: TextFormField(
                                obscureText: true,
                                style: TextStyle(color: Colors.black),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller:
                                    AuthController.controller.passwordController,
                                validator: (value) => (value!.isEmpty ||
                                        value.length < 6)
                                    ? 'Password must be at least 6 characters '
                                    : null,
                                decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 134, 145, 163)),
                                    prefixIcon: Icon(FontAwesomeIcons.lock,
                                        color:
                                            Color.fromARGB(255, 134, 145, 163)))),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ShowUpAnimation(delayStart: Duration(
                              seconds: 0,milliseconds: 800),
                            animationDuration:
                            Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            offset: 0.5,
                            child: TextFormField(
                                obscureText: true,
                                style: TextStyle(color: Colors.black),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: AuthController
                                    .controller.confirmPasswordController,
                                validator: (value) {
                                  print((value ==
                                      AuthController
                                          .controller.passwordController.text));
                                  if (value ==
                                      AuthController
                                          .controller.passwordController.text) {
                                    return null;
                                  } else {
                                    return 'Password and confirm password does\'t match ';
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: "Confirm password",
                                    labelStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 134, 145, 163)),
                                    prefixIcon: Icon(FontAwesomeIcons.lock,
                                        color:
                                            Color.fromARGB(255, 134, 145, 163)))),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Obx(
                            () => AuthController.controller.isLoading.value
                                ? ShowUpAnimation(
                              delayStart: Duration(
                                  seconds: 0),
                              animationDuration:
                              Duration(seconds: 1),
                              curve: Curves.decelerate,
                              direction: Direction.vertical,
                              offset: 0.5,
                                  child: Center(
                                      child: const CircularProgressIndicator(),
                                    ),
                                )
                                : ShowUpAnimation(
                              delayStart: Duration(
                                  seconds: 1,milliseconds: 0),
                              animationDuration:
                              Duration(seconds: 1),
                              curve: Curves.decelerate,
                              direction: Direction.vertical,
                              offset: 0.5,
                                  child: Container(
                                      height: 50,
                                      width: size.size.width,
                                      padding:
                                          const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Color.fromARGB(
                                                        255, 0, 101, 255)),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ))),
                                        child: const Text(
                                          'Sing up',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 3,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () {
                                          final FormState? form = AuthController
                                              .controller.formKey.currentState;
                                          if (form!.validate()) {
                                            AuthController.controller.singup(
                                                AuthController.controller
                                                    .emailController.text,
                                                AuthController.controller
                                                    .passwordController.text);
                                          } else {
                                            print('Form is invalid');
                                          }
                                        },
                                      )),
                                ),
                          ),
                          SizedBox(
                            height: 12,
                          ),

                          ShowUpAnimation(
                            delayStart: Duration(
                                seconds: 1,milliseconds: 200),
                            animationDuration:
                            Duration(seconds: 1),
                            curve: Curves.decelerate,
                            direction: Direction.vertical,
                            offset: 0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already memeber in CryptoTaxi ?",style: TextStyle(color: textcolor),),
                                TextButton(
                                    onPressed: () {
                                      Get.toNamed(LoginScreen.routename);
                                    },
                                    child: Text("Login",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
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
