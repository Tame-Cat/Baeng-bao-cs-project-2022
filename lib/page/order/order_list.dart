import 'dart:async';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/model/order.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/page/order/order_detail.dart';
import 'package:baeng_bao/providers/home_provider.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utils.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderList extends StatefulWidget {
  final UserModel my_account;

  OrderList({
    Key? key,
    required this.my_account,
  }) : super(key: key);

  @override
  _OrderList createState() => _OrderList();
}

class _OrderList extends State<OrderList> {
  String? selectStatus = "ทั้งหมด";
  String _selectedTime1 = "กำหนดเวลา",
      _selectedTime2 = "กำหนดเวลา",
      _selectedDay1 = "กำหนดวัน",
      _selectedDay2 = "กำหนดวัน";
  final passwordController = TextEditingController();
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = context.read<HomeProvider>();
  }

  Future<void> _showTime(String order_id, String data) async {
    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      if (data == "1") {
        setState(() {
          _selectedTime1 =
              '${time.hour}:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} น.';
        });

        await FirebaseFirestore.instance
            .collection('order')
            .doc(order_id)
            .update({
          'time_receive': _selectedTime1,
        });
      } else {
        setState(() {
          _selectedTime2 =
              '${time.hour}:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} น.';
        });

        await FirebaseFirestore.instance
            .collection('order')
            .doc(order_id)
            .update({
          'time_return': _selectedTime2,
        });
      }
    }
  }

  Future<void> _showDate(String order_id, String data) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        lastDate: DateTime(DateTime.now().year + 1));
    if (picked != null) {
      selectedDate = picked;
      if (data == "1") {
        setState(() {
          _selectedDay1 =
              "${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${(selectedDate.year + 543).toString()}";
        });

        await FirebaseFirestore.instance
            .collection('order')
            .doc(order_id)
            .update({
          'day_receive': _selectedDay1,
        });
      } else {
        setState(() {
          _selectedDay2 =
              "${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${(selectedDate.year + 543).toString()}";
        });

        await FirebaseFirestore.instance
            .collection('order')
            .doc(order_id)
            .update({
          'day_return': _selectedDay2,
        });
      }
    }
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
                  stream: selectOrder(selectStatus, widget.my_account.type),
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
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        child: Text('วันที่ ' + order.day + ' / ' + order.time,
                            style: TextStyle(fontSize: 15)),
                        alignment: Alignment.topRight,
                      ),
                      SingleChildScrollView(
                        child: ListView(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          children: order.item.map((doc) {
                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          doc['photo'],
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc['name'],
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              doc['detail'],
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      setColorStatus(order.status),
                      FutureBuilder<String>(
                        future: CloudFirestoreApi.getPatientNameFromPatientId(
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
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      setSelectDateTime(order, widget.my_account.type),
                      setButton(order, widget.my_account.type)
                    ],
                  )),
            )),
      );

  void approveOrder(OrderModel order) {
    if (order.status == "รอดำเนินการยืม") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('⭐ แจ้งเตือน'),
            content: const Text("คุณต้องการรับเรื่องการยืมนี้ ใช่หรือไม่?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ไม่ใช่'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, false);
                  await FirebaseFirestore.instance
                      .collection('order')
                      .doc(order.order_id)
                      .update({
                    'status': "นัดรับอุปกรณ์",
                  });

                  order.item.forEach((doc) async {
                    await FirebaseFirestore.instance
                        .collection('item')
                        .doc(doc["item_id"])
                        .update({
                      'status': "ถูกยืม",
                    });
                  });

                  await FirebaseFirestore.instance
                      .collection('user')
                      .doc(order.user_id)
                      .update({'status': "borrow"});

                  await FirebaseFirestore.instance
                      .collection('patient')
                      .doc(order.patient_id)
                      .update({'status': "borrow"});

                  Utils.showToast(context, 'รับเรื่องการยืม', Colors.green);
                },
                child: const Text('ใช่'),
              ),
            ],
          );
        },
      );
    } else if (order.status == "นัดรับอุปกรณ์") {
      if (order.day_receive == "") {
        Utils.showToast(context, "กรุณากำหนดวันคืนก่อน", Colors.red);
        return;
      }

      if (order.time_receive == "") {
        Utils.showToast(context, "กรุณากำหนดเวลาคืนก่อน", Colors.red);
        return;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('⭐ แจ้งเตือน'),
            content: const Text("คุณต้องการยืนยันการส่งมอบ ใช่หรือไม่?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ไม่ใช่'),
              ),
              TextButton(
                onPressed: () async {
                  final patient = await CloudFirestoreApi.getPatientFromId(
                      order.patient_id);

                  final docHistory =
                      FirebaseFirestore.instance.collection('history').doc();
                  await docHistory.set({
                    'dateTime': DateTime.now(),
                    'history_id': docHistory.id,
                    'patient_firstname': patient.firstname,
                    'patient_id': order.patient_id,
                    'patient_lastname': patient.lastname,
                    'patient_symptom': patient.symptom,
                    'status': "ยืมอุปกรณ์",
                    'user_id': order.user_id
                  });

                  await FirebaseFirestore.instance
                      .collection('order')
                      .doc(order.order_id)
                      .update({
                    'status': "กำลังยืมอุปกรณ์",
                  });

                  Utils.showToast(
                      context, 'ยืนยันการส่งมอบสำเร็จ', Colors.green);
                  Navigator.pop(context, false);
                },
                child: const Text('ใช่'),
              ),
            ],
          );
        },
      );
    } else if (order.status == "กำลังยืมอุปกรณ์") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('⭐ แจ้งเตือน'),
            content: const Text("คุณต้องการทำการส่งคืน ใช่หรือไม่?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ไม่ใช่'),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('order')
                      .doc(order.order_id)
                      .update({
                    'status': "นัดคืนอุปกรณ์",
                  });

                  Utils.showToast(context, 'ทำการส่งคืน', Colors.green);
                  Navigator.pop(context, false);
                },
                child: const Text('ใช่'),
              ),
            ],
          );
        },
      );
    } else if (order.status == "นัดคืนอุปกรณ์") {
      if (order.day_return == "") {
        Utils.showToast(context, "กรุณากำหนดวันคืนก่อน", Colors.red);
        return;
      }

      if (order.time_return == "") {
        Utils.showToast(context, "กรุณากำหนดเวลาคืนก่อน", Colors.red);
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('⭐ แจ้งเตือน'),
            content: const Text("คุณต้องการยืนยันการส่งคืน ใช่หรือไม่?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ไม่ใช่'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('⭐ กรุณาใส่รหัสผ่าน'),
                        content: TextFormField(
                          maxLines: 1,
                          controller: passwordController,
                          decoration: const InputDecoration(
                            hintText: 'ยืนยันรหัสผ่าน',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              if (passwordController.text !=
                                  widget.my_account.password) {
                                Navigator.pop(context, "false");
                                passwordController.clear();
                                Utils.showToast(
                                    context,
                                    "รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่",
                                    Colors.red);
                                return;
                              } else {
                                Navigator.pop(context, "false");
                                passwordController.clear();
                                final patient =
                                    await CloudFirestoreApi.getPatientFromId(
                                        order.patient_id);

                                final docHistory = FirebaseFirestore.instance
                                    .collection('history')
                                    .doc();
                                await docHistory.set({
                                  'dateTime': DateTime.now(),
                                  'history_id': docHistory.id,
                                  'patient_firstname': patient.firstname,
                                  'patient_id': order.patient_id,
                                  'patient_lastname': patient.lastname,
                                  'patient_symptom': patient.symptom,
                                  'status': "คืนอุปกรณ์",
                                  'user_id': order.user_id
                                });

                                await FirebaseFirestore.instance
                                    .collection('order')
                                    .doc(order.order_id)
                                    .update({
                                  'status': "คืนอุปกรณ์",
                                });

                                order.item.forEach((doc) async {
                                  await FirebaseFirestore.instance
                                      .collection('item')
                                      .doc(doc["item_id"])
                                      .update({
                                    'status': "อยู่ในคลัง",
                                  });
                                });

                                await CloudFirestoreApi.checkNormalUser(
                                    order.user_id);
                                await CloudFirestoreApi.checkNormalPatient(
                                    order.patient_id);

                                Utils.showToast(
                                    context, 'ทำการส่งคืนสำเร็จ', Colors.green);
                              }
                            },
                            child: const Text('ตกลง'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('ใช่'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('⭐ แจ้งเตือน'),
            content: const Text("คุณต้องการปฏิเสธการยืมนี้ ใช่หรือไม่?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ไม่ใช่'),
              ),
              TextButton(
                onPressed: () async {
                  final patient = await CloudFirestoreApi.getPatientFromId(
                      order.patient_id);

                  final docHistory =
                      FirebaseFirestore.instance.collection('history').doc();
                  await docHistory.set({
                    'dateTime': DateTime.now(),
                    'history_id': docHistory.id,
                    'patient_firstname': patient.firstname,
                    'patient_id': order.patient_id,
                    'patient_lastname': patient.lastname,
                    'patient_symptom': patient.symptom,
                    'status': "ปฏิเสธการยืม",
                    'user_id': order.user_id
                  });

                  await FirebaseFirestore.instance
                      .collection('order')
                      .doc(order.order_id)
                      .update({
                    'status': "ปฏิเสธการยืม",
                  });

                  for (int i = 0; i < order.item.length; i++) {
                    await FirebaseFirestore.instance
                        .collection('item')
                        .doc(order.item[i])
                        .update({
                      'status': "อยู่ในคลัง",
                    });
                  }

                  Utils.showToast(context, 'ปฏิเสธการยืมสำเร็จ', Colors.red);
                  Navigator.pop(context, false);
                },
                child: const Text('ใช่'),
              ),
            ],
          );
        },
      );
    }
  }

  void popUpConfrimPassword(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('⭐ กรุณาใส่รหัสผ่าน'),
            content: TextFormField(
              maxLines: 1,
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'ยืนยันรหัสผ่าน',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, "false");

                  if (passwordController.text != widget.my_account.password) {
                    Utils.showToast(
                        context, "รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่", Colors.red);
                    return;
                  } else {
                    Utils.showToast(
                        context, passwordController.text, Colors.green);
                  }
                },
                child: const Text('ตกลง'),
              ),
            ],
          );
        },
      );

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
        label: Text(
          'กำลังยืมอุปกรณ์',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      );
    } else if (status == "นัดคืนอุปกรณ์") {
      return const Chip(
        label: Text('นัดคืนอุปกรณ์'),
        backgroundColor: Colors.amberAccent,
      );
    } else if (status == "คืนอุปกรณ์") {
      return const Chip(
        label: Text(
          'คืนอุปกรณ์',
          style: TextStyle(color: Colors.white),
        ),
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

  selectOrder(String? selectStatus, String type) {
    if (selectStatus == "ทั้งหมด") {
      if (type == "ผู้ใช้งาน") {
        return FirebaseFirestore.instance
            .collection("order")
            .where("user_id", isEqualTo: widget.my_account.user_id)
            .orderBy(OrderField.createdTime, descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => OrderModel.fromJson(doc.data()))
                .toList());
      } else {
        return FirebaseFirestore.instance
            .collection("order")
            .orderBy(OrderField.createdTime, descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => OrderModel.fromJson(doc.data()))
                .toList());
      }
    } else {
      if (type == "ผู้ใช้งาน") {
        return FirebaseFirestore.instance
            .collection("order")
            .where("status", isEqualTo: selectStatus)
            .where("user_id", isEqualTo: widget.my_account.user_id)
            .orderBy(OrderField.createdTime, descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => OrderModel.fromJson(doc.data()))
                .toList());
      } else {
        return FirebaseFirestore.instance
            .collection("order")
            .where("status", isEqualTo: selectStatus)
            .orderBy(OrderField.createdTime, descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => OrderModel.fromJson(doc.data()))
                .toList());
      }
    }
  }

  void deleteOrderMethod(BuildContext context, String order_id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการยกเลิกคำขอนี้ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, false);
                await FirebaseFirestore.instance
                    .collection('order')
                    .doc(order_id)
                    .delete();

                Utils.showToast(context, "ยกเลิกคำขอยืมสำเร็จ", Colors.red);
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }

  setButton(OrderModel order, String type) {
    if (type != "ผู้ใช้งาน") {
      if (order.status == "รอดำเนินการยืม") {
        return Row(
          children: [
            Expanded(
                child: ButtonWidget(
                    title: "รับเรื่องการยืม",
                    color: MyConstant.buttonColor,
                    textColor: Colors.black,
                    onPressed: () => approveOrder(order))),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: ButtonWidget(
                    title: "ไม่อนุมัติการยืม",
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () => orderCancel(order))),
          ],
        );
      } else if (order.status == "นัดรับอุปกรณ์") {
        return Row(
          children: [
            Expanded(
                child: ButtonWidget(
                    title: "ยืนยันการส่งมอบ",
                    color: MyConstant.buttonColor,
                    textColor: Colors.black,
                    onPressed: () => approveOrder(order))),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: ButtonWidget(
                    title: "ไม่อนุมัติการยืม",
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () => orderCancel(order))),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      if (order.status == "รอดำเนินการยืม") {
        return SizedBox(
            width: double.infinity,
            child: ButtonWidget(
                title: "ยกเลิกคำขอยืม",
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () => deleteOrderMethod(context, order.order_id)));
      } else if (order.status == "กำลังยืมอุปกรณ์") {
        return SizedBox(
            width: double.infinity,
            child: ButtonWidget(
                title: "ทำการส่งคืน",
                color: MyConstant.buttonColor,
                textColor: Colors.black,
                onPressed: () => approveOrder(order)));
      } else if (order.status == "นัดคืนอุปกรณ์") {
        return SizedBox(
            width: double.infinity,
            child: ButtonWidget(
                title: "ยืนยันการส่งคืน",
                color: MyConstant.buttonColor,
                textColor: Colors.black,
                onPressed: () => approveOrder(order)));
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  setSelectDateTime(OrderModel order, String type) {
    if (type != "ผู้ใช้งาน") {
      if (order.status == "นัดรับอุปกรณ์") {
        return order.day_receive != "" && order.time_receive != ""
            ? Text("วันเวลานัดรับ ${order.day_receive} / ${order.time_receive}")
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      order.day_receive != ""
                          ? Text(order.day_receive)
                          : Text(_selectedDay1),
                      ElevatedButton(
                          onPressed: () => _showDate(order.order_id, "1"),
                          child: const Text("เลือกวัน"))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      order.time_receive != ""
                          ? Text(order.time_receive)
                          : Text(_selectedTime1),
                      ElevatedButton(
                          onPressed: () => _showTime(order.order_id, "1"),
                          child: const Text("เลือกเวลา"))
                    ],
                  ),
                ],
              );
      } else if (order.status == "นัดคืนอุปกรณ์") {
        return order.day_return != "" && order.time_return != ""
            ? Text("วันเวลานัดคืน ${order.day_return} / ${order.time_return}")
            : const SizedBox.shrink();
      } else {
        return const SizedBox.shrink();
      }
    } else {
      if (order.status == "นัดรับอุปกรณ์") {
        return order.day_receive != "" && order.time_receive != ""
            ? Text("วันเวลานัดรับ ${order.day_receive} / ${order.time_receive}")
            : const SizedBox.shrink();
      } else if (order.status == "นัดคืนอุปกรณ์") {
        return order.day_return != "" && order.time_return != ""
            ? Text("วันเวลานัดคืน ${order.day_return} / ${order.time_return}")
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      order.day_return != ""
                          ? Text(order.day_return)
                          : Text(_selectedDay2),
                      ElevatedButton(
                          onPressed: () => _showDate(order.order_id, "2"),
                          child: const Text("เลือกวัน"))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      order.time_return != ""
                          ? Text(order.time_return)
                          : Text(_selectedTime2),
                      ElevatedButton(
                          onPressed: () => _showTime(order.order_id, "2"),
                          child: const Text("เลือกเวลา"))
                    ],
                  ),
                ],
              );
        ;
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  void orderCancel(OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการปฏิเสธการยืมนี้ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                final patient =
                    await CloudFirestoreApi.getPatientFromId(order.patient_id);

                final docHistory =
                    FirebaseFirestore.instance.collection('history').doc();
                await docHistory.set({
                  'dateTime': DateTime.now(),
                  'history_id': docHistory.id,
                  'patient_firstname': patient.firstname,
                  'patient_id': order.patient_id,
                  'patient_lastname': patient.lastname,
                  'patient_symptom': patient.symptom,
                  'status': "ปฏิเสธการยืม",
                  'user_id': order.user_id
                });

                await FirebaseFirestore.instance
                    .collection('order')
                    .doc(order.order_id)
                    .update({
                  'status': "ปฏิเสธการยืม",
                });

                for (int i = 0; i < order.item.length; i++) {
                  await FirebaseFirestore.instance
                      .collection('item')
                      .doc(order.item[i])
                      .update({
                    'status': "อยู่ในคลัง",
                  });
                }

                Utils.showToast(context, 'ปฏิเสธการยืมสำเร็จ', Colors.red);
                Navigator.pop(context, false);
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}
