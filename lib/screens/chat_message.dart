import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget{
  ChatMessage(this.data, this.mine);
  //mine = true se usuário que está logado
  final DocumentSnapshot<Object?> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    print(data.get('senderPhotoUrl'));
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical:  10,
          horizontal: 10
      ),
      child: Row(
        children: <Widget>[
          //primeira coluna
          !mine  ?
          Padding(padding: const EdgeInsets.only( right:  16),
              child: CircleAvatar(
                backgroundImage: Image.network(data.get('senderPhotoUrl')).image,
              )):
          Container(),
          // segunda coluna
          Expanded(child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.end :
            CrossAxisAlignment.start,
            children: <Widget>[
              data.get('url') != ""
                  ? Image.network(data.get('url'),
                  width: 150) :
              Text(data.get('text'),
                style: TextStyle(fontSize: 16),),
              Text(data.get('senderName'),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                  )),
            ],
          ),

          ),
          ///terceira coluna
          mine  ?
          Padding(padding: const EdgeInsets.only( left:  16),
              child: CircleAvatar(
                backgroundImage: Image.network(data.get('senderPhotoUrl')).image,
              )):
          Container(),
        ],
      ),
    );
  }


}