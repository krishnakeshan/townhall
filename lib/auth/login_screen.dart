import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:townhall/main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (buildContext) {
                return HomePage();
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(context) => Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.all(36),
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              Container(
                child: Image(
                  image: AssetImage(
                    "assets/images/undraw_maker_launch_crhe.png",
                  ),
                ),
              ),

              // App Name
              Container(
                margin: EdgeInsets.only(top: 48),
                child: Text(
                  "Welcome to",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Text(
                  "Townhall",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pacifico(
                    color: Colors.blue,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),

              // Definition
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Text(
                  "Connect with fellow citizens to discuss issues around you",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),

              // Login to get started
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(top: 48),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/images/google.png",
                          width: 25,
                          height: 25,
                        ),
                      ),

                      // Text
                      Expanded(
                        child: Text(
                          "Sign in with Google",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: _signInWithGoogle,
              ),
            ],
          ),
        ),
      );

  Future<UserCredential> _signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
