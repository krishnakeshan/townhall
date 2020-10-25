import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:townhall/auth/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:townhall/event/event.dart';
import 'package:townhall/event/view_event_screen.dart';
import 'package:townhall/issue/issue.dart';
import 'package:townhall/issue/new_issue_screen.dart';
import 'package:townhall/issue/view_issue_screen.dart';
import 'package:townhall/townhall_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TownhallService.instance().init();
  runApp(App());
}

class App extends StatelessWidget {
  // Properties
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // Methods
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // check for errors
        if (snapshot.hasError) {
          // return error
        }

        // check for success
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Townhall',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: GoogleFonts.ubuntuTextTheme(),
            ),
            home: HomePage(),
          );
        }

        // show loading
        return MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.blue,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Properties
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int selectedIndex = 0;
  TownhallService _townhallService = TownhallService.instance();
  Completer<GoogleMapController> _controller = Completer();
  List<Issue> issues = List();
  List<Event> events = List();

  // Methods
  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((user) {
      if (user == null) {
        // go to auth screen
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (buildContext) {
          return LoginScreen();
        }));
      } else {
        // carry on sync
        if (mounted) {
          setState(() {});
        }

        getIssues();
        getEvents();
      }
    });
  }

  getIssues() async {
    var result = await _townhallService.getIssues();
    if (mounted) {
      setState(() {
        issues = result;
      });
    }
  }

  getEvents() async {
    var result = await _townhallService.getEvents();
    if (mounted) {
      setState(() {
        events = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.black87,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Container()),

              // Logged in user
              Container(
                child: Text(
                  "Logged in as",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    FirebaseAuth.instance.currentUser.photoURL,
                  ),
                ),
              ),

              Container(
                child: Text(
                  FirebaseAuth.instance.currentUser.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),

              Expanded(child: Container()),

              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Text(
                  "Powered by Nimbella",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: getTabView(selectedIndex),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NewIssueScreen()),
                );
              },
              tooltip: 'New Issue',
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          // Issues Tab
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Issues",
          ),

          // Events
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: "Events",
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) {
          if (mounted) {
            setState(() {
              selectedIndex = index;
            });
          }
        },
      ),
    );
  }

  getTabView(int index) {
    if (index == 0)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: CameraPosition(
                  target: issues.isEmpty
                      ? LatLng(12.969430947659568, 77.61441707611084)
                      : LatLng(
                          issues.first.latitude,
                          issues.first.longitude,
                        ),
                  zoom: 14.4746,
                ),
                markers: issues.isNotEmpty ? getIssueMarkers() : null,
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            flex: 1,
          ),

          // Issues List
          Container(
            margin: EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              "Issues near you",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: ListView.builder(
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      padding: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            offset: Offset(0, 0.5),
                            blurRadius: 2,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Issue Image
                          Image.network(
                            issues[index].mediaUrls.first,
                            height: 170,
                            fit: BoxFit.cover,
                          ),
                          // Issue Title
                          Container(
                            margin: EdgeInsets.only(
                                left: 16, top: 16, right: 16, bottom: 8),
                            child: Text(
                              issues[index].title,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              issues[index].description,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewIssueScreen(
                            issue: issues[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            flex: 2,
          ),
        ],
      );

    // events tab
    else if (index == 1)
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                return GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0, 0.5),
                          blurRadius: 1,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 6),
                                child: Text(
                                  event.description,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Attendees
                        Container(
                          margin: EdgeInsets.only(right: 16),
                          child: Text(
                            "${event.attendees.length}\ngoing",
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Share button
                        IconButton(
                          icon: Icon(
                            Icons.share,
                            color: Colors.blue,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewEventScreen(event: event),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );

    // others
    else
      return Container();
  }

  getIssueMarkers() {
    List<Marker> markers = List();
    for (Issue issue in issues) {
      markers.add(
        Marker(
          markerId: MarkerId(issue.id),
          position: LatLng(issue.latitude, issue.longitude),
        ),
      );
    }
    return Set.from(markers).cast<Marker>();
  }
}
