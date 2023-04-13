import 'package:flutter/cupertino.dart';

class BucketField {
  static const createdTime = 'dateTime';
}

class Bucket {
  String bucket_id;
  String detail;
  String item_id;
  String name;
  String photo;
  String user_id;

  Bucket({
    required this.bucket_id,
    required this.detail,
    required this.item_id,
    required this.name,
    required this.photo,
    required this.user_id,
  });

  static Bucket fromJson(Map<String, dynamic> json) => Bucket(
        bucket_id: json['bucket_id'],
        detail: json['detail'],
        item_id: json['item_id'],
        name: json['name'],
        photo: json['photo'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'bucket_id': bucket_id,
        'detail': detail,
        'item_id': item_id,
        'name': name,
        'photo': photo,
        'user_id': user_id,
      };
}
