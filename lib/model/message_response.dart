import 'dart:convert';

MessageResponse messageResponseFromJson(String str) =>
    MessageResponse.fromJson(jsonDecode(str));

String messageResponseToJson(MessageResponse data) =>
    json.encode(data.toJson());

class MessageResponse {
  MessageResponse({
    required this.msg,
  });

  final String? msg;

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(
        msg: json["msg"] == null ? null : json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg == null ? null : msg,
      };
}
