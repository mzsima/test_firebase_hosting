import 'package:firebase_hosting_test/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentUserBox extends ConsumerStatefulWidget {
  const CurrentUserBox({Key? key}) : super(key: key);

  @override
  _CurrentUserBoxState createState() => _CurrentUserBoxState();
}

class _CurrentUserBoxState extends ConsumerState<CurrentUserBox> {
  String _currentUser = "member_id_A";

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider.notifier);

    return DropdownButton<String>(
      value: _currentUser,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          _currentUser = newValue!;
        });
        currentUser.state = _currentUser;
      },
      items: <String>['member_id_A', 'member_id_B', 'member_id_C']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
