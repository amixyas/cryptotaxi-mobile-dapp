import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:show_up_animation/show_up_animation.dart';

class WaitingForConfirmationScreen extends StatefulWidget {
  WaitingForConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<WaitingForConfirmationScreen> createState() =>
      _WaitingForConfirmationScreenState();
}

class _WaitingForConfirmationScreenState
    extends State<WaitingForConfirmationScreen> {
  bool refused = false;
  String motif = "";

  Future<void> get() async {
    var s = await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(AuthController.controller.auth!.currentUser!.uid)
        .child("motif")
        .get();
    motif = s.value.toString();
    if (motif.isNotEmpty) {
      refused = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    get();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
        width: double.infinity,
        height: OneContext().mediaQuery.size.height,
        color: Colors.amberAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ShowUpAnimation(
                delayStart: Duration(milliseconds: 0),
                animationDuration: Duration(seconds: 1),
                curve: Curves.decelerate,
                direction: Direction.vertical,
                offset: 0.5,
                child: refused
                    ? Image.asset(
                        "assets/images/rejected.png",
                        fit: BoxFit.fill,
                        height: OneContext().mediaQuery.size.height * 0.2,
                        width: OneContext().mediaQuery.size.height * 0.2,
                      )
                    : Image.asset(
                        "assets/images/wait.png",
                        fit: BoxFit.fill,
                        height: OneContext().mediaQuery.size.height * 0.2,
                        width: OneContext().mediaQuery.size.height * 0.2,
                      )),
            ShowUpAnimation(
                delayStart: Duration(milliseconds: 200),
                animationDuration: Duration(seconds: 1),
                curve: Curves.decelerate,
                direction: Direction.vertical,
                offset: 0.5,
                child: Center(
                  child: refused
                      ? Text(
                          "YOU HAVE BEEN REFUSED!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 16),
                        )
                      : Text(
                          "PLEASE WAIT WHILE THE ADMIN VERIFY THE DOCUMENTS YOU PROVIDED!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textcolor,
                              fontSize: 16),
                        ),
                )),
            SizedBox(
              height: 10,
            ),
            ShowUpAnimation(
                delayStart: Duration(milliseconds: 400),
                animationDuration: Duration(seconds: 1),
                curve: Curves.decelerate,
                direction: Direction.vertical,
                offset: 0.5,
                child: Center(
                  child: refused
                      ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            motif,
                            textAlign: TextAlign.center,
                            maxLines: null,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textcolor),
                          ),
                      )
                      : Text(
                          "Check the app again after few hours.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textcolor,
                              fontSize: 16),
                        ),
                )),
            if (refused)
              ShowUpAnimation(
                  delayStart: Duration(milliseconds: 400),
                  animationDuration: Duration(seconds: 1),
                  curve: Curves.decelerate,
                  direction: Direction.vertical,
                  offset: 0.5,
                  child: Center(
                    child: Material(
                      elevation: 12,
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        width: 200,
                        child: TextButton(
                            onPressed: () async {
                              try {
                                await FirebaseDatabase.instance
                                    .ref()
                                    .child("users")
                                    .child(AuthController.controller.auth!.currentUser!.uid)
                                    .child("firstUse")
                                    .set(true);
                                await FirebaseDatabase.instance
                                    .ref()
                                    .child("users")
                                    .child(AuthController.controller.auth!.currentUser!.uid)
                                    .child("motif")
                                    .set("");
                                AuthController.controller.initialScreen(AuthController.controller.auth!.currentUser!);
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: Text(
                              "Submit again",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16),
                            )),
                      ),
                    ),
                  )),
            ShowUpAnimation(
                delayStart: Duration(milliseconds: 600),
                animationDuration: Duration(seconds: 1),
                curve: Curves.decelerate,
                direction: Direction.vertical,
                offset: 0.5,
                child: Center(
                  child: Material(
                    elevation: 12,
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                    child: SizedBox(
                      width: 120,
                      child: TextButton(
                          onPressed: () {
                            try {
                              AuthController.controller.logout();
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Text(
                            "Logout",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16),
                          )),
                    ),
                  ),
                )),
          ],
        ),
      )),
    );
  }
}
