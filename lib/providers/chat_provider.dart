import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:baeng_bao/constants/firestore_constants.dart';
import 'package:baeng_bao/model/chat_link.dart';
import 'package:baeng_bao/model/message_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child("Chat/$fileName");
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Future addChatLink(String user_id, String post_id, String sender_id) async {
    late String chat_link_id1 = '', chat_link_id2 = '';
    final refUsers1 = firebaseFirestore
        .collection('chatLink')
        .where(
          'receiver_id',
          isEqualTo: user_id,
        )
        .where(
          'sender_id',
          isEqualTo: sender_id,
        )
        .where('post_id', isEqualTo: post_id);

    final refUsers2 = firebaseFirestore
        .collection('chatLink')
        .where(
          'receiver_id',
          isEqualTo: sender_id,
        )
        .where(
          'sender_id',
          isEqualTo: user_id,
        )
        .where('post_id', isEqualTo: post_id);

    final getChatLink1 = await refUsers1.get();
    final getChatLink2 = await refUsers2.get();
    if (getChatLink1.size == 0 && getChatLink2.size == 0) {
      final doc = firebaseFirestore.collection('chatLink').doc();
      final listUser = [];
      listUser.add(user_id);
      listUser.add(sender_id);
      await doc.set({
        'day': '',
        'id': doc.id,
        'message': '',
        'post_id': post_id,
        'receiver_id': user_id,
        'sender_id': sender_id,
        'status': "talking",
        'time': '',
        'type': 'text',
        'user': listUser,
        'dateTime': DateTime.now(),
      }).whenComplete(() => print('ChatLink Created'));
      return doc.id;
    } else {
      await refUsers1.get().then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          chat_link_id1 = result.data()['id'];
        });
      });
      await refUsers2.get().then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          chat_link_id2 = result.data()['id'];
        });
      });

      String id = '$chat_link_id1 $chat_link_id2'.trim();
      return id;
    }
  }

  Future<void> updateAllseen(
      String groupChatId, String chatLinkId, String user_id) async {
    firebaseFirestore
        .collection('messages/$groupChatId/$groupChatId')
        .where('idTo', isEqualTo: user_id)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'seen': 'yes'});
      }
    });

    firebaseFirestore
        .collection('chatLink')
        .doc(chatLinkId)
        .update({'unseen': 0});
  }

  Future<int> getCountSeen(String groupChatId, String user_id) async {
    final ref = await firebaseFirestore
        .collection('messages/$groupChatId/$groupChatId')
        .where('idTo', isEqualTo: user_id)
        .where('seen', isEqualTo: 'no')
        .get();

    return ref.size + 1;
  }

  Future<String> getStatusChatLinkFromId(String id) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('chatLink')
        .where('id', isEqualTo: id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        data = result.data()['status'];
      });
    });
    return data!;
  }

  static Future<bool> checkChatLink(int chatLinkLength, String user_id) async {
    int count = 0;
    await FirebaseFirestore.instance
        .collection('chatLink')
        .where('user', arrayContains: user_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        final day = result.data()['day'];

        if (day == '') {
          count++;
        }
      });
    });

    if (count == chatLinkLength) {
      return false;
    } else {
      return true;
    }
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId, String seen) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      seen: seen,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
