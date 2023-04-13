import 'dart:io';

import 'package:baeng_bao/api/firestorage_api.dart';
import 'package:baeng_bao/model/patient.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utility/my_dialog.dart';
import 'package:baeng_bao/utils.dart';
import 'package:baeng_bao/widgets/Show_progress.dart';
import 'package:baeng_bao/widgets/Show_title.dart';

class PatientEdit extends StatefulWidget {
  Patient patient;
  UserModel my_account;
  PatientEdit({Key? key, required this.patient, required this.my_account})
      : super(key: key);

  @override
  State<PatientEdit> createState() => _PatientEdit();
}

class _PatientEdit extends State<PatientEdit> {
  final addressController = TextEditingController();
  final birthdayController = TextEditingController();
  final idcardController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final symptomController = TextEditingController();

  final picker = ImagePicker();
  String imagePath1 = '', imagePath2 = '', imagePath3 = '';
  File? croppedFile1, croppedFile2, croppedFile3;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    addressController.addListener(() => setState(() {}));
    birthdayController.addListener(() => setState(() {}));
    idcardController.addListener(() => setState(() {}));
    firstnameController.addListener(() => setState(() {}));
    lastnameController.addListener(() => setState(() {}));
    symptomController.addListener(() => setState(() {}));

    addressController.text = widget.patient.address;
    // birthdayController.text =
    //     Utils.displayDay(widget.patient.birthday.toDate());
    idcardController.text = widget.patient.id_card;
    firstnameController.text = widget.patient.firstname;
    lastnameController.text = widget.patient.lastname;
    symptomController.text = widget.patient.symptom;

    imagePath1 = widget.patient.photo;
    imagePath2 = widget.patient.photo_id_card;
    imagePath3 = widget.patient.photo_house;
  }

  @override
  void dispose() {
    addressController.dispose();
    birthdayController.dispose();
    idcardController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    symptomController.dispose();
    super.dispose();
  }

  Future _selectDate() async {
    selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(DateTime.now().year - 80),
        lastDate: DateTime(DateTime.now().year + 1));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        birthdayController.text =
            '${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${selectedDate.year + 543}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text('หน้าแก้ไขข้อมูลผู้ป่วย'),
          backgroundColor: MyConstant.primary,
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 2),
                buildImage(),
                const SizedBox(height: 8),
                buildFirstName(),
                const SizedBox(height: 8),
                buildLastName(),
                const SizedBox(height: 8),
                buildIdCard(),
                const SizedBox(height: 8),
                buildAddress(),
                const SizedBox(height: 8),
                buildSymptom(),
                const SizedBox(height: 8),
                buildBirth(),
                const SizedBox(height: 8),
                buildPhotoIdCard(),
                const SizedBox(height: 8),
                buildPhotoHouse(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: size * 0.9,
                      child: ButtonWidget(
                        title: "บันทึกข้อมูล",
                        color: MyConstant.buttonColor,
                        textColor: Colors.black,
                        onPressed: () => register(),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget buildImage() => Stack(
        children: [
          imagePath1 != ''
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: croppedFile1 == null
                      ? Image.network(
                          imagePath1,
                          height: 100,
                        )
                      : Image.file(
                          File(imagePath1),
                          height: 100,
                        ),
                )
              : GestureDetector(
                  onTap: () async {
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      croppedFile1 = (await ImageCropper().cropImage(
                        sourcePath: pickedFile.path,
                        aspectRatioPresets: [
                          CropAspectRatioPreset.square,
                          CropAspectRatioPreset.ratio3x2,
                          CropAspectRatioPreset.original,
                          CropAspectRatioPreset.ratio4x3,
                          CropAspectRatioPreset.ratio16x9
                        ],
                        androidUiSettings: AndroidUiSettings(
                          toolbarTitle: 'การตัดรูป',
                          toolbarColor: MyConstant.primary,
                          toolbarWidgetColor: Colors.white,
                          activeControlsWidgetColor: MyConstant.primary,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false,
                        ),
                      ));
                      if (croppedFile1 != null) {
                        setState(() {
                          imagePath1 = croppedFile1!.path;
                        });
                      }
                    }
                  },
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_open,
                            size: 40,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'เลือกรูปภาพ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          imagePath1 != ""
              ? Positioned(
                  top: 4.0,
                  right: 8.0,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      imagePath1 = '';
                    }),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ))
              : Container(),
        ],
      );

  Widget buildPhotoIdCard() => Stack(
        children: [
          imagePath2 != ''
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: croppedFile2 == null
                      ? Image.network(
                          imagePath2,
                          height: 100,
                        )
                      : Image.file(
                          File(imagePath2),
                          height: 100,
                        ),
                )
              : GestureDetector(
                  onTap: () async {
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      croppedFile2 = (await ImageCropper().cropImage(
                        sourcePath: pickedFile.path,
                        aspectRatioPresets: [
                          CropAspectRatioPreset.square,
                          CropAspectRatioPreset.ratio3x2,
                          CropAspectRatioPreset.original,
                          CropAspectRatioPreset.ratio4x3,
                          CropAspectRatioPreset.ratio16x9
                        ],
                        androidUiSettings: AndroidUiSettings(
                          toolbarTitle: 'การตัดรูป',
                          toolbarColor: MyConstant.primary,
                          toolbarWidgetColor: Colors.white,
                          activeControlsWidgetColor: MyConstant.primary,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false,
                        ),
                      ));
                      if (croppedFile2 != null) {
                        setState(() {
                          imagePath2 = croppedFile2!.path;
                        });
                      }
                    }
                  },
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_open,
                            size: 40,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'เลือกรูปภาพ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          imagePath2 != ""
              ? Positioned(
                  top: 4.0,
                  right: 8.0,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      imagePath2 = '';
                    }),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ))
              : Container(),
        ],
      );

  Widget buildPhotoHouse() => Stack(
        children: [
          imagePath3 != ''
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: croppedFile3 == null
                      ? Image.network(
                          imagePath3,
                          height: 100,
                        )
                      : Image.file(
                          File(imagePath3),
                          height: 100,
                        ),
                )
              : GestureDetector(
                  onTap: () async {
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      croppedFile3 = (await ImageCropper().cropImage(
                        sourcePath: pickedFile.path,
                        aspectRatioPresets: [
                          CropAspectRatioPreset.square,
                          CropAspectRatioPreset.ratio3x2,
                          CropAspectRatioPreset.original,
                          CropAspectRatioPreset.ratio4x3,
                          CropAspectRatioPreset.ratio16x9
                        ],
                        androidUiSettings: AndroidUiSettings(
                          toolbarTitle: 'การตัดรูป',
                          toolbarColor: MyConstant.primary,
                          toolbarWidgetColor: Colors.white,
                          activeControlsWidgetColor: MyConstant.primary,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false,
                        ),
                      ));
                      if (croppedFile3 != null) {
                        setState(() {
                          imagePath3 = croppedFile3!.path;
                        });
                      }
                    }
                  },
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_open,
                            size: 40,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'เลือกรูปภาพ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          imagePath3 != ""
              ? Positioned(
                  top: 4.0,
                  right: 8.0,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      imagePath3 = '';
                    }),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ))
              : Container(),
        ],
      );

  Widget buildIdCard() {
    return TextFormField(
      controller: idcardController,
      readOnly: true,
      decoration: InputDecoration(
        labelStyle: MyConstant().h3Style(),
        labelText: 'เลขประจำตัวบัตรประชาชน',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyConstant.dark),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyConstant.light),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildFirstName() {
    return TextFormField(
      controller: firstnameController,
      decoration: InputDecoration(
        labelStyle: MyConstant().h3Style(),
        labelText: 'ชื่อ (ไม่ต้องระบุคำนำหน้าชื่อ)',
        suffixIcon: firstnameController.text.isEmpty
            ? Container(width: 0)
            : IconButton(
                icon: const Icon(Icons.close),
                color: Colors.grey,
                onPressed: () => firstnameController.clear(),
              ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyConstant.dark),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyConstant.light),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildLastName() {
    return TextFormField(
      controller: lastnameController,
      decoration: InputDecoration(
        labelStyle: MyConstant().h3Style(),
        labelText: 'นามสกุล',
        suffixIcon: lastnameController.text.isEmpty
            ? Container(width: 0)
            : IconButton(
                icon: const Icon(Icons.close),
                color: Colors.grey,
                onPressed: () => lastnameController.clear(),
              ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyConstant.dark),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyConstant.light),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildBirth() => TextFormField(
        maxLines: 1,
        readOnly: true,
        controller: birthdayController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'วันเกิด',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );

  Widget buildAddress() => TextFormField(
        maxLines: 3,
        controller: addressController,
        decoration: InputDecoration(
          hintText: 'ที่อยู่',
          hintStyle: MyConstant().h3Style(),
          suffixIcon: addressController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                  onPressed: () => addressController.clear(),
                ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );

  Widget buildSymptom() => TextFormField(
        maxLines: 2,
        controller: symptomController,
        decoration: InputDecoration(
          hintText: 'อาการของผู้ป่วย',
          hintStyle: MyConstant().h3Style(),
          suffixIcon: symptomController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                  onPressed: () => symptomController.clear(),
                ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );

  Future register() async {
    FocusScope.of(context).unfocus();
    final firstName = firstnameController.text.trim();
    final lastName = lastnameController.text.trim();
    final idCard = idcardController.text.trim();
    final address = addressController.text.trim();
    final symptom = symptomController.text.trim();
    final birthday = birthdayController.text.trim();

    if (address.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ที่อยู่ก่อน', Colors.red);
      return;
    }

    if (idCard.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่เลขบัตรประชาชนก่อน', Colors.red);
      return;
    }

    if (idCard.length != 13) {
      Utils.showToast(context, 'เลขบัตรประชาชนต้องมี 13 หลัก', Colors.red);
      return;
    }

    if (firstName.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ชื่อก่อน', Colors.red);
      return;
    }

    if (lastName.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่นามสกุลก่อน', Colors.red);
      return;
    }

    if (symptom.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่อาการก่อน', Colors.red);
      return;
    }

    if (birthday.isEmpty) {
      Utils.showToast(context, 'กรุณาเลือกวันเกิดก่อน', Colors.red);
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final data1, data2, data3;
    if (imagePath1 == widget.patient.photo) {
      data1 = "1";
    } else {
      data1 = "2";
    }

    if (imagePath2 == widget.patient.photo_id_card) {
      data2 = "1";
    } else {
      data2 = "2";
    }

    if (imagePath3 == widget.patient.photo_house) {
      data3 = "1";
    } else {
      data3 = "2";
    }

    if (data1 == "1" && data2 == "1" && data3 == "1") {
      await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patient.patient_id)
          .update({
        'address': address,
        'birthday': selectedDate,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'symptom': symptom,
        'user_id': widget.my_account.user_id,
      });
    } else if (data1 == "1" && data2 == "2" && data3 == "1") {
      await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patient.patient_id)
          .update({
        'address': address,
        'birthday': selectedDate,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'photo_id_card':
            await FirestorageApi.uploadPhoto(croppedFile2!, "Id_Card"),
        'symptom': symptom,
        'user_id': widget.my_account.user_id,
      });
    } else if (data1 == "1" && data2 == "2" && data3 == "2") {
      await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patient.patient_id)
          .update({
        'address': address,
        'birthday': selectedDate,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'photo_house':
            await FirestorageApi.uploadPhoto(croppedFile3!, "Photo_house"),
        'photo_id_card':
            await FirestorageApi.uploadPhoto(croppedFile2!, "Id_Card"),
        'symptom': symptom,
        'user_id': widget.my_account.user_id,
      });
    } else if (data1 == "1" && data2 == "1" && data3 == "2") {
      await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patient.patient_id)
          .update({
        'address': address,
        'birthday': selectedDate,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'photo_house':
            await FirestorageApi.uploadPhoto(croppedFile3!, "Photo_house"),
        'symptom': symptom,
        'user_id': widget.my_account.user_id,
      });
    } else if (data1 == "2" && data2 == "1" && data3 == "1") {
      await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patient.patient_id)
          .update({
        'address': address,
        'birthday': selectedDate,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'photo': await FirestorageApi.uploadPhoto(croppedFile1!, "Patient"),
        'symptom': symptom,
        'user_id': widget.my_account.user_id,
      });
    } else if (data1 == "2" && data2 == "2" && data3 == "1") {
      await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patient.patient_id)
          .update({
        'address': address,
        'birthday': selectedDate,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'photo': await FirestorageApi.uploadPhoto(croppedFile1!, "Patient"),
        'photo_id_card':
            await FirestorageApi.uploadPhoto(croppedFile2!, "Id_Card"),
        'symptom': symptom,
        'user_id': widget.my_account.user_id,
      });
    } else if (data1 == "2" && data2 == "2" && data3 == "2") {
      await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patient.patient_id)
          .update({
        'address': address,
        'birthday': selectedDate,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'photo': await FirestorageApi.uploadPhoto(croppedFile1!, "Patient"),
        'photo_house':
            await FirestorageApi.uploadPhoto(croppedFile3!, "Photo_house"),
        'photo_id_card':
            await FirestorageApi.uploadPhoto(croppedFile2!, "Id_Card"),
        'symptom': symptom,
        'user_id': widget.my_account.user_id,
      });
    } else if (data1 == "2" && data2 == "1" && data3 == "2") {
      await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patient.patient_id)
          .update({
        'address': address,
        'birthday': selectedDate,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'photo': await FirestorageApi.uploadPhoto(croppedFile1!, "Patient"),
        'photo_house':
            await FirestorageApi.uploadPhoto(croppedFile3!, "Photo_house"),
        'symptom': symptom,
        'user_id': widget.my_account.user_id,
      });
    }

    pd.dismiss();
    Utils.showToast(context, "แก้ไขผู้ป่วยสำเร็จ", Colors.green);
    Navigator.pop(context, false);
  }
}
