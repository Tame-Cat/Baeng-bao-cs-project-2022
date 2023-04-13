// ignore_for_file: unnecessary_statements

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/item.dart';
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

class StaffDetail extends StatefulWidget {
  UserModel staff, my_account;
  StaffDetail({Key? key, required this.staff, required this.my_account})
      : super(key: key);
  @override
  _StaffDetail createState() => _StaffDetail();
}

class _StaffDetail extends State<StaffDetail> {
  String? address, birthday, email, firstname, lastname, idcard, photo, tel;

  SharedPreferences? prefs;

  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();

    address = widget.staff.address;
    birthday = widget.staff.birthday;
    firstname = widget.staff.firstname;
    lastname = widget.staff.lastname;
    email = widget.staff.email;
    idcard = widget.staff.id_card;
    tel = widget.staff.tel;
    photo = widget.staff.photo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primary,
        title: Text(firstname!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FullImage(
                          photo: photo!,
                        )),
              ),
              child: CachedNetworkImage(
                imageUrl: photo!,
                imageBuilder: (context, imageProvider) => Image.network(
                  photo!,
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
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${firstname!} ${lastname!}",
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
                  Text('เลขบัตรประชาชน',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                children: [
                  Text(idcard!,
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
                  Text(birthday!,
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
                    child: Text('อีเมล',
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
                  Text(email!,
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
                    child: Text('เบอร์โทร',
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
                  Text(tel!,
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
                  Text(address!,
                      style: TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            widget.my_account.type == "แอดมิน"
                ? Column(
                    children: [
                      Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ButtonWidget(
                              title: "แก้ไข",
                              color: MyConstant.buttonColor,
                              textColor: Colors.black,
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StaffEdit(
                                            staff: widget.staff,
                                            my_account: widget.my_account)),
                                  ))),
                      Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ButtonWidget(
                              title: "ลบ",
                              color: Colors.red,
                              textColor: Colors.white,
                              onPressed: () => deleteMethod(
                                  context, widget.staff, widget.my_account))),
                    ],
                  )
                : const SizedBox.shrink(),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  void deleteMethod(
      BuildContext context, UserModel staff, UserModel my_account) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการลบเจ้าหน้าที่นี้ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, false);
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(staff.user_id)
                    .delete();

                Utils.showToast(context, "ลบเจ้าหน้าที่สำเร็จ", Colors.red);

                //Get.replace(StockAdminPage(my_account: my_account));
              },
              child: new Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}
