import 'dart:io';

import 'package:baeng_bao/model/category.dart';
import 'package:baeng_bao/page/category/category_edit.dart';
import 'package:baeng_bao/page/item/item_edit.dart';
import 'package:baeng_bao/page/item/item_list_staff.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/utils.dart';

class HomePage extends StatefulWidget {
  UserModel my_account;
  HomePage({Key? key, required this.my_account}) : super(key: key);
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  String productType = "1";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        const SizedBox(height: 10),
        Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: const Text(
                'หมวดหมู่ทั้งหมด',
                style: TextStyle(fontSize: 20),
              ),
            )),
        const SizedBox(height: 5),
        StreamBuilder<List<CategoryModel>>(
          stream: FirebaseFirestore.instance
              .collection("category")
              .orderBy("dateTime", descending: false)
              .snapshots()
              .map((snapshot) => snapshot.docs
                  .map((doc) => CategoryModel.fromJson(doc.data()))
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
                  final categorys = snapshot.data;

                  return categorys!.isEmpty
                      ? const Center(
                          child: Text(
                            'ไม่มีข้อมูล',
                            style: TextStyle(fontSize: 24),
                          ),
                        )
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 1,
                                  mainAxisSpacing: 10,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10),
                          itemCount: categorys.length,
                          itemBuilder: (context, index) {
                            final category = categorys[index];

                            return categoryList(
                                context, category, widget.my_account);
                          },
                        );
                }
            }
          },
        )
      ],
    ));
  }
}

Widget categoryList(
        BuildContext context, CategoryModel category, UserModel my_account) =>
    ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ItemListStaff(
                    category: category,
                    my_account: my_account,
                  )),
        ),
        onLongPress: () => addEditCategory(context, category, my_account),
        child: Card(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CachedNetworkImage(
                imageUrl: category.photo,
                imageBuilder: (context, imageProvider) => Image.network(
                  category.photo,
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
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                    "assets/no_image.jpg",
                    fit: BoxFit.fitWidth,
                    width: double.infinity),
              ),
              Platform.isIOS
                  ? Container(
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );

addEditCategory(
    BuildContext context, CategoryModel category, UserModel my_account) async {
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

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategoryEdit(
                          category: category, my_account: my_account)),
                );
              },
              child: const Text(
                'แก้ไขหมวดหมู่',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context, false);

                final ref = await FirebaseFirestore.instance
                    .collection("item")
                    .where("category_id", isEqualTo: category.category_id)
                    .get();

                if (ref.size != 0) {
                  Utils.showToast(
                      context,
                      "ไม่สามารถลบหมวดหมู่ได้ เนื่องจากอุปกรณ์แล้ว",
                      Colors.red);
                  return;
                } else {
                  await FirebaseFirestore.instance
                      .collection('category')
                      .doc(category.category_id)
                      .delete();

                  Utils.showToast(context, "ลบหมวดหมู่สำเร็จ", Colors.green);
                }
              },
              child: const Text(
                'ลบหมวดหมู่',
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
