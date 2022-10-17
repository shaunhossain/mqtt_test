import 'dart:convert';

MessageResponse messageResponseFromJson(String str) => MessageResponse.fromJson(jsonDecode(str));

String messageResponseToJson(MessageResponse data) => json.encode(data.toJson());

class MessageResponse {
  MessageResponse({
    required this.msg,
    required this.image,
  });

  final String? msg;
  final String? image;

  factory MessageResponse.fromJson(Map<String, dynamic> json) => MessageResponse(
    msg: json["msg"] == null ? null : json["msg"],
    image: json["image"] == null ? null : json["image"],
  );

  Map<String, dynamic> toJson() => {
    "msg": msg == null ? null : msg,
    "image": image == null ? null : image,
  };
}
