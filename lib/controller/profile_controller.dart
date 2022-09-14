import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:cryptotaxi/view/feedbackScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:one_context/one_context.dart';
import 'package:shake/shake.dart';

class ProfileController extends GetxController {
  static ProfileController controller = Get.find();
  late TextEditingController name;

  late TextEditingController email;

  late TextEditingController address;
  TextEditingController? car;

  late TextEditingController phone;
  bool shown = false;
  late ShakeDetector detector;

  GlobalKey form = GlobalKey<FormState>();
  String? phonenumber;
  var phoneEdit = false.obs;
  var canEdit = false.obs;
  var canSubmit = false.obs;
  var carExpanded = false.obs;
  DatabaseReference? imgRef;

  RxList<String> carImg = <String>[].obs;
  RxList<String> carint = <String>[].obs;
  void goToFeedBack()async {
    if(shown){return ;}else{
      shown=true;
    if (await confirm(OneContext().context!,
    title: Text("Feedback"),
    content: Text(
    "Click the confirm button if you want to go to feedback page"),
    textOK: Text("Confirm"),
    textCancel: Text("Back"))) {
    Get.to(() => FeedBackScreen())?.then((value) { shown=false;});
    }else{
      shown=false;
    }}
  }
  @override
  Future<void> getImages() async {
    print("THIS IS ROLEEEEEEEEEEEEE ${AuthController.controller.role.value}");
    if (AuthController.controller.role.value == "driver") {
      print(
          "GETTING IMG FOR ${AuthController.controller.auth!.currentUser!.uid}");
      imgRef?.onDisconnect();
      imgRef =  FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(AuthController.controller.auth!.currentUser!.uid)
          .child("imgs").ref;

      imgRef?.onValue.forEach((element) async {
        carImg.clear();
        carint.clear();
        print("THIS IS ELEMENT ${element.snapshot.value.toString()}");

        for (final child in element.snapshot.children) {
          print("THIS IS TIOMGGGGGGGG ${child.value.toString()}");
          carImg.add(child.value.toString());
          carint.add(child.key.toString());
        }
      });
    }
  }

  void onInit() {
    // TODO: implement onInit
    super.onInit();

    detector =
    ShakeDetector.waitForStart(
      onPhoneShake: () async {
        goToFeedBack();
      },
      minimumShakeCount: 3,
    );
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }
}
