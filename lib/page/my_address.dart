// import 'dart:async';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:baeng_bao/model/user_model.dart';
// import 'package:baeng_bao/page/main_user.dart';
// import 'package:baeng_bao/utility/my_constant.dart';
// import 'package:baeng_bao/utils.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MyAddress extends StatefulWidget {
//   final UserModel my_account;

//   MyAddress({Key? key, required this.my_account}) : super(key: key);
//   @override
//   _MyAddress createState() => _MyAddress();
// }

// class _MyAddress extends State<MyAddress> {
//   final addressController = TextEditingController();

//   GoogleMapController? mapController;
//   final Set<Marker> markers = {};
//   Marker? _origin;
//   double? latitude, longitude;
//   LatLng? _initialPosition;

//   @override // รัน initState ก่อน
//   void initState() {
//     super.initState();
//     markers.clear();
//     addressController.addListener(() => setState(() {}));
//     addressController.text = widget.my_account.address;

//     latitude = widget.my_account.latitude;
//     longitude = widget.my_account.longitude;

//     setState(() {
//       markers.add(Marker(
//         markerId: const MarkerId('id'),
//         position: LatLng(widget.my_account.latitude,
//             widget.my_account.longitude), //position of marker
//         infoWindow: const InfoWindow(
//           title: 'จุดพิกัด',
//         ),
//         icon: BitmapDescriptor.defaultMarker, //Icon for Marker
//       ));
//     });
//   }

//   @override
//   void dispose() {
//     addressController.dispose();
//     super.dispose();
//   }

//   @override // แสดง UI
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('หน้าจัดการที่อยู่'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             buildGoogleMap(),
//             Container(
//               margin: const EdgeInsets.all(10),
//               child: Column(
//                 children: [
//                   buildAddress(),
//                   buildButton(),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildGoogleMap() => SizedBox(
//       height: 200,
//       child: GoogleMap(
//         zoomGesturesEnabled: true,
//         onTap: (LatLng latLng) {
//           markers.clear();

//           latitude = latLng.latitude;
//           longitude = latLng.longitude;

//           print('${latitude.toString()}  ${longitude.toString()}');
//           setState(() {
//             markers.add(Marker(
//               markerId: const MarkerId('id'),
//               position: LatLng(latitude!, longitude!), //position of marker
//               infoWindow: const InfoWindow(
//                 title: 'จุดพิกัด',
//               ),
//               icon: BitmapDescriptor.defaultMarker, //Icon for Marker
//             ));
//           });
//         },
//         initialCameraPosition: const CameraPosition(
//           target: LatLng(13.7244416, 100.3529099),
//           zoom: 5.0,
//         ),
//         markers: markers,
//         mapType: MapType.normal, //map type
//         onMapCreated: (controller) {
//           setState(() {
//             mapController = controller;
//           });
//         },
//       ));

//   Widget buildAddress() => TextFormField(
//         maxLines: 1,
//         controller: addressController,
//         decoration: InputDecoration(
//           border: const OutlineInputBorder(),
//           labelStyle: MyConstant().h3Style(),
//           labelText: 'ที่อยู่',
//           suffixIcon: addressController.text.isEmpty
//               ? Container(width: 0)
//               : IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => addressController.clear(),
//                 ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: MyConstant.dark),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: MyConstant.light),
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),
//       );

//   Widget buildButton() => SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all(Colors.blue),
//           ),
//           onPressed: () => save_data(),
//           child: const Text('บันทึกสถานที่', style: TextStyle(fontSize: 18)),
//         ),
//       );

//   // ฟังก์ชัน save_data
//   void save_data() async {
//     final address = addressController.text.trim();

//     if (address.isEmpty) {
//       Utils.showToast(context, 'กรุณาใส่ที่อยู่ก่อนก่อน', Colors.red);
//       return;
//     }

//     ProgressDialog pd = ProgressDialog(
//       loadingText: 'กรุณารอสักครู่...',
//       context: context,
//       backgroundColor: Colors.white,
//       textColor: Colors.black,
//     );
//     pd.show();

//     await FirebaseFirestore.instance
//         .collection('user')
//         .doc(widget.my_account.user_id)
//         .update(
//             {'address': address, 'latitude': latitude, 'longitude': longitude});

//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('address', address);

//     final user = UserModel(
//       user_id: widget.my_account.user_id,
//       email: widget.my_account.email,
//       password: widget.my_account.password,
//       photo: widget.my_account.photo,
//       token: widget.my_account.token,
//       address: address,
//       firstname: widget.my_account.firstname,
//       lastname: widget.my_account.lastname,
//       latitude: latitude!,
//       longitude: longitude!,
//       stay: widget.my_account.stay,
//     );

//     pd.dismiss();
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//           builder: (context) => MainUser(from: 'edit_user', my_account: user)),
//       (Route<dynamic> route) => false,
//     );

//     if (pd.isShowing) {
//       Timer(const Duration(seconds: 3), () {
//         pd.dismiss();
//         Utils.showToast(
//             context, 'เกิดข้อผิดพลาด กรุณาลองใหม่', Colors.red); // แสดงข้อความ
//       });
//     }
//   }
// }
