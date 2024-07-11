import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class ChatViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  File? imageFile;

  Stream<QuerySnapshot> getChats(String userId){
    return _fireStore
        .collection('chats')
        .where('user', arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> searchUsers(String query){
    return _fireStore
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String message, String receiverId) async{
    final currentUser = _auth.currentUser;

    if(currentUser!=null){
      await _fireStore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'messagesBody': message,
        'type': 'text',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _fireStore.collection('chats').doc(chatId).set({
        'user': [currentUser.uid,receiverId],
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
      },SetOptions(merge: true));
    }
  }

  Future getImage(String chatId, String receiverId) async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage(chatId, receiverId);
      }
    });
  }

  Future uploadImage(String chatId, String receiverId) async {
    String fileName = Uuid().v1();
    int status = 1;

    await _fireStore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(fileName)
        .set({
      'senderId': _auth.currentUser!.uid,
      'messagesBody': 'Loading...',
      'type': "img",
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    var ref =
    FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _fireStore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _fireStore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(fileName)
          .update({"messagesBody": imageUrl});

      print(imageUrl);
    }
  }

  Future<String?> getChatRoom(String receiverId) async {
    final currentUser = _auth.currentUser;

    if(currentUser != null){
      final chatQuery = await _fireStore
          .collection('chats')
          .where('user', arrayContains: currentUser.uid)
          .get();
      //todo
      final chats = chatQuery.docs.where((chat) => chat['users'].contains(receiverId)).toList();

      if(chats.isNotEmpty){
        return chats.first.id;
      }
    }
    return null;
  }

  Future<String> createChatRoom(String receiverId) async{
    final currentUser = _auth.currentUser;

    if(currentUser != null){
      final chatRoom = await _fireStore.collection('chats').add({
        'users': [currentUser.uid, receiverId],
        'lastMessage': '',
        'timestamp' : FieldValue.serverTimestamp(),
      });
      return chatRoom.id;
    }
    throw Exception('current user is null');
  }

}


























