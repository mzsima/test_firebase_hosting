
import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_hosting_test/model/user.dart';
import 'package:firebase_hosting_test/screens/login_page.dart';
import 'package:firebase_hosting_test/widgets/update_user_profile_dialog.dart';
import 'package:flutter/material.dart';

class CreateProfile extends StatelessWidget {
  const CreateProfile({
    Key? key,
    required this.curUser,
  }) : super(key: key);

  final MUser curUser;

  @override
  Widget build(BuildContext context) {
    final _avatarUrlTextController = TextEditingController(text: curUser.avatarUrl);
    final _displayNameTextController = TextEditingController(text: curUser.displayName);

    return Container(
      width: 160,
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: 
            [
              const Spacer(),
              InkWell(
                child: CircleAvatar(
                  backgroundColor: Color(0xffE6E6E6),
                  radius: 16,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Color(0xffCCCCCC),
                  )
                ),
                onTap: () {
                  showDialog(context: context, builder: (context) {
                    return UpdateUserProfileDialog(curUser: curUser, avatarUrlTextController: _avatarUrlTextController, displayNameTextController: _displayNameTextController);
                  });
                },
              ),
              Text(curUser.displayName!, 
                style: const TextStyle(color: Colors.grey),),
              const Spacer()
            ],
          ),
          IconButton(
            onPressed:() {
              FirebaseAuth.instance.signOut().then((value) {
                return Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              });
            }, 
            icon: const Icon(Icons.logout, size: 30,), color:Colors.grey)
        ],
      )
    );
  }
}

