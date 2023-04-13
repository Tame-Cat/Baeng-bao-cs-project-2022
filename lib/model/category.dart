import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class CategoryModelField {
  static const createdTime = 'dateTime';
}

class CategoryModel {
  String name;
  String photo;
  String category_id;
  String user_id;

  CategoryModel({
    required this.name,
    required this.photo,
    required this.category_id,
    required this.user_id,
  });

  static CategoryModel fromJson(Map<String, dynamic> json) => CategoryModel(
        name: json['name'],
        photo: json['photo'],
        category_id: json['category_id'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'photo': photo,
        'category_id': category_id,
        'user_id': user_id,
      };
}
