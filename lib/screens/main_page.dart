import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_hosting_test/model/diary.dart';
import 'package:firebase_hosting_test/model/user.dart';
import 'package:firebase_hosting_test/services/service.dart';
import 'package:firebase_hosting_test/widgets/create_profile.dart';
import 'package:firebase_hosting_test/widgets/diary_list_view.dart';
import 'package:firebase_hosting_test/widgets/write_diary_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? _dropDownText;
  DateTime selectedDate = DateTime.now();
  var userDiaryFilteredEntriesList;
  var latestFilteredDiariesStream;
  var earliestFilteredDiariesStream;

  @override
  Widget build(BuildContext context) {
    final _titleTextController = TextEditingController();
    final _descriptionTextController = TextEditingController();
    var _listOfDiaries = Provider.of<List<Diary>>(context);
    var _user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        toolbarHeight: 80,
        elevation: 1,
        title: Row(children: [
          Text(
            'YARIKIRI β',
            style: TextStyle(fontSize: 40, color: Colors.blueAccent[400]),
          )
        ]),
        actions: [
          Row(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    items: <String>['Latest', 'Earliest'].map((String val) {
                      return DropdownMenuItem<String>(
                          value: val, child: Text(val));
                    }).toList(),
                    hint: _dropDownText == null
                        ? const Text('Select')
                        : Text(_dropDownText!),
                    onChanged: (value) {
                      if (value == 'Latest') {
                        setState(() {
                          _dropDownText = value;
                        });
                        _listOfDiaries.clear();
                        latestFilteredDiariesStream =
                            MService().getLatestDiaries(_user!.uid);
                        latestFilteredDiariesStream.then((value) {
                          for (var item in value) {
                            setState(() {
                              _listOfDiaries.add(item);
                            });
                          }
                        });
                      } else if (value == 'Earliest') {
                        setState(() {
                          _dropDownText = value;
                        });
                        _listOfDiaries.clear();
                        earliestFilteredDiariesStream =
                            MService().getEarliestDiaries(_user!.uid);
                        earliestFilteredDiariesStream.then((value) {
                          for (var item in value) {
                            setState(() {
                              _listOfDiaries.add(item);
                            });
                          }
                        });
                      }
                    },
                  )),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final usersListStream = snapshot.data!.docs.map((docs) {
                      return MUser.fromDocument(docs);
                    }).where((muser) {
                      return muser.uid ==
                          FirebaseAuth.instance.currentUser!.uid;
                    }).toList();

                    MUser curUser = usersListStream[0];

                    return CreateProfile(curUser: curUser);
                  })
            ],
          )
        ],
      ),
      body: Row(children: [
        Expanded(
          flex: 4,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border(right: BorderSide(width: 0.4))),
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(38),
                    child: SfDateRangePicker(
                        onSelectionChanged: (dateRangePickerSelection) {
                      setState(() {
                        selectedDate = dateRangePickerSelection.value;
                        _listOfDiaries.clear();
                        userDiaryFilteredEntriesList = MService()
                            .getSameDateDiaries(
                                Timestamp.fromDate(selectedDate).toDate(),
                                FirebaseAuth.instance.currentUser!.uid);

                        userDiaryFilteredEntriesList.then((value) {
                          for (var item in value) {
                            setState(() {
                              _listOfDiaries.add(item);
                            });
                          }
                          return null;
                        });
                      });
                    })),
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Card(
                      elevation: 4,
                      child: TextButton.icon(
                        icon: const Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.greenAccent,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text('Write New', style: TextStyle(fontSize: 17)),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return WriteDiaryDialog(
                                    selectedDate: selectedDate,
                                    titleTextController: _titleTextController,
                                    descriptionTextController:
                                        _descriptionTextController);
                              });
                        },
                      )),
                )
              ],
            ),
          ),
        ),
        Expanded(
            flex: 10,
            child: DiaryListView(
                listOfDiaries: _listOfDiaries, selectedDate: selectedDate))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return WriteDiaryDialog(
                    selectedDate: selectedDate,
                    titleTextController: _titleTextController,
                    descriptionTextController: _descriptionTextController);
              });
        },
        tooltip: 'Add',
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
