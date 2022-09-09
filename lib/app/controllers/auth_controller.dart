import 'package:chatapp/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;
  UserCredential? userCredential;

  GoogleSignInAccount? _currentUser;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> firstInitialized() async {
    final box = GetStorage();
    if (box.read('skipIntro') != null || box.read('skipIntro') == true) {
      isSkipIntro.value = true;
    }
  }

  Future<bool> autoLogin() async {
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        return true;
      }
      return false;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<void> login() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.signIn().then((value) => _currentUser = value);
      final isSignIn = await _googleSignIn.isSignedIn();

      if (isSignIn) {
        // to handle user data leak before login
        print("Success login with : ");
        print(_currentUser);
        final googleAuth = await _currentUser!.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);
        print("User credential");
        print(userCredential);

        //save user status login => not showing introduction again
        final box = GetStorage();
        box.write('skipIntro', true);

        isAuth.value = true;
        Get.offAllNamed(Routes.HOME);
      } else {
        print("Login failed");
      }
    } catch (error) {
      printError();
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
