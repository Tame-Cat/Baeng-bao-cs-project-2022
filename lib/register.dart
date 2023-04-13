import 'dart:io';

import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/api/firestorage_api.dart';
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final addressController = TextEditingController();
  final birthdayController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final idcardController = TextEditingController();
  final telController = TextEditingController();
  bool isPasswordVisible = true, isPasswordConfirmVisible = true;

  @override
  void initState() {
    super.initState();
    addressController.addListener(() => setState(() {}));
    birthdayController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    passwordConfirmController.addListener(() => setState(() {}));
    firstnameController.addListener(() => setState(() {}));
    lastnameController.addListener(() => setState(() {}));
    idcardController.addListener(() => setState(() {}));
    telController.addListener(() => setState(() {}));
    birthdayController.text = Utils.getDateThai().toString();

    addressController.text = '';
    birthdayController.text = '';
    emailController.text = '';
    passwordController.text = '';
    passwordConfirmController.text = '';
    firstnameController.text = '';
    lastnameController.text = '';
    idcardController.text = '';
    telController.text = '';
  }

  @override
  void dispose() {
    addressController.dispose();
    birthdayController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    idcardController.dispose();
    telController.dispose();
    super.dispose();
  }

  Future _selectDate() async {
    DateTime selectedDate = DateTime.now();
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
        title: const Text('หน้าสมัครสมาชิก'),
        backgroundColor: MyConstant.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5),
            buildIdCard(size),
            buildEmail(size),
            buildPassword(size),
            buildPasswordConfirm(size),
            buildFirstName(size),
            buildLastName(size),
            buildTel(size),
            buildBirth(size),
            buildAddress(size),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: size * 0.9,
                  child: ButtonWidget(
                    title: "ลงทะเบียน",
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
    );
  }

  Row buildEmail(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.9,
          margin: EdgeInsets.only(top: 10),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: InputDecoration(
              labelStyle: MyConstant().h3Style(),
              labelText: 'อีเมล',
              suffixIcon: emailController.text.isEmpty
                  ? Container(width: 0)
                  : IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                      onPressed: () => emailController.clear(),
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
          ),
        ),
      ],
    );
  }

  Row buildPassword(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          width: size * 0.9,
          child: TextFormField(
            keyboardType: TextInputType.visiblePassword,
            controller: passwordController,
            obscureText: isPasswordVisible,
            decoration: InputDecoration(
              labelStyle: MyConstant().h3Style(),
              labelText: 'รหัสผ่าน',
              suffixIcon: IconButton(
                icon: isPasswordVisible
                    ? const Icon(
                        Icons.visibility,
                        color: Colors.grey,
                      )
                    : const Icon(
                        Icons.visibility_off,
                        color: Colors.grey,
                      ),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
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
          ),
        ),
      ],
    );
  }

  Row buildPasswordConfirm(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          width: size * 0.9,
          child: TextFormField(
            keyboardType: TextInputType.visiblePassword,
            controller: passwordConfirmController,
            obscureText: isPasswordConfirmVisible,
            decoration: InputDecoration(
              labelStyle: MyConstant().h3Style(),
              labelText: 'ยืนยันรหัสผ่าน',
              suffixIcon: IconButton(
                icon: isPasswordConfirmVisible
                    ? const Icon(
                        Icons.visibility,
                        color: Colors.grey,
                      )
                    : const Icon(
                        Icons.visibility_off,
                        color: Colors.grey,
                      ),
                onPressed: () => setState(
                    () => isPasswordConfirmVisible = !isPasswordConfirmVisible),
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
          ),
        ),
      ],
    );
  }

  Row buildIdCard(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          width: size * 0.9,
          child: TextFormField(
            controller: idcardController,
            decoration: InputDecoration(
              labelStyle: MyConstant().h3Style(),
              labelText: 'เลขประจำตัวบัตรประชาชน',
              suffixIcon: idcardController.text.isEmpty
                  ? Container(width: 0)
                  : IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.grey,
                      onPressed: () => idcardController.clear(),
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
          ),
        ),
      ],
    );
  }

  Row buildFirstName(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          width: size * 0.9,
          child: TextFormField(
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
          ),
        ),
      ],
    );
  }

  Row buildLastName(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          width: size * 0.9,
          child: TextFormField(
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
          ),
        ),
      ],
    );
  }

  Widget buildTel(double size) => Container(
        margin: const EdgeInsets.only(top: 10),
        width: size * 0.9,
        child: TextFormField(
          maxLines: 1,
          controller: telController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: InputDecoration(
            hintText: 'เบอร์โทรศัพท์',
            hintStyle: MyConstant().h3Style(),
            suffixIcon: telController.text.isEmpty
                ? Container(width: 0)
                : IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                    onPressed: () => telController.clear(),
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
        ),
      );

  Widget buildBirth(double size) => Container(
      margin: const EdgeInsets.only(top: 10),
      width: size * 0.9,
      child: TextFormField(
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
      ));

  Widget buildAddress(double size) => Container(
        margin: const EdgeInsets.only(top: 10),
        width: size * 0.9,
        child: TextFormField(
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
        ),
      );

  Future register() async {
    FocusScope.of(context).unfocus();
    final address = addressController.text.trim();
    final firstName = firstnameController.text.trim();
    final lastName = lastnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();
    final tel = telController.text.trim();
    final idCard = idcardController.text.trim();

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

    if (email.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่อีเมลล์ก่อน', Colors.red);
      return;
    }

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (email.isEmpty) {
      Utils.showToast(context, 'กรุณากรอกอีเมลล์ก่อน', Colors.red);
      return;
    } else if (!emailRegExp.hasMatch(email)) {
      Utils.showToast(context, 'กรุณาตรวจสอบอีเมลล์ก่อน', Colors.red);
      return;
    }

    if (password.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสก่อน', Colors.red);
      return;
    }

    if (password.length < 5) {
      Utils.showToast(context, 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว', Colors.red);
      return;
    }

    if (password != passwordConfirm) {
      Utils.showToast(context, 'กรุณาใส่รหัสยืนยันให้ตรงกัน', Colors.red);
      return;
    }

    if (tel.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่เบอร์โทรก่อน', Colors.red);
      return;
    }

    if (tel.length < 8) {
      Utils.showToast(context, 'เบอร์โทรต้องมีอย่างน้อย 9 ตัว', Colors.red);
      return;
    }

    if (birthdayController.text == "") {
      Utils.showToast(context, 'กรุณาใส่วันเกิดก่อน', Colors.red);
      return;
    }

    if (await CloudFirestoreApi.checkExistEmail(email)) {
      Utils.showToast(context, 'อีเมลล์นี้ซ้ำกรุณาเปลี่ยน', Colors.red);
      return;
    }

    if (await CloudFirestoreApi.checkExistIdCard(idCard)) {
      Utils.showToast(context, 'รหัสประชาชนซ้ำกรุณาเปลี่ยน', Colors.red);
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final docUser = FirebaseFirestore.instance.collection('user').doc();
    await docUser.set({
      'address': address,
      'birthday': birthdayController.text,
      'email': email,
      'dateTime': DateTime.now(),
      'firstname': firstName,
      'id_card': idCard,
      'lastname': lastName,
      'password': password,
      'photo': '',
      'photo_house': '',
      'photo_id_card': '',
      'status': 'normal',
      'tel': tel,
      'token': '',
      'type': 'ผู้ใช้งาน',
      'user_id': docUser.id,
    });

    pd.dismiss();
    Utils.showToast(context, "สมัครสมาชิกสำเร็จ", Colors.green);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Login(),
        ),
        (route) => false);
  }
}
