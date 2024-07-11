import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../viewModels/chat_vm.dart';
import '../chatroom/chatroom.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../search/search_screen.dart';
import '../sign_in/sign_in_screen.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});


  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Center(
          child: Text('Lets Chat', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white
        ),),),
        actions: [
          IconButton(
              onPressed: () {
                _auth.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const SignInScreen()));
              },
              icon: const Icon(Icons.logout,color: Colors.white,))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          final users = snapshot.data!.docs;
          List<UserTile> userWidgets = [];
          for(var user in users){
            final userData = user.data() as Map<String, dynamic>;
            if(userData['id'] != loggedInUser!.uid){
              final userWidget = UserTile(
                userId: userData['id'],
                name: userData['name'],
                email: userData['email'],
                imageUrl: userData['imageUrl'],
              ); userWidgets.add(userWidget);
            }
          }
          return ListView(
            children: userWidgets,
          );
        },
      ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const SearchScreen()));
                    }, child: const Icon(Icons.search),),
        );
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;
  const UserTile({super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatViewModel>(context, listen:false);
    return
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),

        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(name),
          subtitle: Text(email),
          onTap: ()async{
            final chatId = await chatProvider.getChatRoom(userId) ?? await chatProvider.createChatRoom(userId);
            await Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(chatId: chatId, receiverId: userId)));
          },
        ),
      );











  }
}