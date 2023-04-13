import 'dart:io';

import 'package:baeng_bao/model/bucket.dart';
import 'package:baeng_bao/model/category.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/page/item/item_add.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utils.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/page/item/item_detail.dart';
import 'package:intl/intl.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';

class BucketList extends StatefulWidget {
  UserModel my_account;
  BucketList({Key? key, required this.my_account}) : super(key: key);
  @override
  _BucketList createState() => _BucketList();
}

class _BucketList extends State<BucketList> {
  String? selectPatient;
  final reasonController = TextEditingController();
  List itemList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //reasonController.addListener(() => setState(() {}));
    loadBucket(widget.my_account.user_id);
  }

  Future loadBucket(String user_id) async {
    await FirebaseFirestore.instance
        .collection('bucket')
        .where('user_id', isEqualTo: user_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        itemList.add({
          "detail": result.data()['detail'],
          "item_id": result.data()['item_id'],
          "name": result.data()['name'],
          "photo": result.data()['photo'],
        });
        print(itemList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyConstant.primary,
          title: const Text("สร้างคำร้องขอยืม"),
        ),
        body: SafeArea(
            child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, top: 5),
                        child: const Text(
                          'เลือกผู้ป่วย',
                          style: TextStyle(fontSize: 18),
                        ),
                      )),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('patient')
                          .where("status", isEqualTo: "normal")
                          .where("user_id",
                              isEqualTo: widget.my_account.user_id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(
                            child: Text('ไม่มีข้อมูล'),
                          );

                        return Container(
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 5),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(15)),
                          width: double.infinity,
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                isDense: true,
                                hint: const Text('กรุณาเลือกผู้ป่วย'),
                                value: selectPatient,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectPatient = newValue.toString().trim();
                                    print(selectPatient);
                                  });
                                },
                                items: snapshot.data?.docs
                                    .map((DocumentSnapshot doc) {
                                  return DropdownMenuItem<String>(
                                      value: doc["patient_id"].toString(),
                                      child: Text(
                                        doc["firstname"] +
                                            " " +
                                            doc["lastname"],
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ));
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }),
                  StreamBuilder<List<Bucket>>(
                    stream: FirebaseFirestore.instance
                        .collection("bucket")
                        .where("user_id", isEqualTo: widget.my_account.user_id)
                        .orderBy("dateTime", descending: false)
                        .snapshots()
                        .map((snapshot) => snapshot.docs
                            .map((doc) => Bucket.fromJson(doc.data()))
                            .toList()),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Center(
                              child: CircularProgressIndicator());
                        default:
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text(
                              'เกิดข้อผิดพลาด',
                              style: TextStyle(fontSize: 24),
                            ));
                          } else {
                            final buckets = snapshot.data;

                            return buckets!.isEmpty
                                ? const SizedBox(
                                    height: 80,
                                    child: Center(
                                      child: Text(
                                        'คุณยังไม่ได้เลือกอุปกรณ์',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ))
                                : ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: buckets.length,
                                    itemBuilder: (context, index) {
                                      final bucket = buckets[index];

                                      return bucketList(
                                          context, bucket, widget.my_account);
                                    },
                                  );
                          }
                      }
                    },
                  ),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, bottom: 5),
                        child: const Text(
                          'สาเหตุในการขอยืมอุปกรณ์',
                          style: TextStyle(fontSize: 18),
                        ),
                      )),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      maxLines: 2,
                      controller: reasonController,
                      decoration: InputDecoration(
                        suffixIcon: reasonController.text.isEmpty
                            ? Container(width: 0)
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => reasonController.clear(),
                              ),
                        border: const OutlineInputBorder(),
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
                    ),
                  ),
                  // const SizedBox(
                  //   height: 200,
                  // )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ButtonWidget(
                        title: "ยื่นคำร้องขอยืม",
                        color: MyConstant.buttonColor,
                        textColor: Colors.black,
                        onPressed: () => save_data()))
              ],
            )
          ],
        )));
  }

  Widget bucketList(
          BuildContext context, Bucket bucket, UserModel my_account) =>
      Slidable(
          endActionPane: ActionPane(motion: const ScrollMotion(), children: [
            SlidableAction(
              onPressed: (c) {
                deleteMethod(context, bucket, my_account);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'ลบ',
              spacing: 8,
            )
          ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: GestureDetector(
                onTap: () async {
                  final item =
                      await CloudFirestoreApi.getItemFromItemId(bucket.item_id);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ItemDetail(
                              item: item,
                              my_account: my_account,
                            )),
                  );
                },
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CachedNetworkImage(
                              height: 80,
                              width: 80,
                              imageUrl: bucket.photo,
                              imageBuilder: (context, imageProvider) =>
                                  Image.network(
                                bucket.photo,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
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
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Image.asset(
                                  "assets/no_image.jpg",
                                  fit: BoxFit.fitWidth,
                                  width: double.infinity),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bucket.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  bucket.detail,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                            onTap: () =>
                                deleteMethod(context, bucket, my_account),
                            child: const Icon(Icons.delete))
                      ],
                    ),
                  ),
                )),
          ));

  void save_data() async {
    FocusScope.of(context).unfocus();

    final reason = reasonController.text.toString().trim();
    if (selectPatient == null) {
      Utils.showToast(context, 'กรุณาเลือกผู้ป่วยก่อน', Colors.red);
      return;
    }

    if (itemList.isEmpty) {
      Utils.showToast(context, 'กรุณาเลือกอุปกรณ์ก่อน', Colors.red);
    }

    if (reason.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่สาเหตุก่อน', Colors.red);
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    print(itemList);

    final docOrder = FirebaseFirestore.instance.collection('order').doc();
    await docOrder.set({
      'dateTime': DateTime.now(),
      'day': Utils.getDateThai(),
      'day_receive': "",
      'day_return': "",
      'item': itemList,
      'order_id': docOrder.id,
      'patient_id': selectPatient,
      'reason': reason,
      'status': "รอดำเนินการยืม",
      'time': '${DateFormat('kk:mm').format(DateTime.now())} น.',
      'time_receive': "",
      'time_return': "",
      'user_id': widget.my_account.user_id,
    });

    pd.dismiss();
    Navigator.pop(context, false);
  }

  void deleteMethod(
      BuildContext context, Bucket bucket, UserModel my_account) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการลบอุปกรณ์จากตะกร้านี้ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, false);
                itemList.clear();
                loadBucket(my_account.user_id);
                await FirebaseFirestore.instance
                    .collection('bucket')
                    .doc(bucket.bucket_id)
                    .delete();

                Utils.showToast(
                    context, "ลบอุปกรณ์จากตะกร้าสำเร็จ", Colors.red);
              },
              child: new Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}

goBack(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Login()),
    (Route<dynamic> route) => false,
  );
}
