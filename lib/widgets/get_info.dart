
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetInfo extends StatelessWidget {
  const GetInfo({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(child:
    StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('diaries').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return ListTile(
              title: Text(document.get('display_name')),
              subtitle: Text(document.get('profession')),
            );
          }).toList(),
        );
      },
    )
    );
  }
}