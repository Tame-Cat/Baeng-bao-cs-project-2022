import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:baeng_bao/main.dart';
import 'package:share_plus/share_plus.dart';

class FullImage extends StatelessWidget {
  // รับค่า photo มาจากไฟล์ก่อน
  String photo;
  FullImage({Key? key, required this.photo}) : super(key: key);

  // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 2,
                child: CachedNetworkImage(
                  imageUrl: photo,
                  imageBuilder: (context, imageProvider) => Image.network(photo,
                      fit: BoxFit.cover, width: double.infinity),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Image.asset(
                      "assets/no_image.jpg",
                      fit: BoxFit.fitWidth,
                      width: double.infinity),
                )),
          ),
        ),
        Positioned(
            top: 35.0,
            right: 55.0,
            child: IconButton(
              onPressed: () async => await Share.share(photo),
              icon: const Icon(
                Icons.share,
                color: Colors.white,
                size: 25,
              ),
            )),
        Positioned(
            top: 35.0,
            right: 20.0,
            child: IconButton(
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            )),
      ],
    ));
  }
}

class FullImage2 extends StatelessWidget {
  // รับค่า photo มาจากไฟล์ก่อน
  File photo;
  FullImage2({Key? key, required this.photo}) : super(key: key);

  // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            // แสดงรูปภาพ
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 2,
              child: Image.file(
                photo,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 80.0,
          right: 80.0,
          child: InkWell(
            onTap: () {
              // กดย้อนกลับ
              Navigator.pop(context, false);
            },
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    ));
  }
}
