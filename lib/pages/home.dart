import 'package:ausocial/constants.dart';
import 'package:ausocial/models/users.dart';
import 'package:ausocial/pages/events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final userRef = Firestore.instance.collection('users');
final eventRef = Firestore.instance.collection('event');
final DateTime timeStamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
//  PageController pageController;
//  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
//    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
      onError: (err) {
        print('Error Signing in: $err');
      },
    );

    //Re authenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((error) {
      print(error);
    });
  }

  void handleSignIn(GoogleSignInAccount account) {
    createUserInFirestore();
    if (account != null) {
      print('User signed in : $account');
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc =
        await userRef.document(googleSignIn.currentUser.id).get();

    if (!doc.exists) {
      userRef.document(user.id).setData({
        "id": user.id,
        "username": user.displayName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timeStamp": timeStamp,
      });
      doc = await userRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print('From Create user in fireStore: ${currentUser.username}');
  }

  void login() {
    googleSignIn.signIn();
  }

  void logout() {
    googleSignIn.signOut();
  }

//  onPageChanged(int pageIndex) {
//    setState(() {
//      this.pageIndex = pageIndex;
//    });
//  }

//  onTap(int pageIndex) {
//    pageController.animateToPage(
//      pageIndex,
//      duration: Duration(milliseconds: 300),
//      curve: Curves.bounceInOut,
//    );
//  }

  buildAuthScreen() {
    return EventsPage(
      currentUsers: currentUser,
    );
//    return Scaffold(
//      body: PageView(
//        children: <Widget>[
//          EventsPage(currentUser: currentUser),
//          StoriesPage(),
//        ],
//        controller: pageController,
//        onPageChanged: onPageChanged,
//        physics: NeverScrollableScrollPhysics(),
//      ),
//      bottomNavigationBar: SnakeNavigationBar(
//        snakeShape: SnakeShape.rectangle,
//        currentIndex: pageIndex,
//        onPositionChanged: onTap,
//        snakeColor: Color(primaryBlue),
//        showUnselectedLabels: false,
//        showSelectedLabels: false,
//        items: [
//          BottomNavigationBarItem(
//            icon: Icon(
//              SimpleLineIcons.event,
//              color: Colors.white,
////              size: 20.0,
//            ),
//          ),
//          BottomNavigationBarItem(
//            icon: Icon(
//              AntDesign.smileo,
////              size: 20.0,
//              color: Colors.white,
//            ),
//          ),
//        ],
//      ),
//    );
  }

  Widget buildUnAuthScreen() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Center(
                  child: Text(
                    'SOCI-AU',
                    style: GoogleFonts.abel(
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                      color: Color(primaryBlue),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 60.0),
                child: Image(
                  image: AssetImage(
                    'assets/images/homeBG.png',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 80),
                child: RaisedButton(
                  color: Color(primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    child: Text(
                      'Sign in with Google',
                      style: GoogleFonts.abel(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: login,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
