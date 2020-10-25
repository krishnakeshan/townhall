import 'package:flutter/material.dart';
import 'package:townhall/auth/user.dart';
import 'package:townhall/event/event.dart';

class ViewEventScreen extends StatefulWidget {
  final Event event;

  ViewEventScreen({this.event});

  @override
  createState() => _ViewEventScreenState(event: event);
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  Event event;
  bool going = true;

  _ViewEventScreenState({this.event});

  @override
  build(context) => Scaffold(
        appBar: AppBar(
          title: Text(
            "View Event",
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Container(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Description
              Container(
                margin: EdgeInsets.only(top: 12),
                child: Text(
                  event.description,
                ),
              ),

              // Issue
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.issueId,
                  textAlign: TextAlign.center,
                ),
              ),

              // Going
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Going
                    Expanded(
                      child: Text(
                        "Going",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Switch
                    Switch(
                      value: going,
                      onChanged: (newValue) {
                        setState(() {
                          going = newValue;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),

              // Attendees
              Container(
                margin: EdgeInsets.only(top: 18, bottom: 8),
                child: Text(
                  "Attendees",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: event.attendees.length,
                  itemBuilder: (context, index) {
                    User user = event.attendees[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Name
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16,
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
        ),
      );
}
