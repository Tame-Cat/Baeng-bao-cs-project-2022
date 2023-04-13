import 'dart:io';

import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:baeng_bao/api/firestorage_api.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utils.dart';

class CategoryAdd extends StatefulWidget {
  UserModel my_account;
  CategoryAdd({Key? key, required this.my_account}) : super(key: key);

  @override
  State<CategoryAdd> createState() => _CategoryAdd();
}

class _CategoryAdd extends State<CategoryAdd> {
  final _formKey = GlobalKey<FormState>();
  double? _height, _width;

  final picker = ImagePicker();
  String? _selected, imagePath = '', productType = "เครื่องเขียน";
  final nameController = TextEditingController();

  File? croppedFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyConstant.primary,
          title: const Text('เพิ่มหมวดหมู่'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          width: _width,
          height: _height,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  buildImage(),
                  const SizedBox(height: 8),
                  buildName(),
                  const SizedBox(height: 8),
                  buildButton(),
                ],
              ),
            ),
          ),
        ));
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
                          toolbarColor: MyConstant.primary,
                          toolbarWidgetColor: Colors.white,
                          activeControlsWidgetColor: MyConstant.primary,
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

  Widget buildName() => TextFormField(
        maxLines: 1,
        controller: nameController,
        decoration: InputDecoration(
          suffixIcon: nameController.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                  ),
                  onPressed: () => nameController.clear(),
                ),
          border: const OutlineInputBorder(),
          labelText: 'กรุณาใส่ชื่อหมวดหมู่',
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

  Widget buildButton() => SizedBox(
      width: double.infinity,
      child: ButtonWidget(
          title: "เพิ่มหมวดหมู่",
          color: MyConstant.buttonColor,
          textColor: Colors.black,
          onPressed: () => save_data()));

  void save_data() async {
    FocusScope.of(context).unfocus();
    final name = nameController.text.toString().trim();

    if (imagePath == '') {
      Utils.showToast(context, 'กรุณาเลือกรูปภาพก่อน', Colors.red);
      return;
    }

    if (name.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ชื่อหมวดหมู่ก่อน', Colors.red);
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final docCategory = FirebaseFirestore.instance.collection('category').doc();
    await docCategory.set({
      'category_id': docCategory.id,
      'dateTime': DateTime.now(),
      'name': name,
      'photo': await FirestorageApi.uploadPhoto(croppedFile!, "Category"),
      'size': 0,
      'user_id': widget.my_account.user_id,
    });

    pd.dismiss();
    Navigator.pop(context, false);
  }
}
