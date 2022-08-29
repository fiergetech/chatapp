import 'package:chatapp/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../controllers/introduction_controller.dart';

class IntroductionView extends GetView<IntroductionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Fast and secure chat",
            body: "A simple, lightweight yet secure chat application",
            image: Container(
              width: Get.width * 0.6,
              height: Get.height * 0.6,
              child: Center(
                  child: Lottie.asset("assets/lottie/main-laptop-duduk.json")),
            ),
          ),
          PageViewModel(
            title: "Find your new friends",
            body: "Expand more of your networks and collegues",
            image: Container(
              width: Get.width * 0.6,
              height: Get.height * 0.6,
              child: Center(child: Lottie.asset("assets/lottie/ojek.json")),
            ),
          ),
          PageViewModel(
            title: "Interact easily",
            body: "A simple, lightweight chat application",
            image: Container(
              width: Get.width * 0.6,
              height: Get.height * 0.6,
              child: Center(child: Lottie.asset("assets/lottie/payment.json")),
            ),
          ),
          PageViewModel(
            title: "Join now!",
            body: "Sign up to start your new experience of chatting",
            image: Container(
              width: Get.width * 0.6,
              height: Get.height * 0.6,
              child: Center(child: Lottie.asset("assets/lottie/register.json")),
            ),
          ),
        ],
        onDone: () => Get.offAllNamed(Routes.LOGIN),
        showSkipButton: true,
        skip: Text("Skip"),
        next: Text(
          "Next",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        done:
            const Text("Login", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
