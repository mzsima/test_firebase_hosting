import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_hosting_test/model/diary.dart';
import 'package:firebase_hosting_test/util/utils.dart';
import 'package:firebase_hosting_test/widgets/delete_entry_dialog.dart';
import 'package:flutter/material.dart';

import 'dart:html' as html;

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker_web/image_picker_web.dart';

import 'package:path/path.dart' as Path;

import 'inner_list_card.dart';

class UpdateEntryDialog extends StatefulWidget {
  const UpdateEntryDialog({
    Key? key,
    required this.diary,
    required CollectionReference linkReference,
    required TextEditingController titleTextController,
    required TextEditingController descriptionTextController,
    required this.widget,
    this.cloudFile,
    this.fileBytes,
    this.imageWidget,
  })  : _titleTextController = titleTextController,
        _linkReference = linkReference,
        _descriptionTextController = descriptionTextController,
        super(key: key);

  final Diary diary;
  final TextEditingController _titleTextController;
  final TextEditingController _descriptionTextController;
  final CollectionReference _linkReference;
  final InnerListCard widget;
  final html.File? cloudFile;
  final fileBytes;
  final Image? imageWidget;

  @override
  _UpdateEntryDialogState createState() => _UpdateEntryDialogState();
}

class _UpdateEntryDialogState extends State<UpdateEntryDialog> {
  var _fileBytes;
  Image? _imageWidget;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 5,
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Text('Discard'),
                style: TextButton.styleFrom(primary: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Done'),
                ),
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                    onSurface: Colors.blueGrey,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        side: BorderSide(color: Colors.green, width: 1))),
                onPressed: () {
                  var _user = FirebaseAuth.instance.currentUser;
                  final _fieldNotEmpty =
                      widget._titleTextController.text.isNotEmpty &&
                          widget._descriptionTextController.text.isNotEmpty;
                  final diaryTitleChanged =
                      widget.diary.title != widget._titleTextController.text;
                  final diaryEntryChanged = widget.diary.entry !=
                      widget._descriptionTextController.text;

                  final diaryUpdate = diaryTitleChanged ||
                      diaryEntryChanged ||
                      _fileBytes != null;

                  firebase_storage.FirebaseStorage fs =
                      firebase_storage.FirebaseStorage.instance;
                  final dateTime = DateTime.now();
                  final path = '$dateTime';

                  if (_fieldNotEmpty && diaryUpdate) {
                    widget._linkReference.doc(widget.diary.id).update(Diary(
                          userId: _user!.uid,
                          author: _user.email!.split('@')[0],
                          title: widget._titleTextController.text,
                          entry: widget._descriptionTextController.text,
                          photoUrls: (widget.diary.photoUrls != null)
                              ? widget.diary.photoUrls.toString()
                              : null,
                          entryTime: Timestamp.fromDate(DateTime.now()),
                        ).toMap());

                    if (_fileBytes != null) {
                      firebase_storage.SettableMetadata? metadata =
                          firebase_storage.SettableMetadata(
                              contentType: 'image/jpeg',
                              customMetadata: {'picked-file-path': path});

                      fs
                          .ref()
                          .child('images/$path${_user.uid}')
                          .putData(_fileBytes, metadata)
                          .then((value) {
                        return value.ref.getDownloadURL().then((value) {
                          widget._linkReference
                              .doc(widget.diary.id!)
                              .update({'photo_list': value.toString()});
                        });
                      });
                    }
                    Navigator.of(context).pop();
                  }
                },
              ),
            )
          ]),
          SizedBox(
            height: 30,
          ),
          Expanded(
            flex: 1,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white12,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              splashRadius: 26,
                              icon: Icon(Icons.image_rounded),
                              onPressed: () async {
                                await getMultipleImageInfos();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              splashRadius: 26,
                              color: Colors.red,
                              icon: Icon(Icons.delete_outline_rounded),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return DeleteEntryDialog(
                                          bookCollectionReference:
                                              widget._linkReference,
                                          diary: widget.diary);
                                    });
                              },
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Text(
                            '${formatDateFromTimestamp(widget.diary.entryTime)}'),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.60,
                          height: MediaQuery.of(context).size.height * 0.40,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (_imageWidget != null)
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _imageWidget,
                                  )
                                : Image.network((widget.diary.photoUrls == null)
                                    ? 'https://picsum.photos/400/200'
                                    : widget.diary.photoUrls.toString()),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Form(
                              child: Column(children: [
                            TextFormField(
                              controller: widget._titleTextController,
                              decoration: InputDecoration(hintText: 'Title...'),
                            ),
                            TextFormField(
                              maxLines: null, // make true multiline
                              controller: widget._descriptionTextController,
                              decoration:
                                  InputDecoration(hintText: 'Description...'),
                            ),
                          ])),
                        )
                      ],
                    ),
                  )
                ]),
          )
        ]),
      ),
    );
  }

  Future<void> getMultipleImageInfos() async {
    var mediaData = await ImagePickerWeb.getImageInfo;
    // String mimeType = mime(Path.basename(mediaData.fileName!))!;
    // html.File mediaFile =
    //     new html.File(mediaData.data!, mediaData.fileName!, {'type': mimeType});

    setState(() {
      // _cloudFile = mediaFile;
      _fileBytes = mediaData.data;
      _imageWidget = Image.memory(mediaData.data!);
    });
  }
}
