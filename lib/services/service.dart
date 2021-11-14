import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_hosting_test/model/diary.dart';
import 'package:firebase_hosting_test/model/user.dart';
import 'package:flutter/material.dart';

class MService {
  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference diaryCollectionReference =
      FirebaseFirestore.instance.collection('diaries');

  Future<UserCredential> loginUser(String email, String password) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUser(
      String displayName, BuildContext context, String uid) async {
    MUser user = MUser(
        avatarUrl: 'https://picsum.photos/200/300',
        displayName: displayName,
        uid: uid);
    userCollectionReference.add(user.toMap());
    return;
  }

  Future<void> update(MUser user, String displayName, String avatarUrl,
      BuildContext context) async {
    MUser updateUser =
        MUser(displayName: displayName, avatarUrl: avatarUrl, uid: user.uid);
    userCollectionReference.doc(user.id).update(updateUser.toMap());
    return;
  }

  Future<List<Diary>> getSameDateDiaries(DateTime first, String userId) {
    return diaryCollectionReference
        .where('entry_time',
            isGreaterThanOrEqualTo: Timestamp.fromDate(first).toDate())
        .where('entry_time',
            isLessThan:
                Timestamp.fromDate(first.add(Duration(days: 1))).toDate())
        .where('user_id', isEqualTo: userId)
        .get()
        .then((value) {
      return value.docs.map((diary) {
        return Diary.fromDocument(diary);
      }).toList();
    });
  }

  getLatestDiaries(String uid) {
    return diaryCollectionReference
        .where('user_id', isEqualTo: uid)
        .orderBy('entry_time', descending: true)
        .get()
        .then((value) {
      return value.docs.map((diary) {
        return Diary.fromDocument(diary);
      });
    });
  }

  getEarliestDiaries(String uid) {
    return diaryCollectionReference
        .where('user_id', isEqualTo: uid)
        .orderBy('entry_time', descending: false)
        .get()
        .then((value) {
      return value.docs.map((diary) {
        return Diary.fromDocument(diary);
      });
    });
  }
}
