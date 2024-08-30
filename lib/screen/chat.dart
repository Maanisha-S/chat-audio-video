import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashchat/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';


class ChatScreen extends StatefulWidget {

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _fireStore = FirebaseFirestore.instance;
  late User LoggedInUser;
  File? _image;

  final imagePicker = ImagePicker();
  String? downloadURL;
  var pick;

  Future imagePickerMethod() async {
    pick = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pick != null) {
        _image = File(pick.path);
        uploadImage();
      } else {
        debugPrint('failed');
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    Reference ref =
    FirebaseStorage.instance.ref().child("/images").child("$fileName.jpg");
    await ref.putFile(_image!);
    downloadURL = await ref.getDownloadURL();
    print(downloadURL);
    await _fireStore.collection('messages').add({
      'sender': LoggedInUser.email,
      'url': downloadURL,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  late String messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          LoggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.call,color: Colors.white,),
              onPressed: () {
               Navigator.pushNamed(context, ChattingAppRoutes.audioRoute);
              }),
          IconButton(
              icon: const Icon(Icons.video_call,color: Colors.white,),
              onPressed: () {
                Navigator.pushNamed(context, ChattingAppRoutes.videoRoute);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(loggedInUser: LoggedInUser),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        setState(() {
                          messageText = value;
                        });
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),

                  ),
                  InkWell(
                    onTap: () {
                      imagePickerMethod();
                    },
                    child: Image.asset(
                      'images/pic.png',
                      height: 28.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (messageText.trim().isNotEmpty) {
                        _fireStore.collection('messages').add({
                          'text': messageText,
                          'sender': LoggedInUser.email,
                          'timestamp': FieldValue.serverTimestamp(),
                        }).then((_) {
                          messageTextController.clear();
                          setState(() {
                            messageText = ''; // Clear the messageText variable
                          });
                        }).catchError((error) {
                          print('Failed to add message: $error');
                        });
                      } else {
                        print('Message text is empty');
                      }
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final User loggedInUser;
  MessagesStream({required this.loggedInUser});

  final _fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs;
        return Expanded(
          child: ListView.builder(
            reverse: true,
            padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            itemCount: messages.length,
            itemBuilder: (context, position) {
              final messageText = messages[position].data()['text'];
              final messageSender = messages[position].data()['sender'];
              final messageImage = messages[position].data()['url'];
              final currentUser = loggedInUser.email;
              return MessageBubble(
                sender: messageSender,
                text: messageText ?? '',
                imageUrl: messageImage ?? '',
                isMe: currentUser == messageSender,
              );
            },
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.imageUrl,
  });

  final String sender;
  final String text;
  final bool isMe;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                topRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Column(
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 200,
                    width: 200,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
