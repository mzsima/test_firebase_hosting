import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get allCombination =>
      _firestore.collection("member_combination");

  CollectionReference get allAssessment =>
      _firestore.collection("assessment_result");

  Future<void> createAssessment(
      double value, String target, String respondent) async {
    _firestore.collection("assessment_result").add({
      "target": target,
      "respondent": respondent,
      "value": value,
    });
    return;
  }

  Future<void> updateAssessment(String assessmentId, double value) async {
    _firestore.collection("assessment_result").doc(assessmentId).update({
      "value": value,
    });
    return;
  }
}

final databaseProvider = Provider((_) => Database());
