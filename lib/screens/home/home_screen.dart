import 'package:chat_pp/screens/search/search_screen.dart';
import 'package:chat_pp/viewModels/chat_vm.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../chatroom/chatroom.dart';
import '../sign_in/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data();
    final users = chatData!['users'] as List<dynamic>;
    final receiverId = users.firstWhere((id) => id != loggedInUser!.uid);
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();
    final userData = userDoc.data()!;
    return {
      'chatId': chatId,
      'lastMessage': chatData['lastMessage'] ?? '',
      'timestamp': chatData['timestamp']?.toDate() ?? DateTime.now(),
      'userData': userData,
    };
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatViewModel>(context);
    return PopScope(
        canPop: false,
        child: Scaffold(
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
              child: Text("Let's Chat", style: TextStyle(
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
              Expanded(
                  child: loggedInUser == null
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder(
                      stream: chatProvider.getChats(loggedInUser!.uid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final chatDocs = snapshot.data!.docs;
                        return FutureBuilder<List<Map<String, dynamic>>>(
                            future: Future.wait(chatDocs
                                .map((chatDoc) => _fetchChatData(chatDoc.id))),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final chatDataList = snapshot.data!;
                              return ListView.builder(
                                  itemCount: chatDataList.length,
                                  itemBuilder: (context, index) {
                                    final chatData = chatDataList[index];
                                    return ChatTile(
                                        chatId: chatData['chatId'],
                                        lastMessage: chatData['lastMessage'],
                                        timestamp: chatData['timestamp'],
                                        receiverData: chatData['userData']);
                                  });
                            });
                      }))
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const SearchScreen()));
            }, child: const Icon(Icons.search),),
        )
    );
  }
}

class ChatTile extends StatelessWidget {
  final String chatId;
  final String lastMessage;
  final DateTime timestamp;
  final Map<String, dynamic> receiverData;
  const ChatTile({super.key,
    required this.chatId,
    required this.lastMessage,
    required this.timestamp,
    required this.receiverData});

  @override
  Widget build(BuildContext context) {
    return lastMessage != ""? ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(receiverData['imageUrl']),
      ),
      title: Text(
        receiverData['name'],
      ),
      subtitle: Text(lastMessage, maxLines: 2,),
      trailing: Text(
        '${DateTime.timestamp().hour}:${DateTime.timestamp().minute}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      onTap: ()  {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(
            chatId: chatId, receiverId: receiverData['id'])));

      },
    ): Container();
  }
}
