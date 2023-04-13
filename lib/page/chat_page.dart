import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:baeng_bao/api/cloudfirestore_api.dart';
import 'package:baeng_bao/constants/color_constants.dart';
import 'package:baeng_bao/constants/firestore_constants.dart';
import 'package:baeng_bao/model/message_chat.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/providers/chat_provider.dart';
import 'package:baeng_bao/providers/home_provider.dart';
import 'package:baeng_bao/page/full_image.dart';
import 'package:baeng_bao/page/item/item_detail.dart';
import 'package:baeng_bao/utils.dart';
import 'package:baeng_bao/widgets/loading_view.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.arguments}) : super(key: key);

  final ChatPageArguments arguments;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late String currentUserId;
  late String chatLinkId;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "", status = "";

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = context.read<HomeProvider>();
    chatProvider = context.read<ChatProvider>();

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  Future<void> readLocal() async {
    currentUserId = widget.arguments.my_account.user_id;

    String peerId = widget.arguments.peerId;
    // if (currentUserId.compareTo(peerId) > 0) {
    //   groupChatId = '$currentUserId-$peerId';
    // } else {
    //   groupChatId = '$peerId-$currentUserId';
    // }

    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId, "stay": "yes"},
    );

    final id = await chatProvider.addChatLink(
        widget.arguments.peerId, widget.arguments.post_id, currentUserId);

    print(id);

    final checkStatus = await chatProvider.getStatusChatLinkFromId(id);
    print(checkStatus);

    setState(() {
      chatLinkId = id;
      status = checkStatus;

      groupChatId = chatLinkId;

      if (chatLinkId != '') {
        chatProvider.updateAllseen(groupChatId, chatLinkId, currentUserId);
        chatProvider.updateDataFirestore(FirestoreConstants.pathUserCollection,
            currentUserId, {'stay': 'yes'});
      }
    });
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  // void getSticker() {
  //   focusNode.unfocus();
  //   setState(() {
  //     isShowSticker = !isShowSticker;
  //   });
  // }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Future<void> onSendMessage(String content, int type) async {
    if (chatLinkId.isEmpty) {
      Utils.showToast(context, "ไม่สามารถส่งข้อความได้", Colors.red);
      return;
    }

    if (content.trim().isNotEmpty) {
      textEditingController.clear();

      chatProvider.sendMessage(
          content,
          type,
          groupChatId,
          currentUserId,
          widget.arguments.peerId,
          await CloudFirestoreApi.checkUserStay(widget.arguments.peerId));

      chatProvider.updateDataFirestore("chatLink", chatLinkId, {
        'receiver_id': widget.arguments.peerId,
        'sender_id': widget.arguments.my_account.user_id,
        'status': "talking",
        'message': content,
        'post_id': widget.arguments.post_id,
        'post_name': widget.arguments.post_name,
        'unseen': await chatProvider.getCountSeen(
            groupChatId, widget.arguments.peerId.trim()),
        'type': type,
        'time':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()}',
        'day': Utils.getDateThai(),
        'dateTime': DateTime.now()
      });

      Utils.sendPushNotifications(context,
          title: "มีข้อความ",
          body: content,
          token: await CloudFirestoreApi.getTokenFromUserId(
              widget.arguments.peerId));
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
    }
  }

  void exChange() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการแลกเปลี่ยนอุปกรณ์ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false);

                // final post = await homeProvider
                //     .getPostFromPostId(widget.arguments.post_id);

                // List userList = [];
                // userList.add(widget.arguments.peerId);
                // userList.add(widget.arguments.my_account.user_id);

                // final docHistory =
                //     FirebaseFirestore.instance.collection('history').doc();
                // await docHistory.set({
                //   'dateTime': DateTime.now(),
                //   'history_id': docHistory.id,
                //   'name': post.name,
                //   'photo': post.photo,
                //   'post_id': widget.arguments.post_id,
                //   'receiver_id': widget.arguments.peerId,
                //   'sender_id': widget.arguments.my_account.user_id,
                //   'user': userList
                // });

                // await FirebaseFirestore.instance
                //     .collection('post')
                //     .doc(widget.arguments.post_id)
                //     .update({'status': "complete"});

                // List<String> checkId = [];
                // await FirebaseFirestore.instance
                //     .collection('chatLink')
                //     .where('post_id', isEqualTo: widget.arguments.post_id)
                //     .get()
                //     .then((querySnapshot) {
                //   querySnapshot.docs.forEach((result) async {
                //     var id = result.data()['id'];
                //     checkId.add(id);
                //     checkId.removeWhere((item) => item == chatLinkId);

                //     for (int i = 0; i < checkId.length; i++) {
                //       await FirebaseFirestore.instance
                //           .collection('chatLink')
                //           .doc(checkId[i])
                //           .update({'status': "complete"});
                //     }
                //   });
                // });

                // setState(() {});

                // Utils.showToastSuccess(context, 'แลกเปลี่ยนอุุปกรณ์สำเร็จ');
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        return Row(
          children: [
            messageChat.type == TypeMessage.text
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: 200.0,
                            ),
                            child: Text(
                              messageChat.content,
                              style:
                                  TextStyle(color: ColorConstants.primaryColor),
                            ),
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            decoration: BoxDecoration(
                                color: ColorConstants.greyColor2,
                                borderRadius: BorderRadius.circular(8)),
                            margin: EdgeInsets.only(right: 10),
                          ),
                          Container(
                            child: Text(
                              DateFormat('dd MMM kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(messageChat.timestamp))),
                              style: TextStyle(
                                  color: ColorConstants.greyColor,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic),
                            ),
                            margin:
                                EdgeInsets.only(right: 10, top: 2, bottom: 5),
                          )
                        ],
                      ),
                      Material(
                        child: Image.network(
                          widget.arguments.my_account.photo,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: ColorConstants.themeColor,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 35,
                              color: ColorConstants.greyColor,
                            );
                          },
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            child: OutlinedButton(
                              child: Material(
                                child: Image.network(
                                  messageChat.content,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: ColorConstants.greyColor2,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      width: 130,
                                      height: 130,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: ColorConstants.themeColor,
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, object, stackTrace) {
                                    return Material(
                                      child: Image.asset(
                                        'assets/no_image.jpg',
                                        width: 130,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    );
                                  },
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullImage(
                                      photo: messageChat.content,
                                    ),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(0))),
                            ),
                            margin: EdgeInsets.only(bottom: 2, right: 10),
                          ),
                          Container(
                            child: Text(
                              DateFormat('dd MMM kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(messageChat.timestamp))),
                              style: TextStyle(
                                  color: ColorConstants.greyColor,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic),
                            ),
                            margin: EdgeInsets.only(right: 10),
                          )
                        ],
                      ),
                      Material(
                        child: Image.network(
                          widget.arguments.my_account.photo,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: ColorConstants.themeColor,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 35,
                              color: ColorConstants.greyColor,
                            );
                          },
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ],
                  )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              messageChat.type == TypeMessage.text
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          child: Image.network(
                            widget.arguments.peerAvatar,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: ColorConstants.themeColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 35,
                                color: ColorConstants.greyColor,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                messageChat.content,
                                style: TextStyle(color: Colors.white),
                              ),
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              decoration: BoxDecoration(
                                  color: ColorConstants.primaryColor,
                                  borderRadius: BorderRadius.circular(8)),
                              margin: EdgeInsets.only(left: 10),
                            ),
                            Container(
                              child: Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(messageChat.timestamp))),
                                style: TextStyle(
                                    color: ColorConstants.greyColor,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic),
                              ),
                              margin:
                                  EdgeInsets.only(left: 10, top: 2, bottom: 5),
                            )
                          ],
                        )
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          child: Image.network(
                            widget.arguments.peerAvatar,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: ColorConstants.themeColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 35,
                                color: ColorConstants.greyColor,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: OutlinedButton(
                                child: Material(
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: ColorConstants.greyColor2,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 130,
                                        height: 130,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: ColorConstants.themeColor,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) {
                                      return Material(
                                        child: Image.asset(
                                          'assets/no_image.jpg',
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      );
                                    },
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullImage(
                                        photo: messageChat.content,
                                      ),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(0))),
                              ),
                              // padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              margin: EdgeInsets.only(left: 10),
                            ),
                            Container(
                              child: Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(messageChat.timestamp))),
                                style: TextStyle(
                                    color: ColorConstants.greyColor,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic),
                              ),
                              margin:
                                  EdgeInsets.only(left: 10, top: 2, bottom: 5),
                            )
                          ],
                        )
                      ],
                    )
              // isLastMessageLeft(index)
              //     ? Container(
              //         child: Text(
              //           DateFormat('dd MMM kk:mm').format(
              //               DateTime.fromMillisecondsSinceEpoch(
              //                   int.parse(messageChat.timestamp))),
              //           style: TextStyle(
              //               color: ColorConstants.greyColor,
              //               fontSize: 12,
              //               fontStyle: FontStyle.italic),
              //         ),
              //         margin: EdgeInsets.only(left: 50, top: 5, bottom: 5),
              //       )
              //     : SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
          ),
          //margin: EdgeInsets.only(bottom: 10),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null, 'stay': 'no'},
      );
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.widget.arguments.peerNickname,
        ),
        actions: [
          // FutureBuilder<Post>(
          //   future: homeProvider.getPostFromPostId(widget.arguments.post_id),
          //   builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
          //     if (snapshot.hasError) {
          //       return const Text("");
          //     }

          //     if (snapshot.connectionState == ConnectionState.done) {
          //       Post post = snapshot.data!;
          //       return post.status == "complete"
          //           ? Container()
          //           : post.user_id == widget.arguments.my_account.user_id
          //               ? GestureDetector(
          //                   onTap: () => exChange(),
          //                   child: Container(
          //                       margin: const EdgeInsets.all(10),
          //                       child: const Center(child: Text("แลกอุปกรณ์"))))
          //               : Container();
          //     }

          //     return const Text("");
          //   },
          // )
        ],
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // Container(
                  //     width: double.infinity,
                  //     decoration: const BoxDecoration(
                  //         border: Border(
                  //             top: BorderSide(
                  //                 color: ColorConstants.greyColor2,
                  //                 width: 0.5)),
                  //         color: Colors.white),
                  //     child: FutureBuilder<Post>(
                  //       future: homeProvider
                  //           .getPostFromPostId(widget.arguments.post_id),
                  //       builder: (BuildContext context,
                  //           AsyncSnapshot<Post> snapshot) {
                  //         if (snapshot.hasError) {
                  //           return const Text("");
                  //         }

                  //         if (snapshot.connectionState ==
                  //             ConnectionState.done) {
                  //           Post post = snapshot.data!;

                  //           return ListTile(
                  //             leading: Material(
                  //               borderRadius:
                  //                   const BorderRadius.all(Radius.circular(25)),
                  //               clipBehavior: Clip.hardEdge,
                  //               child: Image.network(
                  //                 post.photo,
                  //                 fit: BoxFit.cover,
                  //                 width: 50,
                  //                 height: 50,
                  //                 loadingBuilder: (BuildContext context,
                  //                     Widget child,
                  //                     ImageChunkEvent? loadingProgress) {
                  //                   if (loadingProgress == null) return child;
                  //                   return SizedBox(
                  //                     width: 50,
                  //                     height: 50,
                  //                     child: Center(
                  //                       child: CircularProgressIndicator(
                  //                         color: ColorConstants.themeColor,
                  //                         value: loadingProgress
                  //                                     .expectedTotalBytes !=
                  //                                 null
                  //                             ? loadingProgress
                  //                                     .cumulativeBytesLoaded /
                  //                                 loadingProgress
                  //                                     .expectedTotalBytes!
                  //                             : null,
                  //                       ),
                  //                     ),
                  //                   );
                  //                 },
                  //                 errorBuilder: (context, object, stackTrace) {
                  //                   return const Icon(
                  //                     Icons.account_circle,
                  //                     size: 50,
                  //                     color: ColorConstants.greyColor,
                  //                   );
                  //                 },
                  //               ),
                  //             ),
                  //             title: Text(
                  //               "อุปกรณ์ ${post.name}",
                  //               maxLines: 1,
                  //               style: const TextStyle(
                  //                   color: ColorConstants.primaryColor),
                  //             ),
                  //             subtitle: Stack(
                  //               children: [
                  //                 post.status == "complete"
                  //                     ? const Text(
                  //                         "อุปกรณ์ถูกแลกเปลี่ยนแล้ว",
                  //                         maxLines: 1,
                  //                         style: TextStyle(color: Colors.red),
                  //                       )
                  //                     : const Text(
                  //                         "ยังมีอุปกรณ์อยู่",
                  //                         maxLines: 1,
                  //                         style: TextStyle(color: Colors.green),
                  //                       )
                  //               ],
                  //             ),
                  //             trailing: const Icon(Icons.navigate_next),
                  //             selected: true,
                  //             onTap: () async {
                  //               bool like =
                  //                   await CloudFirestoreApi.checkFavorite(
                  //                       widget.arguments.post_id,
                  //                       widget.arguments.my_account.user_id);

                  //               // final post =
                  //               //     await CloudFirestoreApi.getPostFromPostId(
                  //               //         widget.arguments.post_id);

                  //               // ignore: use_build_context_synchronously
                  //               // Navigator.push(
                  //               //   context,
                  //               //   MaterialPageRoute(
                  //               //       builder: (context) => ItemDetail(
                  //               //             like: like,
                  //               //             post: post,
                  //               //             my_account:
                  //               //                 widget.arguments.my_account,
                  //               //           )),
                  //               // );
                  //             },
                  //           );
                  //         }

                  //         return const Text("");
                  //       },
                  //     )),
                  buildListMessage(),

                  // Sticker
                  // isShowSticker ? buildSticker() : SizedBox.shrink(),

                  // Input content
                  status == "complete" ? Container() : buildInput(),
                ],
              ),

              // Loading
              buildLoading()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? LoadingView() : SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      // ignore: sort_child_properties_last
      child: Row(
        children: [
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: getImage,
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, TypeMessage.text);
              },
              style: const TextStyle(
                  color: ColorConstants.primaryColor, fontSize: 15),
              controller: textEditingController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: ColorConstants.greyColor),
              ),
              focusNode: focusNode,
              autofocus: true,
            ),
          ),

          // Button send message
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () =>
                    onSendMessage(textEditingController.text, TypeMessage.text),
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.length > 0) {
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return Center(
                        child: Text("ยังไม่มีข้อความ...",
                            style: TextStyle(fontSize: 24)));
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.themeColor,
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
    );
  }
}

class ChatPageArguments {
  final UserModel my_account;
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  final String post_id;
  final String post_name;

  ChatPageArguments(
      {required this.my_account,
      required this.peerId,
      required this.peerAvatar,
      required this.peerNickname,
      required this.post_id,
      required this.post_name});
}
