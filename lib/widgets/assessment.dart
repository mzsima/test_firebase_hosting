import 'package:firebase_hosting_test/services/database.dart';
import 'package:firebase_hosting_test/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Assessment extends ConsumerStatefulWidget {
  const Assessment({Key? key}) : super(key: key);

  @override
  ConsumerState<Assessment> createState() => _AssessmentState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _AssessmentState extends ConsumerState<Assessment> {
  double _currentSliderValue = 50;
  double _initValue = -1;
  String _target = "";

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(targetProvider);
    final database = ref.read(databaseProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (_target != target.state) {
      _initValue = -1;
      _currentSliderValue = 0;
    }
    _target = target.state.isNotEmpty ? target.state : "選択してください";

    final _assessment = database.allAssessment
        .where("target", isEqualTo: target.state)
        .where("respondent", isEqualTo: currentUser.state);

    _assessment.get().then((value) {
      if (_initValue < 0) {
        setState(() {
          if (value.docs.isNotEmpty) {
            _initValue = value.docs[0].get("value");
          } else {
            _initValue = 0;
          }
        });
      }
    });

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('対象者：${_target}'),
      ),
      if (target.state.isNotEmpty) Text('現在：${_initValue} pt'),
      if (target.state.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(48.0),
          child: Slider(
            value: _currentSliderValue,
            min: 0,
            max: 100,
            divisions: 5,
            label: _currentSliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
          ),
        ),
      if (target.state.isNotEmpty)
        ElevatedButton(
            child: Text("回答する"),
            onPressed: () {
              _assessment.get().then((value) {
                if (value.docs.isNotEmpty) {
                  database.updateAssessment(
                      value.docs[0].id, _currentSliderValue);
                } else {
                  database.createAssessment(
                      _currentSliderValue, target.state, currentUser.state);
                }
                setState(() {
                  _initValue = -1;
                });
              });
            }),
    ]);
  }
}
