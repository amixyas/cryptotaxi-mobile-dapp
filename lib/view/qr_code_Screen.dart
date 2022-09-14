import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_context/one_context.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../controller/qr_controller.dart';


class QR_CodeScreen extends StatefulWidget {
   QR_CodeScreen({Key? key}) : super(key: key);

  @override
  State<QR_CodeScreen> createState() => _QR_CodeScreenState();
}

class _QR_CodeScreenState extends State<QR_CodeScreen> {
   Barcode? code;
   bool working = false;
   void _onQRViewCreated(QRViewController controller) {
     QR_Controller.controller.qRController = controller;
     controller.scannedDataStream.listen((scanData) {
       print(scanData.code);
       code=scanData;
       QR_Controller.controller.result.value = scanData.code!;
       goingBack();
     });
   }
   void goingBack(){
    if(working==false){ Get.back(result: QR_Controller.controller.result.value,closeOverlays: true);}
    working=true;
   }
   @override
   void dispose() {
     QR_Controller.controller.qRController?.dispose();
     super.dispose();
   }
   @override
   void reassemble() {
     super.reassemble();
     if (Platform.isAndroid) {
       QR_Controller.controller.qRController!.pauseCamera();
     } else if (Platform.isIOS) {
       QR_Controller.controller.qRController!.resumeCamera();
     }
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: QR_Controller.controller.qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderWidth: 10,
              cutOutSize: OneContext().mediaQuery.size.width*0.8
                ,

            ),
          ),
          Positioned(
           bottom: 20,
           child: Card(child: Padding(
             padding: const EdgeInsets.all(10.0),
             child:  Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 if (code != null)
                  Obx(()=> Text(
                      'Data: ${QR_Controller.controller.result.value}'))
                 else
                   Center(child: const Text('Scan a code')),
               ],
             ),
           ),),
         )
        ],
      ),
    );
  }
}
