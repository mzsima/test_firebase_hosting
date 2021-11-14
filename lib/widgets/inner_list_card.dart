import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_hosting_test/model/diary.dart';
import 'package:firebase_hosting_test/util/utils.dart';
import 'package:firebase_hosting_test/widgets/update_entry_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'delete_entry_dialog.dart';

class InnerListCard extends StatelessWidget {
  const InnerListCard({
    Key? key,
    required this.diary,
    required this.selectedDate,
    required this.bookCollectionReference,
  }) : super(key: key);

  final Diary diary;
  final DateTime? selectedDate;
  final CollectionReference<Object?> bookCollectionReference;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _titleTextController =
        TextEditingController(text: diary.title);
    final TextEditingController _descriptionTextController =
        TextEditingController(text: diary.entry);
    return Column(
      children: [
        ListTile(
          title: Padding(
            padding: const EdgeInsetsDirectional.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${formatDateFromTimestamp(diary.entryTime)}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    )),
                IconButton(
                  icon: Icon(Icons.delete_forever, color: Colors.grey),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DeleteEntryDialog(
                            bookCollectionReference: bookCollectionReference,
                            diary: diary);
                      },
                    );
                  },
                )
              ],
            ),
          ),
          subtitle: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('・${formatDateFromTimestampHour(diary.entryTime!)}',
                      style: TextStyle(color: Colors.green)),
                  TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.more_horiz),
                      label: Text('')),
                ],
              ),
              Image.network((diary.photoUrls == null)
                  ? 'https://picsum.photos/400/200'
                  : diary.photoUrls.toString()),
              Row(children: [
                Flexible(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(diary.title!,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(diary.entry!),
                        ),
                      ]),
                ),
              ])
            ],
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Row(
                              children: [
                                Text(
                                  '${formatDateFromTimestamp(diary.entryTime)}',
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return UpdateEntryDialog(
                                              diary: diary,
                                              linkReference:
                                                  bookCollectionReference,
                                              titleTextController:
                                                  _titleTextController,
                                              descriptionTextController:
                                                  _descriptionTextController,
                                              widget: this);
                                        });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_forever_rounded),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DeleteEntryDialog(
                                              bookCollectionReference:
                                                  bookCollectionReference,
                                              diary: diary);
                                        });
                                  },
                                ),
                              ],
                            ))
                      ],
                    ),
                    content: ListTile(
                      subtitle: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${formatDateFromTimestamp(diary.entryTime)}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ))
                            ],
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.60,
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: Image.network((diary.photoUrls == null)
                                  ? 'https://picsum.photos/400/200'
                                  : diary.photoUrls.toString())),
                          Row(
                            children: [
                              Flexible(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${diary.title}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${diary.entry}',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ],
                              ))
                            ],
                          )
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      )
                    ],
                  );
                });
          },
        ),
      ],
    );
  }
}
