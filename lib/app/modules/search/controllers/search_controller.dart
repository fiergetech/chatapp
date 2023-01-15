import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  late TextEditingController searchC;

  var queryFirst = [].obs;
  var tempSearch = [].obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  void searchUser(String data, String email) async {
    print("SEARCH  : $data");
    if (data.length == 0) {
      queryFirst.value = [];
      tempSearch.value = [];
    } else {
      var capitalized = data.substring(0, 1).toUpperCase() + data.substring(1);
      print(capitalized);
      if (queryFirst.length == 0 && data.length == 1) {
        //first function to start while first type
        CollectionReference users = await firestore.collection("users");
        final keyNameResult = await users
            .where("keyName", isEqualTo: data.substring(0, 1).toUpperCase())
            .where("email", isNotEqualTo: email)
            .get();

        print("TOTAL DATA: ${keyNameResult.docs.length}");
        if (keyNameResult.docs.length > 0) {
          for (int i = 0; i < keyNameResult.docs.length; i++) {
            queryFirst
                .add(keyNameResult.docs[i].data() as Map<String, dynamic>);
          }
          print("QUERY RESULT : ");
          print(queryFirst);
        } else {
          print("NO DATA FOUND");
        }
      }
      //String name = "Klugaga Singa";
      //name.startsWith(element)
      if (queryFirst.length != 0) {
        tempSearch.value = [];
        queryFirst.forEach((element) {
          if (element["name"].startsWith(capitalized)) {
            tempSearch.add(element);
          }
        });
      }
    }
    queryFirst.refresh();
    tempSearch.refresh();
  }

  @override
  void onInit() {
    searchC = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
  //TODO: Implement SearchController

  /*final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;*/
}
