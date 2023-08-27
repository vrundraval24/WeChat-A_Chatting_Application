import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_chat_app/models/chat_user.dart';
import 'package:we_chat_app/models/message.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  // To return current user... it is a method that we call using (user) and it returns (auth.currentUser!)
  static User get user => auth.currentUser!;

  // For storing current user self info
  static late ChatUser me;

  // Check if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // Get current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // Create a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: "Hey! I'm using WeChat.",
        createdAt: time,
        isOnline: false,
        lastActive: time,
        id: user.uid,
        pushToken: '',
        email: user.email.toString());

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // For getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // Update user information
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePic(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transferred: ${p0.bytesTransferred / 1000} kb');
    });

    me.image = await ref.getDownloadURL();

    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // --------------------- Chat screen related APIs ---------------------

  // Useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // For getting all messages from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages')
        .snapshots();
  }

  // For sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    // Message sending time also used as doc id
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: Type.text,
        fromId: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson());

    // .then((val) {
    // updateMessageReadStatus(message);
    // });
  }

  // To check if user have read msg
  static Future<void> updateMessageReadStatus(Message msg) async {
    firestore
        .collection('chats/${getConversationId(msg.fromId)}/messages')
        .doc(msg.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
    // log("message read updated");
    // log(jsonEncode(firestore.collection('chats/${getConversationId(msg.fromId)}/messages').doc(msg.sent).get()));
  }

  // Get only last message of specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
