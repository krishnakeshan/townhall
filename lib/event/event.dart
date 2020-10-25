import 'package:townhall/auth/user.dart';

class Event {
  String id;
  String title;
  String description;
  String issueId;
  List<User> attendees;

  Event(this.id, this.title, this.description, this.issueId, this.attendees);
}
