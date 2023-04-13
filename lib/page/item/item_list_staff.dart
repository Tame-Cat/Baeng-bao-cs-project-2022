import 'dart:io';

import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/category.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/page/item/item_add.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/page/item/item_detail.dart';
import 'package:baeng_bao/page/item/item_edit.dart';
import 'package:baeng_bao/utils.dart';

class ItemListStaff extends StatefulWidget {
  CategoryModel category;
  UserModel my_account;
  ItemListStaff({Key? key, required this.category, required this.my_account})
      : super(key: key);
  @override
  _ItemListStaff createState() => _ItemListStaff();
}

class _ItemListStaff extends State<ItemListStaff> {
  String productType = "1";
  String? keyword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyConstant.primary,
          title: Text(widget.category.name),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
          children: [
            const SizedBox(height: 5),
            Card(
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'กรุณาใส่คำค้นหา...'),
                      onChanged: (val) {
                        setState(() {
                          keyword = val;
                          print(keyword);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<Item>>(
              stream: keyword == ''
                  ? FirebaseFirestore.instance
                      .collection("item")
                      .where("category_id",
                          isEqualTo: widget.category.category_id)
                      .orderBy("dateTime", descending: false)
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => Item.fromJson(doc.data()))
                          .toList())
                  : FirebaseFirestore.instance
                      .collection("item")
                      .where("category_id",
                          isEqualTo: widget.category.category_id)
                      .orderBy('name')
                      .startAt([keyword])
                      .endAt(['${keyword!}\uf8ff'])
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => Item.fromJson(doc.data()))
                          .toList()),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text(
                        'เกิดข้อผิดพลาด',
                        style: TextStyle(fontSize: 24),
                      ));
                    } else {
                      final items = snapshot.data;

                      return items!.isEmpty
                          ? const Center(
                              child: Text(
                                'ไม่มีข้อมูล',
                                style: TextStyle(fontSize: 24),
                              ),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];

                                return itemList(
                                    context, item, widget.my_account);
                              },
                            );
                    }
                }
              },
            )
          ],
        ))),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.black,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ItemAdd(my_account: widget.my_account)),
          ),
          child: const Icon(Icons.add),
        ));
  }
}

Widget itemList(BuildContext context, Item item, UserModel my_account) =>
    Slidable(
        endActionPane: ActionPane(motion: const ScrollMotion(), children: [
          SlidableAction(
            onPressed: (c) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ItemEdit(item: item, my_account: my_account)),
            ),
            backgroundColor: MyConstant.primary,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'แก้ไข',
            spacing: 8,
          ),
          SlidableAction(
            onPressed: (c) {
              deleteMethod(context, item, my_account);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'ลบ',
            spacing: 8,
          )
        ]),
        child: Container(
            margin: const EdgeInsets.only(left: 3, right: 3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemDetail(
                            item: item,
                            my_account: my_account,
                          )),
                ),
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        imageUrl: item.photo,
                        imageBuilder: (context, imageProvider) => Image.network(
                          item.photo,
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
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Image.asset(
                            "assets/no_image.jpg",
                            fit: BoxFit.fitWidth,
                            width: double.infinity),
                      ),
                      Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item.detail,
                                maxLines: 2,
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                item.status,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: item.status == "อยู่ในคลัง"
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            )));

void deleteMethod(BuildContext context, Item item, UserModel my_account) async {
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

              final ref = await FirebaseFirestore.instance
                  .collection("order")
                  .where("item_id", isEqualTo: item.item_id)
                  .get();

              if (ref.size != 0) {
                Utils.showToast(
                    context,
                    "ไม่สามารถลบอุปกรณ์ได้ เนื่องจากมีประวัติการยืมแล้ว",
                    Colors.red);
                return;
              }

              await FirebaseFirestore.instance
                  .collection('item')
                  .doc(item.item_id)
                  .delete();

              await CloudFirestoreApi.deleteBucketFromItemId(item.item_id);

              Utils.showToast(context, "ลบอุปกรณ์สำเร็จ", Colors.red);

              //Get.replace(StockAdminPage(my_account: my_account));
            },
            child: new Text('ใช่'),
          ),
        ],
      );
    },
  );
}

addEditItem(BuildContext context, Item item, UserModel my_account) async {
  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text(
            '⭐ กรุณาเลือกรายการ',
            style: TextStyle(fontSize: 18),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, false);
                if (item.user_id != my_account.user_id) {
                  Utils.showToast(
                      context, "สามารถแก้ไขได้แค่อุปกรณ์ตัวเอง", Colors.red);
                  return;
                }

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) =>
                //           ItemEdit(category: category, my_account: my_account)),
                // );
              },
              child: const Text(
                'แก้ไขอุปกรณ์',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context, false);

                if (item.user_id != my_account.user_id) {
                  Utils.showToast(
                      context, "สามารถลบได้แค่อุปกรณ์ตัวเอง", Colors.red);
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('item')
                    .doc(item.item_id)
                    .delete();

                Utils.showToast(context, "ลบอุปกรณ์สำเร็จ", Colors.red);
              },
              child: const Text(
                'ลบอุปกรณ์',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      });
}

goBack(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Login()),
    (Route<dynamic> route) => false,
  );
}
