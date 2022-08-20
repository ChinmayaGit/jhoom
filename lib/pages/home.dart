import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'components/create_account.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:jhoom/models/user.dart';
import 'package:jhoom/pages/timeline.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final audioRef = Firestore.instance.collection('audioInfo');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final report = Firestore.instance.collection('reports');
final randomPost = Firestore.instance.collection('randomPost');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  static const String id = "Home";
  final List<CameraDescription> cameras;
  final bool upload;

  Home({this.cameras, this.upload});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isAuth = false;
  PageController pageController;

  // int _page = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }

  @override
  void initState() {
    super.initState();
    netCheck();
    pageController = PageController();
    requestPermission(Permission.storage);
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
//        onError: (err) {
//      print('Error signing in: $err');
//    }
    );
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    });
//        .catchError((err) {
//      print('Error signing in: $err');
//    });
  }

  netCheck() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {}
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: "Check your internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
    }
//    final result = await InternetAddress.lookup('google.com');
//    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//      print('connected');
//    }else{
//      Fluttertoast.showToast(
//          msg: "Check your internet connection",
//          toastLength: Toast.LENGTH_SHORT,
//          gravity: ToastGravity.CENTER,
//          timeInSecForIosWeb: 5,
//          backgroundColor: Colors.black38,
//          textColor: Colors.lightGreenAccent,
//          fontSize: 16.0);
//
//    }
  }
bool loading = false;
  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      setState(() {
        loading = true;
      });
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

// Chinu-This code is for IOS to create user name in IOS but it create two user name page in android.
  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    // if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
//      print("Firebase Messaging Token: $token\n");
      usersRef
          .document(user.id)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
//        print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
//          print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
//        print("Notification NOT shown");
      },
    );
  }

//  getiOSPermission() {
//    _firebaseMessaging.requestNotificationPermissions(
//        IosNotificationSettings(alert: true, badge: true, sound: true));
//    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
// //      print("Settings registered: $settings");
//    });
//  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      if(username == null)
      {
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": user.displayName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "PhoneNo": "",
        "UpiId": "",
        "timestamp": timestamp
      });}else{
        usersRef.document(user.id).setData({
          "id": user.id,
          "username": username,
          "photoUrl": user.photoUrl,
          "email": user.email,
          "displayName": user.displayName,
          "bio": "",
          "PhoneNo": "",
          "UpiId": "",
          "timestamp": timestamp });
      }
      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .document(user.id)
          .collection('userFollowers')
          .document(user.id)
          .setData({});

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  //
  // onPageChanged(int pageIndex) {
  //   setState(() {
  //     this._page = pageIndex;
  //   });
  // }
  //
  // onTap(int pageIndex) {
  //   pageController.animateToPage(
  //     pageIndex,
  //     duration: Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  // }

  Scaffold buildAuthScreen() {
    // final List<Widget> _children = [
    //   Timeline(
    //     currentUser: currentUser, cameras: widget.cameras, profileId: currentUser?.id, upload:widget.upload
    //   ),
    // Notifications(),
    // CapturePage(widget.cameras),
    // Search(),
    // Profile(profileId: currentUser?.id),
    // ];
    return Scaffold(
      key: _scaffoldKey,
      body: Timeline(
          currentUser: currentUser,
          cameras: widget.cameras,
          profileId: currentUser?.id,
          upload: widget.upload),
      // _children[_page],
      // bottomNavigationBar: CurvedNavigationBar(
      //   items: <Widget>[
      //     Icon(
      //       Icons.whatshot,
      //       size: 30,
      //       color: Colors.white,
      //     ),
      //     Icon(
      //       Icons.notifications_active,
      //       size: 30,
      //       color: Colors.white,
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Image(
      //         width: 40,
      //         height: 30,
      //         image: AssetImage("assets/images/bitboxicon.png"),
      //       ),
      //     ),
      //     Icon(
      //       Icons.search,
      //       size: 30,
      //       color: Colors.white,
      //     ),
      //     Icon(
      //       Icons.account_circle,
      //       size: 30,
      //       color: Colors.white,
      //     ),
      //   ],
      //
      //   color: Colors.black,
      //   buttonBackgroundColor: Colors.black,
      //   backgroundColor: Colors.black87,
      //   animationCurve: Curves.easeInOut,
      //   animationDuration: Duration(milliseconds: 600),
      //   height: 45,
      //   onTap: (index) {
      //     setState(() {
      //       _page = index;
      //     });
      //   },
      // ),
    );
//     return RaisedButton(
//       child: Text('Logout'),
//       onPressed: logout,
//     );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  //   GestureZoomBox(
                  //   maxScale: 10.0,
                  //   doubleTapScale: 10.0,
                  //   duration: Duration(seconds: 3),
                  //   // onPressed: () => Navigator.pop(context),
                  //   child: Image(image: AssetImage(
                  //       "assets/images/jhoom.png"),),
                  // ),

                  Text(
                    'JHOOM',
                    style: TextStyle(
                      fontFamily: "SaucerBB",
                      fontSize: 60.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Be the Next Jhoom Star 🌟',
                    style: TextStyle(
                      fontFamily: "SaucerBB",
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector (
                      onTap: login,
                      child:loading == false ?
                      Container (
                              width: 260.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage (
                                    'assets/images/google_signin_button.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ):CircularProgressIndicator(),),
                  Text(
                    'leymonlabs.in',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
