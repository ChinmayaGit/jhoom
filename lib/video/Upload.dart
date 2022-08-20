import 'dart:io';
import 'package:camera/camera.dart';
import 'package:jhoom/main.dart';
import 'package:jhoom/pages/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'flick_video_player_animation/data_manager.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class Upload extends StatefulWidget {
  final List<CameraDescription> cameras;
  final File videoFile;

  final String videoPath;
  final String audioUrl;
  final String audioName;

  Upload(
      {this.videoFile,
      this.videoPath,
      this.audioUrl,
      this.audioName,
      this.cameras});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  File _videos;
  bool isUploading = false;
  String postId = Uuid().v4();
  bool isPlaying = false;
  FlickManager flickManager;
  AnimationPlayerDataManager dataManager;
  int size;
  File bgFile;
  bool downloads = false;

  void initState() {
    super.initState();
    flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.file(widget.videoFile));
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  clearImage() {
    setState(() {
      _videos = null;
    });
  }

  getVideoDuration() async {
    size = _videos.lengthSync();
    return size;
  }

  Future<String> uploadVideo(videoFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.mp4").putFile(videoFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  //
  // uploadAudio(audioFile) async {
  //    String audioName = widget.audioName;
  //    String idName = currentUser.id;
  //    String audioLocation = "audio/catch/$idName/$audioName";
  //    final StorageReference storageReference =
  //    FirebaseStorage().ref().child(audioLocation);
  //    final StorageUploadTask uploadTask = storageReference.putFile(audioFile);
  //    await uploadTask.onComplete;
  //
  //    final ref = FirebaseStorage().ref().child(audioLocation);
  //    var audioString = await ref.getDownloadURL();
  //    await Firestore.instance
  //        .collection('audioInfo')
  //        .document('All')
  //        .collection(currentUser.id)
  //        .document()
  //        .setData({
  //      'url': audioString,
  //      'location': audioLocation,
  //      'name': widget.audioName,
  //      'postid': currentUser.id
  //    });
  //    compress(audioString);
  //  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": currentUser.id,
      "username": currentUser.username,
      "mediaUrl": mediaUrl,
      "audioUrl": widget.audioUrl,
      "audioName": widget.audioName,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
      "Views": {},
    });
  }

  createRandomPostInFirestore(
      {String mediaUrl, String location, String description}) {
    randomPost.document(postId).setData({
      "postId": postId,
      "ownerId": currentUser.id,
      "username": currentUser.username,
      "mediaUrl": mediaUrl,
      "audioUrl": widget.audioUrl,
      "audioName": widget.audioName,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
      "Views": {},
    });
  }

//  rePort() {
//    report.document("randomPost").collection(currentUser.id).document().setData({
//    });
//  }
//   audioCheck() async {
//     if (widget.audioFile != null) {
//       setState(() {
//         isUploading = true;
//       });
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => Home(
//                 cameras: cameras,
//                 upload: true,
//               )));
//       await uploadAudio(widget.audioFile);
//     } else {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => Home(
//                 cameras: cameras,
//                 upload: true,
//               )));
//       compress();
//     }
//   }
  compress() async {
    setState(() {
      isUploading = true;
      setState(() {
        Fluttertoast.showToast(
            msg: "20%",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.black,
            textColor: Colors.red,
            fontSize: 16.0);
      });
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  cameras: cameras,
                  upload: true,
                )));
    _videos = widget.videoFile;
    getVideoDuration();
    if (size < 3000000) {
      handleVideoSubmit(widget.videoFile);
    } else {
      final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
      String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
      final Directory extDir = await getApplicationDocumentsDirectory();

      final String dirPath = '${extDir.path}/jhoom';

//    await Directory(dirPath).create(recursive: true);
//    String watermarkVideoFile = '$dirPath/${timestamp()}.mp4';
//    String image = "https://i.imgur.com/VSLBuiC.png";

      String localVideoFile1 = widget.videoPath;
      await Directory(dirPath).create(recursive: true);
      String compVideoFile = '$dirPath/${timestamp()}.mp4';
      _flutterFFmpeg
          .execute("-i $localVideoFile1 -vf mpdecimate -b 800k $compVideoFile")
          .then((val) {
        setState(() {
          Fluttertoast.showToast(
              msg: "50%",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 5,
              backgroundColor: Colors.black,
              textColor: Colors.yellow,
              fontSize: 16.0);
        });
        File files = File(compVideoFile);
        _videos = files;
        getVideoDuration();
        handleVideoSubmit(files);
      });
    }
  }

  handleVideoSubmit(videoFiles) async {
    if (size <= 15000000) {
      String mediaUrl = await uploadVideo(videoFiles);

      createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text,
      );
      createRandomPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text,
      );
      captionController.clear();
      locationController.clear();
      setState(() {
        videoFiles = null;
        isUploading = false;
        postId = Uuid().v4();
        Fluttertoast.showToast(
            msg: "Upload Successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.black38,
            textColor: Colors.lightGreenAccent,
            fontSize: 16.0);

        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                      cameras: cameras,
                      upload: false,
                    )));
      });
    } else {
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
                    "Warning!",
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Video must be less than 30Sec and file size must be less than 15 MB.Also you can save the video by pressing the download button given above.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  high() async {
    setState(() {
      downloads = true;
    });
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/jhoom';

    String localVideoFile1 = widget.videoPath;
    await Directory(dirPath).create(recursive: true);
    String compVideoFile = '$dirPath/${timestamp()}.mp4';
    _flutterFFmpeg
        .execute(
            "-i $localVideoFile1 -vf mpdecimate -vcodec libx265 -crf 28 $compVideoFile")
        .then((val) {
      File files = File(compVideoFile);
      downloadFile(files);
    });
  }

  highLess() async {
    setState(() {
      downloads = true;
    });
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/jhoom';

    String localVideoFile1 = widget.videoPath;
    await Directory(dirPath).create(recursive: true);
    String compVideoFile = '$dirPath/${timestamp()}.mp4';
    _flutterFFmpeg
        .execute(
            "-i $localVideoFile1 -vf mpdecimate -vcodec libx265 -crf 28 -preset veryfast $compVideoFile")
        .then((val) {
      File files = File(compVideoFile);
      downloadFile(files);
    });
  }

  medium() async {
    setState(() {
      downloads = true;
    });
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/jhoom';

    String localVideoFile1 = widget.videoPath;
    await Directory(dirPath).create(recursive: true);
    String compVideoFile = '$dirPath/${timestamp()}.mp4';
    _flutterFFmpeg
        .execute("-i $localVideoFile1 -vf mpdecimate -b 800k $compVideoFile")
        .then((val) {
      File files = File(compVideoFile);
      downloadFile(files);
    });
  }

  mediumLess() async {
    setState(() {
      downloads = true;
    });
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/jhoom';

    String localVideoFile1 = widget.videoPath;
    await Directory(dirPath).create(recursive: true);
    String compVideoFile = '$dirPath/${timestamp()}.mp4';
    _flutterFFmpeg
        .execute(
            "-i $localVideoFile1 -vf mpdecimate -b 800k -preset veryfast $compVideoFile")
        .then((val) {
      File files = File(compVideoFile);
      downloadFile(files);
    });
  }

  Future<void> downloadFile(File files) async {
    final String dirPath = '/storage/emulated/0/jhoom/downloads/';
    await Directory(dirPath).create(recursive: true);
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final File file = files;
    bgFile = await file
        .copy('/storage/emulated/0/jhoom/downloads/${timestamp()}.mp4');
//    Directory appDocDirectory = await getApplicationDocumentsDirectory();
//
//    final String dirPath = '/storage/emulated/0/Bitbox/Downloads/';
//    await Directory(dirPath).create(recursive: true)// The created directory is returned as a Future.
//        .then((Directory directory) async{
//      String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
//      final File file = widget.videoFile;
//      bgFile = await file
//          .copy('/storage/emulated/0/Bitbox/Downloads/${timestamp()}.mp4');
//      print('Path of New Dir: '+directory.path);
//    });
    setState(() {
      downloads = false;
      Fluttertoast.showToast(
          msg: "Video Location: Internal storage/jhoom/downloads/",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.white54,
          textColor: Colors.black,
          fontSize: 16.0);
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
            child: GestureDetector(
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
                              "Please turn off power saving mode it may slow the Compression...",
                              textAlign: TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: () {
                                high();
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    height: 50,
                                    decoration: new BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.rectangle,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "High Compress",
                                      style: TextStyle(color: Colors.white),
                                    ))),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                highLess();
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    height: 50,
                                    decoration: new BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.rectangle,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "High Compress (Less time)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ))),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                medium();
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    height: 50,
                                    decoration: new BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.rectangle,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "Medium Compress",
                                      style: TextStyle(color: Colors.white),
                                    ))),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                mediumLess();
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    height: 50,
                                    decoration: new BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.rectangle,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "Medium Compress (Less Time)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ))),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                downloadFile(widget.videoFile);
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    height: 50,
                                    decoration: new BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.rectangle,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "Normal Save",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: downloads == true
                  ? CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Image.asset(
                        "assets/images/PostPage/download.png",
                        height: 29,
                      )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
              ),
              color: Colors.black,
              onPressed: isUploading ? null : () => compress(),
              child: Text(
                "Post",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading
              ? Container(
                  height: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Please wait...."),
                    ],
                  ))
              : VisibilityDetector(
                  key: ObjectKey(flickManager),
                  onVisibilityChanged: (visibility) {
                    if (visibility.visibleFraction == 0 && this.mounted) {
                      flickManager.flickControlManager.autoPause();
                    } else if (visibility.visibleFraction == 1) {
                      flickManager.flickControlManager.autoResume();
                    }
                  },
                  child: Container(
                    child: FlickVideoPlayer(
                      flickManager: flickManager,
                      flickVideoWithControls: FlickVideoWithControls(
                        controls: FlickPortraitControls(),
                      ),
                      flickVideoWithControlsFullscreen: FlickVideoWithControls(
                        controls: FlickLandscapeControls(),
                      ),
                    ),
                  ),
                ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              onPressed: () {
                getUserLocation();
                Fluttertoast.showToast(
                    msg:
                        "Please turn on your phone loaction manully to get location.....",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.white54,
                    textColor: Colors.black,
                    fontSize: 16.0);
              },
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
//    String completeAddress =
//        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
//    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    locationController.text = formattedAddress;
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildUploadForm();
  }
}
