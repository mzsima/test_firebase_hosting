import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_hosting_test/services/database.dart';
import 'package:firebase_hosting_test/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TargetList extends ConsumerWidget {
  const TargetList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);
    final currentUser = ref.watch(currentUserProvider);
    final target = ref.watch(targetProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "評価対象者",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.amber,
            child: StreamBuilder<QuerySnapshot>(
                stream: database.allCombination
                    .where("respondent", arrayContains: currentUser.state)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, i) {
                          return ListTile(
                              title: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              primary: Colors.black,
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              target.state =
                                  snapshot.data!.docs[i].get("target_id");
                            },
                            child:
                                Text(snapshot.data!.docs[i].get("target_id")),
                          ));
                        });
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  }
                  return Text("");
                }),
          )
        ],
      ),
    );
  }
}
