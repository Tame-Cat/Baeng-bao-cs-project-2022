import 'dart:io';

//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/model/patient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:baeng_bao/model/favorite.dart';
import 'package:baeng_bao/model/user_model.dart';

class CloudFirestoreApi {
  static Future<bool> checkExistEmail(String email) async {
    final ref = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .get();

    if (ref.size != 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkExistIdCard(String id_card) async {
    final ref = await FirebaseFirestore.instance
        .collection('user')
        .where('id_card', isEqualTo: id_card)
        .get();

    print(ref.size);

    if (ref.size != 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future<String> checkUserStay(String user_id) async {
    String stay = "";
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        stay = result.data()['stay'];
      });
    });

    return stay;
  }

  static Future<String> getArrayId(String collection) async {
    final snapshotBucket =
        await FirebaseFirestore.instance.collection(collection).get();

    return (snapshotBucket.docs.length + 1).toString();
  }

  static Future<UserModel> getUserFromUserId(String user_id) async {
    UserModel? user;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        user = UserModel.fromJson(result.data());
      });
    });
    return user!;
  }

  static Future<String> getPatientNameFromPatientId(String patient_id) async {
    String? user;
    await FirebaseFirestore.instance
        .collection('patient')
        .where('patient_id', isEqualTo: patient_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        final firstname = result.data()['firstname'];
        final lastname = result.data()['lastname'];
        user = firstname + " " + lastname;
      });
    });
    return user!;
  }

  static Future<Patient> getPatientFromId(String patient_id) async {
    Patient? data;
    await FirebaseFirestore.instance
        .collection('patient')
        .where('patient_id', isEqualTo: patient_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        data = Patient.fromJson(result.data());
      });
    });
    return data!;
  }

  static Future<List<String>> getCategoryName() async {
    List<String> data = [];
    await FirebaseFirestore.instance
        .collection('category')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        final name = result.data()['name'];
        data.add(name);
      });
    });
    return data;
  }

  static Future<String> getCategoryNameFromId(String category_id) async {
    String data = "";
    await FirebaseFirestore.instance
        .collection('category')
        .where('category_id', isEqualTo: category_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        data = result.data()['name'];
      });
    });
    return data;
  }

  static Future<Item> getItemFromItemId(String item_id) async {
    Item? item;
    await FirebaseFirestore.instance
        .collection('item')
        .where('item_id', isEqualTo: item_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        item = Item.fromJson(result.data());
      });
    });
    return item!;
  }

  static Future<int> checkStatusUser(String user_id) async {
    var count = 0;
    await FirebaseFirestore.instance
        .collection('order')
        .where('user_id', isEqualTo: user_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        final status = result.data()['status'];

        if (status == "รอดำเนินการยืม" ||
            status == "นัดรับอุปกรณ์" ||
            status == "กำลังยืมอุปกรณ์" ||
            status == "นัดคืนอุปกรณ์") {
          count++;
        }
      });
    });
    return count;
  }

  static Future<int> checkStatusPatient(String patient_id) async {
    var count = 0;
    await FirebaseFirestore.instance
        .collection('order')
        .where('patient_id', isEqualTo: patient_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        final status = result.data()['status'];

        if (status == "รอดำเนินการยืม" ||
            status == "นัดรับอุปกรณ์" ||
            status == "กำลังยืมอุปกรณ์" ||
            status == "นัดคืนอุปกรณ์") {
          count++;
        }
      });
    });
    return count;
  }

  static Future<bool> checkUserExists(String user_id) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('user').doc(user_id).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  static Future<int> checkOrderEmptryUser(String user_id) async {
    final ref = await FirebaseFirestore.instance
        .collection('order')
        .where('user_id', isEqualTo: user_id)
        .get();

    return ref.size;
  }

  static Future<int> checkOrderEmptryPatient(String patient_id) async {
    final ref = await FirebaseFirestore.instance
        .collection('order')
        .where('patient_id', isEqualTo: patient_id)
        .get();

    return ref.size;
  }

  static Future<void> checkNormalUser(String user_id) async {
    var data = "";
    final ref = await FirebaseFirestore.instance
        .collection('order')
        .where('user_id', isEqualTo: user_id)
        .where('status', isEqualTo: "คืนอุปกรณ์")
        .get();

    if (ref.size != 0) {
      data = "borrow";
    } else {
      data = "normal";
    }

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user_id)
        .update({'status': data});
  }

  static Future<void> checkNormalPatient(String patient_id) async {
    var data = "";
    final ref = await FirebaseFirestore.instance
        .collection('patient')
        .where('patient_id', isEqualTo: patient_id)
        .where('status', isEqualTo: "คืนอุปกรณ์")
        .get();

    if (ref.size != 0) {
      data = "borrow";
    } else {
      data = "normal";
    }

    await FirebaseFirestore.instance
        .collection('patient')
        .doc(patient_id)
        .update({'status': data});
  }

  static Future<void> deleteBucketFromItemId(String item_id) async {
    await FirebaseFirestore.instance
        .collection('bucket')
        .where('item_id', isEqualTo: item_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        final bucket_id = result.data()['bucket_id'];

        await FirebaseFirestore.instance
            .collection('bucket')
            .doc(bucket_id)
            .delete();
      });
    });
  }

  static Future<String> getTokenFromUserId(String user_id) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        data = result.data()['token'];
      });
    });
    return data!;
  }
}
