import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/controller/driverRide_controller.dart';
import 'package:cryptotaxi/controller/profile_controller.dart';
import 'package:cryptotaxi/controller/wallet_controller.dart';
import 'package:cryptotaxi/root.dart';
import 'package:cryptotaxi/view/SignupScreen.dart';
import 'package:cryptotaxi/view/firstUseScreen.dart';
import 'package:cryptotaxi/view/homePage.dart';
import 'package:cryptotaxi/view/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_context/one_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import 'controller/SC_controller.dart';
import 'controller/driver_controller.dart';
import 'controller/navigation_controller.dart';
import 'controller/notification_controller.dart';
import 'controller/qr_controller.dart';
import 'controller/rideHistory_Controller.dart';
import 'controller/ride_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp().then((value) async {
    Get.put(AuthController());
    Get.put(NavigationController());
    Get.put(SC_Controller());
    Get.put(WalletController());
    Get.put(NotificationController());
    Get.put(DriverController());
    Get.put(RideController());
    Get.replace(RideHistoryController());


    Get.put(ProfileController());
    // Get.lazyPut(() => RideController());
    Get.lazyPut(() => DriverRideController());
    Get.lazyPut(() => QR_Controller());

    // Get.lazyPut(() => RideController());


    // Get.lazyPut(()=> RideHistoryController());
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(Phoenix(child: MyApp()));
  });

}

const textcolor = const Color.fromARGB(255, 23, 43, 77);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: EasyLoading.init(builder: OneContext().builder),
      title: 'Crypto Taxi',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,

        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context)
              .textTheme, // If this is not set, then ThemeData.light().textTheme is used.
        ).apply(
          bodyColor: Color.fromARGB(255, 94, 107, 131),
        ),
      ),
      home: LoginScreen(),
      routes: {
        LoginScreen.routename: (ctx) => LoginScreen(),
        SignupScreen.routename: (ctx) => SignupScreen(),
        Home.routename: (ctx) => Home(),
        FirstUse.routename: (ctx) => FirstUse()
      },
    );
  }
}
