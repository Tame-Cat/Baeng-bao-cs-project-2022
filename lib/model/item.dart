import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class CategoryField {
  static const createdTime = 'dateTime';
}

class Item {
  String category_id;
  String category_name;
  Timestamp dateTime;
  String detail;
  String donor;
  String item_id;
  String name;
  String photo;
  String status;
  String user_id;

  Item({
    required this.category_id,
    required this.category_name,
    required this.dateTime,
    required this.detail,
    required this.donor,
    required this.item_id,
    required this.name,
    required this.photo,
    required this.status,
    required this.user_id,
  });

  static Item fromJson(Map<String, dynamic> json) => Item(
        category_id: json['category_id'],
        category_name: json['category_name'],
        dateTime: json['dateTime'],
        detail: json['detail'],
        donor: json['donor'],
        item_id: json['item_id'],
        name: json['name'],
        photo: json['photo'],
        status: json['status'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'category_id': category_id,
        'category_name': category_name,
        'dateTime': dateTime,
        'detail': detail,
        'donor': donor,
        'item_id': item_id,
        'name': name,
        'photo': photo,
        'status': status,
        'user_id': user_id,
      };
}
