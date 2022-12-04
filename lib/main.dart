import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /*
  final CollectionReference _contatos =
    FirebaseFirestore.instance.collection("contatos");
  _contatos.add({"nome": 'Maria', "cpf": "4444",
   "fone" : "4444"});
  print("criando documento para coleção contatos");

  QuerySnapshot snapshot = await _contatos.get();
  snapshot.docs.forEach((element) {
    print(element.data().toString());
  });
   */
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NavigationOptions(),
    );
  }
}
