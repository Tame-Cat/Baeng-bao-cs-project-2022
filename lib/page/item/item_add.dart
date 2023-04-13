import 'dart:io';

import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/model/category.dart';
import 'package:baeng_bao/model/item.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:baeng_bao/api/firestorage_api.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utils.dart';

class ItemAdd extends StatefulWidget {
  UserModel my_account;
  ItemAdd({Key? key, required this.my_account}) : super(key: key);

  @override
  State<ItemAdd> createState() => _ItemAdd();
}

class _ItemAdd extends State<ItemAdd> {
  double? _height, _width;

  final picker = ImagePicker();
  String? _selected, imagePath = '', productType = "เครื่องเขียน";
  final nameController = TextEditingController();
  final detailController = TextEditingController();
  final donorController = TextEditingController();
  File? croppedFile;

  List<String> categoryData = [];
  var _mySelection;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.addListener(() => setState(() {}));
    detailController.addListener(() => setState(() {}));
    donorController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    detailController.dispose();
    donorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primary,
        title: const Text('เพิ่มอุปกรณ์'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: _width,
        height: _height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 2),
              buildImage(),
              const SizedBox(height: 8),
              buildName(),
              const SizedBox(height: 8),
              buildDescription(),
              const SizedBox(height: 8),
              buildDonor(),
              const SizedBox(height: 8),
              buildCategory(),
              const SizedBox(height: 8),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage() => Stack(
        children: [
          imagePath != ''
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Image.file(
                    File(imagePath!),
                    height: 100,
                  ),
                )
              : GestureDetector(
                  onTap: () async {
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      croppedFile = (await ImageCropper().cropImage(
                        sourcePath: pickedFile.path,
                        aspectRatioPresets: [
                          CropAspectRatioPreset.square,
                          CropAspectRatioPreset.ratio3x2,
                          CropAspectRatioPreset.original,
                          CropAspectRatioPreset.ratio4x3,
                          CropAspectRatioPreset.ratio16x9
                        ],
                        androidUiSettings: AndroidUiSettings(
                          toolbarTitle: 'การตัดรูป',
                          toolbarColor: Colors.green[700],
                          toolbarWidgetColor: Colors.white,
                          activeControlsWidgetColor: Colors.green[700],
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false,
                        ),
                      ));
                      if (croppedFile != null) {
                        setState(() {
                          imagePath = croppedFile!.path;
                        });
                      }
                    }
                  },
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_open,
                            size: 40,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'เลือกรูปภาพ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          imagePath != ""
              ? Positioned(
                  top: 4.0,
                  right: 8.0,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      imagePath = '';
                    }),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ))
              : Container(),
        ],
      );

  Widget buildCategory() => StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('category').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: Text('ไม่มีข้อมูล'),
          );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(15)),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isDense: true,
                hint: const Text('กรุณาเลือกหมวดหมู่'),
                value: _selected,
                onChanged: (String? newValue) {
                  setState(() {
                    _selected = newValue.toString().trim();
                    print(_selected);
                  });
                },
                items: snapshot.data?.docs.map((DocumentSnapshot doc) {
                  return DropdownMenuItem<String>(
                      value: doc["category_id"].toString(),
                      child: Text(
                        doc["name"],
                        style: TextStyle(color: Colors.black),
                      ));
                }).toList(),
              ),
            ),
          ),
        );
      });

  Widget buildName() => TextFormField(
        maxLines: 1,
        controller: nameController,
        decoration: InputDecoration(
          suffixIcon: nameController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => nameController.clear(),
                ),
          border: const OutlineInputBorder(),
          labelText: 'กรุณาใส่ชื่ออุปกรณ์',
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
      );

  Widget buildDescription() => TextFormField(
        maxLines: 3,
        controller: detailController,
        decoration: InputDecoration(
          suffixIcon: detailController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => detailController.clear(),
                ),
          border: const OutlineInputBorder(),
          labelText: 'กรุณาใส่คำอธิบาย',
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
      );

  Widget buildDonor() => TextFormField(
        maxLines: 1,
        controller: donorController,
        decoration: InputDecoration(
          suffixIcon: donorController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => donorController.clear(),
                ),
          border: const OutlineInputBorder(),
          labelStyle: MyConstant().h3Style(),
          labelText: 'กรุณาใส่ชื่อผู้บริจาค',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );

  Widget buildButton() => SizedBox(
      width: double.infinity,
      child: ButtonWidget(
          title: "เพิ่มอุปกรณ์",
          onPressed: () => save_data(),
          color: MyConstant.buttonColor,
          textColor: Colors.black));

  void save_data() async {
    FocusScope.of(context).unfocus();
    final name = nameController.text.toString().trim();
    final detail = detailController.text.toString().trim();
    final donor = donorController.text.toString().trim();

    if (imagePath == '') {
      Utils.showToast(context, 'กรุณาเลือกรูปภาพก่อน', Colors.red);
      return;
    }

    if (name.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ชื่อค้าก่อน', Colors.red);
      return;
    }

    if (donor.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ผู้บริจาคก่อน', Colors.red);
      return;
    }

    if (_selected == null) {
      Utils.showToast(context, 'กรุณาเลือกหมวดหมู่ก่อน', Colors.red);
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final docItem = FirebaseFirestore.instance.collection('item').doc();
    await docItem.set({
      'category_id': _selected,
      'category_name':
          await CloudFirestoreApi.getCategoryNameFromId(_selected!),
      'dateTime': DateTime.now(),
      'detail': detail,
      'donor': donor,
      'item_id': docItem.id,
      'name': name,
      'photo': await FirestorageApi.uploadPhoto(croppedFile!, "Item"),
      'status': "อยู่ในคลัง",
      'user_id': widget.my_account.user_id,
    });

    pd.dismiss();
    Navigator.pop(context, false);
  }
}
