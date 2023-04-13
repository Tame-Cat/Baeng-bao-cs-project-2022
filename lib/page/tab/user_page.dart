import 'dart:io';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/change_password.dart';
import 'package:baeng_bao/page/full_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baeng_bao/page/user/edit_user.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/page/my_address.dart';
import 'package:baeng_bao/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class UserPage extends StatefulWidget {
  UserModel my_account;
  UserPage({Key? key, required this.my_account}) : super(key: key);
  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  String? user_id = '',
      address = '',
      firstname = '',
      lastname = '',
      password = '',
      birthday = '',
      email = '',
      id_card = '',
      token = '',
      tel = '',
      type = '',
      photo_before = '',
      photo_house = '',
      photo_id_card = '',
      status = '';
  UserModel? my_account;
  double? latitude, longitude;
  bool visible = false;

  SharedPreferences? prefs;
  String imagePath = '';
  final picker = ImagePicker();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    load();
  }

  // โหลดข้อมูล SharedPreferences
  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      address = prefs!.getString('address') ?? '';
      birthday = prefs!.getString('birthday') ?? '';
      print(birthday);
      email = prefs!.getString('email') ?? '';
      firstname = prefs!.getString('firstname') ?? '';
      id_card = prefs!.getString('id_card') ?? '';
      lastname = prefs!.getString('lastname') ?? '';
      password = prefs!.getString('password') ?? '';
      photo_before = prefs!.getString('photo') ?? '';
      photo_house = prefs!.getString('photo_house') ?? '';
      photo_id_card = prefs!.getString('photo_id_card') ?? '';
      status = prefs!.getString('status') ?? '';
      tel = prefs!.getString('tel') ?? '';
      type = prefs!.getString('type') ?? '';
      user_id = prefs!.getString('user_id') ?? '';

      my_account = UserModel(
          address: address!,
          email: email!,
          password: password!,
          token: '',
          birthday: birthday!,
          photo: photo_before!,
          photo_house: photo_house!,
          photo_id_card: photo_id_card!,
          status: status!,
          user_id: user_id!,
          id_card: id_card!,
          firstname: firstname!,
          lastname: lastname!,
          tel: tel!,
          type: type!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 10.0,
          ),
          buildPhoto(),
          const SizedBox(
            height: 10.0,
          ),
          buildIdCard(),
          const SizedBox(
            height: 10.0,
          ),
          email != '' ? buildEmail() : Container(),
          const SizedBox(
            height: 10.0,
          ),
          buildFirstname(),
          const SizedBox(
            height: 10.0,
          ),
          buildLastname(),
          const SizedBox(
            height: 10.0,
          ),
          buildPassword(),
          const SizedBox(
            height: 7.0,
          ),
          buildType(),
          const SizedBox(
            height: 10.0,
          ),
          buildBirthday(),
          const SizedBox(
            height: 10.0,
          ),
          type == "ผู้ใช้งาน"
              ? Column(
                  children: [
                    buildPhotoHouse(),
                    const SizedBox(
                      height: 10.0,
                    ),
                    buildPhotoIdCard(),
                  ],
                )
              : Container(),
          const Divider(),
          buildButtonEdit(),
          buildButtonChangePassword(),
          user_id != '' ? buildButtonLogout() : buildButtonLogin()
        ],
      ),
    );
  }

  Widget buildPhoto() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 25.0,
                ),
                onPressed: () => print('object'),
              ),
            ),
          ),
          CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xff476cfb),
            child: ClipOval(
              child: SizedBox(
                  width: 105,
                  height: 105,
                  child: photo_before != ''
                      ? Image.network(
                          '$photo_before', // this image doesn't exist
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/placeholder.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/user.png',
                          fit: BoxFit.cover,
                        )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: IconButton(
              icon: const Icon(
                Icons.photo_camera,
                size: 25.0,
              ),
              onPressed: () async {
                if (user_id == '') {
                  Utils.showToast(context, 'กรุณาล็อกอินก่อน', Colors.red);
                  return;
                } else {
                  final pickedFile =
                      await picker.getImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    File? croppedFile = (await ImageCropper().cropImage(
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
                        toolbarColor: Colors.green[700],
                        toolbarWidgetColor: Colors.white,
                        activeControlsWidgetColor: Colors.green[700],
                        initAspectRatio: CropAspectRatioPreset.original,
                        lockAspectRatio: false,
                      ),
                      iosUiSettings: IOSUiSettings(
                        minimumAspectRatio: 1.0,
                      ),
                    ));
                    if (croppedFile != null) {
                      setState(() {
                        imagePath = croppedFile.path;
                        uploadPic(croppedFile);
                        print(imagePath);
                      });
                    }
                  }
                }
              },
            ),
          ),
        ],
      );

  Widget buildPhotoHouse() => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 80,
              child: Text('รูปสำเนาทะเบียนบ้าน :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            photo_house == ""
                ? const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text("ไม่มีข้อมูล",
                        style: TextStyle(color: Colors.black, fontSize: 16.0)),
                  )
                : GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullImage(
                                photo: '$photo_house',
                              )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl: '$photo_house',
                        imageBuilder: (context, imageProvider) => Image.network(
                          '$photo_house',
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
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Image.asset(
                            "assets/no_image.jpg",
                            fit: BoxFit.fitWidth,
                            width: double.infinity),
                      ),
                    ),
                  )
          ],
        ),
      );

  Widget buildPhotoIdCard() => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 80,
              child: Text('รูปสำเนาบัตรประชาชน :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            photo_id_card == ""
                ? const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text("ไม่มีข้อมูล",
                        style: TextStyle(color: Colors.black, fontSize: 16.0)),
                  )
                : GestureDetector(
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullImage(
                                    photo: '$photo_id_card',
                                  )),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl: '$photo_id_card',
                        imageBuilder: (context, imageProvider) => Image.network(
                          '$photo_id_card',
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
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Image.asset(
                            "assets/no_image.jpg",
                            fit: BoxFit.fitWidth,
                            width: double.infinity),
                      ),
                    )),
          ],
        ),
      );

  Widget buildIdCard() => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 80,
              child: Text('เลขบัตรประชาชน :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$id_card',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildEmail() => Padding(
        padding: EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 80,
              child: Text('อีเมลล์ :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$email',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildFirstname() => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 80,
              child: Text('ชื่อผู้ใช้ :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$firstname',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildLastname() => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text('นามสกุล :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$lastname',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildPassword() => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 85,
                  child: Text('รหัสผ่าน :',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: visible == false
                      ? Text(setPasswordLength(password),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16.0))
                      : Text('$password',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16.0)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (visible == true) {
                        visible = false;
                      } else {
                        visible = true;
                      }
                      print(visible);
                    });
                  },
                  child: visible == false
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off)),
            ),
          ],
        ),
      );

  Widget buildType() => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 85,
              child: Text('ประเภท :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text('$type',
                  style: const TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildBirthday() => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  const SizedBox(
                    width: 85,
                    child: Text('วันเกิด :',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                  Container(
                    width: 200,
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text('$birthday',
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget buildButtonEdit() => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () => goToEditUser(),
        label: const Text('แก้ไขข้อมูล', style: TextStyle(color: Colors.white)),
        icon: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
        ),
      ));

  Widget buildButtonChangePassword() => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  ChangePassword(my_account: widget.my_account)),
        ),
        label:
            const Text('แก้ไขรหัสผ่าน', style: TextStyle(color: Colors.white)),
        icon: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
        ),
      ));

  Widget buildButtonLogin() => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Login()),
          );
        },
        label: const Text(
          'เข้าสู่ระบบ',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.logout, color: Colors.white),
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
        ),
      ));

  Widget buildButtonLogout() => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () => goToLogout(),
        label: const Text(
          'ออกจากระบบ',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.logout, color: Colors.white),
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
        ),
      ));

  Future uploadPic(File _image) async {
    FocusScope.of(context).unfocus();

    if (_image == null) {
      return;
    } else {
      ProgressDialog pd = ProgressDialog(
        loadingText: 'กรุณารอสักครู่...',
        context: context,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      pd.show();

      String fileName =
          'User_${DateTime.now().millisecondsSinceEpoch}${p.extension(_image.path)}';
      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child("User/$fileName").putFile(_image);
      if (snapshot.state == TaskState.success) {
        pd.dismiss();
        final String url = await snapshot.ref.getDownloadURL();

        if (photo_before != '') {
          await FirebaseStorage.instance.refFromURL(photo_before!).delete();
        }
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('photo', url);
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user_id)
            .update({'photo': url});

        setState(() {
          photo_before = url;
        });
      } else {
        pd.dismiss();
        Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่', Colors.red);
        return;
      }
    }
  }

  goToEditUser() async {
    if (user_id == '') {
      Utils.showToast(context, 'กรุณาล็อกอินก่อน', Colors.red);
      return;
    } else {
      final count = await CloudFirestoreApi.checkStatusUser(user_id!);
      print(count);
      if (count != 0) {
        Utils.showToast(context, 'ไม่สามารถแก้ไขได้ เนื่องจากอยู่ในสถานะการยืม',
            Colors.red);
        return;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditUserPage(
                    my_account: my_account!,
                    from: 'edit_user',
                  )),
        );
      }
    }
  }

  goToLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการออกจากระบบ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();

                await FirebaseFirestore.instance
                    .collection("user")
                    .doc(widget.my_account.user_id)
                    .update({'token': "", 'stay': 'no'});

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Login(),
                    ),
                    (route) => false);
              },
              child: new Text('ใช่'),
            ),
          ],
        );
      },
    );
  }

  String setPasswordLength(String? password) {
    String data = "";
    for (int i = 0; i < password!.length; i++) {
      data = data + "*";
    }

    return data;
  }
}
