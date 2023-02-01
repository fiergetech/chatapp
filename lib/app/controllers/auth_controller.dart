import 'package:chatapp/app/data/models/users_model.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;
  UserCredential? userCredential;
  var user = UsersModel().obs;
  //TODO FirebaseFirestore;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  GoogleSignInAccount? _currentUser;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> firstInitialized() async {
    await autoLogin().then((value) {
      if (value) {
        isAuth.value = true;
      }
    });
    await skipIntro().then((value) {
      if (value) {
        isSkipIntro.value = true;
      }
    });
  }

  Future<bool> skipIntro() async {
    final box = GetStorage();
    if (box.read('skipIntro') != null || box.read('skipIntro') == true) {
      return true;
    }

    return false;
  }

  Future<bool> autoLogin() async {
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        await _googleSignIn
            .signInSilently()
            .then((value) => _currentUser = value);
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
        CollectionReference users = firestore.collection('users');

        await users.doc(_currentUser!.email).update({
          "lastSignInTime":
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        });
        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

        return true;
      }
      return false;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<void> login() async {
    // change isAuth to true autologin
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
        if (box.read('skipIntro') != null) {
          box.remove('skipIntro');
        }
        box.write('skipIntro', true);

        CollectionReference users = firestore.collection('users');

        final checkuser = await users.doc(_currentUser!.email).get();
        if (checkuser.data() == null) {
          await users.doc(_currentUser!.email).set({
            "uid": userCredential!.user!.uid,
            "name": _currentUser!.displayName,
            "keyName": _currentUser!.displayName!.substring(0, 1).toUpperCase(),
            "email": _currentUser!.email,
            "photoUrl": _currentUser!.photoUrl ?? "noimage",
            "status": "",
            "createdAt":
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updatedAt": DateTime.now().toIso8601String(),
            "chats": [],
          });
        } else {
          await users.doc(_currentUser!.email).update({
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
          });
        }
        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

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
    await _googleSignIn.disconnect();

    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  // profile
  void changeProfile(String name, String status) {
    String date = DateTime.now().toIso8601String();
    // update firebase
    CollectionReference users = firestore.collection('users');
    users.doc(_currentUser!.email).update({
      "name": name,
      "keyName": name.substring(0, 1).toUpperCase(),
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updatedAt": date,
    });

    // update model
    user.update((user) {
      user!.name = name;
      user.keyName = name.substring(0, 1).toUpperCase();
      user.status = status;
      user.lastSignInTime =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user.updatedAt = date;
    });

    user.refresh();
    Get.defaultDialog(title: "Succes", middleText: "Profile update success");
  }

  void updateStatus(String status) {
    String date = DateTime.now().toIso8601String();

    // update firebase
    CollectionReference users = firestore.collection('users');
    users.doc(_currentUser!.email).update({
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updatedAt": date,
    });

    // update model
    user.update((user) {
      user!.status = status;
      user.lastSignInTime =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user.updatedAt = date;
    });

    user.refresh();
    Get.defaultDialog(title: "Succes", middleText: "Status update success");
  }

  void addNewConnection(String friendEmail) async {
    bool flagNewConnection = false;
    var chat_id;
    var connection;
    var lastTime;
    String date = DateTime.now().toIso8601String();
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    final docUser = await users.doc(_currentUser!.email).get();
    final docChats = (docUser.data() as Map<String, dynamic>)["chats"] as List;

    if (docChats.length != 0) {
      // user ever chat with anyone

      /*docChats.add({
        "connection": friendEmail,
        "chat_id": chatsDataId,
        "lastTime": chatsData["lastTime"],
      });*/

      docChats.forEach((singleChat) {
        if (singleChat["connection"] == friendEmail) {
          chat_id = singleChat["chat_id"];
        }
      });
      if (chat_id != null) {
        // ever create connection (history chat) with > friendEmail
        flagNewConnection = false;
      } else {
        flagNewConnection = true;
      }
    } else {
      // havent chat with anyone
      flagNewConnection = true;
    }

    if (flagNewConnection) {
      final chatDocs = await chats.where(
        "connections",
        whereIn: [
          [
            friendEmail, //zurfech
            _currentUser!.email, //hindro
          ],
          [
            _currentUser!.email, //hindro
            friendEmail, //zurfech
          ],
        ],
      ).get();
      if (chatDocs.docs.length != 0) {
        //already connection between both
        final chatsDataId = chatDocs.docs[0].id;
        final chatsData = chatDocs.docs[0].data() as Map<String, dynamic>;

        // TODO don't replace old data
        docChats.add({
          "connection": friendEmail,
          "chat_id": chatsDataId,
          "lastTime": chatsData["lastTime"],
        });

        await users.doc(_currentUser!.email).update({"chats": docChats});

        user.update((user) {
          user!.chats = docChats as List<ChatUser>;
        });
        user.refresh();
        chat_id = chatsDataId;
      } else {
        //create new never have connection
        final newChatDoc = await chats.add({
          "connections": [
            _currentUser!.email,
            friendEmail,
          ],
          "total_chats": 0,
          "total_read": 0,
          "total_unread": 0,
          "chat": [],
          "lastTime": date,
        });

        docChats.add({
          "connection": friendEmail,
          "chat_id": newChatDoc.id,
          "lastTime": date,
        });

        await users.doc(_currentUser!.email).update({"chats": docChats});

        user.update((user) {
          user!.chats = docChats as List<ChatUser>;
        });
        user.refresh();
        chat_id = newChatDoc.id;
      }
    }
    print(chat_id);
    // havent create connection (history chat) with > friendEmail
    // ever create connection (history chat) with > friendEmail
    Get.toNamed(Routes.CHAT_ROOM, arguments: chat_id);
  }
}
