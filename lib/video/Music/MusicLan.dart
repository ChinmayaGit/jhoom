import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'audiocut.dart';
import 'global.dart';
import 'musicupload.dart';
import 'package:path/path.dart' as p;

class SongCategories extends StatefulWidget {
  final List<CameraDescription> cameras;

  SongCategories(this.cameras);

  @override
  _SongCategoriesState createState() => _SongCategoriesState();
}

class _SongCategoriesState extends State<SongCategories> {
  int _selectedCat = 0;
  File file;
  String fileName = '';
  final Trimmer _trimmer = Trimmer();
  // bool getSong = false;

  Future getaudio() async {

    file = await FilePicker.getFile(type: FileType.audio);
    fileName = p.basename(file.path);
    setState(() {
      fileName = p.basename(file.path);
    });
    compress(file, fileName);
  }

  compress(file, fileName) async {
    // setState(() {
    //   getSong = true;
    // });
    // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    // final Directory extDir = await getApplicationDocumentsDirectory();
    //
    // final String dirPath = '${extDir.path}/jhoom';
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String bgPath = appDocDir.uri.resolve("${timestamp()}").path;
    // File bgFile = await file.copy(bgPath);
    //
    // String localVideoFile2 = bgPath;
    // await Directory(dirPath).create(recursive: true);
    // String compAudioFile = '$dirPath/${timestamp()}.mp3';
    // _flutterFFmpeg
    //     .execute("-i $localVideoFile2 -b:a 96k -map a $compAudioFile")
    //     .then((rc) async {
      String name = "null";
    //
      if (file != null) {
        await _trimmer.loadVideo(videoFile: file);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AudioCut(widget.cameras, _trimmer, name, name, bgPath);
        }));
      }
    //   setState(() {
    //     getSong = false;
    //   });
    // });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                Text(
                  " Songs Categories",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 30),
                ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 15),
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (ctx, i) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCat = i;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 25.0),
                            // padding: const EdgeInsets.symmetric(vertical: 45.0),
                            width: 50,
                            constraints: BoxConstraints(minHeight: 101),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border:
                                  _selectedCat == i ? Border.all() : Border(),
                              color: _selectedCat == i
                                  ? Colors.transparent
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            // child: Transform.rotate(
                            //   angle: -pi / 2,
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: Text(
                                "${categories[i].title}",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        color: _selectedCat == i
                                            ? Colors.black
                                            : Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ListView.builder(
                      itemCount: categories[_selectedCat].subCat.length,
                      itemBuilder: (ctx, i) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MusicUploadPage(
                                        widget.cameras,
                                        "${categories[_selectedCat].subCat[i].title}",
                                        "${categories[_selectedCat].title}")));
//                            print("${categories[_selectedCat].subCat[i].title}");
//                            print("${categories[_selectedCat].title}");
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(9.0),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image(
                                          image: AssetImage(
                                              categories[_selectedCat]
                                                  .subCat[i]
                                                  .ico),
                                          height: 40,
                                        ))),
                                Expanded(
                                  flex: 4,
                                  child: Center(
                                    child: Text(
                                      "${categories[_selectedCat].subCat[i].title}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Icon(Icons.chevron_right,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Container(
                    height: 100,
                    child: Center(
                      child:
                      // getSong == true
                      //     ? Center(
                      //         child: CircularProgressIndicator(),
                      //       )
                      //     :
                      Text(
                              "Get Song from Storage",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    getaudio();
                  },
                ))
          ],
        ),
      ),
    );
  }
}
