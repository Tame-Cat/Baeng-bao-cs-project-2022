import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class HistoryField {
  static const createdTime = 'dateTime';
}

class History {
  Timestamp dateTime;
  String history_id;
  String patient_firstname;
  String patient_id;
  String patient_lastname;
  String patient_symptom;
  String status;
  String user_id;

  History(
      {required this.dateTime,
      required this.history_id,
      required this.patient_firstname,
      required this.patient_id,
      required this.patient_lastname,
      required this.patient_symptom,
      required this.status,
      required this.user_id});

  static History fromJson(Map<String, dynamic> json) => History(
        dateTime: json['dateTime'],
        history_id: json['history_id'],
        patient_firstname: json['patient_firstname'],
        patient_id: json['patient_id'],
        patient_lastname: json['patient_lastname'],
        patient_symptom: json['patient_symptom'],
        status: json['status'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'dateTime': dateTime,
        'history_id': history_id,
        'patient_firstname': patient_firstname,
        'patient_id': patient_id,
        'patient_lastname': patient_lastname,
        'patient_symptom': patient_symptom,
        'status': status,
        'user_id': user_id,
      };
}
