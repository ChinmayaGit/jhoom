import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'CapturePage.dart';
import 'Notifications.dart';
import 'package:jhoom/models/user.dart';
import 'package:jhoom/widgets/post.dart';
import 'package:jhoom/widgets/progress.dart';
import 'package:jhoom/pages/components/edit_profile.dart';
import 'package:jhoom/pages/home.dart';
import 'package:jhoom/pages/profile.dart';
import 'package:jhoom/pages/search.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final List<CameraDescription> cameras;
  final User currentUser;
  final String profileId;
  final bool upload;

  Timeline({this.currentUser, this.cameras, this.profileId, this.upload});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  PageController pageController;
  int _page = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this._page = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      // print(status);
      _permissionStatus = status;
      // print(_permissionStatus);
    });
  }
  Future<void> checkPermission() async {
    if (_permissionStatus.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CapturePage(widget.cameras),
        ),);
    } else {
      requestPermission(Permission.storage).then((value) {
        if (_permissionStatus.isDenied) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Please give us the Storage permission to save file in your phone.",
                        textAlign: TextAlign.center,
                      ),
                      RaisedButton(onPressed: () {
                        Navigator.pop(context);
                        requestPermission(Permission.storage);
                      })
                    ],
                  ),
                ),
              );
            },
          );
        }
      });
    }
  }
  @override
  Widget build(context) {
    final List<Widget> _children = [
      FormStep1(
          currentUser: currentUser,
          cameras: widget.cameras,
          profileId: currentUser?.id,
          upload: widget.upload,),
      Notifications(),
      CapturePage(widget.cameras),
      Search(),
      Profile(profileId: currentUser?.id),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      body: _children[_page],
      bottomNavigationBar: CurvedNavigationBar(
        items: <Widget>[
          Icon(
            Icons.whatshot,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.notifications_active,
            size: 30,
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              width: 40,
              height: 30,
              image: AssetImage("assets/images/JhoomAdd.png"),
            ),
          ),
          Icon(
            Icons.search,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.account_circle,
            size: 30,
            color: Colors.white,
          ),
        ],
        color: Colors.black26,
        buttonBackgroundColor: Colors.black,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        backgroundColor: Colors.black.withOpacity(0.0),
        height: 45,
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
    );

//      Scaffold(
//      body:
//      RefreshIndicator(
//          onRefresh: () => getTimeline(), child: buildTimeline()),
//    );
  }
}

class Timeline2 extends StatefulWidget {
  final List<CameraDescription> cameras;
  final User currentUser;
  final String profileId;
  final bool upload;

  Timeline2({this.currentUser, this.cameras, this.profileId, this.upload});

  @override
  _Timeline2State createState() => _Timeline2State();
}

class _Timeline2State extends State<Timeline2> {
  PageController pageController;
  int _page = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this._page = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(context) {
    final List<Widget> _children = [
      FormStep2(
          currentUser: currentUser,
          cameras: widget.cameras,
          profileId: currentUser?.id,
          upload: widget.upload),
      Notifications(),
      CapturePage(widget.cameras),
      Search(),
      Profile(profileId: currentUser?.id),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      body: _children[_page],
      bottomNavigationBar: CurvedNavigationBar(
        items: <Widget>[
          Icon(
            Icons.whatshot,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.notifications_active,
            size: 30,
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              width: 40,
              height: 30,
              image: AssetImage("assets/images/JhoomAdd.png"),
            ),
          ),
          Icon(
            Icons.search,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.account_circle,
            size: 30,
            color: Colors.white,
          ),
        ],
        color: Colors.black26,
        buttonBackgroundColor: Colors.black,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        backgroundColor: Colors.black.withOpacity(0.0),
        height: 45,
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
    );
  }
}

class FormStep1 extends StatefulWidget {
  static const String id = "FormStep1";
  final List<CameraDescription> cameras;
  final User currentUser;
  final String profileId;
  final bool upload;

  FormStep1({this.currentUser, this.cameras, this.profileId, this.upload});

  @override
  _FormStep1State createState() => _FormStep1State();
}

class _FormStep1State extends State<FormStep1> with TickerProviderStateMixin {
  List<Post> posts;
  List<String> followingList = [];
  List<String> randomList = [];



  @override
  void initState() {
    super.initState();
    getRandomTimeline();
  }

  @override
  void dispose() {
    super.dispose();
//    flickManager.dispose();
  }

//  getTimeline() async {
//    QuerySnapshot snapshot = await timelineRef
//        .document(widget.currentUser.id)
//        .collection('timelinePosts')
//        .orderBy('timestamp', descending: true)
//        .getDocuments();
//    List<Post> posts =
//        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
//    setState(() {
//      this.posts = posts;
//    });
//  }
  getRandomTimeline() async {
    QuerySnapshot snapshot =
        await randomPost.orderBy('timestamp', descending: true).getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return PageView(scrollDirection: Axis.vertical, children: posts);
    }
  }

  buildUsersToFollow() {
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          RefreshIndicator(
              onRefresh: () => getRandomTimeline(), child: buildTimeline()),
          // Padding(
          //   padding: const EdgeInsets.only(top: 80),
          //   child: SlideMenu(
          //     child: Align(
          //         alignment: Alignment.topRight,
          //         child: Container(
          //           decoration: new BoxDecoration(
          //             color: Colors.deepOrangeAccent,
          //             shape: BoxShape.rectangle,
          //             borderRadius: BorderRadius.only(
          //               topLeft: Radius.circular(40),
          //               bottomLeft: Radius.circular(10),
          //
          //             ),
          //
          //             boxShadow: <BoxShadow>[
          //               new BoxShadow(
          //                 color: Colors.black38,
          //                 blurRadius: 10.0,
          //                 offset: new Offset(7.0, 7.0),
          //               ),
          //             ],
          //           ),
          //           height: 50,
          //           width: 60,
          //           child: Icon(
          //             Icons.arrow_back_ios,
          //             color: Colors.white,
          //           ),
          //         )),
          //     menuItems: <Widget>[
          //       Padding(
          //         padding: const EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
          //         child: new Container(
          //           height: 300,
          //           decoration: ShapeDecoration(
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: new BorderRadius.circular(18.0),
          //               ),
          //               color: Colors.black12),
          //           child: Notifications(),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,80,16,0),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => EditProfile()));
                },
                child: Container(
                    height: 50,
                    width: 40,
                    child: Image(image: AssetImage("assets/images/Profile/money.png"),)
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: widget.upload == true
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Center(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Please turn off power saving mode it may slow the Loading...",
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                                decoration: new BoxDecoration(
                                  color: Colors.deepOrangeAccent,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(40),
                                      bottomRight: Radius.circular(10)),
                                  boxShadow: <BoxShadow>[
                                    new BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 10.0,
                                      offset: new Offset(7.0, 7.0),
                                    ),
                                  ],
                                ),
                                height: 60,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 2,
                                    ),
                                    CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      "Uploading...",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                )),
                          ),
                        )
                      : Container(
                          child: Image(
                            width: 90,
                            height: 80,
                            image: AssetImage("assets/images/PostPage/jhoomlogo.png"),
                          ),
                        ),
                ),
              ),
              FlatButton(
                onPressed: () {},
                child: Text('For you',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
              Text(
                '|',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Timeline2(
                            currentUser: currentUser,
                            cameras: widget.cameras,
                            profileId: currentUser?.id,
                            upload: widget.upload),
                      ));
                },
                child: Text('Following',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              Expanded(
                child: Container(
                  height: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FormStep2 extends StatefulWidget {
  final List<CameraDescription> cameras;
  final User currentUser;
  final String profileId;
  final bool upload;

  FormStep2({this.currentUser, this.cameras, this.profileId, this.upload});

  @override
  _FormStep2State createState() => _FormStep2State();
}

class _FormStep2State extends State<FormStep2> {
  List<Post> posts;
  List<String> followingList = [];
  List<String> randomList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }



  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.currentUser.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return PageView(scrollDirection: Axis.vertical, children: posts);
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = widget.currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 90,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "Users to Follow",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: userResults)
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          RefreshIndicator(
              onRefresh: () => getTimeline(), child: buildTimeline()),
          // Padding(
          //   padding: const EdgeInsets.only(top: 80),
          //   child: SlideMenu(
          //     child: Align(
          //         alignment: Alignment.topRight,
          //         child: Container(
          //           decoration: new BoxDecoration(
          //             color: Colors.deepOrangeAccent,
          //             shape: BoxShape.rectangle,
          //             borderRadius: BorderRadius.only(
          //                 topLeft: Radius.circular(40),
          //                 bottomLeft: Radius.circular(10)),
          //             boxShadow: <BoxShadow>[
          //               new BoxShadow(
          //                 color: Colors.black38,
          //                 blurRadius: 10.0,
          //                 offset: new Offset(7.0, 7.0),
          //               ),
          //             ],
          //           ),
          //           height: 50,
          //           width: 60,
          //           child: Icon(
          //             Icons.arrow_back_ios,
          //             color: Colors.white,
          //           ),
          //         )),
          //     menuItems: <Widget>[
          //       Padding(
          //         padding: const EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
          //         child: new Container(
          //           height: 300,
          //           decoration: ShapeDecoration(
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: new BorderRadius.circular(18.0),
          //               ),
          //               color: Colors.black12),
          //           child: Notifications(),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,80,16,0),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => EditProfile()));
                },
                child: Container(
                  height: 50,
                  width: 40,
                  child: Image(image: AssetImage("assets/images/Profile/money.png"),)
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: widget.upload == true
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Center(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Please turn off power saving mode it may slow the Loading...",
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                              decoration: new BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(40),
                                    bottomRight: Radius.circular(10)),
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 10.0,
                                    offset: new Offset(7.0, 7.0),
                                  ),
                                ],
                              ),
                              height: 60,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 2,
                                  ),
                                  CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    "Uploading...",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )),
                        )
                      : Container(
                          child: Image(
                            width: 90,
                            height: 80,
                            image: AssetImage("assets/images/PostPage/jhoomlogo.png"),
                          ),
                        ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Timeline(
                            currentUser: currentUser,
                            cameras: widget.cameras,
                            profileId: currentUser?.id,
                            upload: widget.upload),
                      ));
                },
                child: Text('For you',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              Text(
                '|',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              FlatButton(
                onPressed: () {},
                child: Text('Following',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
              Expanded(
                child: Container(
                  height: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
//
// class SlideMenu extends StatefulWidget {
//   final Widget child;
//   final List<Widget> menuItems;
//
//   SlideMenu({this.child, this.menuItems});
//
//   @override
//   _SlideMenuState createState() => new _SlideMenuState();
// }
//
// class _SlideMenuState extends State<SlideMenu>
//     with SingleTickerProviderStateMixin {
//   AnimationController _controller;
//
//   @override
//   initState() {
//     super.initState();
//     _controller = new AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 200));
//   }
//
//   @override
//   dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final animation = new Tween(
//         begin: const Offset(0.0, 0.0), end: const Offset(-0.9, 0.0))
//         .animate(new CurveTween(curve: Curves.decelerate).animate(_controller));
//
//     return new GestureDetector(
//       onTap: () {
//         // we can access context.size here
//         if (_controller.value <= 0.8111083984375003) {
//           setState(() {
//             _controller.value = 0.9111083984375003;
//           });
//         } else {
//           setState(() {
//             _controller.value = 0;
//           });
//         }
//       },
//       onHorizontalDragUpdate: (data) {
//         // we can access context.size here
//         setState(() {
//           _controller.value -= data.primaryDelta / context.size.width;
//           // print(_controller.value);
//         });
//       },
//       onHorizontalDragEnd: (data) {
//         if (data.primaryVelocity > 0)
//           _controller
//               .animateTo(.0); //close menu on fast swipe in the right direction
//         else if (_controller.value >= .5 ||
//             data.primaryVelocity <
//                 -0) // fully open if dragged a lot to left or on fast swipe to left
//           _controller.animateTo(1.0);
//         else // close if none of above
//           _controller.animateTo(.0);
//       },
//       child: new Stack(
//         children: <Widget>[
//           new SlideTransition(position: animation, child: widget.child),
//           new Positioned.fill(
//             child: new LayoutBuilder(
//               builder: (context, constraint) {
//                 return new AnimatedBuilder(
//                   animation: _controller,
//                   builder: (context, child) {
//                     return new Stack(
//                       children: <Widget>[
//                         new Positioned(
//                           right: .0,
//                           width: constraint.maxWidth * animation.value.dx * -1,
//                           child: new Container(
//                             color: Colors.transparent,
//                             child: new Row(
//                               children: widget.menuItems.map((child) {
//                                 return new Expanded(
//                                   child: child,
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
