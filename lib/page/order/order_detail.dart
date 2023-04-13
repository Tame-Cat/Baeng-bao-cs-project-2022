// ignore_for_file: unnecessary_statements

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/model/order.dart';
import 'package:baeng_bao/model/patient.dart';
import 'package:baeng_bao/page/item/item_detail.dart';
import 'package:baeng_bao/page/patient/patient_detail.dart';
import 'package:baeng_bao/page/patient/patient_edit.dart';
import 'package:baeng_bao/page/staff/staff_edit.dart';
import 'package:baeng_bao/page/user/user_detail.dart';
import 'package:baeng_bao/providers/home_provider.dart';
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

class OrderDetail extends StatefulWidget {
  OrderModel order;
  UserModel my_account;
  OrderDetail({Key? key, required this.order, required this.my_account})
      : super(key: key);
  @override
  _OrderDetail createState() => _OrderDetail();
}

class _OrderDetail extends State<OrderDetail> {
  String? selectStatus = "ทั้งหมด",
      status,
      day_receive = "",
      time_receive = "",
      day_return = "",
      time_return = "";
  String _selectedTime1 = "กำหนดเวลา",
      _selectedTime2 = "กำหนดเวลา",
      _selectedDay1 = "กำหนดวัน",
      _selectedDay2 = "กำหนดวัน";

  late OrderModel order;
  final passwordController = TextEditingController();
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = context.read<HomeProvider>();

    status = widget.order.status;
    day_receive = widget.order.day_receive;
    time_receive = widget.order.time_receive;
    day_return = widget.order.day_return;
    time_return = widget.order.time_return;
    order = widget.order;
  }

  Future<void> _showTime(String order_id, String data) async {
    print(data);
    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      setState(() {
        if (data == "1") {
          _selectedTime1 =
              '${time.hour}:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} น.';

          homeProvider.updateDataFirestore(
              "order", order_id, {'time_receive': _selectedTime1});
          time_receive = _selectedTime1;
        } else if (data == "2") {
          _selectedTime2 =
              '${time.hour}:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} น.';

          homeProvider.updateDataFirestore(
              "order", order_id, {'time_return': _selectedTime2});
          time_return = _selectedTime2;
        } else if (data == "3") {
          homeProvider.updateDataFirestore("order", order_id, {
            'time_receive':
                '${time.hour}:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} น.'
          });

          time_receive =
              '${time.hour}:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} น.';
        } else {
          homeProvider.updateDataFirestore("order", order_id, {
            'time_receive':
                '${time.hour}:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} น.'
          });

          time_return =
              '${time.hour}:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} น.';
        }
      });
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
      setState(() {
        selectedDate = picked;
        if (data == "1") {
          _selectedDay1 =
              "${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${(selectedDate.year + 543).toString()}";

          homeProvider.updateDataFirestore(
              "order", order_id, {'day_receive': _selectedDay1});

          day_receive = _selectedDay1;
        } else if (data == "2") {
          _selectedDay2 =
              "${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${(selectedDate.year + 543).toString()}";

          homeProvider.updateDataFirestore(
              "order", order_id, {'day_return': _selectedDay2});

          day_return = _selectedDay2;
        } else if (data == "3") {
          homeProvider.updateDataFirestore("order", order_id, {
            'day_receive':
                "${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${(selectedDate.year + 543).toString()}"
          });

          day_receive =
              "${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${(selectedDate.year + 543).toString()}";
        } else {
          homeProvider.updateDataFirestore("order", order_id, {
            'day_return':
                "${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${(selectedDate.year + 543).toString()}"
          });

          day_return =
              "${selectedDate.day.toString()} ${Utils.getMonthThaiFromNumber(selectedDate.month)} ${(selectedDate.year + 543).toString()}";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primary,
        title: const Text("ข้อมูลการแลกเปลี่ยน"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  Text('ชื่อผู้ป่วย',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: FutureBuilder<Patient>(
                  future: CloudFirestoreApi.getPatientFromId(
                      widget.order.patient_id),
                  builder:
                      (BuildContext context, AsyncSnapshot<Patient> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      final data = snapshot.data!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${data.firstname} ${data.lastname}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Container(
                              margin: const EdgeInsets.only(right: 25),
                              child: GestureDetector(
                                  onTap: () async {
                                    final ref = await FirebaseFirestore.instance
                                        .collection("patient")
                                        .where("patient_id",
                                            isEqualTo: data.patient_id)
                                        .get();

                                    if (ref.size == 0) {
                                      Utils.showToast(
                                          context,
                                          "ไม่สามารถดูข้อมูลได้ ข้อมูลอาจถูกลบไปแล้ว",
                                          Colors.red);
                                      return;
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                PatientDetail(
                                              patient: data,
                                              my_account: widget.my_account,
                                            ),
                                          ));
                                    }
                                  },
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                  )))
                        ],
                      );
                    }

                    return const Text("");
                  },
                )),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  Text(
                    'ชื่อผู้ยืม',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
                  )
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: FutureBuilder<UserModel>(
                  future:
                      CloudFirestoreApi.getUserFromUserId(widget.order.user_id),
                  builder: (BuildContext context,
                      AsyncSnapshot<UserModel> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      final data = snapshot.data!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${data.firstname} ${data.lastname}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Container(
                              margin: const EdgeInsets.only(right: 25),
                              child: GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              UserDetail(
                                            user: data,
                                            my_account: widget.my_account,
                                          ),
                                        ));
                                  },
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                  )))
                        ],
                      );
                    }

                    return const Text("");
                  },
                )),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  SizedBox(
                    child: Text('สถานะ',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [setColorStatus(status!)],
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
                    child: Text('รายชื่ออุปกรณ์ที่ยืม',
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: ListView(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10),
                children: widget.order.item.map((doc) {
                  return Column(
                    children: [
                      GestureDetector(
                          onTap: () async {
                            final ref = await FirebaseFirestore.instance
                                .collection("item")
                                .where("item_id", isEqualTo: doc['item_id'])
                                .get();

                            if (ref.size == 0) {
                              Utils.showToast(
                                  context,
                                  "ไม่สามารถดูข้อมูลได้ ข้อมูลอาจถูกลบไปแล้ว",
                                  Colors.red);
                              return;
                            } else {
                              final item =
                                  await CloudFirestoreApi.getItemFromItemId(
                                      doc['item_id']);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ItemDetail(
                                          item: item,
                                          my_account: widget.my_account,
                                        )),
                              );
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                doc['photo'],
                                width: 70,
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                          )),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: const [
                  Text('สาเหตุในการยืม',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16.0))
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    Text(widget.order.reason,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 16.0))
                  ],
                )),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Text('วันเดือนปีในการยืม',
                          style: TextStyle(
                              color: Colors.blueGrey, fontSize: 16.0)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Text('${widget.order.day} / ${widget.order.time}',
                      style: TextStyle(color: Colors.black, fontSize: 16.0))
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            day_receive != "" && time_receive != ""
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: const [
                            Text('วันเดือนปีในการรับ',
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16.0)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            Text('$day_receive / $time_receive',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16.0))
                          ],
                        ),
                      ),
                      status == "นัดรับอุปกรณ์" &&
                              widget.my_account.type != "ผู้ใช้งาน"
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: ButtonWidget(
                                          title: "แก้ไขวัน",
                                          color: Colors.blue,
                                          textColor: Colors.white,
                                          onPressed: () =>
                                              _showDate(order.order_id, "3"))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: ButtonWidget(
                                          title: "แก้ไขเวลา",
                                          color: Colors.blue,
                                          textColor: Colors.white,
                                          onPressed: () =>
                                              _showTime(order.order_id, "3")))
                                ],
                              ),
                            )
                          : const SizedBox.shrink()
                    ],
                  )
                : const SizedBox.shrink(),
            day_return != "" && time_return != ""
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: const [
                            Text('วันเดือนปีในการนัดคืน',
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16.0)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            Text('$day_return / $time_return',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16.0))
                          ],
                        ),
                      ),
                      status == "นัดคืนอุปกรณ์" &&
                              widget.my_account.type == "ผู้ใช้งาน"
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: ButtonWidget(
                                          title: "แก้ไขวัน",
                                          color: Colors.blue,
                                          textColor: Colors.white,
                                          onPressed: () =>
                                              _showDate(order.order_id, "4"))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: ButtonWidget(
                                          title: "แก้ไขเวลา",
                                          color: Colors.blue,
                                          textColor: Colors.white,
                                          onPressed: () =>
                                              _showTime(order.order_id, "4")))
                                ],
                              ),
                            )
                          : const SizedBox.shrink()
                    ],
                  )
                : const SizedBox.shrink(),
            setSelectDateTime(order, widget.my_account.type),
            setButton(order, widget.my_account.type)
          ],
        ),
      ),
    );
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
      if (status == "รอดำเนินการยืม") {
        return Column(
          children: [
            Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: ButtonWidget(
                    title: "รับเรื่องการยืม",
                    color: MyConstant.buttonColor,
                    textColor: Colors.black,
                    onPressed: () => approveOrder(order))),
            const SizedBox(
              width: 10,
            ),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: ButtonWidget(
                    title: "ไม่อนุมัติการยืม",
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () => orderCancel(order))),
          ],
        );
      } else if (status == "นัดรับอุปกรณ์") {
        return Column(
          children: [
            Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: ButtonWidget(
                    title: "ยืนยันการส่งมอบ",
                    color: MyConstant.buttonColor,
                    textColor: Colors.black,
                    onPressed: () => approveOrder(order))),
            const SizedBox(
              width: 10,
            ),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 10, right: 10),
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
      if (status == "รอดำเนินการยืม") {
        return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: ButtonWidget(
                title: "ยกเลิกคำขอยืม",
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () => deleteOrderMethod(context, order.order_id)));
      } else if (status == "กำลังยืมอุปกรณ์") {
        return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: ButtonWidget(
                title: "ทำการส่งคืน",
                color: MyConstant.buttonColor,
                textColor: Colors.black,
                onPressed: () => approveOrder(order)));
      } else if (status == "นัดคืนอุปกรณ์") {
        return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10),
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
      if (status == "นัดรับอุปกรณ์") {
        if (day_receive == "" || time_receive == "") {
          return Container(
              margin: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedDay1),
                      ElevatedButton(
                          onPressed: () => _showDate(order.order_id, "1"),
                          child: const Text("เลือกวัน"))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedTime1),
                      ElevatedButton(
                          onPressed: () => _showTime(order.order_id, "1"),
                          child: const Text("เลือกเวลา"))
                    ],
                  ),
                ],
              ));
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    } else {
      if (status == "นัดคืนอุปกรณ์") {
        if (day_return == "" || time_return == "") {
          return Container(
              margin: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedDay2),
                      ElevatedButton(
                          onPressed: () => _showDate(order.order_id, "2"),
                          child: const Text("เลือกวัน"))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedTime2),
                      ElevatedButton(
                          onPressed: () => _showTime(order.order_id, "2"),
                          child: const Text("เลือกเวลา"))
                    ],
                  ),
                ],
              ));
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  void approveOrder(OrderModel order) {
    if (status == "รอดำเนินการยืม") {
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

                  setState(() {
                    status = "นัดรับอุปกรณ์";
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
    } else if (status == "นัดรับอุปกรณ์") {
      if (day_receive == "") {
        if (_selectedDay1 == "กำหนดวัน") {
          Utils.showToast(context, "กรุณากำหนดวันคืนก่อน", Colors.red);
          return;
        }
      }

      if (time_receive == "") {
        if (_selectedTime1 == "กำหนดเวลา") {
          Utils.showToast(context, "กรุณากำหนดเวลาคืนก่อน", Colors.red);
          return;
        }
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

                  setState(() {
                    status = "กำลังยืมอุปกรณ์";
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
    } else if (status == "กำลังยืมอุปกรณ์") {
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

                  setState(() {
                    status = "นัดคืนอุปกรณ์";
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
    } else if (status == "นัดคืนอุปกรณ์") {
      if (day_return == "") {
        if (_selectedDay2 == "กำหนดวัน") {
          Utils.showToast(context, "กรุณากำหนดวันคืนก่อน", Colors.red);
          return;
        }
      }

      if (time_return == "") {
        if (_selectedTime2 == "กำหนดเวลา") {
          Utils.showToast(context, "กรุณากำหนดเวลาคืนก่อน", Colors.red);
          return;
        }
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

                                setState(() {
                                  status = "คืนอุปกรณ์";
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

                setState(() {
                  status = "ปฏิเสธการยืม";
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
