import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserModelField {
  static const createdTime = 'dateTime';
}

class UserModel {
  String address;
  String birthday;
  String email;
  String firstname;
  String id_card;
  String lastname;
  String password;
  String photo;
  String photo_house;
  String photo_id_card;
  String status;
  String tel;
  String token;
  String type;
  String user_id;

  UserModel({
    required this.address,
    required this.birthday,
    required this.email,
    required this.firstname,
    required this.id_card,
    required this.lastname,
    required this.password,
    required this.photo,
    required this.photo_house,
    required this.photo_id_card,
    required this.status,
    required this.tel,
    required this.token,
    required this.type,
    required this.user_id,
  });

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        address: json['address'],
        birthday: json['birthday'],
        email: json['email'],
        firstname: json['firstname'],
        id_card: json['id_card'],
        lastname: json['lastname'],
        password: json['password'],
        photo: json['photo'],
        photo_house: json['photo_house'],
        photo_id_card: json['photo_id_card'],
        status: json['status'],
        tel: json['tel'],
        token: json['token'],
        type: json['type'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'birthday': birthday,
        'email': email,
        'firstname': firstname,
        'id_card': id_card,
        'lastname': lastname,
        'password': password,
        'photo': photo,
        'photo_house': photo_house,
        'photo_id_card': photo_id_card,
        'status': status,
        'token': token,
        'type': type,
        'user_id': user_id,
      };
}
