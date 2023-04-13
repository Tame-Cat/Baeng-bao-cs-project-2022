import 'package:baeng_bao/utility/my_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/history.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/page/item/item_detail.dart';
import 'package:baeng_bao/utils.dart';

class HistoryPage extends StatefulWidget {
  UserModel my_account;
  HistoryPage({Key? key, required this.my_account}) : super(key: key);

  @override
  _HistoryPage createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
          child: SingleChildScrollView(
            child: StreamBuilder<List<History>>(
              stream: widget.my_account.type == "ผู้ใช้งาน"
                  ? FirebaseFirestore.instance
                      .collection('history')
                      .where('user_id', isEqualTo: widget.my_account.user_id)
                      .orderBy(HistoryField.createdTime, descending: true)
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => History.fromJson(doc.data()))
                          .toList())
                  : FirebaseFirestore.instance
                      .collection('history')
                      .orderBy(HistoryField.createdTime, descending: true)
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => History.fromJson(doc.data()))
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
                      final historys = snapshot.data;

                      return historys!.isEmpty
                          ? const Center(
                              child: Text(
                                'ไม่มีข้อมูล',
                                style: TextStyle(fontSize: 24),
                              ),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: historys.length,
                              itemBuilder: (context, index) {
                                final history = historys[index];

                                return historyList(history, widget.my_account);
                              },
                            );
                    }
                }
              },
            ),
          )),
    );
  }

  Widget historyList(History history, UserModel my_account) => ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${history.patient_firstname} ${history.patient_lastname}",
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "อาการผู้ป่วย : ${history.patient_symptom}",
                style: const TextStyle(color: Colors.grey),
              ),
              Row(
                children: [
                  const Text(
                    "สถานะ : ",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    history.status,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: history.status == "ปฏิเสธการยืม"
                            ? Colors.red
                            : MyConstant.primary),
                  ),
                ],
              ),
              Text(
                "วันที่ทำรายการ : ${Utils.displayDayHistory(history.dateTime.toDate())}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ));
}
