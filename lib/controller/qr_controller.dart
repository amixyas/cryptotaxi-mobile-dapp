import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'navigation_controller.dart';

class QR_Controller extends GetxController{
  static QR_Controller controller = Get.find();

  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qRController;
    var result ="".obs ;

}