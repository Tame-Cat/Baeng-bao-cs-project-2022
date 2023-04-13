import 'package:flutter/cupertino.dart';

class FavoriteField {
  static const createdTime = 'createdTime';
}

class Favorite {
  String favorite_id;
  String post_id;
  String user_id;

  Favorite(
      {required this.favorite_id,
      required this.post_id,
      required this.user_id});

  static Favorite fromJson(Map<String, dynamic> json) => Favorite(
        favorite_id: json['favorite_id'],
        post_id: json['post_id'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'favorite_id': favorite_id,
        'post_id': post_id,
        'user_id': user_id,
      };
}
