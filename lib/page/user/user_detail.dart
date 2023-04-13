// ignore_for_file: unnecessary_statements

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/model/patient.dart';
import 'package:baeng_bao/page/patient/patient_edit.dart';
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

class UserDetail extends StatefulWidget {
  UserModel user, my_account;
  UserDetail({Key? key, required this.user, required this.my_account})
      : super(key: key);
  @override
  _UserDetail createState() => _UserDetail();
}

class _UserDetail extends State<UserDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primary,
        title: const Text("ข้อมูลผู้ใช้งาน"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => widget.user.photo != ""
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullImage(
                                photo: widget.user.photo,
                              )),
                    )
                  : print("test"),
              child: CachedNetworkImage(
                imageUrl: widget.user.photo,
                imageBuilder: (context, imageProvider) => Image.network(
                  widget.user.photo,
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
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.user.firstname} ${widget.user.lastname}',
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
                  Text('สถานะ',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Text(widget.user.status == "normal" ? "ปกติ" : "ยืมอุปกรณ์",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    child: Text('เลขบัตรประชาชน',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Text(widget.user.id_card,
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
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Text(widget.user.birthday,
                      style: TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
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
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Text(widget.user.address,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    child: Text('รูปถ่ายบัตรประชาชน',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => widget.user.photo_id_card != ""
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullImage(
                                photo: widget.user.photo_id_card,
                              )),
                    )
                  : print("test"),
              child: CachedNetworkImage(
                imageUrl: widget.user.photo_id_card,
                imageBuilder: (context, imageProvider) => Image.network(
                  widget.user.photo_id_card,
                  fit: BoxFit.cover,
                  height: 150,
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
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    child: Text('รูปถ่ายสำเนาทะเบียนบ้าน',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => widget.user.photo_house != ""
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullImage(
                                photo: widget.user.photo_house,
                              )),
                    )
                  : print("test"),
              child: CachedNetworkImage(
                imageUrl: widget.user.photo_house,
                imageBuilder: (context, imageProvider) => Image.network(
                  widget.user.photo_house,
                  fit: BoxFit.cover,
                  height: 150,
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
            )
          ],
        ),
      ),
    );
  }

  void deleteMethod(
      BuildContext context, UserModel user, UserModel my_account) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการลบผู้ใช้งานรายนี้ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, false);
                await FirebaseFirestore.instance
                    .collection('patient')
                    .doc(user.user_id)
                    .delete();

                Utils.showToast(context, "ลบผู้ใช้งานสำเร็จ", Colors.red);

                //Get.replace(StockAdminPage(my_account: my_account));
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}
