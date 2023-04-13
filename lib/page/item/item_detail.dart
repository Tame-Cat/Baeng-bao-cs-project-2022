// ignore_for_file: unnecessary_statements

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/page/item/item_edit.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/providers/chat_provider.dart';
import 'package:baeng_bao/page/chat_page.dart';
import 'package:baeng_bao/page/full_image.dart';
import 'package:baeng_bao/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemDetail extends StatefulWidget {
  Item item;
  UserModel my_account;
  ItemDetail({Key? key, required this.item, required this.my_account})
      : super(key: key);
  @override
  _ItemDetail createState() => _ItemDetail();
}

class _ItemDetail extends State<ItemDetail> {
  String? name, category_name, detail, photo, category_id, donor, bucket_id;

  SharedPreferences? prefs;
  bool isLiked = false, updateBucket = false;

  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();

    name = widget.item.name;
    category_name = widget.item.category_name;
    detail = widget.item.detail;
    donor = widget.item.donor;
    photo = widget.item.photo;
    //checkBucket();
  }

  Future checkBucket() async {
    final snapshotBucket = await FirebaseFirestore.instance
        .collection('bucket')
        .where('user_id', isEqualTo: widget.my_account.user_id)
        .where('item_id', isEqualTo: widget.item.item_id)
        .get();

    if (snapshotBucket.size != 0) {
      await FirebaseFirestore.instance
          .collection('bucket')
          .where('item_id', isEqualTo: widget.item.item_id)
          .where(
            'user_id',
            isEqualTo: widget.my_account.user_id,
          )
          .limit(1)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          setState(() {
            updateBucket = true;
            bucket_id = result.data()['bucket_id'];
          });
        });
      });
    } else {
      setState(() {
        updateBucket = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primary,
        title: Text(name!),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: Text(
                    name!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    child: Text('สถานะ : ',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                  Text(widget.item.status,
                      style: TextStyle(
                          color: widget.item.status == "อยู่ในคลัง"
                              ? Colors.green
                              : Colors.red,
                          fontSize: 16.0))
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    width: 80,
                    child: Text('รายละเอียด',
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
                  Text(detail!,
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
                    child: Text('ผู้บริจาค',
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
                  Text(donor!,
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
                    Text('วันที่ถูกเพิ่ม',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0))
                  ],
                )),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    Text(Utils.displayDayHistory(widget.item.dateTime.toDate()),
                        style: const TextStyle(
                            color: Colors.blueGrey, fontSize: 16.0))
                  ],
                )),
            const SizedBox(
              height: 10.0,
            ),
            widget.my_account.type != "ผู้ใช้งาน"
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
                                        builder: (context) => ItemEdit(
                                            item: widget.item,
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
                                  context, widget.item, widget.my_account))),
                    ],
                  )
                : Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ButtonWidget(
                        title: "ใส่ในตะกร้า",
                        color: MyConstant.buttonColor,
                        textColor: Colors.black,
                        onPressed: () => addBucket())),
          ],
        ),
      ),
    );
  }

  void deleteMethod(
      BuildContext context, Item item, UserModel my_account) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการลบอุปกรณ์นี้ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, false);
                await FirebaseFirestore.instance
                    .collection('item')
                    .doc(item.item_id)
                    .delete();

                await CloudFirestoreApi.deleteBucketFromItemId(item.item_id);

                Utils.showToast(context, "ลบอุปกรณ์สำเร็จ", Colors.red);

                //Get.replace(StockAdminPage(my_account: my_account));
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }

  Future addBucket() async {
    final refBucket = await FirebaseFirestore.instance
        .collection('bucket')
        .where('user_id', isEqualTo: widget.my_account.user_id)
        .where('item_id', isEqualTo: widget.item.item_id)
        .get();

    final refItem = await FirebaseFirestore.instance
        .collection('item')
        .where('item_id', isEqualTo: widget.item.item_id)
        .get();

    if (refBucket.size != 0) {
      Utils.showToast(context, "มีอุปกรณ์อยู่ในตะกร้าแล้ว", Colors.red);
      return;
    }

    if (refItem.size == 0) {
      Utils.showToast(
          context, "ไม่มีอุปกรณ์นี้ กรุณาตรวจดูอีกครั้งแล้ว", Colors.red);
      return;
    }

    final docBucket = FirebaseFirestore.instance.collection('bucket').doc();
    await docBucket.set({
      'bucket_id': docBucket.id,
      'dateTime': DateTime.now(),
      'detail': widget.item.detail,
      'item_id': widget.item.item_id,
      'name': widget.item.name,
      'photo': widget.item.photo,
      'user_id': widget.my_account.user_id,
    }).whenComplete(() {
      checkBucket();
      Utils.showToastSuccess(context, 'เพิ่มลงตะกร้าสำเร็จ');
    });
  }
}
