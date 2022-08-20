// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:video_trimmer/trim_editor.dart';
// import 'package:video_trimmer/video_trimmer.dart';
// import 'package:video_trimmer/video_viewer.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
//
// import 'Edits.dart';
//
// // class SlowFastMo extends StatefulWidget {
// //
// //   final File videoFile;
// //   final String videoPath;
// //   final String audioUrl;
// //   final String audioName;
// //   final Trimmer trimmer;
// //   SlowFastMo({
// //     this.videoPath,
// //     this.videoFile,
// //     this.audioName,
// //     this.audioUrl,
// //     this.trimmer,
// //   });
// //
// //   @override
// //   _SlowFastMoState createState() => new _SlowFastMoState();
// // }
// //
// // class _SlowFastMoState extends State<SlowFastMo> {
// //   FlickManager flickManager;
// //   final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
// //   final Trimmer _trimmer = Trimmer();  final _loadingStreamCtrl = StreamController<bool>.broadcast();
// //   double _startValue = 0.0;
// //   double _endValue = 0.0;
// //   File videoFiles;
// //
// //   void initState() {
// //     super.initState();
// //
// //     flickManager = FlickManager(
// //         videoPlayerController: VideoPlayerController.file(widget.videoFile));
// //   }
// //
// //   @override
// //   void dispose() {
// //     flickManager.dispose();
// //     super.dispose();
// //   }
// //   // bool analysing = false;
// //
// //   slowMo(path) async {
// //
// //     flickManager.flickControlManager.autoPause();
// //     setState(() {
// //       _loadingStreamCtrl.sink.add(true);
// //     });
// //     String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
// //     final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
// //     String _localVideoFile1 = widget.videoPath;
// //     String _localVideoFile2 = path;
// //     final Directory extDir = await getApplicationDocumentsDirectory();
// //     final String dirPath = '${extDir.path}/jhoom';
// //     await Directory(dirPath).create(recursive: true);
// //     String saveVideoFile = "$dirPath/${timestamp()}.mp4";
// //     Duration startPoint = Duration(milliseconds: _startValue.toInt());
// //     Duration endPoint = Duration(milliseconds: _endValue.toInt());
// //
// //     // print(startPoint.inSeconds.toString());
// //     // print(endPoint.inSeconds.toString());
// //
// //     var arguments = [
// //       "-i",
// //       "$_localVideoFile2",
// //       "-i",
// //       "$_localVideoFile1",
// //       "-filter:v",
// //       "setpts=2.0*PTS:enable='between(t,${startPoint.inSeconds.toString()},${endPoint.inSeconds.toString()})'",
// //       "$saveVideoFile"
// //     ];
// //
// //     _flutterFFmpeg.executeWithArguments(arguments).then((value) {
// //
// //       Navigator.of(context).push(MaterialPageRoute(builder: (context) {
// //
// //         return SlowFastMo(
// //
// //           trimmer: _trimmer,
// //           videoFile: videoFiles,
// //           videoPath: saveVideoFile,
// //           audioName: widget.audioName,
// //           audioUrl: widget.audioUrl,
// //
// //         );
// //       }));
// //       // setState(() {
// //       //   effectAdd = false;
// //       // });
// //
// //       setState(() {
// //         _loadingStreamCtrl.sink.add(false);
// //       });
// //     });
// //     videoFiles = File(saveVideoFile);
// //     return videoFiles;
// //   }
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //         backgroundColor: Colors.black,
// //         body: Center(
// //             child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: <Widget>[
// //                   Expanded(
// //                     flex: 10,
// //                     child:
// //                     Stack(
// //                       alignment: Alignment.topRight,
// //                       children: [
// //                         Container(
// //                           child: FlickVideoPlayer(
// //                             flickManager: flickManager,
// //                             flickVideoWithControls: FlickVideoWithControls(
// //                               controls: FlickPortraitControls(),
// //                             ),
// //                             flickVideoWithControlsFullscreen: FlickVideoWithControls(
// //                               controls: FlickLandscapeControls(),
// //                             ),
// //                           ),
// //                         ),
// //                         GestureDetector(
// //                           onTap: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) => Edit(
// //                                   videoPath: widget.videoPath,
// //                                   videoFile: widget.videoFile,
// //                                   audioName: widget.audioName,
// //                                   audioUrl: widget.audioUrl,
// //                                   filter: true,
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                           child: Padding(
// //                             padding: const EdgeInsets.only(top:30.0),
// //                             child: Container(
// //                               decoration: new BoxDecoration(
// //                                 color: Colors.deepOrangeAccent,
// //                                 shape: BoxShape.rectangle,
// //                                 borderRadius: BorderRadius.only(
// //                                     topLeft: Radius.circular(10),
// //                                     bottomLeft: Radius.circular(40)),
// //                               ),
// //                               height: 50,
// //                               width: 60,
// //                               child: Icon(
// //                                 Icons.arrow_forward_ios,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         StreamBuilder<bool>(
// //                           stream: _loadingStreamCtrl.stream,
// //                           builder: (context, AsyncSnapshot<bool> snapshot) {
// //                             if (snapshot.data == true) {
// //                               return Center(
// //                                 child: Column(
// //                                   mainAxisAlignment: MainAxisAlignment.center,
// //                                   children: <Widget>[
// //
// //
// //                                     Container(
// //                                       height: 200,
// //                                       decoration: ShapeDecoration(
// //                                         shape: RoundedRectangleBorder(
// //                                           borderRadius: new BorderRadius.circular(18.0),
// //                                         ),   color: Colors.white30,
// //                                       ),
// //
// //                                       child: Column(
// //                                         children: [
// //                                           Padding(
// //                                             padding: const EdgeInsets.all(20.0),
// //                                             child: CircularProgressIndicator(),
// //                                           ),
// //                                           Center(
// //                                             child: Padding(
// //                                               padding: const EdgeInsets.only(top: 50),
// //                                               child: Text(
// //                                                 "Filter is applying Please wait...",
// //                                                 textAlign: TextAlign.center,
// //                                                 style: TextStyle(fontSize: 20, color: Colors.white),
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ],
// //
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               );
// //                             }
// //                             return Container();
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 2,
// //                     child: Center(
// //                       child: TrimEditor(
// //                         viewerHeight: 50.0,
// //                         viewerWidth: MediaQuery.of(context).size.width,
// //                         maxVideoLength: Duration(seconds: 30),
// //                         onChangeStart: (value) {
// //                           _startValue = value;
// //                         },
// //                         onChangeEnd: (value) {
// //                           _endValue = value;
// //                         },
// //                         onChangePlaybackState: (value) {
// //                           setState(() {});
// //                         },
// //                       ),
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 1,
// //                     child: GestureDetector(
// //                       onTap:
// //                       ()
// //                         {
// //                       slowMo(widget.videoPath);},
// //                       child: Container(
// //                         color: Colors.white,
// //                         child: Icon(Icons.slow_motion_video),
// //                       ),
// //                     ),
// //                   )
// //                 ])));
// //   }
// // }
//
// class SlowFastMo extends StatefulWidget {
//   final Trimmer _trimmer;
//   final String audioUrl;
//   final String audioName;
//   SlowFastMo(this._trimmer,this.audioName,this.audioUrl);
//
//   @override
//   _SlowFastMoState createState() => _SlowFastMoState();
// }
//
// class _SlowFastMoState extends State<SlowFastMo> {
//   double _startValue = 0.0;
//   double _endValue = 0.0;
//   bool _isPlaying = false;
//   bool _progressVisibility = false;
//   Duration fastestMarathon = Duration(hours: 0, minutes: 0, seconds: 25);
//
//   Future<String> _saveVideo() async {
//     setState(() {
//       _progressVisibility = true;
//     });
//
//     String _value;
//
//     await widget._trimmer
//         .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
//         .then((value) {
//       setState(() {
//         _progressVisibility = false;
//
//         _value = value;
//         // print(value);
//       });
//     });
//
//     return _value;
//   }
//
// //checkTime(){
// //  print(_endValue);
// //  print(_startValue);
// //    print(_endValue - _startValue);
// //    if(_endValue - _startValue<26000)//2600 =26sec
// //    {
// //      _saveVideo().then((outputPath) {
// //        print('OUTPUT PATH: $outputPath');
// //        final snackBar = SnackBar(
// //          content: Text('Video Saved successfully'),
// //        );
// //        Scaffold.of(context).showSnackBar(snackBar);
// //      });
// //    }else{
// //     return Scaffold.of(context).showSnackBar(SnackBar(
// //       content: Text('audio must be less than 25 sec'),
// //     ),);
// //  }
// //}
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Builder(
//         builder: (context) => Center(
//           child: Container(
//             padding: EdgeInsets.only(bottom: 30.0),
//             color: Colors.black,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: <Widget>[
//                 Visibility(
//                   visible: _progressVisibility,
//                   child: LinearProgressIndicator(
//                     backgroundColor: Colors.red,
//                   ),
//                 ),
//                 Expanded(
//                   child: VideoViewer(),
//                 ),
//                 Center(
//                   child: TrimEditor(
//                     viewerHeight: 50.0,
//                     viewerWidth: MediaQuery.of(context).size.width,
//                     maxVideoLength: Duration(seconds: 30),
//                     onChangeStart: (value) {
//                       _startValue = value;
//                     },
//                     onChangeEnd: (value) {
//                       _endValue = value;
//                     },
//                     onChangePlaybackState: (value) {
//                       setState(() {
//                         _isPlaying = value;
//                       });
//                     },
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: FlatButton(
//                         child: _isPlaying
//                             ? Icon(
//                           Icons.pause,
//                           size: 40.0,
//                           color: Colors.white,
//                         )
//                             : Icon(
//                           Icons.play_arrow,
//                           size: 40.0,
//                           color: Colors.white,
//                         ),
//                         onPressed: () async {
//                           bool playbackState =
//                           await widget._trimmer.videPlaybackControl(
//                             startValue: _startValue,
//                             endValue: _endValue,
//                           );
//                           setState(() {
//                             _isPlaying = playbackState;
//                           });
//                         },
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: FlatButton(
//                           onPressed: _progressVisibility
//                               ? null
//                               : () async {
//                             _saveVideo().then((videoPath) async {
//
//                               final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
//                               String localVideoFile1 = videoPath;
//
//                               String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
//                               final Directory extDir = await getApplicationDocumentsDirectory();
//                               final String dirPath = '${extDir.path}/jhoom';
//                               await Directory(dirPath).create(recursive: true);
//                               String saveVideoFile = '$dirPath/${timestamp()}.mp4';
//                               String cutOne = '$dirPath/${timestamp()}.ts';
//                               String cutTwo = '$dirPath/${timestamp()}.ts';
//                               String cutThree = '$dirPath/${timestamp()}.mp4';
//                               _flutterFFmpeg
//                                   .execute(
//                                   "-i $localVideoFile1 -filter:v 'setpts=2.0*PTS' $saveVideoFile")
//                                   .then((value) {
//
//                                 // _flutterFFmpeg
//                                 //     .execute(
//                                 //     "-i $localVideoFile1 -ss $_startValue -c copy -bsf:v h264_mp4toannexb -f mpegts $cutOne")
//                                 //     .then((value) {
//                                 //   _flutterFFmpeg
//                                 //       .execute(
//                                 //       "-i $localVideoFile1 -ss $_endValue -c copy -bsf:v h264_mp4toannexb -f mpegts $cutTwo")
//                                 //       .then((value) {
//                                 //     // ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
//                                 //     _flutterFFmpeg
//                                 //         .execute(
//                                 //         "-i 'concat:$cutOne|$cutTwo' -c copy -bsf:a aac_adtstoasc $cutThree")
//                                 //         .then((value) {
//                                       File videoFiles = File(saveVideoFile);
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) => Edit(
//                                                 videoFile: videoFiles,
//                                                 videoPath: saveVideoFile,
//                                                 audioName: widget.audioName,
//                                                 audioUrl: widget.audioUrl,
//                                                 filter: true,
//                                               )));
//                                       // print('OUTPUT PATH: $videoPath');
//                                       final snackBar = SnackBar(
//                                         content: Text(
//                                             'Video Saved successfully $videoPath'),
//                                       );
//                                       Scaffold.of(context).showSnackBar(snackBar);
//
//                                 //     });
//                                 //
//                                 //
//                                 //   });
//                                 //
//                                 //
//                                 //
//                                 // });
//
//
//                               });
//
//
//
//
//                             });
// //                    checkTime();
//                           },
//                           child: Icon(
//                             Icons.arrow_forward_ios,
//                             color: Colors.white,
//                           )),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }