class Issue {
  String id;
  String title;
  String description;
  double latitude;
  double longitude;
  List<String> mediaUrls;
  List<Comment> comments;

  Issue(this.id, this.title, this.description, this.latitude, this.longitude,
      this.mediaUrls, this.comments);
}

class Comment {
  String id;
  String user;
  String comment;

  Comment(this.id, this.user, this.comment);
}
