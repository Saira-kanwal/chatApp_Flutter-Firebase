import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModels/chat_vm.dart';
import '../chatroom/chatroom.dart';
import '../sign_in/sign_in_screen.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String searchQuery = '';

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

  void handleSearch(String query){
    setState(() {
      searchQuery = query;
      print(searchQuery);
    });
  }
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        title: const Center(
          child: Text('Search', style: TextStyle(
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
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search User...",
                border: OutlineInputBorder()
              ),
              onChanged: handleSearch
            ),
          ),
          Expanded(child:
          StreamBuilder<QuerySnapshot>(
            stream: searchQuery.isEmpty ? const Stream.empty() : chatProvider.searchUsers(searchQuery),
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return const Center(child: CircularProgressIndicator(),);
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
            }))
        ],
      ),
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
    ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(name),
      subtitle: Text(email),
     onTap: ()async{
        final chatId = await chatProvider.getChatRoom(userId) ?? await chatProvider.createChatRoom(userId);
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(chatId: chatId, receiverId: userId)));
      },
    );











  }
}

