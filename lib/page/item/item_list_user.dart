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

class ItemListUser extends StatefulWidget {
  UserModel my_account;
  ItemListUser({Key? key, required this.my_account}) : super(key: key);
  @override
  _ItemListUser createState() => _ItemListUser();
}

class _ItemListUser extends State<ItemListUser> {
  String? productType;
  String? keyword = '';
  bool test = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
          const SizedBox(
            height: 5,
          ),
          StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('category').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: Text('ไม่มีข้อมูล'),
                  );

                return Container(
                  margin: const EdgeInsets.only(left: 3, right: 3),
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        isDense: true,
                        hint: const Text('กรุณาเลือกหมวดหมู่'),
                        value: productType,
                        onChanged: (String? newValue) {
                          setState(() {
                            productType = newValue.toString().trim();
                            print(productType);
                          });
                        },
                        items: snapshot.data?.docs.map((DocumentSnapshot doc) {
                          return DropdownMenuItem<String>(
                              value: doc["name"].toString(),
                              child: Text(
                                doc["name"],
                                style: TextStyle(color: Colors.black),
                              ));
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }),
          const SizedBox(
            height: 5,
          ),
          StreamBuilder<List<Item>>(
            stream: keyword == ''
                ? productType == ''
                    ? FirebaseFirestore.instance
                        .collection("item")
                        .where("status", isEqualTo: "อยู่ในคลัง")
                        .orderBy("dateTime", descending: false)
                        .snapshots()
                        .map((snapshot) => snapshot.docs
                            .map((doc) => Item.fromJson(doc.data()))
                            .toList())
                    : FirebaseFirestore.instance
                        .collection("item")
                        .where("category_name", isEqualTo: productType)
                        .where("status", isEqualTo: "อยู่ในคลัง")
                        .orderBy("dateTime", descending: false)
                        .snapshots()
                        .map((snapshot) => snapshot.docs
                            .map((doc) => Item.fromJson(doc.data()))
                            .toList())
                : productType == ''
                    ? FirebaseFirestore.instance
                        .collection("item")
                        .orderBy('name')
                        .startAt([keyword])
                        .endAt(['${keyword!}\uf8ff'])
                        .snapshots()
                        .map((snapshot) => snapshot.docs
                            .map((doc) => Item.fromJson(doc.data()))
                            .toList())
                    : FirebaseFirestore.instance
                        .collection("item")
                        .where("category_name", isEqualTo: productType)
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

                              return itemList(context, item, widget.my_account);
                            },
                          );
                  }
              }
            },
          )
        ],
      )),
    );
  }
}

Widget itemList(BuildContext context, Item item, UserModel my_account) =>
    Container(
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
                            value: loadingProgress.expectedTotalBytes != null
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
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.detail,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            item.status,
                            style: TextStyle(
                                fontSize: 13,
                                color: item.status == "อยู่ในคลัง"
                                    ? Colors.green
                                    : item.status == "รอยืนยัน"
                                        ? Colors.yellow
                                        : Colors.red),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          )),
    );

goBack(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Login()),
    (Route<dynamic> route) => false,
  );
}
