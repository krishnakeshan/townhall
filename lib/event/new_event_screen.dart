import 'package:flutter/material.dart';
import 'package:townhall/event/event.dart';
import 'package:townhall/issue/issue.dart';
import 'package:townhall/issue/new_issue_screen.dart';
import 'package:townhall/townhall_service.dart';

class NewEventScreen extends StatefulWidget {
  // Properties
  final Issue issue;

  NewEventScreen({this.issue});

  @override
  _NewEventScreenState createState() => _NewEventScreenState(issue: issue);
}

class _NewEventScreenState extends State<NewEventScreen> {
  Issue issue;

  _NewEventScreenState({this.issue});

  @override
  Widget build(context) => Scaffold(
        appBar: AppBar(
          title: Text("Create Event"),
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Issue
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 0.5),
                  ),
                ],
              ),
              child: Text(
                issue.title,
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                "Event Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Event Form
            NewEventForm(
              issue: issue,
            ),
          ],
        ),
      );
}

class NewEventForm extends StatefulWidget {
  final Issue issue;

  NewEventForm({this.issue});

  @override
  _NewEventFormState createState() => _NewEventFormState(issue: issue);
}

class _NewEventFormState extends State<NewEventForm> {
  // Properties
  final _formKey = GlobalKey<FormState>();
  final Issue issue;
  final titleController = TextEditingController(),
      descriptionController = TextEditingController();

  _NewEventFormState({this.issue});

  // Methods
  @override
  Widget build(context) => Form(
        key: _formKey,
        child: Column(
          children: [
            // Title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Event Title",
              ),
              validator: (value) =>
                  value.isEmpty ? "Please enter a valid title" : null,
            ),

            // Description
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: "Event Description",
              ),
              validator: (value) =>
                  value.isEmpty ? "Please enter a valid description" : null,
            ),

            // Submit Button
            Container(
              margin: EdgeInsets.only(top: 16),
              child: RaisedButton.icon(
                color: Colors.blue,
                onPressed: () {
                  // validate form
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Creating Event..."),
                      ),
                    );

                    var newEvent = Event(
                      "",
                      titleController.text,
                      descriptionController.text,
                      issue.id,
                      List(),
                    );
                    TownhallService.instance().newEvent(newEvent);
                  }
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                label: Text(
                  "Create Event",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
}
