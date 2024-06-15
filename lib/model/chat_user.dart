// To parse this JSON data, do
//
//     final chatUserModal = chatUserModalFromJson(jsonString);

import 'dart:convert';

ChatUserModal chatUserModalFromJson(String str) =>
    ChatUserModal.fromJson(json.decode(str));

String chatUserModalToJson(ChatUserModal data) => json.encode(data.toJson());

class ChatUserModal {
  String image;
  String about;
  String name;
  String createdAt;
  bool isOnline;
  String lastActive;
  String id;
  String pushToken;
  String email;

  ChatUserModal({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.lastActive,
    required this.id,
    required this.pushToken,
    required this.email,
  });

  factory ChatUserModal.fromJson(Map<String, dynamic> json) => ChatUserModal(
        image: json["image"],
        about: json["about"],
        name: json["name"],
        createdAt: json["created_at"],
        isOnline: json["isOnline"],
        lastActive: json["last_active"],
        id: json["id"],
        pushToken: json["push_token"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "about": about,
        "name": name,
        "created_at": createdAt,
        "isOnline": isOnline,
        "last_active": lastActive,
        "id": id,
        "push_token": pushToken,
        "email": email,
      };
}
