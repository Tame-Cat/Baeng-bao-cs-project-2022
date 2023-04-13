import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Utils {
  static bool isKeyboardShowing() {
    return WidgetsBinding.instance.window.viewInsets.bottom > 0;
  }

  static closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static void showToast(BuildContext context, String text, Color color) =>
      Fluttertoast.showToast(
          msg: text,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: color,
          textColor: Colors.white,
          fontSize: 16.0);

  static void showToastSuccess(BuildContext context, String text) =>
      Fluttertoast.showToast(
          msg: text,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

  static String getDateThai() {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    String day, month = '', year;

    day = date.day.toString();
    year = (date.year + 543).toString();

    if (date.month == 1) {
      month = 'ม.ค.';
    } else if (date.month == 2) {
      month = 'ก.พ.';
    } else if (date.month == 3) {
      month = 'มี.ค.';
    } else if (date.month == 4) {
      month = 'เม.ย.';
    } else if (date.month == 5) {
      month = 'พ.ค.';
    } else if (date.month == 6) {
      month = 'มิ.ย.';
    } else if (date.month == 7) {
      month = 'ก.ค.';
    } else if (date.month == 8) {
      month = 'ส.ค.';
    } else if (date.month == 9) {
      month = 'ก.ย.';
    } else if (date.month == 10) {
      month = 'ต.ค.';
    } else if (date.month == 11) {
      month = 'พ.ย.';
    } else if (date.month == 12) {
      month = 'ธ.ค.';
    }

    return day + ' ' + month + ' ' + year;
  }

  static String getWeekOfMonth() {
    String date = DateTime.now().toString();
    String firstDay = date.substring(0, 8) + '01' + date.substring(10);

    DateTime now = new DateTime.now();
    String month = now.month.toString();
    String year = (now.year + 543).toString();

    int weekDay = DateTime.parse(firstDay).weekday;
    DateTime testDate = DateTime.now();
    int weekOfMonth = 0;

    weekDay--;
    weekOfMonth = ((testDate.day + weekDay) / 7).ceil();
    weekDay++;

    if (month.length == 1) {
      month = '0' + month;
    }

    return 'w' + weekOfMonth.toString() + '/' + month + '/' + year;
  }

  static String getMonth() {
    DateTime now = new DateTime.now();
    String year = (now.year + 543).toString();
    String month = '';

    if (now.month == 1) {
      month = 'ม.ค.';
    } else if (now.month == 2) {
      month = 'ก.พ.';
    } else if (now.month == 3) {
      month = 'มี.ค.';
    } else if (now.month == 4) {
      month = 'เม.ย.';
    } else if (now.month == 5) {
      month = 'พ.ค.';
    } else if (now.month == 6) {
      month = 'มิ.ย.';
    } else if (now.month == 7) {
      month = 'ก.ค.';
    } else if (now.month == 8) {
      month = 'ส.ค.';
    } else if (now.month == 9) {
      month = 'ก.ย.';
    } else if (now.month == 10) {
      month = 'ต.ค.';
    } else if (now.month == 11) {
      month = 'พ.ย.';
    } else if (now.month == 12) {
      month = 'ธ.ค.';
    }

    return month + ' ' + year;
  }

  static String getYear() {
    DateTime now = new DateTime.now();
    String year = (now.year + 543).toString();

    return year;
  }

  static final List<String> orderStatus = [
    "ทั้งหมด",
    "รอดำเนินการยืม",
    "ปฏิเสธการยืม",
    "นัดรับอุปกรณ์",
    "กำลังยืมอุปกรณ์",
    "นัดคืนอุปกรณ์",
    "คืนอุปกรณ์",
  ];

  static getMonthThaiFromNumber(int month) {
    if (month == 1) {
      return 'ม.ค.';
    } else if (month == 2) {
      return 'ก.พ.';
    } else if (month == 3) {
      return 'มี.ค.';
    } else if (month == 4) {
      return 'เม.ย.';
    } else if (month == 5) {
      return 'พ.ค.';
    } else if (month == 6) {
      return 'มิ.ย.';
    } else if (month == 7) {
      return 'ก.ค.';
    } else if (month == 8) {
      return 'ส.ค.';
    } else if (month == 9) {
      return 'ก.ย.';
    } else if (month == 10) {
      return 'ต.ค.';
    } else if (month == 11) {
      return 'พ.ย.';
    } else if (month == 12) {
      return 'ธ.ค.';
    }
  }

  static displayDay(DateTime postDay) {
    if (postDay.day == DateTime.now().day) {
      return '${postDay.hour}:${postDay.minute} น.';
    } else {
      return '${postDay.day} ${Utils.getMonthThaiFromNumber(postDay.month)} ${postDay.year + 543}';
    }
  }

  static displayDayHistory(DateTime postDay) {
    return '${postDay.day} ${Utils.getMonthThaiFromNumber(postDay.month)} ${postDay.year + 543} / ${postDay.hour} : ${postDay.minute.toString().length == 1 ? '0${postDay.minute}' : postDay.minute} น.';
  }

  static displayAge(DateTime data) {
    if (data.year != DateTime.now().year) {
      return "${DateTime.now().year - data.year} ปี";
    } else if (data.month != DateTime.now().month) {
      return "${DateTime.now().month - data.month} เดือน";
    } else {
      return "${DateTime.now().day - data.day} วัน";
    }
  }

  static Future<bool> sendPushNotifications(BuildContext context,
      {required String title,
      required String body,
      required String token}) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": token, //"/topics/$type"
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "type": '0rder',
        "id": '28',
        "click_action": 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAmNCJ_x0:APA91bHPGiQO0y3qWk1e-rz34luj2xtyA-486D55khxOGcUF73IwdI3gMP4rUy5M8nZs1cMH2k1TQAA5zfFTWSdHb6gFc9VMdgMCRCMZn5wZa8OfFeAORSglUt5nWPxsXJNbiXktsstq' // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      print('test ok push CFM');
      return true;
    } else {
      print('CFM error');
      return false;
    }
  }
}
