import 'dart:typed_data';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:jhoom/pages/home.dart';
import 'package:jhoom/widgets/progress.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:animator/animator.dart';
import 'package:jhoom/main.dart';
import 'package:jhoom/pages/Notifications.dart';
import 'package:jhoom/pages/components/comments.dart';
import 'package:jhoom/video/Videcamera.dart';
import 'package:jhoom/video/flick_video_player_animation/data_manager.dart';
import 'package:jhoom/video/flick_video_player_animation/utils/mock_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jhoom/models/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class Post extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final String audioUrl;
  final String audioName;
  final dynamic likes;
  final dynamic views;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.audioUrl,
    this.audioName,
    this.likes,
    this.cameras,
    this.views,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      audioUrl: doc['audioUrl'],
      audioName: doc['audioName'],
      likes: doc['likes'],
      views: doc['Views'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  int getViewCount(views) {
    // if no likes, return 0
    if (views == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    views.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        audioUrl: this.audioUrl,
        audioName: this.audioName,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        views: this.views,
        viewCount: getLikeCount(this.views),
      );
}

class _PostState extends State<Post> with TickerProviderStateMixin {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final String audioUrl;
  final String audioName;
  bool showHeart = false;
  bool isLiked;
  int likeCount;
  Map likes;
  bool isView;
  int viewCount;
  Map views;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.audioUrl,
    this.audioName,
    this.likes,
    this.likeCount,
    this.views,
    this.viewCount,
  });

  List items = mockData['items'];
  bool abo = false;
  bool foryou = true;
  String subject = '';
  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);
  PageController foryouController = new PageController();

//  FlickManager flickManager;
  AnimationPlayerDataManager dataManager;
  AnimationController animationController;

  final _loadingStreamCtrl = StreamController<bool>.broadcast();

  CachedVideoPlayerController controller;

  bool downloads = false;
  bool shares = false;
  bool sSize = false;

  @override
  void initState() {
    // thumNail();
    controller = CachedVideoPlayerController.network(mediaUrl);

    controller.initialize().then((_) {
      setState(() {});
      controller.play();
      controller.setLooping(true);
    });
    super.initState();
    viewTime();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 5));
    animationController.repeat();

    requestPermission(Permission.storage);
//    flickManager = FlickManager(
//      videoPlayerController: VideoPlayerController.network(mediaUrl),
//      autoPlay: false,
//    );
//    flickManager.flickVideoManager.addListener(() {
//      if (flickManager.flickVideoManager.errorInVideo) {
//        print(flickManager.flickVideoManager.errorInVideo);}
//      if (flickManager.flickVideoManager.isVideoInitialized) {}
//      if (flickManager.flickVideoManager.isBuffering) {}
//    });
//    dataManager = AnimationPlayerDataManager(flickManager, items);
  }

  // String thumbPath ;
  // thumNail()async{
  //   final uint8list = await VideoThumbnail.thumbnailFile(
  //     video: mediaUrl,
  //     thumbnailPath: (await getTemporaryDirectory()).path,
  //   imageFormat: b.ImageFormat.WEBP,
  //   maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
  //   quality: 75,
  //
  //   );
  //   print("chinu");
  //   print(thumbnailPath);
  //   thumbPath =(await getTemporaryDirectory()).path;
  //   return thumbPath;
  // }

  @override
  void dispose() {
    animationController.dispose();
    controller.dispose();
    super.dispose();
//    flickManager.dispose();
    _loadingStreamCtrl.close();
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                backgroundColor: Colors.white,
              ),
            ),
          ),
          title: Row(
            children: <Widget>[
              Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => showProfile(context, profileId: user.id),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
                    child: Text(
                      "+ Follow",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            location,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: Icon(
                    Icons.more,
                    color: Colors.white,
                  ),
                )
              : Text(
                  '',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  Future<void> downloadFile() async {
    setState(() {
      downloads = true;
      // Fluttertoast.showToast(
      //     msg: "20%",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 5,
      //     backgroundColor: Colors.black,
      //     textColor: Colors.red,
      //     fontSize: 16.0);
    });

    final Random random = Random();
    var randid = random.nextInt(10000);
    Dio dio = Dio();
    // final Directory extDir = await getApplicationDocumentsDirectory();
    // final String dirPath = '${extDir.path}/jhoom';
    // await Directory(dirPath).create(recursive: true);

    // String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    await Directory("/storage/emulated/0/jhoom/downloads/")
        .create(recursive: true);
    String watermarkVideoFile = '/storage/emulated/0/jhoom/downloads/';
    //
    // String image = "https://i.imgur.com/TPfeyeJ.png";

    FileUtils.mkdir([watermarkVideoFile]);
    await dio
        .download(
      mediaUrl,
      watermarkVideoFile + randid.toString() + ".mp4",
    )
        .then((value) {
      // String waterPath = watermarkVideoFile + randid.toString() + ".mp4";
      // _flutterFFmpeg
      //     .execute(
      //         "-i $waterPath -i $image -filter_complex overlay=20:20 -codec:a copy $watermarkVideoFile")
      //     .then((rc) {
      setState(() {
        Fluttertoast.showToast(
            msg: "Download Location: Internal storage/jhoom/downloads/",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0);
        downloads = false;
      });
      // });
    });
  }

  Future<void> downloadShareFile() async {
    setState(() {
      shares = true;
      // Fluttertoast.showToast(
      //     msg: "20%",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 5,
      //     backgroundColor: Colors.black,
      //     textColor: Colors.red,
      //     fontSize: 16.0);
    });

    final Random random = Random();
    var randid = random.nextInt(10000);
    Dio dio = Dio();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/jhoom';
    await Directory(dirPath).create(recursive: true);

    // String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    // String watermarkVideoFile = '$dirPath/${timestamp()}.mp4';
    // String image = "https://i.imgur.com/TPfeyeJ.png";

    FileUtils.mkdir([dirPath]);
    await dio
        .download(
      mediaUrl,
      dirPath + randid.toString() + ".mp4",
    )
        .then((value) async {
      // Fluttertoast.showToast(
      //     msg: "60%",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 5,
      //     backgroundColor: Colors.black,
      //     textColor: Colors.yellow,
      //     fontSize: 16.0);
      String waterPath = dirPath + randid.toString() + ".mp4";
      // _flutterFFmpeg
      //     .execute(
      //         "-i $waterPath -i $image -filter_complex overlay=20:20 -codec:a copy $watermarkVideoFile")
      //     .then((value) async {
      File file = File(waterPath);
      Uint8List bytes = file.readAsBytesSync();
      await WcFlutterShare.share(
          sharePopupTitle: 'share',
          subject: 'Jhoom',
          text:
              'https://play.google.com/store/apps/details?id=com.leymonlab.jhoom',
          fileName: 'share.mp4',
          mimeType: 'image/png',
          bytesOfFile: bytes.buffer.asUint8List());

      setState(() {
        shares = false;
        // });
      });
    });
  }

//      .then((value) async {
//  File file = File(dirPath + randid.toString() + ".mp4");
//  Uint8List bytes = file.readAsBytesSync();
//  await WcFlutterShare.share(
//  sharePopupTitle: 'share',
//  subject: 'Jhoom',
//  text: 'AppLink',
//  fileName: 'share.mp4',
//  mimeType: 'image/png',
//  bytesOfFile: bytes.buffer.asUint8List());
//});
//
//setState(() {
//shares = false;
//});
  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    // delete post itself
    postsRef
        .document(ownerId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    storageRef.child("post_$postId.mp4").delete();
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    randomPost.document(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    QuerySnapshot reportSnapshot =
        await report.document(currentUser.id).collection(postId).getDocuments();
    reportSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
//    or try this
//    report
//        .document(currentUser.id)
//        .collection(postId)
//        .document()
//        .get()
//        .then((doc) {
//      if (doc.exists) {
//        doc.reference.delete();
//      }
//    });
  }

  viewTime() {
    Timer(Duration(seconds: 3), () {
      handleViewPost();
    });
  }

  handleViewPost() {
    bool _isView = views[currentUserId] == true;
    if (!_isView) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'Views.$currentUserId': true});
      randomPost.document(postId).updateData({
        'Views.$currentUserId': true,
      });
      setState(() {
        viewCount += 1;
        isView = true;
        views[currentUserId] = true;
      });
    } else if (_isView) {}
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({
        'likes.$currentUserId': false,
      });
      randomPost.document(postId).updateData({
        'likes.$currentUserId': false,
      });
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      randomPost.document(postId).updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  rePort(String text) {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    report.document(currentUser.id).collection(postId).document().setData({
      "Reported": text,
      "username": username,
      "postId": postId,
      "ownerId": ownerId,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
    });
  }

  buildPostVideo() {
    double height = MediaQuery.of(context).size.height;
    double widths = MediaQuery.of(context).size.width;
    double width = MediaQuery.of(context).size.width * 1.5;
    double aspect = controller.value.aspectRatio;

    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        children: <Widget>[
//          VisibilityDetector(
//            key: ObjectKey(flickManager),
//            onVisibilityChanged: (visibility) {
//              if (visibility.visibleFraction == 0 && this.mounted) {
//                flickManager.flickControlManager.autoPause();
//              } else if (visibility.visibleFraction == 1) {
//                flickManager.flickControlManager.autoResume();
//              }
//            },
//            child:
          VisibilityDetector(
            key: Key("unique key"),
            onVisibilityChanged: (VisibilityInfo info) {
              // debugPrint("${info.visibleFraction} of my widget is visible");
              if (info.visibleFraction == 0) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // If the video is playing, pause it.
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    // If the video is paused, play it.
                    controller.play();
                  }
                });
              },
              child: Center(
                child: aspect >= 1
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            color: Colors.black,
                            height: height,
                            width: widths,
                          ),
                          AspectRatio(
                            child: controller.value != null &&
                                    controller.value.initialized
                                ? CachedVideoPlayer(controller)
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            aspectRatio: controller.value.aspectRatio,
                          ),
                        ],
                      )
                    : sSize == false
                        ? Container(
                            child: controller.value != null &&
                                    controller.value.initialized
                                ? OverflowBox(
                                    maxWidth: double.infinity,
                                    maxHeight: double.infinity,
                                    child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: Container(
                                          width: width,
                                          height: height,
                                          child: CachedVideoPlayer(controller),
                                        )))
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                color: Colors.black,
                                height: height,
                                width: widths,
                              ),
                              AspectRatio(
                                child: controller.value != null &&
                                        controller.value.initialized
                                    ? CachedVideoPlayer(controller)
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                aspectRatio: controller.value.aspectRatio,
                              ),
                            ],
                          ),
              ),
            ),
          ),

//            FlickVideoPlayer(
//              flickManager: controller,
//              flickVideoWithControls: AnimationPlayerPortraitVideoControls(
//                  dataManager: dataManager, pauseOnTap: _pauseOnTap),
//            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: 110,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text("Report"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  rePort("Show me lesser post like this.");
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Show me lesser post like this."),
                                ),
                              ),
                              Divider(
                                color: Colors.black,
                              ),
                              GestureDetector(
                                onTap: () {
                                  rePort("Make as inappropriate");
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Make as inappropriate"),
                                ),
                              ),
                              Divider(
                                color: Colors.black,
                              ),
                              GestureDetector(
                                onTap: () {
                                  rePort("This is sexually explicit");
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("This is sexually explicit"),
                                ),
                              ),
                              Divider(
                                color: Colors.black,
                              ),
                              GestureDetector(
                                onTap: () {
                                  rePort("Report as Fake News");
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Report as Fake News"),
                                ),
                              )
                            ],
                          ),
                          actions: <Widget>[
                            RaisedButton.icon(
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close),
                              label: Text("Close"),
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
                      child: Text(
                        "Report",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          showHeart
              ? Container(
                  height: 500,
                  width: 500,
                  child: Animator(
                    duration: Duration(milliseconds: 300),
                    tween: Tween(begin: 0.8, end: 1.4),
                    curve: Curves.elasticOut,
                    cycles: 0,
                    builder: (anim) => Transform.scale(
                      scale: anim.value,
                      child: Icon(
                        Icons.favorite,
                        size: 80.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              : Text(""),
          StreamBuilder<bool>(
            stream: _loadingStreamCtrl.stream,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data == true) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text(
                        "Audio is extracting please wait..",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 23.0)),
            Row(
              children: [
                GestureDetector(
                  onTap: handleLikePost,
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 28.0,
                    color: Colors.pink,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Text(
                    "$likeCount likes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => _settingModalBottomSheet(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),

//                  showComments(
//                context,
//              postId: postId,
//              ownerId: ownerId,
//              mediaUrl: mediaUrl,
//              ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.white,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 3.0)),
            IconButton(
                icon: sSize
                    ? Icon(
                  Icons.zoom_out_map,
                  color: Colors.white,
                )
                    : Image(
                  height: 20,
                  image: AssetImage(
                    'assets/images/PostPage/shrink.png'),
                ),
                // color: Colors.white,
                onPressed: () {
                  if (sSize) {
                    setState(() {
                      sSize = false;
                    });
                  } else {
                    setState(() {
                      sSize = true;
                    });
                  }
                }),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 23.0),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                description,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        // Row(
        //   children: <Widget>[
        //     Container(
        //       margin: EdgeInsets.only(left: 23.0),
        //       child: Text(
        //         "$likeCount likes",
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  final Random random = Random();
  String audioPath = "";

  Future<void> extractAudio() async {
    // setState(() {
    //   _loadingStreamCtrl.sink.add(true);
    // });
    // if (widget.audioUrl != "null") {
    //   setState(() {
    //     _loadingStreamCtrl.sink.add(true);
    //   });
    //   Dio dio = Dio();
    //
    //   final Directory extDir = await getApplicationDocumentsDirectory();
    //   final String dirPath = '${extDir.path}/Audio/flutter_test';
    //   await Directory(dirPath).create(recursive: true);
    //   var randid = random.nextInt(10000);
    //
    //   FileUtils.mkdir([dirPath]);
    //   await dio.download(
    //     audioUrl,
    //     dirPath + randid.toString() + ".mp3",
    //   );
    //   audioPath = dirPath + randid.toString() + ".mp3";
    //
    //   // Navigator.push(
    //   //     context, MaterialPageRoute(
    //   //     builder: (context) =>  musicfromPost(cameras, audioPath, audioUrl, audioName)));
    //
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) =>
    //               CameraMusic(cameras, audioPath, audioUrl, audioName)));
    //   setState(() {
    //     _loadingStreamCtrl.sink.add(false);
    //   });
    // } else {
    setState(() {
      _loadingStreamCtrl.sink.add(true);
      Fluttertoast.showToast(
          msg: "20%",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.black,
          textColor: Colors.red,
          fontSize: 16.0);
    });
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    final Random random = Random();
    var randid = random.nextInt(10000);
    Dio dio = Dio();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/jhoom';
    await Directory(dirPath).create(recursive: true);

    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    String audioFile = '$dirPath/${timestamp()}.mp3';

    FileUtils.mkdir([dirPath]);
    await dio
        .download(
      mediaUrl,
      dirPath + randid.toString() + ".mp4",
    )
        .then((value) {
      setState(() {
        Fluttertoast.showToast(
            msg: "80%",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.black,
            textColor: Colors.green,
            fontSize: 16.0);
      });
      String audioPath = dirPath + randid.toString() + ".mp4";
      _flutterFFmpeg
          .execute(
              "-i $audioPath -vn -ar 44100 -ac 2 -ab 96k -f mp3 $audioFile")
          .then((rc) async {
        String name = "null";
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CameraMusic(cameras, audioFile, name, name)));
        // File audioFil= File(audioFile);
        // if (audioFil != null) {
        //
        //   await _trimmer.loadVideo(videoFile: audioFil);
        //
        //   Navigator.of(context)
        //       .push(MaterialPageRoute(builder: (context) =>
        //  AudioCut(
        //         widget.cameras, _trimmer, name, name, audioFile),
        //   ));
        // }
      });
    });
    setState(() {
      _loadingStreamCtrl.sink.add(false);
    });
    // }
  }

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
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    isView = (views[currentUserId] == true);
    // print(isLiked);
    // print(likes);
    // print(isView);
    // print(views);
    // print("chinu");

    return Container(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          buildPostVideo(),
          Container(
            height: 350,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: AnimatedBuilder(
                          animation: animationController,
                          child: GestureDetector(
                            onTap: () {
                              if (_permissionStatus.isGranted) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // return object of type Dialog
                                    return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text("Make Your Own Video"),
                                        content: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: GestureDetector(
                                                  child: Stack(
                                                    children: [
                                                      CircleAvatar(
                                                        child: Icon(
                                                            Icons.videocam),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    extractAudio();
                                                  }),
                                            ),
                                            // Expanded(
                                            //   flex: 1,
                                            //   child: CircleAvatar(
                                            //     backgroundColor:
                                            //         Colors.black,
                                            //     child: IconButton(
                                            //         icon: Icon(
                                            //           Icons.content_cut,
                                            //           color: Colors.white,
                                            //         ),
                                            //         onPressed: (){
                                            //           Navigator.pop(context);
                                            //           extractCutAudio();
                                            //
                                            //         }),
                                            //     // child: IconButton(
                                            //     //     icon: Icon(
                                            //     //         Icons.play_arrow,
                                            //     //         color:
                                            //     //             Colors.white),
                                            //     //     onPressed: () async {
                                            //     //       controller.pause();
                                            //     //       Fluttertoast.showToast(
                                            //     //           msg:
                                            //     //               "Audio is Playing Please wait.....",
                                            //     //           toastLength: Toast
                                            //     //               .LENGTH_SHORT,
                                            //     //           gravity:
                                            //     //               ToastGravity
                                            //     //                   .CENTER,
                                            //     //           timeInSecForIosWeb:
                                            //     //               1,
                                            //     //           backgroundColor:
                                            //     //               Colors
                                            //     //                   .black54,
                                            //     //           textColor:
                                            //     //               Colors.white,
                                            //     //           fontSize: 16.0);
                                            //     //       await _audioPlayer
                                            //     //           .play(audioUrl);
                                            //     //     }),
                                            //   ),
                                            // ),
                                          ],
                                        ));
                                  },
                                );
                              } else {
                                requestPermission(Permission.storage)
                                    .then((value) {
                                  requestPermission(Permission.camera)
                                      .then((value) {
                                    requestPermission(Permission.microphone)
                                        .then((value) {
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
                                                      "Please give us the Storage permission , Camera permission and Microphone permission to Record the videos.",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        requestPermission(
                                                                Permission
                                                                    .storage)
                                                            .then((value) {
                                                          requestPermission(
                                                                  Permission
                                                                      .camera)
                                                              .then((value) {
                                                            requestPermission(
                                                                Permission
                                                                    .microphone);
                                                          });
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        child: Container(
                                                          decoration:
                                                              ShapeDecoration(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        new BorderRadius.circular(
                                                                            18.0),
                                                                  ),
                                                                  color: Colors
                                                                      .black54),
                                                          child: Center(
                                                              child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            child: Text(
                                                              "Grant us permissions.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 15),
                                                            ),
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    });
                                  });
                                });
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: Color(0x222222).withOpacity(1),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundImage: AssetImage(
                                    'assets/images/PostPage/oboy.jpg'),
                              ),
                            ),
                          ),
                          builder: (context, _widget) {
                            return Transform.rotate(
                                angle: animationController.value * 6.3,
                                child: _widget);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 295,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: GestureDetector(
                        onTap: () {
                          if (_permissionStatus.isGranted) {
                            downloadShareFile();
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
                                              "Please give us the Storage permission to share the file.",
                                              textAlign: TextAlign.center,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                                requestPermission(
                                                    Permission.storage);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Container(
                                                  decoration: ShapeDecoration(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(18.0),
                                                      ),
                                                      color: Colors.black54),
                                                  child: Center(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Text(
                                                      "Grant us permissions.",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15),
                                                    ),
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            });
                          }
                        },
                        child: shares == true
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )
                            : Image.asset(
                                "assets/images/PostPage/share.png",
                                height: 25,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 260,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0),
                      child: GestureDetector(
                          onTap: () {
                            if (_permissionStatus.isGranted) {
                              downloadFile();
                            } else {
                              requestPermission(Permission.storage)
                                  .then((value) {
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
                                                "Please give us the Storage permission to download the file.",
                                                textAlign: TextAlign.center,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  requestPermission(
                                                      Permission.storage);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Container(
                                                    decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  18.0),
                                                        ),
                                                        color: Colors.black54),
                                                    child: Center(
                                                        child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: Text(
                                                        "Grant us permissions.",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15),
                                                      ),
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              });
                            }
                          },
                          child: downloads == true
                              ? CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )
                              : Image.asset(
                                  "assets/images/PostPage/download.png",
                                  height: 29,
                                )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 220,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0),
                      child: Icon(Icons.remove_red_eye,
                          size: 28.0, color: Colors.white),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "$viewCount Views",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 190,
            child: buildPostFooter(),
          ),
          Container(
            height: 125,
            child: buildPostHeader(),
          ),
        ],
      ),
    );
  }
}

void _settingModalBottomSheet(context,
    {String postId, String ownerId, String mediaUrl}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.80,
      child: Center(
        child: Comments(
          postId: postId,
          postOwnerId: ownerId,
          postMediaUrl: mediaUrl,
        ),
      ),
    ),
  );
//  showModalBottomSheet(
//
//      context: context,
//      builder: (BuildContext bc) {
//        return Comments(
//          postId: postId,
//          postOwnerId: ownerId,
//          postMediaUrl: mediaUrl,
//        );
//      }
//
//      );
}

//showComments(BuildContext context,
//    {String postId, String ownerId, String mediaUrl}) {
//  Navigator.push(context, MaterialPageRoute(builder: (context) {
//    return Comments(
//      postId: postId,
//      postOwnerId: ownerId,
//      postMediaUrl: mediaUrl,
//    );
//  }));
//}
