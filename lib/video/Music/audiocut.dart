import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jhoom/video/Videcamera.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class AudioCut extends StatefulWidget {

  final List<CameraDescription> cameras;
  final Trimmer _trimmer;
  final String audioUrl;
  final String audioName;
  final String audioPath;

  AudioCut(this.cameras, this._trimmer, this.audioUrl,
      this.audioName, this.audioPath);

  @override
  _AudioCutState createState() => _AudioCutState();
}

class _AudioCutState extends State<AudioCut> {


  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;

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
  File bgFile;
  Future<void> downloadFile(File files) async {
    final String dirPath = '/storage/emulated/0/jhoom/downloads/';
    await Directory(dirPath).create(recursive: true);
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final File file = files;
    bgFile = await file
        .copy('/storage/emulated/0/jhoom/downloads/${timestamp()}.mp3');
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
      Fluttertoast.showToast(
          msg: "Audio Location: Internal storage/jhoom/downloads/",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.white54,
          textColor: Colors.black,
          fontSize: 16.0);
    });
  }
  bool getSong = false;
  compress(file) async {

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/jhoom';
    // String bgPath = appDocDir.uri.resolve("${timestamp()}").path;
    // File bgFile = await file.copy(bgPath);

    String localVideoFile2 = file;
    await Directory(dirPath).create(recursive: true);
    String compAudioFile = '$dirPath/${timestamp()}.mp3';

    _flutterFFmpeg
        .execute("-i $localVideoFile2 -b:a 96k -map a $compAudioFile")
        .then((rc) async {
    // String name = "null";

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CameraMusic(
                    widget.cameras,
                    compAudioFile,
                    widget.audioUrl,
                    widget.audioName)));
      setState(() {
        getSong = false;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: Center(child: Text("Audio cutter")),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.fiber_manual_record,color: Colors.transparent,),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Visibility(
                    visible: _progressVisibility,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  Container(
                    height: 120,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      color: Colors.white10,
                    ),
                    child: Center(
                      child: TrimEditor(
                        viewerHeight: 50.0,
                        viewerWidth: MediaQuery.of(context).size.width,
                        maxVideoLength: Duration(seconds: 120),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50.0),
                              ),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: FlatButton(
                                child: _isPlaying
                                    ? Icon(
                                        Icons.pause,
                                        size: 40.0,
                                        color: Colors.redAccent,
                                      )
                                    : Icon(
                                        Icons.play_arrow,
                                        size: 40.0,
                                        color: Colors.greenAccent,
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
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50.0),
                              ),
                              color: Colors.white,
                            ),
                            child: FlatButton(
                                onPressed: _progressVisibility
                                    ? null
                                    : () async {
                                        _saveVideo().then((audioPath) async {
                                          setState(() {
                                            getSong = true;
                                          });
                                          final FlutterFFmpeg _flutterFFmpeg =
                                              new FlutterFFmpeg();
                                          final Directory extDir =
                                              await getApplicationDocumentsDirectory();
                                          final String dirPath =
                                              '${extDir.path}/jhoom';
                                          await Directory(dirPath)
                                              .create(recursive: true);

                                          String timestamp() => DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString();
                                          String audioFile =
                                              '$dirPath/${timestamp()}.mp3';
                                          _flutterFFmpeg
                                              .execute(
                                                  "-i $audioPath -vn -ar 44100 -ac 2 -ab 96k -f mp3 $audioFile")
                                              .then((rc) {
                                            // print("chinu");
                                            // print(audioPath);
                                            // print(audioFile);
                                            // print(widget.audioUrl);
                                            // print( widget.audioName);
                                            compress(audioFile);
                                          });

                                        });


                                      },
                                child:
                                getSong == true
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    :
                                Icon(
                                  Icons.arrow_forward_ios,
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _progressVisibility
                              ? null
                              : () async {
                            _saveVideo().then((audioPath) async {
                              final FlutterFFmpeg _flutterFFmpeg =
                              new FlutterFFmpeg();
                              final Directory extDir =
                              await getApplicationDocumentsDirectory();
                              final String dirPath =
                                  '${extDir.path}/jhoom';
                              await Directory(dirPath)
                                  .create(recursive: true);

                              String timestamp() => DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              String audioFile =
                                  '$dirPath/${timestamp()}.mp3';
                              _flutterFFmpeg
                                  .execute(
                                  "-i $audioPath -vn -ar 44100 -ac 2 -ab 96k -f mp3 $audioFile")
                                  .then((rc) {
                                File audioFiles=File(audioFile);
                                downloadFile(audioFiles);
                              });
                            });

                          },
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Container(
                          height: 50,
                          decoration: new BoxDecoration(
                            color: Colors.white10,
                            shape: BoxShape.rectangle,
                            borderRadius:
                            BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.file_download,color: Colors.white,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Save Crop audio to phone storage.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],

                          )),
                    ),
                          ),

                ],
              ),
            ]));
  }
}
