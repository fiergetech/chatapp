import 'package:chatapp/app/controllers/auth_controller.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/app/utils/error_screen.dart';
import 'package:chatapp/app/utils/loading_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/utils/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  await GetStorage.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final authC = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorScreen();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: Future.delayed(Duration(seconds: 3)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Obx(
                  () => GetMaterialApp(
                    title: "Your text",
                    initialRoute: authC.isSkipIntro.isTrue
                        ? authC.isAuth.isTrue
                            ? Routes.HOME
                            : Routes.LOGIN
                        : Routes.INTRODUCTION,
                    getPages: AppPages.routes,
                  ),
                );
              }
              return FutureBuilder(
                future: authC.firstInitialized(),
                builder: (context, snapshot) => SplashScreen(),
              );
            },
          );
        }
        return LoadingScreen();
      },
    );
  }
}
