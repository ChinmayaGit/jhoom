import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../video/Music/MusicLan.dart';
import 'home.dart';

import 'package:jhoom/video/Edit/Edits.dart';
import 'package:jhoom/widgets/header.dart';


class CapturePage extends StatefulWidget {
  static const String id = "CapturePage";

  final List<CameraDescription> cameras;

  CapturePage(this.cameras);

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  File file;
  File files;
  File bgFile;

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
    requestPermission(Permission.storage).then((value) =>
        requestPermission(Permission.camera)
            .then((value) => requestPermission(Permission.microphone)));
  }



//   auddioVideo(videoFile, file) async {
//     final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
//     final Directory extDir = await getApplicationDocumentsDirectory();
//
//     final String dirPath = '${extDir.path}/jhoom';
//     await Directory(dirPath).create(recursive: true);
//     String audioFileName = '${timestamp()}.mp3';
//
//     String audioFile = '$dirPath/${timestamp()}.mp3';
//
// //    await Directory(dirPath).create(recursive: true);
// //    String compVideoFile = '$dirPath/${timestamp()}.mp4';
//     String localVideoFile1 = videoFile;
//
//     _flutterFFmpeg
//         .execute(
//             "-i $localVideoFile1 -vf mpdecimate -vn -ar 44100 -ac 2 -ab 192k -f mp3 $audioFile")
//         .then((rc) async {
// //    _flutterFFmpeg
// //        .execute (
// //            "-i $localVideoFile1 -vf mpdecimate -b 800k $compVideoFile")
// //        .then((rc) async{
// //
// //        File files = File(compVideoFile);
//       File audioFiles = File(audioFile);
//      // Navigator.push(
//      //   context,
//      //   MaterialPageRoute(
//      //     builder: (context) => Edit(
//      //       currentUser: currentUser,
//      //       videoPath: localVideoFile1,
//      //       videoFile: file,
//      //       audioFile: audioFiles,
//      //       audioName: audioFileName,
//      //     ),
//      //   ),
//      // );
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => Upload(
//             currentUser: currentUser,
//             videoPath: localVideoFile1,
//             videoFile: file,
//             // audioFile: audioFiles,
//             // audioName: audioFileName,
//           ),
//         ),
//       );
//     });
//   }
  TextEditingController request = TextEditingController();

 addRequest() async {
    await Firestore.instance.collection('Request').document().setData({
      'id': currentUser.id,
      'request': request.text,
      'time': timestamp,
    });
    setState(() {
      Fluttertoast.showToast(
          msg: "Request send successfully.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.black,
          textColor: Colors.lightGreenAccent,
          fontSize: 16.0);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(context) {
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    return _permissionStatus.isGranted
        ? Scaffold(
            appBar: header(context, titleText: "Upload"),
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                new Image(
                  image: new AssetImage('assets/images/Upload/cameraimg.jpg'),
                  fit: BoxFit.cover,
                  color: Colors.black54,
                  colorBlendMode: BlendMode.darken,
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Image(
                                image: new AssetImage(
                                    'assets/images/Upload/camermuse.png'),
                                height: 100,
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Camera",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "+",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "Music",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )),
                            Expanded(
                              flex: 1,
                              child: Image(
                                image: new AssetImage(
                                    'assets/images/Upload/Musicico.png'),
                              ),
                            ),
                          ],
                        ),
                        color: Colors.white30,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SongCategories(widget.cameras)));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Image(
                                image: new AssetImage(
                                    'assets/images/Upload/camera.png'),
                                height: 100,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text("From Camera",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25)),
                            )
                          ],
                        ),
                        color: Colors.white30,
                        onPressed: () async {
                          // File file = await ImagePicker.pickVideo(
                          //   source: ImageSource.camera,
                          // );
                          // setState(() {
                          //   this.file = file;
                          // });
                          final file = await ImagePicker().getVideo(
                            source: ImageSource.camera,
                          );
                          setState(() {
                            files = File(file.path);
                          });
                          Directory appDocDir =
                              await getApplicationDocumentsDirectory();
                          String bgPath =
                              appDocDir.uri.resolve("${timestamp()}.mp4").path;
                          bgFile = await files.copy(bgPath);
                          if (bgPath != null) {
                            // auddioVideo(bgPath, files);
                            String name = "null";
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => Upload(
                            //       videoPath: bgPath,
                            //       videoFile: files,
                            //       audioName: name,
                            //       audioUrl: name,
                            //     ),
                            //   ),
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Edit(
                                  videoPath: bgPath,
                                  videoFile: files,
                                  audioName: name,
                                  audioUrl: name,
                                  filter: true,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Image(
                                image: new AssetImage(
                                    'assets/images/Upload/gallery.png'),
                                height: 100,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text("From Gallery",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25)),
                            ),
                          ],
                        ),
                        color: Colors.white30,
                        onPressed: () async {
                          // File file = await ImagePicker.pickVideo(
                          //   source: ImageSource.gallery,
                          // );
                          // setState(() {
                          //   this.file = file;
                          // });
                          final file = await ImagePicker().getVideo(
                            source: ImageSource.gallery,
                          );
                          setState(() {
                            files = File(file.path);
                          });
                          Directory appDocDir =
                              await getApplicationDocumentsDirectory();
                          String bgPath =
                              appDocDir.uri.resolve("${timestamp()}").path;
                          bgFile = await files.copy(bgPath);
                          if (bgPath != null) {
                            String name = "null";
                            // // auddioVideo(bgPath, files);
                            //
                            // // Navigator.push(
                            // //   context,
                            // //   MaterialPageRoute(
                            // //     builder: (context) => Upload(
                            // //       videoPath: bgPath,
                            // //       videoFile: files,
                            // //       audioName: name,
                            // //       audioUrl: name,
                            // //     ),
                            // //   ),
                            // // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Edit(
                                  videoPath: bgPath,
                                  videoFile: files,
                                  audioName: name,
                                  audioUrl: name,
                                  filter: false,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Text("Request Box",
                            style:
                                TextStyle(color: Colors.white, fontSize: 25)),
                        color: Colors.white30,
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
                                        "Tell us what new features you want we will add it as soon as possible.",
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "",
                                        textAlign: TextAlign.center,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          TextField(
                                            controller: request,
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),

                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        addRequest();
                                      },
                                      child: Center(
                                        child: Row(
                                          children: [

                                            Text("Sent"), SizedBox(width: 5,),      Icon(Icons.send),
                                          ],
                                        ),
                                      ))
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: FloatingActionButton(
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
                                "We Need Developers and Investors.If you want to help us or want to join us then contact us at:",
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "",
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "chinugarnaiklabs@gmail.com",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.info_outline,
                  color: Colors.black,
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: header(context, titleText: "Upload"),
            body: GestureDetector(
              onTap: () {
                requestPermission(Permission.storage).then((value) =>
                    requestPermission(Permission.camera).then(
                        (value) => requestPermission(Permission.microphone)));
              },
              child: Stack(fit: StackFit.expand, children: <Widget>[
                new Image(
                  image: new AssetImage('assets/images/Upload/ameraimg.jpg'),
                  fit: BoxFit.cover,
                  color: Colors.black54,
                  colorBlendMode: BlendMode.darken,
                ),
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Please give us the Storage permission , Camera permission and Microphone permission to Record the videos.",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                              ),
                              color: Colors.white30),
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "Grant us permissions.",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )),
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          );
  }
}
