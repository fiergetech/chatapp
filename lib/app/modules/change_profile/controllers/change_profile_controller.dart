import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeProfileController extends GetxController {
  late TextEditingController emailC;
  late TextEditingController nameC;
  late TextEditingController statusC;
  @override
  void onInit() {
    emailC = TextEditingController(text: "johndoe@gmail.com");
    nameC = TextEditingController(text: "John Doe");
    statusC = TextEditingController();

    super.onInit();
  }

  @override
  void onClose() {
    emailC.dispose();
    nameC.dispose();
    statusC.dispose();
    super.onClose();
  }
}
