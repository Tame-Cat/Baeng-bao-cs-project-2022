import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PatientField {
  static const createdTime = 'dateTime';
}

class Patient {
  String address;
  Timestamp birthday;
  Timestamp dateTime;
  String firstname;
  String id_card;
  String lastname;
  String patient_id;
  String photo;
  String photo_house;
  String photo_id_card;
  String status;
  String symptom;
  String user_id;

  Patient({
    required this.address,
    required this.birthday,
    required this.dateTime,
    required this.firstname,
    required this.id_card,
    required this.lastname,
    required this.patient_id,
    required this.photo,
    required this.photo_house,
    required this.photo_id_card,
    required this.status,
    required this.symptom,
    required this.user_id,
  });

  static Patient fromJson(Map<String, dynamic> json) => Patient(
        address: json['address'],
        birthday: json['birthday'],
        dateTime: json['dateTime'],
        firstname: json['firstname'],
        id_card: json['id_card'],
        lastname: json['lastname'],
        patient_id: json['patient_id'],
        photo: json['photo'],
        photo_house: json['photo_house'],
        photo_id_card: json['photo_id_card'],
        status: json['status'],
        symptom: json['symptom'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'birthday': birthday,
        'dateTime': dateTime,
        'firstname': firstname,
        'id_card': id_card,
        'lastname': lastname,
        'patient_id': patient_id,
        'photo': photo,
        'photo_house': photo_house,
        'photo_id_card': photo_id_card,
        'status': status,
        'symptom': symptom,
        'user_id': user_id,
      };
}
