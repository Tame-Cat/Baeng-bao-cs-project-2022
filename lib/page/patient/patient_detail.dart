// ignore_for_file: unnecessary_statements

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/model/patient.dart';
import 'package:baeng_bao/page/patient/patient_edit.dart';
import 'package:baeng_bao/page/staff/staff_edit.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/providers/chat_provider.dart';
import 'package:baeng_bao/page/full_image.dart';
import 'package:baeng_bao/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDetail extends StatefulWidget {
  Patient patient;
  UserModel my_account;
  PatientDetail({Key? key, required this.patient, required this.my_account})
      : super(key: key);
  @override
  _PatientDetail createState() => _PatientDetail();
}

class _PatientDetail extends State<PatientDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primary,
        title: const Text("ข้อมูลผู้ป่วย"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FullImage(
                          photo: widget.patient.photo,
                        )),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.patient.photo,
                imageBuilder: (context, imageProvider) => Image.network(
                  widget.patient.photo,
                  fit: BoxFit.cover,
                  height: 200,
                ),
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                    "assets/no_image.jpg",
                    fit: BoxFit.fitWidth,
                    width: double.infinity),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.patient.firstname} ${widget.patient.lastname}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  Text('สถานะ',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Text(
                      widget.patient.status == "normal" ? "ปกติ" : "ยืมอุปกรณ์",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    child: Text('เลขบัตรประชาชน',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                children: [
                  Text(widget.patient.id_card,
                      style: TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    width: 80,
                    child: Text('วันเดือนปีเกิด',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                children: [
                  Text(Utils.displayDay(widget.patient.birthday.toDate()),
                      style: TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    width: 80,
                    child: Text('ที่อยู่',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                children: [
                  Text(widget.patient.address,
                      style: TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    width: 80,
                    child: Text('อาการ',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                children: [
                  Text(widget.patient.symptom,
                      style: TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    child: Text('รูปถ่ายบัตรประชาชน',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FullImage(
                          photo: widget.patient.photo_id_card,
                        )),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.patient.photo_id_card,
                imageBuilder: (context, imageProvider) => Image.network(
                  widget.patient.photo_id_card,
                  fit: BoxFit.cover,
                  height: 150,
                ),
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                    "assets/no_image.jpg",
                    fit: BoxFit.fitWidth,
                    width: double.infinity),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    child: Text('รูปถ่ายสำเนาทะเบียนบ้าน',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FullImage(
                          photo: widget.patient.photo_house,
                        )),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.patient.photo_house,
                imageBuilder: (context, imageProvider) => Image.network(
                  widget.patient.photo_house,
                  fit: BoxFit.cover,
                  height: 150,
                ),
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                    "assets/no_image.jpg",
                    fit: BoxFit.fitWidth,
                    width: double.infinity),
              ),
            ),
            //const Divider(color: Colors.black),
            widget.my_account.type == "ผู้ใช้งาน"
                ? Column(
                    children: [
                      Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ButtonWidget(
                              title: "แก้ไข",
                              color: MyConstant.buttonColor,
                              textColor: Colors.black,
                              onPressed: () async {
                                final status =
                                    await CloudFirestoreApi.checkStatusPatient(
                                        widget.patient.patient_id);
                                if (status != "normal") {
                                  Utils.showToast(
                                      context,
                                      'ไม่สามารถแก้ไขได้ เนื่องจากอยู่ในสถานะการยืม',
                                      Colors.red);
                                  return;
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PatientEdit(
                                            patient: widget.patient,
                                            my_account: widget.my_account)),
                                  );
                                }
                              })),
                      Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ButtonWidget(
                              title: "ลบ",
                              color: Colors.red,
                              textColor: Colors.white,
                              onPressed: () async {
                                final data = await CloudFirestoreApi
                                    .checkOrderEmptryPatient(
                                        widget.patient.user_id);
                                if (data != 0) {
                                  Utils.showToast(
                                      context,
                                      'ไม่สามารถลบได้ เนื่องจากมีการยืมแล้ว',
                                      Colors.red);
                                  return;
                                } else {
                                  deleteMethod(context, widget.patient,
                                      widget.my_account);
                                }
                              }))
                    ],
                  )
                : const SizedBox.shrink(),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  void deleteMethod(
      BuildContext context, Patient patient, UserModel my_account) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการลบผู้ป่วยรายนี้ ใช่หรือไม่?"),
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
                    .doc(patient.user_id)
                    .delete();

                Utils.showToast(context, "ลบผู้ป่วยสำเร็จ", Colors.red);

                //Get.replace(StockAdminPage(my_account: my_account));
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}
