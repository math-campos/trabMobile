import 'package:chat20222/screens/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'text_composer.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen>{
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffolddKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  final CollectionReference _mensagens = FirebaseFirestore.instance
      .collection("mensagens");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text(_currentUser != null ?
        'Olá , ${_currentUser?.displayName}'
            : "Chat App"),
        actions:<Widget>[
          _currentUser != null ?
          IconButton(
              onPressed: (){
                FirebaseAuth.instance.signOut();
                googleSignIn.signOut();
                _scaffolddKey.currentState?.showSnackBar(
                    SnackBar(content: Text("Logout"))
                );
              },
              icon: Icon(Icons.exit_to_app))
              : Container()
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream : _mensagens.orderBy('time').snapshots(),
              builder: (context, snapshot){
                switch (snapshot.connectionState){
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<DocumentSnapshot> documents =
                    snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                        itemCount: documents.length,
                        reverse : true,
                        itemBuilder: (context, index){
                          return ChatMessage(documents[index],
                              documents[index].get("uid") == _currentUser?.uid);
                        });
                }
              }
          ),
        ),
        _isLoading ? LinearProgressIndicator() : Container(),
        TextComposer(_sendMessage),
      ],),
    );
  }

  void _sendMessage({String? text, XFile? imgFile}) async{
    final CollectionReference _mensagens =
    FirebaseFirestore.instance.collection("mensagens");
    User? user = await _getUser(context: context);

    if (user == null){
      const snackBar = SnackBar(
          content: Text("Não foi possível fazer login"),
          backgroundColor:  Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    Map<String, dynamic> data = {
      'time' : Timestamp.now(),
      'url'  : "",
      'uid'  : user?.uid != null ? user?.uid  : "",
      'senderName' : user?.displayName != null ? user?.displayName : "",
      'senderPhotoUrl' : user?.photoURL  != null ? user?.photoURL : ""
    };

    if (imgFile != null){
      setState(() {
        _isLoading = true;
      });
      firebase_storage.UploadTask uploadTask;
      firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child("imgs")
          .child(DateTime.now().millisecondsSinceEpoch.toString());
      final metadados = firebase_storage.SettableMetadata(
          contentType: "image/jpeg",
          customMetadata: {"picked-file-path" : imgFile.path}
      );
      if (kIsWeb){
        uploadTask = ref.putData(await imgFile.readAsBytes(), metadados);
      }else{
        uploadTask = ref.putFile(File(imgFile.path));
      }
      var taskSnapshot = await uploadTask;
      String imageUrl  = "";
      imageUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _isLoading = false;
      });
      data["url"] = imageUrl;
      print("url: "+ imageUrl);
    }else{
      data["text"] = text;
    }
    _mensagens.add(data);
    print(" dado enviado para o Firestore");

  }

  Future<User?> _getUser({required BuildContext context}) async{
    User? user;
    if (_currentUser != null)
      return _currentUser;

    if (kIsWeb){
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try{
        final UserCredential userCredential =
        await auth.signInWithPopup(authProvider);
        user = userCredential.user;
      }catch (e){
        print(e);
      }
    }else{
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();
      if (googleSignInAccount != null){
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        try {
          final UserCredential userCredential =
          await auth.signInWithCredential(credential);
          user = userCredential.user;
        } on FirebaseAuthException catch (e){
          print(e);
        }catch (e){
          print(e);
        }
      }
    }
    return user;
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user){
      setState(() {
        _currentUser = user;
      });
    });
  }
}