import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:townhall/issue/issue.dart';
import 'package:place_picker/place_picker.dart';

import 'package:townhall/townhall_service.dart';

class NewIssueScreen extends StatefulWidget {
  @override
  _NewIssueScreenState createState() => _NewIssueScreenState();
}

class _NewIssueScreenState extends State<NewIssueScreen> {
  // Properties
  final TownhallService _townhallService = TownhallService.instance();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Random _random = Random.secure();
  _NewIssueFormState _newIssueFormState;

  // Methods
  @override
  void initState() {
    super.initState();

    _newIssueFormState = _NewIssueFormState(onSubmit: submitIssue);
  }

  @override
  Widget build(context) => Scaffold(
        appBar: AppBar(
          title: Text("New Issue"),
        ),
        body: ListView(
          padding: EdgeInsets.all(24),
          // Title Text
          children: [
            Text(
              "Tell us a bit about the issue",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Message
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Text(
                "Please fill the following fields",
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
            ),

            NewIssueForm(state: _newIssueFormState),
          ],
        ),
      );

  submitIssue() async {
    // create an issue
    var issue = Issue(
      null,
      _newIssueFormState.titleController.text,
      _newIssueFormState.descriptionController.text,
      12.969430947659568,
      77.61441707611084,
      List(),
      List(),
    );

    // upload images
    for (var image in _newIssueFormState.images) {
      var name =
          (DateTime.now().millisecondsSinceEpoch + _random.nextInt(pow(2, 32)))
              .toString();
      var ref = _storage.ref().child(name);
      try {
        await ref.putFile(image).onComplete;
        issue.mediaUrls.add(await ref.getDownloadURL());
      } on FirebaseException catch (e) {
        print(e);
      }
    }

    // submit issue
    _townhallService.submitIssue(issue);
  }
}

class NewIssueForm extends StatefulWidget {
  // Properties
  final _NewIssueFormState state;

  NewIssueForm({this.state});

  @override
  _NewIssueFormState createState() => state;
}

class _NewIssueFormState extends State<NewIssueForm> {
  // Properties
  final _formKey = GlobalKey<FormState>();
  List<File> images = List();
  final TextEditingController titleController = TextEditingController(),
      descriptionController = TextEditingController(),
      locationController = TextEditingController();
  LocationResult selectedLocation;
  final _imagePicker = ImagePicker();
  final Function onSubmit;

  _NewIssueFormState({this.onSubmit});

  // Methods
  showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (buildContext) {
          return PlacePicker(
            "AIzaSyBhkaO2dX5-K2MwYa2vZB_O3PURLFHTdAA",
          );
        },
      ),
    );

    // setState
    if (mounted) {
      setState(() {
        selectedLocation = LocationResult();
      });
    }
  }

  @override
  Widget build(context) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Title",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter a valid title";
                } else
                  return null;
              },
            ),

            // Description
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: "Description",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter a valid description";
                } else
                  return null;
              },
            ),

            // Location
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Text(
                "Location",
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 8),
              child: RaisedButton.icon(
                color: Colors.blueGrey,
                label: Text(
                  selectedLocation == null ? "Select Location" : "Selected",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                icon: Icon(
                  selectedLocation == null ? Icons.location_on : Icons.check,
                  color: Colors.white,
                ),
                onPressed: showPlacePicker,
              ),
            ),

            // Images
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Text(
                "Images",
              ),
            ),

            Container(
              height: 100,
              margin: EdgeInsets.only(top: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length + 1,
                itemBuilder: (context, index) {
                  // return add button
                  if (index == images.length) {
                    return GestureDetector(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add),
                      ),
                      onTap: getImage,
                    );
                  }

                  // return image widget
                  else {
                    return Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            // Submit Button
            Container(
              margin: EdgeInsets.only(top: 16),
              child: ElevatedButton(
                child: Text("Create Issue"),
                onPressed: () {
                  // validate input
                  if (_formKey.currentState.validate()) {
                    // show validation
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Submitting your issue."),
                    ));

                    // call submit
                    onSubmit();
                  }
                },
              ),
            ),
          ],
        ),
      );

  Future getImage() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }
}
