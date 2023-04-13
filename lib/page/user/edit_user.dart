import 'dart:io';

import 'package:baeng_bao/api/firestorage_api.dart';
import 'package:baeng_bao/page/main_admin.dart';
import 'package:baeng_bao/page/main_staff.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/page/main_user.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUserPage extends StatefulWidget {
  final UserModel my_account;
  final String from;

  // รับค่ามาจากหน้าก่อน
  EditUserPage({Key? key, required this.my_account, required this.from})
      : super(key: key);

  @override
  _EditUserPage createState() => _EditUserPage();
}

class _EditUserPage extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late String? user_id,
      email,
      birhtDay,
      firstname,
      lastname,
      password,
      address,
      tel,
      idCard,
      from;
  late UserModel user;
  final emailController = TextEditingController();
  final birthdayController = TextEditingController();
  final firstnameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final lastnameController = TextEditingController();
  final idCardController = TextEditingController();
  final telController = TextEditingController();
  final addressController = TextEditingController();
  bool isPasswordVisible = true, isPasswordConfirmVisible = true;
  DateTime selectedDate = DateTime.now();

  final picker = ImagePicker();
  String imagePath1 = '', imagePath2 = '';
  File? croppedFile1, croppedFile2;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    user_id = widget.my_account.user_id;
    email = widget.my_account.email;
    firstname = widget.my_account.firstname;
    lastname = widget.my_account.lastname;
    password = widget.my_account.password;
    birhtDay = widget.my_account.birthday;
    idCard = widget.my_account.id_card;
    address = widget.my_account.address;
    tel = widget.my_account.tel;
    from = widget.from;
    imagePath1 = widget.my_account.photo_id_card;
    imagePath2 = widget.my_account.photo_house;

    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    passwordConfirmController.addListener(() => setState(() {}));
    firstnameController.addListener(() => setState(() {}));
    lastnameController.addListener(() => setState(() {}));
    idCardController.addListener(() => setState(() {}));
    birthdayController.addListener(() => setState(() {}));
    telController.addListener(() => setState(() {}));
    addressController.addListener(() => setState(() {}));

    setState(() {
      birthdayController.text = birhtDay.toString();
    });

    emailController.text = email!;
    firstnameController.text = firstname!;
    lastnameController.text = lastname!;
    idCardController.text = idCard!;

    telController.text = tel!;
    addressController.text = address!;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    idCardController.dispose();
    birthdayController.dispose();
    telController.dispose();
    addressController.dispose();
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
        birthdayController.text = selectedDate.day.toString() +
            ' ' +
            Utils.getMonthThaiFromNumber(selectedDate.month) +
            ' ' +
            (selectedDate.year + 543).toString();
      });
    }
  }

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: MyConstant.primary,
          title: const Text('แก้ไขโปรไฟล์'),
        ),
        body: SizedBox(
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildIdCard(),
                  const SizedBox(height: 8),
                  buildEmail(),
                  const SizedBox(height: 8),
                  buildPassword(),
                  const SizedBox(height: 8),
                  buildPasswordConfirm(),
                  const SizedBox(height: 8),
                  buildFirstname(),
                  const SizedBox(height: 8),
                  buildLastname(),
                  const SizedBox(height: 8),
                  buildTel(),
                  const SizedBox(height: 8),
                  buildBirth(),
                  const SizedBox(height: 8),
                  buildAddress(),
                  const SizedBox(height: 8),
                  buildPhotoIdCard(),
                  const SizedBox(height: 8),
                  buildPhotoHouse(),
                  const SizedBox(height: 8),
                  buildButton(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildIdCard() => TextFormField(
        maxLines: 1,
        readOnly: true,
        controller: idCardController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelStyle: MyConstant().h3Style(),
          labelText: 'เลขบัตรประชาชน',
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

  Widget buildTel() => TextFormField(
        maxLines: 1,
        controller: telController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelStyle: MyConstant().h3Style(),
          labelText: 'เบอร์โทร',
          suffixIcon: telController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
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
      );

  Widget buildBirth() => TextFormField(
        maxLines: 1,
        readOnly: true,
        controller: birthdayController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelStyle: MyConstant().h3Style(),
          labelText: 'วันเดือนปีเกิด',
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
        maxLines: 1,
        controller: addressController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelStyle: MyConstant().h3Style(),
          labelText: 'ที่อยู่',
          suffixIcon: addressController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
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

  Widget buildEmail() => TextFormField(
        maxLines: 1,
        readOnly: true,
        controller: emailController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
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
      );

  Widget buildFirstname() => TextFormField(
        maxLines: 1,
        controller: firstnameController,
        decoration: InputDecoration(
          suffixIcon: firstnameController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => firstnameController.clear(),
                ),
          border: const OutlineInputBorder(),
          labelStyle: MyConstant().h3Style(),
          labelText: 'กรุณาใส่ชื่อ',
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

  Widget buildLastname() => TextFormField(
        maxLines: 1,
        controller: lastnameController,
        decoration: InputDecoration(
          suffixIcon: lastnameController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => lastnameController.clear(),
                ),
          border: const OutlineInputBorder(),
          labelStyle: MyConstant().h3Style(),
          labelText: 'กรุณาใส่นามสกุล',
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

  Widget buildPasswordConfirm() => TextFormField(
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
      );

  Widget buildPassword() => TextFormField(
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
      );

  Widget buildPhotoIdCard() => Stack(
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
                            'รูปถ่ายบัตรประชาชน',
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

  Widget buildPhotoHouse() => Stack(
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
                            'รูปถ่ายสำเนาทะเบียนบ้าน',
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

  Widget buildButton() => SizedBox(
      width: double.infinity,
      child: ButtonWidget(
          title: "แก้ไขข้อมูล",
          color: MyConstant.buttonColor,
          textColor: Colors.black,
          onPressed: () => saveTodo()));

  // ฟังก์ชัน แกไ้ขข้อมูล
  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final address = addressController.text.trim();
    final firstName = firstnameController.text.trim();
    final lastName = lastnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();
    final tel = telController.text.trim();
    final idCard = idCardController.text.trim();

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

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final data1, data2;
    if (imagePath1 == widget.my_account.photo_id_card) {
      data1 = "1";
    } else {
      data1 = "2";
    }

    if (imagePath2 == widget.my_account.photo_house) {
      data2 = "1";
    } else {
      data2 = "2";
    }

    UserModel user;

    if (data1 == "1" && data2 == "1") {
      await FirebaseFirestore.instance.collection('user').doc(user_id).update({
        'address': address,
        'birthday': birthdayController.text,
        'email': email,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'password': password,
        'tel': tel,
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('address', address);
      prefs.setString('birthday', birthdayController.text);
      prefs.setString('email', email);
      prefs.setString('firstname', firstName);
      prefs.setString('id_card', idCard);
      prefs.setString('lastname', lastName);
      prefs.setString('password', password);
      prefs.setString('tel', tel);

      user = UserModel(
        address: address,
        user_id: widget.my_account.user_id,
        email: email,
        password: password,
        photo: widget.my_account.photo,
        photo_house: widget.my_account.photo_house,
        photo_id_card: widget.my_account.photo_id_card,
        status: widget.my_account.status,
        token: widget.my_account.token,
        birthday: birthdayController.text,
        firstname: firstName,
        lastname: lastName,
        id_card: idCard,
        type: widget.my_account.type,
        tel: tel,
      );
    } else if (data1 == "1" && data2 == "2") {
      final photo_house =
          await FirestorageApi.uploadPhoto(croppedFile2!, "Photo_house");
      await FirebaseFirestore.instance.collection('user').doc(user_id).update({
        'address': address,
        'birthday': birthdayController.text,
        'email': email,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'password': password,
        'photo_house': photo_house,
        'tel': tel,
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('address', address);
      prefs.setString('birthday', birthdayController.text);
      prefs.setString('email', email);
      prefs.setString('firstname', firstName);
      prefs.setString('id_card', idCard);
      prefs.setString('lastname', lastName);
      prefs.setString('password', password);
      prefs.setString('photo_house', photo_house);
      prefs.setString('tel', tel);

      user = UserModel(
        address: address,
        user_id: widget.my_account.user_id,
        email: email,
        password: password,
        photo: widget.my_account.photo,
        photo_id_card: widget.my_account.photo_id_card,
        photo_house: photo_house,
        status: widget.my_account.status,
        token: widget.my_account.token,
        birthday: birthdayController.text,
        firstname: firstName,
        lastname: lastName,
        id_card: idCard,
        type: widget.my_account.type,
        tel: tel,
      );
    } else if (data1 == "2" && data2 == "1") {
      final photo_id_card =
          await FirestorageApi.uploadPhoto(croppedFile1!, "Id_Card");
      await FirebaseFirestore.instance.collection('user').doc(user_id).update({
        'address': address,
        'birthday': birthdayController.text,
        'email': email,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'password': password,
        'photo_id_card': photo_id_card,
        'tel': tel,
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('address', address);
      prefs.setString('birthday', birthdayController.text);
      prefs.setString('email', email);
      prefs.setString('firstname', firstName);
      prefs.setString('id_card', idCard);
      prefs.setString('lastname', lastName);
      prefs.setString('password', password);
      prefs.setString('photo_id_card', photo_id_card);
      prefs.setString('tel', tel);

      user = UserModel(
        address: address,
        user_id: widget.my_account.user_id,
        email: email,
        password: password,
        photo: widget.my_account.photo,
        photo_id_card: photo_id_card,
        photo_house: widget.my_account.photo_house,
        status: widget.my_account.status,
        token: widget.my_account.token,
        birthday: birthdayController.text,
        firstname: firstName,
        lastname: lastName,
        id_card: idCard,
        type: widget.my_account.type,
        tel: tel,
      );
    } else {
      final photo_id_card =
          await FirestorageApi.uploadPhoto(croppedFile1!, "Id_Card");
      final photo_house =
          await FirestorageApi.uploadPhoto(croppedFile2!, "Photo_house");

      await FirebaseFirestore.instance.collection('user').doc(user_id).update({
        'address': address,
        'birthday': birthdayController.text,
        'email': email,
        'firstname': firstName,
        'id_card': idCard,
        'lastname': lastName,
        'password': password,
        'photo_id_card': photo_id_card,
        'photo_house': photo_house,
        'tel': tel,
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('address', address);
      prefs.setString('birthday', birthdayController.text);
      prefs.setString('email', email);
      prefs.setString('firstname', firstName);
      prefs.setString('id_card', idCard);
      prefs.setString('lastname', lastName);
      prefs.setString('password', password);
      prefs.setString('photo_id_card', photo_id_card);
      prefs.setString('photo_house', photo_house);
      prefs.setString('tel', tel);

      user = UserModel(
        address: address,
        user_id: widget.my_account.user_id,
        email: email,
        password: password,
        photo: widget.my_account.photo,
        photo_id_card: photo_id_card,
        photo_house: photo_house,
        status: widget.my_account.status,
        token: widget.my_account.token,
        birthday: birthdayController.text,
        firstname: firstName,
        lastname: lastName,
        id_card: idCard,
        type: widget.my_account.type,
        tel: tel,
      );
    }

    pd.dismiss();

    if (widget.my_account.type == "แอดมิน") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainAdmin(from: 'edit_user', my_account: user)),
        (Route<dynamic> route) => false,
      );
    } else if (widget.my_account.type == "เจ้าหน้าที่") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainStaff(from: 'edit_user', my_account: user)),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainUser(from: 'edit_user', my_account: user)),
        (Route<dynamic> route) => false,
      );
    }
  }
}
