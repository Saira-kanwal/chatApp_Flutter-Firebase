import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel
{
  final String? uid;
  final String? name;
  final String? email;
  final String? imageUrl;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.imageUrl,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot)
  {
    return UserModel(
      uid: snapshot.id,
      name: snapshot.get("name"),
      email: snapshot.get("email"),
      imageUrl: snapshot.get("imageUrl"),
    );
  }


  toSnapshot()
  {
    return {
      "name" : name,
      "email" : email,
      "imageUrl" : imageUrl,
    };
  }
}