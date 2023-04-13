// import 'dart:io';

// import 'package:baeng_bao/model/patient.dart';
// import 'package:baeng_bao/page/patient/patient_detail.dart';
// import 'package:baeng_bao/page/patient/patient_edit.dart';
// import 'package:baeng_bao/page/staff/staff_detail.dart';
// import 'package:baeng_bao/page/staff/staff_edit.dart';
// import 'package:baeng_bao/utility/my_constant.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:baeng_bao/model/user_model.dart';
// import 'package:baeng_bao/login.dart';
// import 'package:baeng_bao/page/item/item_detail.dart';
// import 'package:baeng_bao/page/item/item_edit.dart';
// import 'package:baeng_bao/utils.dart';

// class PatientList extends StatefulWidget {
//   UserModel my_account;
//   PatientList({Key? key, required this.my_account}) : super(key: key);
//   @override
//   _PatientList createState() => _PatientList();
// }

// class _PatientList extends State<PatientList> {
//   String productType = "1";
//   String? keyword = '';

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//           child: Column(
//         children: [
//           const SizedBox(height: 5),
//           Card(
//             child: Row(
//               children: [
//                 Flexible(
//                   child: TextField(
//                     decoration: const InputDecoration(
//                         prefixIcon: Icon(Icons.search),
//                         hintText: 'กรุณาใส่คำค้นหา...'),
//                     onChanged: (val) {
//                       setState(() {
//                         keyword = val;
//                         print(keyword);
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           StreamBuilder<List<Patient>>(
//             stream: keyword == ''
//                 ? FirebaseFirestore.instance
//                     .collection("patient")
//                     .where("user_id", isEqualTo: widget.my_account.user_id)
//                     .orderBy("dateTime", descending: false)
//                     .snapshots()
//                     .map((snapshot) => snapshot.docs
//                         .map((doc) => Patient.fromJson(doc.data()))
//                         .toList())
//                 : FirebaseFirestore.instance
//                     .collection("patient")
//                     .where("user_id", isEqualTo: widget.my_account.user_id)
//                     .orderBy('firstname')
//                     .startAt([keyword])
//                     .endAt(['${keyword!}\uf8ff'])
//                     .snapshots()
//                     .map((snapshot) => snapshot.docs
//                         .map((doc) => Patient.fromJson(doc.data()))
//                         .toList()),
//             builder: (context, snapshot) {
//               switch (snapshot.connectionState) {
//                 case ConnectionState.waiting:
//                   return const Center(child: CircularProgressIndicator());
//                 default:
//                   if (snapshot.hasError) {
//                     return const Center(
//                         child: Text(
//                       'เกิดข้อผิดพลาด',
//                       style: TextStyle(fontSize: 24),
//                     ));
//                   } else {
//                     final patients = snapshot.data;

//                     return patients!.isEmpty
//                         ? const Center(
//                             child: Text(
//                               'ไม่มีข้อมูล',
//                               style: TextStyle(fontSize: 24),
//                             ),
//                           )
//                         : ListView.builder(
//                             physics: const NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             itemCount: patients.length,
//                             itemBuilder: (context, index) {
//                               final patient = patients[index];

//                               return patientList(
//                                   context, patient, widget.my_account);
//                             },
//                           );
//                   }
//               }
//             },
//           )
//         ],
//       )),
//     );
//   }
// }

// Widget patientList(
//         BuildContext context, Patient patient, UserModel my_account) =>
//     Slidable(
//         endActionPane: ActionPane(motion: const ScrollMotion(), children: [
//           SlidableAction(
//             onPressed: (c) => Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       PatientEdit(patient: patient, my_account: my_account)),
//             ),
//             backgroundColor: MyConstant.primary,
//             foregroundColor: Colors.white,
//             icon: Icons.delete,
//             label: 'แก้ไข',
//             spacing: 8,
//           ),
//           SlidableAction(
//             onPressed: (c) {
//               deleteMethod(context, patient, my_account);
//             },
//             backgroundColor: Colors.red,
//             foregroundColor: Colors.white,
//             icon: Icons.delete,
//             label: 'ลบ',
//             spacing: 8,
//           )
//         ]),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: GestureDetector(
//               onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => PatientDetail(
//                               patient: patient,
//                               my_account: my_account,
//                             )),
//                   ),
//               child: Card(
//                 child: Container(
//                   padding: EdgeInsets.all(10),
//                   margin: EdgeInsets.all(3),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Row(
//                         children: [
//                           CachedNetworkImage(
//                             height: 80,
//                             width: 80,
//                             imageUrl: patient.photo,
//                             imageBuilder: (context, imageProvider) =>
//                                 Image.network(
//                               patient.photo,
//                               loadingBuilder: (BuildContext context,
//                                   Widget child,
//                                   ImageChunkEvent? loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Center(
//                                   child: CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes !=
//                                             null
//                                         ? loadingProgress
//                                                 .cumulativeBytesLoaded /
//                                             loadingProgress.expectedTotalBytes!
//                                         : null,
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (context, object, stackTrace) {
//                                 return const Icon(
//                                   Icons.account_circle,
//                                   color: Colors.blue,
//                                 );
//                               },
//                               height: 80,
//                               width: 80,
//                               fit: BoxFit.cover,
//                             ),
//                             placeholder: (context, url) => const Center(
//                                 child: CircularProgressIndicator()),
//                             errorWidget: (context, url, error) => Image.asset(
//                                 "assets/no_image.jpg",
//                                 fit: BoxFit.fitWidth,
//                                 width: double.infinity),
//                           ),
//                           SizedBox(width: 20),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "${patient.firstname} ${patient.lastname}",
//                                 style: TextStyle(
//                                     fontSize: 15, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 "อายุ",
//                                 maxLines: 2,
//                                 style: TextStyle(fontSize: 13),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               )),
//         ));

// void deleteMethod(
//     BuildContext context, Patient patient, UserModel my_account) async {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('⭐ แจ้งเตือน'),
//         content: const Text("คุณต้องการลบผู้ป่วยนี้ ใช่หรือไม่?"),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('ไม่ใช่'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context, false);
//               await FirebaseFirestore.instance
//                   .collection('patient')
//                   .doc(patient.user_id)
//                   .delete();

//               Utils.showToast(context, "ลบผู้ป่วยสำเร็จ", Colors.red);

//               //Get.replace(StockAdminPage(my_account: my_account));
//             },
//             child: new Text('ใช่'),
//           ),
//         ],
//       );
//     },
//   );
// }

// addEditStaff(
//     BuildContext context, UserModel staff, UserModel my_account) async {
//   return await showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           title: const Text(
//             '⭐ กรุณาเลือกรายการ',
//             style: TextStyle(fontSize: 18),
//           ),
//           children: <Widget>[
//             SimpleDialogOption(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           StaffEdit(staff: staff, my_account: my_account)),
//                 );
//               },
//               child: const Text(
//                 'แก้ไขข้อมูล',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//             SimpleDialogOption(
//               onPressed: () async {
//                 Navigator.pop(context, false);

//                 await FirebaseFirestore.instance
//                     .collection('user')
//                     .doc(staff.user_id)
//                     .delete();

//                 Utils.showToast(context, "ลบข้อมูลสำเร็จ", Colors.red);
//               },
//               child: const Text(
//                 'ลบข้อมูล',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         );
//       });
// }

// goBack(BuildContext context) {
//   Navigator.pushAndRemoveUntil(
//     context,
//     MaterialPageRoute(builder: (context) => const Login()),
//     (Route<dynamic> route) => false,
//   );
// }
