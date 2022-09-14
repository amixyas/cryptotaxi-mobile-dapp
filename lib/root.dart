import 'package:cryptotaxi/view/homePage.dart';
import 'package:cryptotaxi/view/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/auth_controller.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return (AuthController.controller.firebaseUser != null)
          ? Home()
          : LoginScreen();
    });
  }
}
