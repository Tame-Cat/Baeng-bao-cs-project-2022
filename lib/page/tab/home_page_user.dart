import 'dart:io';

import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/category.dart';
import 'package:baeng_bao/model/patient.dart';
import 'package:baeng_bao/page/patient/patient_detail.dart';
import 'package:baeng_bao/page/patient/patient_edit.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePageUser extends StatefulWidget {
  UserModel my_account;
  HomePageUser({Key? key, required this.my_account}) : super(key: key);
  @override
  _HomePageUser createState() => _HomePageUser();
}

class _HomePageUser extends State<HomePageUser> {
  String? keyword = '';
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        const SizedBox(height: 5),
        Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: const Text(
                'รายชื่อผู้ป่วย',
                style: TextStyle(fontSize: 20),
              ),
            )),
        Card(
          child: Row(
            children: [
              Flexible(
                child: TextField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'กรุณาใส่คำค้นหา...'),
                  onChanged: (val) {
                    setState(() {
                      keyword = val;
                      print(keyword);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        StreamBuilder<List<Patient>>(
          stream: keyword == ""
              ? FirebaseFirestore.instance
                  .collection("patient")
                  .where("user_id", isEqualTo: widget.my_account.user_id)
                  .orderBy("dateTime", descending: false)
                  .snapshots()
                  .map((snapshot) => snapshot.docs
                      .map((doc) => Patient.fromJson(doc.data()))
                      .toList())
              : FirebaseFirestore.instance
                  .collection("patient")
                  .where("user_id", isEqualTo: widget.my_account.user_id)
                  .orderBy('firstname')
                  .startAt([keyword])
                  .endAt(['${keyword!}\uf8ff'])
                  .snapshots()
                  .map((snapshot) => snapshot.docs
                      .map((doc) => Patient.fromJson(doc.data()))
                      .toList()),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                    'เกิดข้อผิดพลาด',
                    style: TextStyle(fontSize: 24),
                  ));
                } else {
                  final patients = snapshot.data;

                  return patients!.isEmpty
                      ? const Center(
                          child: Text(
                            'ไม่มีข้อมูล',
                            style: TextStyle(fontSize: 24),
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: patients.length,
                          itemBuilder: (context, index) {
                            final patient = patients[index];

                            return patinetList(
                                context, patient, widget.my_account);
                          },
                        );
                }
            }
          },
        ),
      ],
    ));
  }
}

Widget patinetList(
        BuildContext context, Patient patient, UserModel my_account) =>
    Slidable(
        endActionPane: ActionPane(motion: const ScrollMotion(), children: [
          SlidableAction(
            onPressed: (c) async {
              final count = await CloudFirestoreApi.checkStatusPatient(
                  patient.patient_id);
              if (count != 0) {
                Utils.showToast(context,
                    'ไม่สามารถแก้ไขได้ เนื่องจากอยู่ในสถานะการยืม', Colors.red);
                return;
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PatientEdit(
                          patient: patient, my_account: my_account)),
                );
              }
            },
            backgroundColor: MyConstant.primary,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'แก้ไข',
            spacing: 8,
          ),
          SlidableAction(
            onPressed: (c) async {
              final data = await CloudFirestoreApi.checkOrderEmptryPatient(
                  patient.user_id);
              if (data != 0) {
                Utils.showToast(context, 'ไม่สามารถลบได้ เนื่องจากมีการยืมแล้ว',
                    Colors.red);
                return;
              } else {
                deleteMethod(context, patient, my_account);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'ลบ',
            spacing: 8,
          )
        ]),
        child: Container(
          margin: EdgeInsets.only(left: 3, right: 3),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PatientDetail(
                            patient: patient,
                            my_account: my_account,
                          )),
                ),
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        imageUrl: patient.photo,
                        imageBuilder: (context, imageProvider) => Image.network(
                          patient.photo,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              color: Colors.blue,
                            );
                          },
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Image.asset(
                            "assets/no_image.jpg",
                            fit: BoxFit.fitWidth,
                            width: double.infinity),
                      ),
                      Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${patient.firstname} ${patient.lastname}",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "อาการ : ${patient.symptom}",
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                "อายุ : ${Utils.displayAge(patient.birthday.toDate())}",
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
              )),
        ));

void deleteMethod(
    BuildContext context, Patient patient, UserModel my_account) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('⭐ แจ้งเตือน'),
        content: const Text("คุณต้องการลบผู้ป่วยนี้ ใช่หรือไม่?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ไม่ใช่'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, false);
              await FirebaseFirestore.instance
                  .collection('patient')
                  .doc(patient.patient_id)
                  .delete();

              Utils.showToast(context, "ลบผู้ป่วยสำเร็จ", Colors.red);

              //Get.replace(StockAdminPage(my_account: my_account));
            },
            child: new Text('ใช่'),
          ),
        ],
      );
    },
  );
}

goBack(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Login()),
    (Route<dynamic> route) => false,
  );
}
