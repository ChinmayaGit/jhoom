import 'dart:io';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'filters.dart';

import 'package:jhoom/video/Upload.dart';

class Edit extends StatefulWidget {
  static const String id = "Edit";
  final File videoFile;
  final String videoPath;
  final String audioUrl;
  final String audioName;
final bool filter;

  Edit({
    this.videoPath,
    this.videoFile,
    this.audioName,
    this.audioUrl,   @required this.filter,
  });

  @override
  _EditState createState() => new _EditState();
}

class _EditState extends State<Edit> {
  FlickManager flickManager;
  final Trimmer _trimmer = Trimmer();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

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
  bool analysing = false;
  changeResolution(videoFile) async {
    setState(() {
 analysing = true;
    });
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/jhoom';
    await Directory(dirPath).create(recursive: true);
    String saveVideoFile = '$dirPath/${timestamp()}.mp4';

    String localVideoFile1 = videoFile;

    _flutterFFmpeg
        .execute(
        "-i $localVideoFile1 -c:a copy -s 720x480 $saveVideoFile")
        .then((value) async{
      File file =File(saveVideoFile);
      if (file != null) {

        await _trimmer.loadVideo(videoFile: file);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) {
          return Filters(
            trimmer: _trimmer,
            videoPath: saveVideoFile,
            videoFile: file,
            audioName: widget.audioName,
            audioUrl: widget.audioUrl,
          );
        }));
      }
      setState(() {
  analysing = false;
      });
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
                child:  analysing == true?
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,200,0,10),
                      child: CircularProgressIndicator(),
                    ),
                    Text(
                      "Analysing Video...",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15),
                    ),
                  ],

                )
                    :FlickVideoPlayer(
                  flickManager: flickManager,
                  flickVideoWithControls: FlickVideoWithControls(
                    controls: FlickPortraitControls(),
                  ),
                  flickVideoWithControlsFullscreen: FlickVideoWithControls(
                    controls: FlickLandscapeControls(),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: FlatButton(
                            onPressed: () async {
                              File file = widget.videoFile;
                              if (file != null) {
                                await _trimmer.loadVideo(videoFile: file);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return TrimmerView(_trimmer,widget.audioName,widget.audioUrl);
                                }));
                              }
                            },
                            child: Icon(
                              Icons.content_cut,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child:
                        widget.filter == true?
                        FlatButton(
                            onPressed: () async {
                              File file = widget.videoFile;
                              if (file != null) {
                                await _trimmer.loadVideo(videoFile: file);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return Filters(
                                    trimmer: _trimmer,
                                    videoPath: widget.videoPath,
                                    videoFile: widget.videoFile,
                                    audioName: widget.audioName,
                                    audioUrl: widget.audioUrl,
                                  );
                                }));
                              }
                            },
                            child: Icon(
                              Icons.filter,
                              color: Colors.white,
                            ))
                            :
                        FlatButton(
                            onPressed: () {
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
                                            "Video resolution may decrease after applying filters",
                                            textAlign: TextAlign.center,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              changeResolution(widget.videoPath);
                                            },
                                            child:
                                            Padding(
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
                                                      child:
                                                      Text(
                                                        "Next",
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
                            },
                            child: Icon(
                              Icons.filter,
                              color: Colors.white,
                            ))

                      )),
                    // Expanded(
                    //   flex: 1,
                    //   child: Padding(
                    //     padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    //     child: FlatButton(
                    //
                    //           onPressed: () async{
                    //             File file = widget.videoFile;
                    //             if (file != null) {
                    //               await _trimmer.loadVideo(videoFile: file);
                    //               Navigator.of(context)
                    //                   .push(MaterialPageRoute(builder: (context) {
                    //                 return SlowFastMo(_trimmer,widget.audioName,widget.audioUrl);
                    //               }));
                    //             }
                    //           },
                    //
                    //         child: Icon(
                    //           Icons.slow_motion_video,
                    //           color: Colors.white,
                    //         )),
                    //   ),
                    // ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Upload(
                                    videoPath: widget.videoPath,
                                    videoFile: widget.videoFile,
                                    audioName: widget.audioName,
                                    audioUrl: widget.audioUrl,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            )),
                      ),
                    ),],
                ),
              )
            ])));
  }
}

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;
  final String audioUrl;
  final String audioName;
  TrimmerView(this._trimmer,this.audioName,this.audioUrl);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;
  Duration fastestMarathon = Duration(hours: 0, minutes: 0, seconds: 25);

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    await widget._trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
        .then((value) {
      setState(() {
        _progressVisibility = false;

        _value = value;
        // print(value);
      });
    });

    return _value;
  }

//checkTime(){
//  print(_endValue);
//  print(_startValue);
//    print(_endValue - _startValue);
//    if(_endValue - _startValue<26000)//2600 =26sec
//    {
//      _saveVideo().then((outputPath) {
//        print('OUTPUT PATH: $outputPath');
//        final snackBar = SnackBar(
//          content: Text('Video Saved successfully'),
//        );
//        Scaffold.of(context).showSnackBar(snackBar);
//      });
//    }else{
//     return Scaffold.of(context).showSnackBar(SnackBar(
//       content: Text('audio must be less than 25 sec'),
//     ),);
//  }
//}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: VideoViewer(),
                ),
                Center(
                  child: TrimEditor(
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: Duration(seconds: 30),
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: FlatButton(
                        child: _isPlaying
                            ? Icon(
                                Icons.pause,
                                size: 40.0,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.play_arrow,
                                size: 40.0,
                                color: Colors.white,
                              ),
                        onPressed: () async {
                          bool playbackState =
                              await widget._trimmer.videPlaybackControl(
                            startValue: _startValue,
                            endValue: _endValue,
                          );
                          setState(() {
                            _isPlaying = playbackState;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: FlatButton(
                          onPressed: _progressVisibility
                              ? null
                              : () async {
                                  _saveVideo().then((videoPath) async {
                                    File videoFiles = File(videoPath);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Edit(
                                                  videoFile: videoFiles,
                                                  videoPath: videoPath,
                                              audioName: widget.audioName,
                                              audioUrl: widget.audioUrl,
                                              filter: true,
                                                )));
                                    // print('OUTPUT PATH: $videoPath');
                                    final snackBar = SnackBar(
                                      content: Text(
                                          'Video Saved successfully $videoPath'),
                                    );
                                    Scaffold.of(context).showSnackBar(snackBar);
                                  });
//                    checkTime();
                                },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
