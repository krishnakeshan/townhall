import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:townhall/event/new_event_screen.dart';
import 'package:townhall/issue/issue.dart';
import 'package:townhall/townhall_service.dart';

class ViewIssueScreen extends StatefulWidget {
  // Properties
  final Issue issue;

  ViewIssueScreen({this.issue});

  @override
  _ViewIssueScreenState createState() => _ViewIssueScreenState(issue: issue);
}

class _ViewIssueScreenState extends State<ViewIssueScreen> {
  Issue issue;
  Completer<GoogleMapController> _controller = Completer();
  List<File> images = List();
  final ImagePicker _imagePicker = ImagePicker();
  final commentController = TextEditingController();

  _ViewIssueScreenState({this.issue});

  @override
  Widget build(buildContext) => Scaffold(
        appBar: AppBar(
          title: Text("View Issue"),
          actions: [
            IconButton(
              icon: Icon(Icons.event),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (buildContext) => NewEventScreen(
                      issue: issue,
                    ),
                  ),
                );
              },
              tooltip: "Create Event",
            ),
          ],
        ),
        body: ListView(
          children: [
            // Images
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 1),
                    child: Image.network(
                      "https://firebasestorage.googleapis.com/v0/b/townhall-95847.appspot.com/o/1605095311544?alt=media&token=712a4741-5f38-4044-a8c9-cd38e1e76fbf",
                      width: 300,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            // Title
            Container(
              margin: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                issue.title,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),

            // Description
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Text(
                issue.description,
              ),
            ),

            Divider(height: 48),

            // Map
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Location",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 250,
              margin: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: CameraPosition(
                  target: LatLng(13.0376969, 77.6663322),
                  zoom: 14.4746,
                ),
              ),
            ),

            Divider(
              height: 48,
            ),

            // Discussion
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(
                "Comments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Add Comment
            Container(
              padding: EdgeInsets.only(left: 16, bottom: 16, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // TextField
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration.collapsed(
                          hintText: "Enter your comment",
                        ),
                      ),
                    ),
                  ),

                  // Send Button
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: () {
                      TownhallService.instance()
                          .addDiscussion(issue, commentController.text);
                      if (mounted) {
                        setState(
                          () {
                            // add comment to list
                            issue.comments.add(
                              Comment(
                                  "",
                                  FirebaseAuth.instance.currentUser.displayName,
                                  commentController.text),
                            );
                            commentController.text = "";
                          },
                        );
                      }
                    },
                    child: Text(
                      "Add".toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Existing
            Container(
              height: 300,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: issue.comments.length,
                itemBuilder: (context, index) {
                  Comment comment = issue.comments[index];
                  // Comment Holder
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // name
                        Text(
                          comment.user,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // comment
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          child: Text(
                            comment.comment,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.plus_one,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (buildContext) {
                return Container(
                  // padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.blue,
                        child: Text(
                          "+1 this issue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // ListView of images
                      Container(
                        margin: EdgeInsets.only(left: 16, top: 16, right: 16),
                        child: Text("Images"),
                      ),

                      Container(
                        height: 100,
                        margin: EdgeInsets.only(
                            left: 16, top: 12, right: 16, bottom: 16),
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

                      // Done Button
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        child: RaisedButton.icon(
                          color: Colors.green,
                          onPressed: () {
                            // call method to increment issue
                          },
                          icon: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );

  getImage() async {
    var pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }
}
