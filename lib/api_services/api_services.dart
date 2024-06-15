import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat/model/chat_user.dart';
import 'package:chat/model/message_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class ApiServices {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  static late ChatUserModal me;

//for accessing firebase message(push notification)
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static get http => null;

  static Future<void> sendPushNotification(
    ChatUserModal chatUserModal,
    String msg,
  ) async {
    try {
      final body = {
        "to": chatUserModal.pushToken,
        "notification": {
          "title": chatUserModal.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some data": "USER ID: ${me.id}",
        }
      };
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var response = await post(
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              "key=AAAAH9wehTU:APA91bG_wIZd9Sym3dbdeQWykbuYs66TGWrVeJr0UcS-2LDfSfcTPokCVoUcBEMHUgYQIEvGICYVOHYTI5zCTr-6vvWYtNDWIjDgyb9vbdRHwkUhzaugYcaenhpg0DspE75upZXk87O6"
        },
        url,
        body: jsonEncode(body),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log(" error on sendPushNotification : $e");
    }
  }

  static Future<void> getFirebaseMessageToken() async {
    await messaging.requestPermission();
    await messaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
      }
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

//for checking if the user exist or not
  static Future<bool> userExist() async {
    return (await fireStore.collection('users').doc(user.uid).get()).exists;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await fireStore.collection('users').doc(user.uid).get().then((value) async {
      if (value.exists) {
        me = ChatUserModal.fromJson(value.data()!);
        getFirebaseMessageToken();
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUserModal(
        image: user.photoURL.toString(),
        about: "user.about",
        name: user.displayName.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        id: user.uid,
        pushToken: '',
        email: user.email.toString());
    return await fireStore.collection('users').doc(user.uid).set(
          chatUser.toJson(),
        );
  }

//for getting all users from firestore firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllusers() {
    return fireStore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

//for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsersInfo(
      ChatUserModal chatUserModal) {
    return fireStore
        .collection('users')
        .where('id', isEqualTo: chatUserModal.id)
        .snapshots();
  }

  //update online or last active status of users
  static Future<void> updateActiveStatus(bool isOnline) async {
    fireStore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

//for checking if the user exist or not
  static Future<void> updateUserInfo() async {
    await fireStore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // update profile picture
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child("profile_picture/${user.uid}.$ext");
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      log("Data transfered: ${p0.bytesTransferred / 1000} kb");
    });
    me.image = await ref.getDownloadURL();
    await fireStore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specific conversation from firestore firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMesssages(
      ChatUserModal user) {
    return fireStore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('dlvryTime', descending: true)
        .snapshots();
  }

  static Future<void> sendMessages(
      ChatUserModal chatUserModal, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final MessageModal message = MessageModal(
        toId: chatUserModal.id,
        dlvryTime: time,
        frId: user.uid,
        message: msg,
        type: type);
    final ref = fireStore
        .collection('chats/${getConversationId(chatUserModal.id)}/messages/');
    ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUserModal, type == Type.text ? msg : 'image'));
  }

  static Future<void> updateMessageReadStatus(MessageModal messageModal) async {
    fireStore
        .collection('chats/${getConversationId(messageModal.frId)}/messages/')
        .doc(messageModal.dlvryTime)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUserModal user) {
    return fireStore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('dlvryTime', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendImage(ChatUserModal chatUserModal, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        "image/${getConversationId(chatUserModal.id)}/${chatUserModal.id}/${DateTime.now().millisecondsSinceEpoch}.$ext");
    await ref
        .putFile(
      file,
      SettableMetadata(contentType: "image/$ext"),
    )
        .then((p0) {
      log("Data transfered: ${p0.bytesTransferred / 1000} kb");
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessages(
      chatUserModal,
      imageUrl,
      Type.image,
    );
  }

  static Future<void> sendVideo(ChatUserModal chatUserModal, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        "video/${getConversationId(chatUserModal.id)}/${chatUserModal.id}/${DateTime.now().millisecondsSinceEpoch}.$ext");
    await ref
        .putFile(
      file,
      SettableMetadata(contentType: "video/$ext"),
    )
        .then((p0) {
      log("Data transfered: ${p0.bytesTransferred / 1000} kb");
    });
    final videoUrl = await ref.getDownloadURL();
    await sendMessages(
      chatUserModal,
      videoUrl,
      Type.video,
    );
  }

  static Future<void> deleteMessage(MessageModal messageModal) async {
    await fireStore
        .collection('chats/${getConversationId(messageModal.toId)}/messages/')
        .doc(messageModal.dlvryTime)
        .delete();

    //for deleting images from the storage
    if (messageModal.type == Type.image) {
      await storage.ref(messageModal.message).delete();
    }
  }

  static Future<void> updateMessage(
      MessageModal messageModal, String updateMessage) async {
    await fireStore
        .collection('chats/${getConversationId(messageModal.toId)}/messages/')
        .doc(messageModal.dlvryTime)
        .update({"message": updateMessage});
  }
}
