import 'package:firebase_hosting_test/model/user.dart';
import 'package:firebase_hosting_test/services/service.dart';
import 'package:flutter/material.dart';

class UpdateUserProfileDialog extends StatelessWidget {
  const UpdateUserProfileDialog({
    Key? key,
    required this.curUser,
    required TextEditingController avatarUrlTextController,
    required TextEditingController displayNameTextController,
  }) : _avatarUrlTextController = avatarUrlTextController, _displayNameTextController = displayNameTextController, super(key: key);

  final MUser curUser;
  final TextEditingController _avatarUrlTextController;
  final TextEditingController _displayNameTextController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Editing ${curUser.displayName}',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _avatarUrlTextController,
                    ),
                    TextFormField(
                      controller: _displayNameTextController,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.green,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            side: BorderSide(color: Colors.green, width: 1)
                          )
                        ),
                        onPressed: () {
                          MService().update(curUser, _displayNameTextController.text, _avatarUrlTextController.text, context);
                          Future.delayed(
                            Duration(milliseconds: 200), 
                          ).then((value) {
                             return Navigator.of(context).pop();
                          });
                        }, 
                        child: const Text('Update'),
                      ),
                    )
                  ],
                )
              )
            )
          ],
        ),
        ),
    );
  }
}