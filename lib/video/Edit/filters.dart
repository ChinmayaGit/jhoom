import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jhoom/video/Edit/Edits.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';

class Filters extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  final Trimmer trimmer;
  final String audioUrl;
  final String audioName;

  Filters({
    this.videoPath,
    this.videoFile,
    this.trimmer,
    this.audioName,
    this.audioUrl,

  });

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  FlickManager flickManager;
  double _startValue = 0.0;
  double _endValue = 0.0;
  // bool effectAdd = false;
  bool changeVideo = false;
  File videoFiles;
  final _loadingStreamCtrl = StreamController<bool>.broadcast();
  final Random random = Random();
  String videoPath = "";
  bool filter = false;

  int time = 30;
  final Trimmer _trimmer = Trimmer();
  void initState() {
    super.initState();

    flickManager = changeVideo == true
        ? FlickManager(
            videoPlayerController: VideoPlayerController.file(videoFiles))
        : FlickManager(
            videoPlayerController:
                VideoPlayerController.file(widget.videoFile));
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
    _loadingStreamCtrl.close();
  }

  addEffect(path) async {
    setState(() {
      filter = false;
    });
    flickManager.flickControlManager.autoPause();
    setState(() {
      _loadingStreamCtrl.sink.add(true);
    });
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String _localVideoFile1 = widget.videoPath;
    String _localVideoFile2 = path;
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/jhoom';
    await Directory(dirPath).create(recursive: true);
    String saveVideoFile = "$dirPath/${timestamp()}.mp4";
    Duration startPoint = Duration(milliseconds: _startValue.toInt());
    Duration endPoint = Duration(milliseconds: _endValue.toInt());

    // print(startPoint.inSeconds.toString());
    // print(endPoint.inSeconds.toString());

    var arguments = [
      "-i",
      "$_localVideoFile2",
      "-i",
      "$_localVideoFile1",
      "-filter_complex",
      "[0]split[m][a];[m][a]alphamerge[keyed]; [1][keyed]overlay=eof_action=endall:enable='between(t,${startPoint.inSeconds.toString()},${endPoint.inSeconds.toString()})'",
      "$saveVideoFile"
    ];

    _flutterFFmpeg.executeWithArguments(arguments).then((value) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return Filters(
          trimmer: _trimmer,
          videoFile: videoFiles,
          videoPath: saveVideoFile,
          audioName: widget.audioName,
          audioUrl: widget.audioUrl,

        );
      }));
      // setState(() {
      //   effectAdd = false;
      // });
      setState(() {
        _loadingStreamCtrl.sink.add(false);
      });
    });
    videoFiles = File(saveVideoFile);
    return videoFiles;
  }

  Future<String> downloadFile(String url, String dir, String path,
      int filVidSize, File filterOne) async {
    // setState(() {
    //   effectAdd = true;
    // });
    flickManager.flickControlManager.autoPause();
 await FlutterDownloader.enqueue(
      url: url,
      savedDir: dir,
      showNotification: true,
      // show download progress in status bar (for Android)
      // openFileFromNotification:
      //     true, // click on notification to open downloaded file (for Android)
    );
    timeToWait(path, filVidSize, filterOne);
    return null;
  }

  //
  timeToWait(path, filVidSize, filterOne) {
    Timer(Duration(seconds: 3), () {
      int size = filterOne.lengthSync();
      if (size >= filVidSize) {
        addEffect(path);
        Fluttertoast.showToast(
            msg: "Download Completed.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0);

      } else {
        // print("chi");
        timeToWait(path, filVidSize, filterOne);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 10,
              child:
              // effectAdd == true
              //     ? Center(
              //         child: CircularProgressIndicator(
              //           backgroundColor: Colors.white,
              //         ),
              //       )
              //     :
                    Stack(
                  alignment: Alignment.topRight,
                  children: [
                  Container(
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Edit(
                            videoPath: widget.videoPath,
                            videoFile: widget.videoFile,
                            audioName: widget.audioName,
                            audioUrl: widget.audioUrl,
                            filter: true,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top:30.0),
                      child: Container(
                        decoration: new BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(40)),
                        ),
                        height: 50,
                        width: 60,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                    StreamBuilder<bool>(
                      stream: _loadingStreamCtrl.stream,
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.data == true) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[


                                Container(
                                  height: 200,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(18.0),
                                    ),   color: Colors.white30,
                                  ),

                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 50),
                                            child: Text(
                                              "Filter is applying Please wait...",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 20, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],

                                    ),
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
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: TrimEditor(
                  viewerHeight: 50.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: Duration(seconds: time),
                  onChangeStart: (value) {
                    _startValue = value;
                  },
                  onChangeEnd: (value) {
                    _endValue = value;
                  },
                  onChangePlaybackState: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child:
                // Stack(
                //   alignment: Alignment.bottomRight,
                //   children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/Smock1.mp4");
                            int filVidSize = 1849583;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/Smock1.mp4';
                            if (filterOne.existsSync()) {

                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });
                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1d82DOiDdR_yjtsJG-Xjk4JI8Ma7X_Pbv";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                fit: BoxFit.cover,
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/smoke1.jpg"),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/Rain.mp4");
                            int filVidSize = 3542319;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/Rain.mp4';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });
                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1UL_4xiLvonhfWyqDMUKHsTj42haERlE-";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/Rain.jpg"),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/love.mp4");
                            int filVidSize = 902015;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/love.mp4';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });
                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1weJQMF0Y_Z1J_m9Hf8LE92RaJesrVz61";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/love.jpg"),
                              ),
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/amber.m4v");
                            int filVidSize = 5602234;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/amber.m4v';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });

                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1NY1MwTjn6YpiBLJu4CQvb-q3zkqJB9EJ";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                fit: BoxFit.cover,
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/ember.jpg"),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/particles.m4v");
                            int filVidSize = 1504168;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/particles.m4v';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });

                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1hBzHufdTFJIJ2qLSsDDX1MJL-wApVy-v";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                fit: BoxFit.cover,
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/particles.jpg"),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/snow.m4v");
                            int filVidSize = 2749606;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/snow.m4v';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });
                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1QUY-EMkvos46PStRVxEc-f-nyImFDLkk";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                fit: BoxFit.cover,
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/snow.jpg"),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/bluestrip.mp4");
                            int filVidSize = 1852437;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/bluestrip.mp4';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });
                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1euPobPGtfMbtwlUWbuUWQ8BvQ7gGzkT1";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                fit: BoxFit.cover,
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/bluestrip.jpg"),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/goldparticles.mp4");
                            int filVidSize = 1403289;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/goldparticles.mp4';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });
                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1BScpZVErPpw0aP-3-JJ2G1lWMquAQl23";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                fit: BoxFit.cover,
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/goldparticles.jpg"),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/Greenparticles.m4v");
                            int filVidSize = 959495;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/Greenparticles.m4v';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });
                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1nHXs2oEG1ipj1GVj5VDKnHkgeDho10bz";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                fit: BoxFit.cover,
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/Greenparticles.jpg"),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            File filterOne = new File(
                                "/storage/emulated/0/jhoom/.filters/pinksparkeal.mp4");
                            int filVidSize = 153115;
                            final path =
                                '/storage/emulated/0/jhoom/.filters/pinksparkeal.mp4';
                            if (filterOne.existsSync()) {
                              addEffect(path);
                            } else {
                              setState(() {
                                filter = true;
                              });
                              Fluttertoast.showToast(
                                  msg: "File is downloading please wait.....",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              String videoUrl =
                                  "https://drive.google.com/uc?export=download&id=1yKC0ZUFGZzAsptevMO79EeJQGVLdSfXF";
                              String filePath =
                                  '/storage/emulated/0/jhoom/.filters';
                              await Directory(filePath).create(recursive: true);
                              downloadFile(
                                  videoUrl, filePath, path, filVidSize, filterOne);
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: filter == true
                                ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image(
                                fit: BoxFit.cover,
                                width: 40,
                                height: 30,
                                image: AssetImage(
                                    "assets/images/filters/pinksparkeal.jpg"),
                              ),
                            ),
                          ),
                        ),
                          // Container(
                          //   height: 90,
                          //   width: 90,
                          //   child:ClipRRect(
                          //     borderRadius: BorderRadius.circular(50.0),
                          //   ),
                          // ),

                      ]),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => Edit(
                    //           videoPath: widget.videoPath,
                    //           videoFile: widget.videoFile,
                    //           audioName: widget.audioName,
                    //           audioUrl: widget.audioUrl,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   child: Container(
                    //     decoration: new BoxDecoration(
                    //       color: Colors.deepOrangeAccent,
                    //       shape: BoxShape.rectangle,
                    //       borderRadius: BorderRadius.only(
                    //           topLeft: Radius.circular(50),
                    //           bottomLeft: Radius.circular(50)),
                    //     ),
                    //     height: 90,
                    //     width: 55,
                    //     child: Icon(
                    //       Icons.arrow_forward_ios,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                  // ],

                // )
      ),
          ],
        ),
      ),
    );
  }
}

