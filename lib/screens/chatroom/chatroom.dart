import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import '../../viewModels/chat_vm.dart';


class ChatScreen extends StatefulWidget {
  // static String routeName = "/chatroom";
  final String? chatId;
  final String receiverId;
  const ChatScreen({super.key, required this.chatId, required this.receiverId});



  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  User? loggedInUser;
  String? chatId;

  @override
  void initState() {
    super.initState();
    chatId =widget.chatId;
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



  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatViewModel>(context);
    final TextEditingController _textController = TextEditingController();

    return FutureBuilder<DocumentSnapshot>(
        future: _fireStore.collection('users').doc(widget.receiverId).get(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            final receiverData = snapshot.data!.data() as Map<String, dynamic>;
            return Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(receiverData['imageUrl']),
                    ),
                    const SizedBox(width: 10,),
                    Text(receiverData['name'],style: const TextStyle(fontSize:20, fontWeight: FontWeight.w500),)
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                      child: chatId!= null && chatId!.isNotEmpty
                          ? MessageStream(chatId: chatId!)
                          : const Center(child: Text("No Messages Yet"),)

                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                    child: Row(
                      children: [
                        IconButton(onPressed: () => chatProvider.getImage(chatId!,widget.receiverId),
                            icon: const Icon(Icons.camera_alt_outlined,color: Colors.purple,size: 35,)),
                        Expanded(child: TextFormField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your messages...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        )),

                        IconButton(onPressed: ()async{
                          if(_textController.text.isNotEmpty){
                            if(chatId == null || chatId!.isEmpty){
                              chatId = await chatProvider.createChatRoom(widget.receiverId);
                            }
                            if(chatId != null){
                              chatProvider.sendMessage(
                                  chatId!,
                                  _textController.text,
                                  widget.receiverId);
                              _textController.clear();
                            }
                          }
                        },
                            icon: const Icon(Icons.send,color: Colors.purple,size: 35,))
                      ],
                    ),
                  )
                ],
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(

            ),
            body: const Center(child: CircularProgressIndicator(),),
          );
        }
    );
  }
}

class MessageStream extends StatelessWidget {
  final String chatId;
  const MessageStream({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').doc(chatId).
        collection('messages').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator(),);
          }
          if (kDebugMode) {
            print(snapshot.data!.docs);
          }
          final messages = snapshot.data!.docs;
          List<MessageBubble> messageWidgets = [];
          for(var message in messages){
            final messageData = message.data() as Map<String, dynamic>;
            final messageText = messageData['messagesBody'];
            final messageSender = messageData['senderId'];
            final type = messageData['type'];
            final timestamp = messageData['timestamp'] ?? FieldValue.serverTimestamp();

            final currentUser = FirebaseAuth.instance.currentUser!.uid;
            final messageWidget = MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender,
                timestamp: timestamp,
                type: type,
            );
            messageWidgets.add(messageWidget);
          }
          return ListView(
            reverse: true,
            children: messageWidgets,
          );
        }
    );
  }
}


class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String type;
  final bool isMe;
  final dynamic timestamp;
  const MessageBubble({super.key, required this.sender, required this.text, required this.isMe, this.timestamp, required this.type});

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    return  Padding(padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          type == 'text' ?
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration:  BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                  blurRadius: 4,
                )
              ],
              borderRadius: isMe ? const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
              ) : const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              color: isMe ? Colors.purple : Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: Column(
                children: [
                  Text(text,
                    style:  TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16
                    ),)
                ],
              ),
            ),
            )
              : Container(
            height: 200,
            width: 200,
            alignment: Alignment.center,
              child: text != ''? Image.network(
                  text,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    }
                  },
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Image.asset('assets/images/placeholder.webp'); // Path to your placeholder image
                  }
                    ) : const CircularProgressIndicator(),
          ),
          Text('${DateTime.timestamp().hour}:${DateTime.timestamp().minute}',style: const TextStyle(color: Colors.grey,fontSize: 12),)
          ],
      ),);
  }
}












