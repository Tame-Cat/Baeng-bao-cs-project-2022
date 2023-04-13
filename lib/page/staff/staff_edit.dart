import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utility/my_dialog.dart';
import 'package:baeng_bao/utils.dart';
import 'package:baeng_bao/widgets/Show_progress.dart';
import 'package:baeng_bao/widgets/Show_title.dart';

class StaffEdit extends StatefulWidget {
  UserModel staff, my_account;
  StaffEdit({Key? key, required this.staff, required this.my_account})
      : super(key: key);

  @override
  State<StaffEdit> createState() => _StaffEdit();
}

class _StaffEdit extends State<StaffEdit> {
  final addressController = TextEditingController();
  final birthdayController = TextEditingController();
  final emailController = TextEditingController();
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
    firstnameController.addListener(() => setState(() {}));
    lastnameController.addListener(() => setState(() {}));
    idcardController.addListener(() => setState(() {}));
    telController.addListener(() => setState(() {}));
    birthdayController.text = Utils.getDateThai().toString();

    addressController.text = widget.staff.address;
    birthdayController.text = widget.staff.birthday;
    emailController.text = widget.staff.email;
    firstnameController.text = widget.staff.firstname;
    lastnameController.text = widget.staff.lastname;
    idcardController.text = widget.staff.id_card;
    telController.text = widget.staff.tel;
  }

  @override
  void dispose() {
    addressController.dispose();
    birthdayController.dispose();
    emailController.dispose();
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
        birthdayController.text = selectedDate.day.toString() +
            ' ' +
            Utils.getMonthThaiFromNumber(selectedDate.month) +
            ' ' +
            (selectedDate.year + 543).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าแก้ไขข้อมูลเจ้าหน้าที่'),
        backgroundColor: MyConstant.primary,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5),
              buildIdCard(size),
              buildEmail(size),
              buildFirstName(size),
              buildLastName(size),
              buildTel(size),
              buildBirth(size),
              buildAddress(size),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
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
            maxLines: 1,
            readOnly: true,
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: InputDecoration(
              labelStyle: MyConstant().h3Style(),
              labelText: 'อีเมล',
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
            maxLines: 1,
            readOnly: true,
            controller: idcardController,
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
            maxLines: 1,
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
            maxLines: 1,
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

    if (tel.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่เบอร์โทรก่อน', Colors.red);
      return;
    }

    if (tel.length < 8) {
      Utils.showToast(context, 'เบอร์โทรต้องมีอย่างน้อย 9 ตัว', Colors.red);
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.staff.user_id)
        .update({
      'address': address,
      'birthday': birthdayController.text,
      'tel': tel,
      'firstname': firstName,
      'lastname': lastName,
      'stay': '',
      'token': '',
    });

    pd.dismiss();
    Utils.showToast(context, "แก้ไขเจ้าหน้าที่สำเร็จ", Colors.green);
    Navigator.pop(context, false);
  }
}
