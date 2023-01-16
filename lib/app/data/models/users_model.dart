// To parse this JSON data, do
//
//     final usersModel = usersModelFromJson(jsonString);

import 'dart:convert';

UsersModel usersModelFromJson(String str) =>
    UsersModel.fromJson(json.decode(str));

String usersModelToJson(UsersModel data) => json.encode(data.toJson());

class UsersModel {
  UsersModel({
    this.uid,
    this.name,
    this.keyName,
    this.email,
    this.createdAt,
    this.lastSignInTime,
    this.photoUrl,
    this.status,
    this.updatedAt,
    this.chats,
  });

  String? uid;
  String? name;
  String? keyName;
  String? email;
  String? createdAt;
  String? lastSignInTime;
  String? photoUrl;
  String? status;
  String? updatedAt;
  List<ChatUser>? chats;

  factory UsersModel.fromJson(Map<String, dynamic> json) => UsersModel(
        uid: json["uid"],
        name: json["name"],
        keyName: json["keyName"],
        email: json["email"],
        createdAt: (json["createdAt"]),
        lastSignInTime: (json["lastSignInTime"]),
        photoUrl: json["photoUrl"],
        status: json["status"],
        updatedAt: (json["updatedAt"]),
        chats:
            List<ChatUser>.from(json["chats"].map((x) => ChatUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "keyName": keyName,
        "email": email,
        "createdAt": createdAt,
        "lastSignInTime": lastSignInTime,
        "photoUrl": photoUrl,
        "status": status,
        "updatedAt": updatedAt,
        "chats": List<dynamic>.from(chats!.map((x) => x.toJson())),
      };
}

class ChatUser {
  ChatUser({
    this.connection,
    this.chatId,
    this.lastTime,
  });

  String? connection;
  String? chatId;
  String? lastTime;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        connection: json["connection"],
        chatId: json["chat_id"],
        lastTime: (json["lastTime"]),
      );

  Map<String, dynamic> toJson() => {
        "connection": connection,
        "chat_id": chatId,
        "lastTime": lastTime,
      };
}
