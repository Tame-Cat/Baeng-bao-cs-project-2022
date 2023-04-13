import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class ChatLinkField {
  static const createdTime = 'dateTime';
}

class ChatLink {
  final String day;
  final String id;
  final String message;
  final String post_id;
  final String post_name;
  final String receiver_id;
  final String sender_id;
  final String status;
  final String time;
  final int type;
  final int unseen;

  const ChatLink({
    required this.day,
    required this.id,
    required this.message,
    required this.post_id,
    required this.post_name,
    required this.receiver_id,
    required this.sender_id,
    required this.status,
    required this.time,
    required this.type,
    required this.unseen,
  });

  static ChatLink fromJson(Map<String, dynamic> json) => ChatLink(
        day: json['day'],
        id: json['id'],
        message: json['message'],
        post_id: json['post_id'],
        post_name: json['post_name'],
        receiver_id: json['receiver_id'],
        sender_id: json['sender_id'],
        status: json['status'],
        time: json['time'],
        type: json['type'],
        unseen: json['unseen'],
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'id': id,
        'message': message,
        'post_id': post_id,
        'post_name': post_name,
        'receiver_id': receiver_id,
        'sender_id': sender_id,
        'status': status,
        'time': time,
        'type': type,
        'unseen': unseen,
      };

  factory ChatLink.fromDocument(DocumentSnapshot doc) {
    String receiver_id = "";
    String sender_id = "";
    String status = "";
    String message = "";
    String post_id = "";
    String post_name = "";
    int unseen = 0;
    int type = 0;
    String time = "";
    String day = "";

    try {
      receiver_id = doc.get("receiver_id");
    } catch (e) {}
    try {
      sender_id = doc.get("sender_id");
    } catch (e) {}
    try {
      status = doc.get("status");
    } catch (e) {}
    try {
      message = doc.get("message");
    } catch (e) {}
    try {
      post_id = doc.get("post_id");
    } catch (e) {}
    try {
      post_name = doc.get("post_name");
    } catch (e) {}
    try {
      unseen = doc.get("unseen");
    } catch (e) {}
    try {
      type = doc.get("type");
    } catch (e) {}
    try {
      time = doc.get("time");
    } catch (e) {}
    try {
      day = doc.get("day");
    } catch (e) {}

    return ChatLink(
      day: day,
      id: doc.id,
      message: message,
      post_id: post_id,
      post_name: post_name,
      receiver_id: receiver_id,
      sender_id: sender_id,
      status: status,
      time: time,
      type: type,
      unseen: unseen,
    );
  }
}
