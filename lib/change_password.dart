import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/page/main_user.dart';
import 'package:baeng_bao/utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  final UserModel my_account;

  // รับค่ามาจากหน้าก่อน
  const ChangePassword({Key? key, required this.my_account}) : super(key: key);

  @override
  _ChangePassword createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();

    oldPasswordController.addListener(() => setState(() {}));
    newPasswordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: MyConstant.primary,
          title: const Text('หน้าเปลี่ยนรหัส'),
        ),
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildOldPassword(),
                  const SizedBox(height: 8),
                  buildNewPassword(),
                  const SizedBox(height: 8),
                  buildConfirmPassword(),
                  const SizedBox(height: 8),
                  buildButton(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildOldPassword() => TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        controller: oldPasswordController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.done,
        obscureText: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'รหัสผ่านเดิม',
          suffixIcon: oldPasswordController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => oldPasswordController.clear(),
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

  Widget buildNewPassword() => TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.name,
        controller: newPasswordController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.done,
        obscureText: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'รหัสผ่านใหม่',
          suffixIcon: newPasswordController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => newPasswordController.clear(),
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

  Widget buildConfirmPassword() => TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.name,
        controller: confirmPasswordController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.done,
        obscureText: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'ยืนยันรหัสผ่าน',
          suffixIcon: confirmPasswordController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => confirmPasswordController.clear(),
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

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ButtonWidget(
            title: "เปลี่ยนรหัส",
            onPressed: () => saveTodo(),
            color: MyConstant.buttonColor,
            textColor: Colors.black),
      );

  // ฟังก์ชัน แกไ้ขข้อมูล
  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสผ่านเดิมก่อน', Colors.red);
      return;
    }

    if (newPassword.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสผ่านใหม่ก่อน', Colors.red);
      return;
    }

    if (confirmPassword.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสผ่านใหม่อีกครั้งก่อน', Colors.red);
      return;
    }

    if (newPassword.length < 5) {
      Utils.showToast(context, 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว', Colors.red);
      return;
    }

    if (oldPassword != widget.my_account.password) {
      Utils.showToast(context, 'กรุณาใส่รหัสผ่านเดิมให้ถูกต้อง', Colors.red);
      return;
    }

    if (newPassword != confirmPassword) {
      Utils.showToast(
          context, 'รหัสผ่านใหม่กับรหัสยืนยันต้องตรงกัน', Colors.red);
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
        .doc(widget.my_account.user_id)
        .update({
      'password': newPassword,
    });

    // final myUser = FirebaseAuth.instance.currentUser;
    // final cred = EmailAuthProvider.credential(
    //     email: myUser!.email!, password: widget.my_account.password);

    // myUser.reauthenticateWithCredential(cred).then((value) {
    //   myUser.updatePassword(newPassword).then((_) {
    //     print("OK");
    //   }).catchError((error) {
    //     print("Error");
    //   });
    // }).catchError((err) {});

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('password', newPassword);

    final user = UserModel(
        address: widget.my_account.address,
        user_id: widget.my_account.user_id,
        email: widget.my_account.email,
        password: newPassword,
        token: widget.my_account.token,
        photo: widget.my_account.photo,
        photo_house: widget.my_account.photo_house,
        photo_id_card: widget.my_account.photo_id_card,
        status: widget.my_account.status,
        birthday: widget.my_account.birthday,
        firstname: widget.my_account.firstname,
        lastname: widget.my_account.lastname,
        id_card: widget.my_account.id_card,
        tel: widget.my_account.tel,
        type: widget.my_account.type);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MainUser(
            my_account: user,
            from: 'edit_user',
          ),
        ),
        (route) => false);
  }
}
