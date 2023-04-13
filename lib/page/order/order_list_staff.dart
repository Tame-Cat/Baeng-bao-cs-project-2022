import 'dart:async';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/history.dart';
import 'package:baeng_bao/model/order.dart';
import 'package:baeng_bao/page/item/item_detail.dart';
import 'package:baeng_bao/page/order/order_detail.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:baeng_bao/constants/color_constants.dart';
import 'package:baeng_bao/model/chat_link.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/providers/home_provider.dart';
import 'package:baeng_bao/page/chat_page.dart';
import 'package:baeng_bao/utils.dart';
import 'package:baeng_bao/widgets/loading_view.dart';
import 'package:provider/provider.dart';

class OrderListStaff extends StatefulWidget {
  UserModel my_account;
  OrderListStaff({Key? key, required this.my_account}) : super(key: key);

  @override
  _OrderListStaff createState() => _OrderListStaff();
}

class _OrderListStaff extends State<OrderListStaff> {
  _OrderListStaff({Key? key});

  late HomeProvider homeProvider;
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  int _limitIncrement = 20;
  bool isLoading = false;
  String? selectStatus = "รอดำเนินการ";

  @override
  void initState() {
    super.initState();
    homeProvider = context.read<HomeProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 3, right: 3),
                  width: double.infinity,
                  child: DropdownButton<String>(
                    value: selectStatus,
                    onChanged: ((value) {
                      setState(() {
                        selectStatus = value!;
                        print(selectStatus);
                      });
                    }),
                    items: Utils.orderStatus
                        .map((e) => DropdownMenuItem(
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  children: [Text(e)],
                                ),
                              ),
                              value: e,
                            ))
                        .toList(),
                    selectedItemBuilder: (BuildContext context) =>
                        Utils.orderStatus
                            .map((e) => Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(e))
                                  ],
                                ))
                            .toList(),
                    hint: const Padding(
                      padding: EdgeInsets.fromLTRB(10, 12, 0, 0),
                      child: Text(
                        'กรุณาเลือกประเภท',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    underline: Container(),
                  ),
                ),
                StreamBuilder<List<OrderModel>>(
                  stream: selectStatus == "ทั้งหมด"
                      ? FirebaseFirestore.instance
                          .collection("order")
                          .orderBy(OrderField.createdTime, descending: true)
                          .snapshots()
                          .map((snapshot) => snapshot.docs
                              .map((doc) => OrderModel.fromJson(doc.data()))
                              .toList())
                      : FirebaseFirestore.instance
                          .collection("order")
                          .where("status", isEqualTo: selectStatus)
                          .orderBy(OrderField.createdTime, descending: true)
                          .snapshots()
                          .map((snapshot) => snapshot.docs
                              .map((doc) => OrderModel.fromJson(doc.data()))
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
                            ),
                          );
                        } else {
                          final orders = snapshot.data;

                          return orders!.isEmpty
                              ? const Center(
                                  child: Text(
                                    'ไม่มีข้อมูล',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                )
                              : ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];

                                    return orderList(context, order);
                                  },
                                );
                        }
                    }
                  },
                )
              ],
            ))));
  }

  Widget orderList(BuildContext context, OrderModel order) => ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: GestureDetector(
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderDetail(
                          order: order, my_account: widget.my_account)),
                ),
            child: Card(
              child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(3),
                  child: Column(
                    children: [
                      Align(
                        child: Text('วันที่ ' + order.day + ' / ' + order.time,
                            style: TextStyle(fontSize: 15)),
                        alignment: Alignment.topRight,
                      ),
                      ListView(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 10),
                        children: order.item.map((doc) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        doc['photo'],
                                        width: 70,
                                      ),
                                      SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc['name'],
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            doc['detail'],
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              setColorStatus(order.status),
                              FutureBuilder<String>(
                                future: CloudFirestoreApi
                                    .getPatientNameFromPatientId(
                                        order.patient_id),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text("");
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    final data = snapshot.data!;
                                    return Text(
                                      "ผู้ป่วย : $data",
                                      style: const TextStyle(fontSize: 16),
                                    );
                                  }

                                  return const Text("");
                                },
                              ),
                              Text(
                                "สาเหตุ : ${order.reason}",
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.grey),
                              ),
                              widget.my_account.type != "ผู้ใช้งาน"
                                  ? Row(
                                      children: [
                                        Expanded(
                                            child: ButtonWidget(
                                                title: "อนุมัติ",
                                                onPressed: () =>
                                                    approveOrder(order),
                                                color: Colors.green,
                                                textColor: Colors.white)),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                            child: ButtonWidget(
                                                title: "ไม่อนุมัติ",
                                                onPressed: () =>
                                                    approveOrder(order),
                                                color: Colors.red,
                                                textColor: Colors.white))
                                      ],
                                    )
                                  : const SizedBox.shrink()
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  )),
            )),
      );

  void approveOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('⭐ แจ้งเตือน'),
          content: Text("คุณต้องการยอมรับออเดอร์นี้ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: new Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                // Get.back();
                // String day = Utils.getDateThai();
                // String month = Utils.getMonth();
                // String year = Utils.getYear();

                // order.stock.forEach((result) async {
                //   String stock_id = result['stock_id'];
                //   String name = result['name'];
                //   int price = result['price'];
                //   int size_price = result['size_price'];
                //   int amount = result['amount'];
                //   String image = result['image'];

                //   CloudFirestoreApi.updateBestSeller(
                //       name, (price + size_price) * amount, image, 'day', day);
                //   CloudFirestoreApi.updateBestSeller(name,
                //       (price + size_price) * amount, image, 'month', month);
                //   CloudFirestoreApi.updateBestSeller(
                //       name, (price + size_price) * amount, image, 'year', year);
                // });

                // CloudFirestoreApi.getDataWeekMonthYearAll('day');
                // CloudFirestoreApi.getDataWeekMonthYearAll('month');
                // CloudFirestoreApi.getDataWeekMonthYearAll('year');

                // await FirebaseFirestore.instance
                //     .collection('order')
                //     .doc(order.order_id)
                //     .update({
                //   'approve': 'true',
                // });

                // Utils.showToast(context, 'คำสั่งซื้ออนุมัติ', Colors.red);
                // Get.back();
              },
              child: new Text('ใช่'),
            ),
          ],
        );
      },
    );
  }

  setColorStatus(String status) {
    if (status == "รอดำเนินการยืม") {
      return const Chip(
        label: Text('รอดำเนินการยืม'),
        backgroundColor: Colors.amberAccent,
      );
    } else if (status == "นัดรับอุปกรณ์") {
      return const Chip(
        label: Text('นัดรับอุปกรณ์'),
        backgroundColor: Colors.amberAccent,
      );
    } else if (status == "กำลังยืมอุปกรณ์") {
      return const Chip(
        label: Text('กำลังยืมอุปกรณ์'),
        backgroundColor: Colors.green,
      );
    } else if (status == "นัดคืนอุปกรณ์") {
      return const Chip(
        label: Text('นัดคืนอุปกรณ์'),
        backgroundColor: Colors.amberAccent,
      );
    } else if (status == "คืนอุปกรณ์") {
      return const Chip(
        label: Text('คืนอุปกรณ์'),
        backgroundColor: Colors.green,
      );
    } else {
      return const Chip(
        label: Text(
          'ปฏิเสธการยืม',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
    }
  }
}
