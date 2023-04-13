// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utils.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPassword();
}

class _ForgetPassword extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String password = "";

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    emailController.text = '';
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override // หน้า UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('ลืมรหัสผ่าน'),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'กรุณาใส่อีเมลล์เพื่อทำการรีเซ็ตรหัสผ่าน',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  buildEmail(),
                  password != ""
                      ? Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'รหัสของคุณคือ : $password',
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: password));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('Copied'),
                                    ));
                                  },
                                  child: const Icon(
                                    Icons.copy,
                                  ))
                            ],
                          ))
                      : Container(),
                  const SizedBox(height: 5),
                  buildButton(context),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildHeader() => const Align(
        child: Text(
          'Register',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        alignment: Alignment.topLeft,
      );

  Widget buildEmail() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: 50,
              child: TextFormField(
                maxLines: 1,
                controller: emailController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Email',
                  suffixIcon: emailController.text.isEmpty
                      ? Container(width: 0)
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => emailController.clear(),
                        ),
                  border: OutlineInputBorder(),
                  labelStyle: MyConstant().h3Style(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyConstant.dark),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyConstant.light),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                autovalidateMode: AutovalidateMode.always,
                // validator: (email) => EPValidator.validateEmail(
                //   email: email!,
                // ),
              )),
        ],
      );

  Widget buildButton(BuildContext context) => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => saveTodo(context),
        label: const Text(
          'แสดงรหัสผ่าน',
          style: TextStyle(fontSize: 16),
        ),
        icon: const Icon(Icons.visibility),
      ));

  void saveTodo(BuildContext context) async {
    final email = emailController.text.trim();

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (email.isEmpty) {
      Utils.showToast(context, 'กรุณากรอกอีเมลล์ก่อน', Colors.red);
      return;
    } else if (!emailRegExp.hasMatch(email)) {
      Utils.showToast(context, 'กรุณาตรวจสอบอีเมลล์ก่อน', Colors.red);
      return;
    }

    final ref = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (ref.size == 0) {
      Utils.showToast(
          context, "ไม่พบข้อมูลอีเมลนี้ กรุณาตรวจสอบอีกครั้ง", Colors.red);
      return;
    } else {
      await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          var userPassword = result.data()['password'];
          setState(() {
            password = userPassword;
          });
        });
      });
    }

    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => const Center(
    //           child: CircularProgressIndicator(),
    //         ));

    // try {
    //   await FirebaseAuth.instance
    //       .sendPasswordResetEmail(email: emailController.text.trim());
    //   Utils.showToast(context, 'Passowrd Reset Email Sent', Colors.green);
    //   Navigator.of(context).popUntil((route) => route.isFirst);
    // } on FirebaseAuthException catch (e) {
    //   Utils.showToast(context, e.message.toString(), Colors.red);
    //   Navigator.of(context).pop();
    // }
  }
}
