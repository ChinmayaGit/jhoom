import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:jhoom/main.dart';
import 'package:jhoom/video/Edit/Edits.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class CameraMusic extends StatefulWidget {
  static const String id = "CameraExampleHome";
  final List<CameraDescription> cameras;
  final String audioPath;
  final String audioUrl;
  final String audioName;

  CameraMusic(this.cameras, this.audioPath, this.audioUrl, this.audioName);

  @override
  _CameraMusicState createState() {
    return _CameraMusicState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

//void logError(String code, String message) =>
//    print('Error: $code\nError Message: $message');

class _CameraMusicState extends State<CameraMusic> with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VoidCallback videoPlayerListener;
  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = true;
  bool isRec = false;
  String currentTime = "00:00";
  String completeTime = "00:00";
  int va;

  int currentTimes;
  int currentTimess;
  int status;
  Timer _incrementCounterTimer;

  int a = 1;
  int b = 0;

  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  @override
  void initState() {
    super.initState();
    getTime();
    controller = new CameraController(
        widget.cameras[0], ResolutionPreset.medium,
        enableAudio: false);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        currentTime = duration.toString().split(".")[0];
        currentTimes = duration.inMilliseconds;
        currentTimess = duration.inSeconds;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        completeTime = duration.toString().split(".")[0];
      });
    });
  }

  getTime() async {
    status = await _audioPlayer.setUrl(widget.audioPath);
    va = await _audioPlayer.getDuration();
    return va;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _incrementCounterTimer.cancel();
    _timer.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool countdown = false;

  Color col = Colors.transparent;
  Color colOne = Colors.transparent;
  Color colTwo = Colors.black54;
  Color colThree = Colors.transparent;
  Color colFour = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return null;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: countdown == true
                      ? Text(
                          "$_start",
                          style: TextStyle(color: Colors.white, fontSize: 100),
                          textAlign: TextAlign.center,
                        )
                      : _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 180),
            //   child: Container(
            //     decoration: BoxDecoration(
            //         border: Border.all(
            //           color: Colors.white,
            //         ),
            //         borderRadius: BorderRadius.all(Radius.circular(15))),
            //     height: 50,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: <Widget>[
            //         Expanded(
            //           flex: 1,
            //           child: GestureDetector(
            //             onTap: () {
            //               setState(() {
            //                 col = Colors.black54;
            //                 colTwo = Colors.transparent;
            //                 colOne = Colors.transparent;
            //                 colThree = Colors.transparent;
            //                 colFour = Colors.transparent;
            //               });
            //             },
            //             child: Container(
            //               decoration: ShapeDecoration(
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: new BorderRadius.circular(18.0),
            //                 ), color: col,
            //               ),
            //
            //               child: Center(
            //                 child: Text(
            //                   "0.3x ",
            //                   style: TextStyle(color: Colors.white),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         Center(
            //           child: Text(
            //             " | ",
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //         Expanded(
            //           flex: 1,
            //           child: GestureDetector(
            //             onTap: () {
            //               setState(() {
            //                 col = Colors.transparent;
            //                 colOne = Colors.black54;
            //                 colTwo = Colors.transparent;
            //                 colThree = Colors.transparent;
            //                 colFour = Colors.transparent;
            //               });
            //             },
            //             child: Container(
            //               decoration: ShapeDecoration(
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: new BorderRadius.circular(18.0),
            //                 ), color: colOne,
            //               ),
            //               child: Center(
            //                 child: Text(
            //                   "0.5x ",
            //                   style: TextStyle(color: Colors.white),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         Center(
            //           child: Text(
            //             " | ",
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //         Expanded(
            //           flex: 1,
            //           child: GestureDetector(
            //             onTap: () {
            //               setState(() {
            //                 col = Colors.transparent;
            //                 colOne = Colors.transparent;
            //                 colTwo = Colors.black54;
            //                 colThree = Colors.transparent;
            //                 colFour = Colors.transparent;
            //               });
            //             },
            //             child: Container(
            //               decoration: ShapeDecoration(
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: new BorderRadius.circular(18.0),
            //                 ), color: colTwo,
            //               ),
            //               child: Center(
            //                 child: Text(
            //                   "1x ",
            //                   style: TextStyle(color: Colors.white),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         Center(
            //           child: Text(
            //             " | ",
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //         Expanded(
            //           flex: 1,
            //           child: GestureDetector(
            //             onTap: () {
            //               setState(() {
            //                 col = Colors.transparent;
            //                 colOne = Colors.transparent;
            //                 colTwo = Colors.transparent;
            //                 colThree = Colors.black54;
            //                 colFour = Colors.transparent;
            //               });
            //             },
            //             child: Container(
            //               decoration: ShapeDecoration(
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: new BorderRadius.circular(18.0),
            //                 ), color: colThree,
            //               ),
            //               child: Center(
            //                 child: Text(
            //                   "2x ",
            //                   style: TextStyle(color: Colors.white),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         Center(
            //           child: Text(
            //             " | ",
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //         Expanded(
            //           flex: 1,
            //           child: GestureDetector(
            //             onTap: () {
            //               setState(() {
            //                 col = Colors.transparent;
            //                 colTwo = Colors.transparent;
            //                 colOne = Colors.transparent;
            //                 colThree = Colors.transparent;
            //                 colFour = Colors.black54;
            //               });
            //             },
            //             child: Container(
            //               decoration: ShapeDecoration(
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: new BorderRadius.circular(18.0),
            //                 ), color: colFour,
            //               ),
            //               child: Center(
            //                 child: Text(
            //                   "3x ",
            //                   style: TextStyle(color: Colors.white),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Container(
              height: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    currentTime,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  Text(
                    " | ",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    completeTime,
                    style: TextStyle(
                        fontWeight: FontWeight.w300, color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(height: 200, child: _captureControlRowWidget()),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                      ),
                      color: Colors.white,
                    ),
                    child: _cameraTogglesRowWidget(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Please give us Camera,Storag and Microphone permission to work..',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Center(
        child: Transform.scale(
          scale: controller.value.aspectRatio / deviceRatio,
          child: new AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: new CameraPreview(controller),
          ),
        ),
      );
    }
  }

  Timer _timer;
  int _start = 3;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.indigoAccent,
          child: IconButton(
              icon: isRec
                  ? Icon(
                      Icons.fiber_manual_record,
                      color: Colors.redAccent,
                    )
                  : Icon(
                      Icons.videocam,
                      color: Colors.white,
                    ),
              // color: Colors.white,
              onPressed: () {
                setState(() {
                  isRec = true;
                  countdown = true;
                });
                startTimer();
                controller != null &&
                        controller.value.isInitialized &&
                        !controller.value.isRecordingVideo
                    ? Timer(Duration(seconds: 4), () async {
                        int status = await _audioPlayer.play(widget.audioPath);
                        if (status == 1) {
                          setState(() {
                            isRec = true;
                            countdown = false;
                          });
                        }
                        onVideoRecordButtonPressed();
                      })
                    : onStopButtonPressedTwo();
              }),
        ),
        IconButton(
          icon: isPlaying
              ? Icon(
                  Icons.pause,
                  color: Colors.white,
                )
              : Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
          onPressed: () {
            if (isPlaying) {
              setState(() {
                isPlaying = false;
              });
              _audioPlayer.pause();
              onPauseButtonPressed();
              va = va - currentTimes;
              return va;
            } else {
              _audioPlayer.resume();

              onResumeButtonPressed();
              setState(() {
                isPlaying = true;
              });
            }
          },
        )
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            height: 50,
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              activeColor: Colors.black,
              title: Icon(
                getCameraLensIcon(cameraDescription.lensDirection),
                color: Colors.black,
              ),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      // if (controller.value.hasError) {
      //   showInSnackBar('Camera error ${controller.value.errorDescription}');
      // }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null)
        // showInSnackBar('Saving video to $filePath');
        _incrementCounterTimer = Timer(Duration(milliseconds: va + 1), () {
          onStopButtonPressed();
          setState(() {});
        });
    });
  }

  audioVideo(videoFile) async {
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/jhoom';
    await Directory(dirPath).create(recursive: true);
    String saveVideoFile = '$dirPath/${timestamp()}.mp4';

    String localVideoFile1 = videoFile;
    String localVideoFile2 = widget.audioPath;

    _flutterFFmpeg
        .execute(
            "-i $localVideoFile1 -i $localVideoFile2 -c copy $saveVideoFile")
        .then((value) {
      File file = File(saveVideoFile);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Edit(
            videoPath: saveVideoFile,
            videoFile: file,
            audioName: widget.audioName,
            audioUrl: widget.audioUrl,
            filter: true,
          ),
        ),
      );
    });
  }

  void onStopButtonPressedTwo() async {
    isRec = false;
    _incrementCounterTimer.cancel();
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('Video recorded to: $videoPath');
    });
    _audioPlayer.stop();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/jhoom';
    await Directory(dirPath).create(recursive: true);
    String saveVideoFile = '$dirPath/${timestamp()}.mp4';
    String saveAudioFile = '$dirPath/${timestamp()}.mp3';

    String localVideoFile1 = videoPath;
    String localVideoFile2 = widget.audioPath;

    // print("chinu");
    // print(currentTimess);
    _flutterFFmpeg
        .execute("-t $currentTimess -i $localVideoFile2 $saveAudioFile")
        .then((value) {
      _flutterFFmpeg
          .execute(
              "-i $localVideoFile1 -i $saveAudioFile -c copy $saveVideoFile")
          .then((value) {
        File file = File(saveVideoFile);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Edit(
              videoPath: saveVideoFile,
              videoFile: file,
              audioName: widget.audioName,
              audioUrl: widget.audioUrl,
              filter: true,
            ),
          ),
        );
      });
    });
    setState(() {});
  }

  void onStopButtonPressed() {
    isRec = false;
    _incrementCounterTimer.cancel();
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('Video recorded to: $videoPath');
    });
    _audioPlayer.stop();
    audioVideo(videoPath);
    setState(() {});
  }

  void onPauseButtonPressed() {
    _incrementCounterTimer.cancel();
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    _incrementCounterTimer = Timer(Duration(milliseconds: va), () {
      // print("chinu");
      // print(va);
      onStopButtonPressed();
      _audioPlayer.stop();

      setState(() {});
    });
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('Video recording resumed');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      // showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
//    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
