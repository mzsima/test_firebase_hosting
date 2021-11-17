import 'package:firebase_hosting_test/widgets/assessment.dart';
import 'package:firebase_hosting_test/widgets/current_user_box.dart';
import 'package:firebase_hosting_test/widgets/target_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssessmentDashboard extends StatefulWidget {
  const AssessmentDashboard({Key? key}) : super(key: key);

  @override
  _AssessmentDashboardState createState() => _AssessmentDashboardState();
}

class _AssessmentDashboardState extends State<AssessmentDashboard> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: Row(
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height,
            color: Colors.red,
            child: TargetList()),
        Column(children: [
          Container(
              alignment: Alignment.topRight,
              width: MediaQuery.of(context).size.width * 0.8,
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: CurrentUserBox(),
              )),
          Expanded(
            child: Assessment(),
          )
        ])
      ],
    ));
  }
}
