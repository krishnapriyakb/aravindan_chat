// To parse this JSON data, do
//
//     final messageModal = messageModalFromJson(jsonString);

import 'dart:convert';

MessageModal messageModalFromJson(String str) =>
    MessageModal.fromJson(json.decode(str));

String messageModalToJson(MessageModal data) => json.encode(data.toJson());

class MessageModal {
  String toId;
  String dlvryTime;
  String frId;
  String message;
  Type type;

  MessageModal({
    required this.toId,
    required this.dlvryTime,
    required this.frId,
    required this.message,
    required this.type,
  });

  factory MessageModal.fromJson(Map<String, dynamic> json) => MessageModal(
        toId: json["toId"],
        dlvryTime: json["dlvryTime"],
        frId: json["frId"],
        message: json["message"],
        type: json["type"] == "video"
            ? Type.video
            : json["type"] == "image"
                ? Type.image
                : Type.text,
      );

  Map<String, dynamic> toJson() => {
        "toId": toId,
        "dlvryTime": dlvryTime,
        "frId": frId,
        "message": message,
        "type": type.name,
      };
}

enum Type { image, text, video }
