import 'package:flutter/cupertino.dart';

class OrderField {
  static const createdTime = 'dateTime';
}

class OrderModel {
  String reason;
  String day;
  String day_receive;
  String day_return;
  List item;
  String order_id;
  String patient_id;
  String status;
  String time;
  String time_receive;
  String time_return;
  String user_id;

  OrderModel({
    required this.reason,
    required this.day,
    required this.day_receive,
    required this.day_return,
    required this.item,
    required this.order_id,
    required this.patient_id,
    required this.status,
    required this.time,
    required this.time_receive,
    required this.time_return,
    required this.user_id,
  });

  static OrderModel fromJson(Map<String, dynamic> json) => OrderModel(
        reason: json['reason'],
        day: json['day'],
        day_receive: json['day_receive'],
        day_return: json['day_return'],
        item: json['item'],
        order_id: json['order_id'],
        patient_id: json['patient_id'],
        status: json['status'],
        time: json['time'],
        time_receive: json['time_receive'],
        time_return: json['time_return'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'day': day,
        'day_receive': day_receive,
        'day_return': day_return,
        'item': item,
        'order_id': order_id,
        'patient_id': patient_id,
        'status': status,
        'time': time,
        'time_receive': time_receive,
        'time_return': time_return,
        'user_id': user_id,
      };
}
