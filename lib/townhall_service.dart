import 'package:http/http.dart' as http;
import 'package:townhall/auth/user.dart' as user;
import 'package:townhall/event/event.dart';
import 'dart:convert';

import 'package:townhall/issue/issue.dart';

import 'package:firebase_auth/firebase_auth.dart';

class TownhallService {
  static TownhallService _instance;

  // Properties
  String _token;
  final String _baseUrl =
      "https://apigcp.nimbella.io/api/v1/web/team0240-9wzdkuu4xkv/atlas_interactions";

  static TownhallService instance() {
    if (_instance == null) _instance = new TownhallService();
    return _instance;
  }

  // Methods
  void init() async {
    _token = await getToken();
  }

  getToken() async {
    final String endPoint = "/login";
    final String url = _baseUrl + endPoint;

    // make request
    var response = await http.post(
      url,
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'usn': 'admin',
        'pwd': 'admin123',
      }),
    );

    print(response.body);

    var responseJson = jsonDecode(response.body);
    return responseJson['token'];
  }

  submitIssue(Issue issue) async {
    final String endPoint = "/submitIssue";
    final String url = _baseUrl + endPoint;

    // make request
    var response = await http.post(
      url,
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        "title": issue.title,
        "description": issue.description,
        "location": {
          "type": "Point",
          "coordinates": [issue.longitude, issue.latitude],
        },
        "submittedBy": _token,
        "attachedMedia": issue.mediaUrls,
      }),
    );

    print(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var responseJson = jsonDecode(response.body);
      return responseJson['success'];
    }
    return false;
  }

  getIssues() async {
    num maxD = 5000, minD = 0;
    String endPoint = "/getIssues";
    String url = _baseUrl + endPoint;

    // make request
    var response = await http.post(
      url,
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'minD': minD,
        'maxD': maxD,
        'long': 77.67383337020874,
        'lat': 12.965729799560522
      }),
    );

    print(response.body);
    List<Issue> issues = new List();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var responseJson = jsonDecode(response.body);
      for (var map in responseJson["res"]) {
        List<Comment> comments = new List();
        for (var comment in map["discussions"]) {
          comments.add(
              Comment(comment["_id"], comment["name"], comment["comment"]));
        }
        issues.add(Issue(
          map["_id"],
          map["title"],
          map["description"],
          map["location"]["coordinates"][0],
          map["location"]["coordinates"][1],
          (map["attachedMedia"]).cast<String>(),
          comments,
        ));
      }
    }
    return issues;
  }

  getIssueById() async {
    final endPoint = "/issueByID";
  }

  addDiscussion(Issue issue, String comment) async {
    final endPoint = "/addDiscussion";
    final url = _baseUrl + endPoint;

    // make request
    await http.post(
      url,
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode({
        "qid": issue.id,
        "discussionObj": {
          "name": FirebaseAuth.instance.currentUser.displayName,
          "comment": comment,
        },
      }),
    );
  }

  newEvent(Event event) async {
    final endPoint = "/newEvent";
    final url = _baseUrl + endPoint;

    // make request
    var response = await http.post(
      url,
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode({
        "title": event.title,
        "description": event.description,
        "issueId": event.issueId,
        "participants": [
          {
            "userId": FirebaseAuth.instance.currentUser.uid,
            "name": FirebaseAuth.instance.currentUser.displayName,
          }
        ],
      }),
    );

    print(response.body);
  }

  getEvents() async {
    final endPoint = "/getEvents";
    final url = _baseUrl + endPoint;

    // make request
    var response = await http.get(url);
    List<Event> events = new List();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var responseJson = jsonDecode(response.body);
      for (var map in responseJson["res"]) {
        // create list of users
        List<user.User> participants = new List();
        for (var userMap in map["participants"]) {
          participants.add(
            user.User(
              userMap["userId"],
              userMap["name"],
            ),
          );
        }

        // create event
        events.add(Event(
          map["_id"],
          map["title"],
          map["description"],
          map["issueId"],
          participants,
        ));
      }
    }

    return events;
  }
}
