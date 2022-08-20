import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:jhoom/models/Audiofiredata.dart';
import 'package:jhoom/pages/home.dart';
import 'package:jhoom/video/Music/audiocut.dart';
import 'package:jhoom/widgets/progress.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'dart:io';
import '../Videcamera.dart';

class MusicUploadPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String name;
  final String lan;
  MusicUploadPage(this.cameras,this.name,this.lan);

  @override
  _MusicUploadPageState createState() => _MusicUploadPageState();
}

class _MusicUploadPageState extends State<MusicUploadPage> {
  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';
  final _loadingStreamCtrl = StreamController<bool>.broadcast();
  final _appbarStreamCtrl = StreamController<bool>.broadcast();
  final Trimmer _trimmer = Trimmer();
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int va;
  String currentTime = "00:00";
  String completeTime = "00:00";
  String audioPath;
  String sa;
int add = 0;
  @override
  void initState() {
    super.initState();
    _audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        currentTime = duration.toString().split(".")[0];
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        completeTime = duration.toString().split(".")[0];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _appbarStreamCtrl.close();
    _loadingStreamCtrl.close();
  }
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> audioInfo = audioRef
        .document(widget.lan).collection(widget.name).where("name", isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = audioInfo;
    });
  }
  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<AudioSearch> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          AudioFireData user = AudioFireData.fromDocument(doc);
          AudioSearch searchResult = AudioSearch(user,widget.cameras);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }
  clearSearch() {
    searchController.clear();
  }
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: new Center(
            child: Container(
              child: StreamBuilder<bool>(
                  stream: _loadingStreamCtrl.stream,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.data == true) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(

                          child: Center(
                            child: Column(
                              children: <Widget>[
                                CircularProgressIndicator(),
                                Text("Downloading ....",style: TextStyle(color: Colors.black),),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return StreamBuilder<bool>(
                stream: _appbarStreamCtrl.stream,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.data == true) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          currentTime,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,color: Colors.black),
                        ),
                        Text(
                          " | ",style: TextStyle(
                      color: Colors.black),
                        ),
                        Text(
                          completeTime,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,color: Colors.black),
                        ),
                      ],
                    );
                  }
                  return Container(
                    child: Text(widget.name,style: TextStyle(color: Colors.black), textAlign: TextAlign.center),
                  );
                },
              );}),
            ),
          ),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios,color: Colors.black,),
            onPressed: () { _appbarStreamCtrl.sink.add(false);
            _audioPlayer.stop();
            Navigator.pop(context);
            },
          ),
          actions: [
            // Padding(
            //   padding: EdgeInsets.all(15.0),
            //   child:
            //   // add >= 2?
            //   IconButton(icon: Icon(Icons.cloud_upload,color: Colors.black,), onPressed: getaudio),
            //   //     :
            //   // IconButton(icon: Icon(Icons.cloud_upload,color: Colors.black,), onPressed: (){
            //   //   add+=1;
            //   //   print(add);
            //   //   showDialog(
            //   //     context: context,
            //   //     builder: (BuildContext context) {
            //   //       // return object of type Dialog
            //   //       return AlertDialog(
            //   //         backgroundColor: Colors.white,
            //   //         title: Center(
            //   //           child: Column(
            //   //             children: <Widget>[
            //   //
            //   //               Text(
            //   //                 "Due to some miss upload we need to get you trust.Share this app to 10 people to activate upload feature.",
            //   //                 textAlign: TextAlign.center,
            //   //               ),
            //   //             ],
            //   //           ),
            //   //         ),
            //   //       );
            //   //     },
            //   //   );
            //
            //   // })
            // )
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.fiber_manual_record,color: Colors.transparent,),
          ),
          ],

        ),

        body:searchResultsFuture == null ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Flexible(
                child: _buildBody(context),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: clearSearch,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 10.0, right: 10.0),
                    hintStyle:
                    TextStyle(color: Colors.black, fontFamily: "WorkSansLight"),
                    filled: true,
                    fillColor: Colors.black12,
                    hintText: "Search for a Songs...",
                  ),
                  onFieldSubmitted: handleSearch,
                ),
              ),
            ],
          ),
        ) : buildSearchResults(),
    );
  }


  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('audioInfo').document(widget.lan).collection(widget.name).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
        padding: const EdgeInsets.only(top: 20.0),
        children:
            snapshot.map((data) => _buildListItem(context, data)).toList());
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    final imgUrl = record.audioUrl;
    String paths = "No Data";
    final Random random = Random();

    Future<void> downloadFile() async {
      _loadingStreamCtrl.sink.add(true);
      Dio dio = Dio();

      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Audio/flutter_test';
      await Directory(dirPath).create(recursive: true);
      var randid = random.nextInt(10000);

      FileUtils.mkdir([dirPath]);
      await dio.download(
        imgUrl,
        dirPath + randid.toString() + ".mp3",
      );

      paths = dirPath + randid.toString() + ".mp3";
      _loadingStreamCtrl.sink.add(false);

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             CameraMusic(widget.cameras, paths, record.audioUrl,record.audioName)));
File audioFile= File(paths);
      if (audioFile != null) {
        await _trimmer.loadVideo(videoFile: audioFile);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) {
          return AudioCut(
              widget.cameras, _trimmer, record.audioUrl, record.audioName, paths);
        }));
      }
    }

    return Padding(
      key: ValueKey(record.audioName),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.black),
        child: ListTile(
          title: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        record.audioName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.lightBlueAccent,
                              child: IconButton(
                                  icon: Icon(Icons.play_arrow,color: Colors.white),
                                  onPressed: () async {
                                    Fluttertoast.showToast(
                                        msg: "Audio is Playing Please wait.....",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black54,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    _appbarStreamCtrl.sink.add(true);
                                    int status =
                                        await _audioPlayer.play(record.audioUrl);
                                    if (status == 1) {
                                      setState(() {
                                        isPlaying = true;
                                      });
                                    }
                                  }),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            IconButton(
                              icon: Icon(Icons.stop,color: Colors.red,),
                              onPressed: () {
                                _appbarStreamCtrl.sink.add(false);
                                _audioPlayer.stop();
                                setState(() {
                                  isPlaying = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: Icon(Icons.videocam),
                          ),
                        ),
                        onTap: () {
                          downloadFile();
                          _appbarStreamCtrl.sink.add(false);
                          _audioPlayer.stop();
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future getaudio() async {
    _appbarStreamCtrl.sink.add(false);
    _audioPlayer.stop();
    file = await FilePicker.getFile(type: FileType.audio);
    fileName = p.basename(file.path);
    setState(() {
      fileName = p.basename(file.path);
    });
    compress(file, fileName);
  }

  compress(file, fileName) async {
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/jhoom';
    Directory appDocDir =
    await getApplicationDocumentsDirectory();
    String bgPath =
        appDocDir.uri.resolve("${timestamp()}").path;
    // File bgFile = await file.copy(bgPath);

    String localVideoFile2 = bgPath;
    await Directory(dirPath).create(recursive: true);
    String compAudioFile = '$dirPath/${timestamp()}.mp3';
      _flutterFFmpeg
          .execute(
          "-i $localVideoFile2 -b:a 96k -map a $compAudioFile")
          .then((rc) {
        File files = File(compAudioFile);
        _uploadAudioToFirebase(files, fileName);
      });

  }

  Future<void> _uploadAudioToFirebase(File file, String filename) async {

    String lan=widget.lan;
    String name=widget.name;
      String audioLocation = "audio/$lan/$name/$filename";
      final StorageReference storageReference =
          FirebaseStorage().ref().child(audioLocation);
      final StorageUploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.onComplete;
      _addPathToDatabase(audioLocation);
    }


  Future<void> _addPathToDatabase(String text) async {
    final ref = FirebaseStorage().ref().child(text);
      var audiostring = await ref.getDownloadURL();
      var audioname = await ref.getName();
      await Firestore.instance
          .collection('audioInfo')
          .document(widget.lan).collection(widget.name).document()
          .setData({'url': audiostring, 'location': text, 'name': audioname});
  }
}

class Record {
  final String location;
  final String audioUrl;
  final String audioName;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['location'] != null),
        assert(map['url'] != null),
        assert(map['name'] != null),
        location = map['location'],
        audioUrl = map['url'],
        audioName = map['name'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$location:$audioUrl:$audioName>";
}


class MusicResult extends StatelessWidget {

  final String location;
  final String audioUrl;
  final String audioName;
  final DocumentReference reference;

  MusicResult.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['location'] != null),
        assert(map['url'] != null),
        assert(map['name'] != null),
        location = map['location'],
        audioUrl = map['url'],
        audioName = map['name'];

  MusicResult.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(audioName),
          ),
        ],
    ),
    );
  }}


class AudioSearch extends StatefulWidget {
  final List<CameraDescription> cameras;
  final AudioFireData audio;

  AudioSearch(this.audio,this.cameras);

  @override
  _AudioSearchState createState() => _AudioSearchState();
}

class _AudioSearchState extends State<AudioSearch> {
  final Random random = Random();
  String paths = "No Data";
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {

    Future<void> downloadFile() async {
      Dio dio = Dio();

      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Audio/flutter_test';
      await Directory(dirPath).create(recursive: true);
      var randid = random.nextInt(10000);

      FileUtils.mkdir([dirPath]);
      await dio.download(
        widget.audio.audioUrl,
        dirPath + randid.toString() + ".mp3",
      );

      paths = dirPath + randid.toString() + ".mp3";
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CameraMusic(widget.cameras,paths,widget.audio.audioUrl,widget.audio.name)));


    }
    return Container(
      color: Colors.white30,
      child: Column(
        children: <Widget>[
      Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.black),
        child: ListTile(
          title: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                       widget.audio.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.lightBlueAccent,
                              child: IconButton(
                                  icon: Icon(Icons.play_arrow,color: Colors.white),
                                  onPressed: () async {
                                    Fluttertoast.showToast(
                                        msg: "Audio is Playing Please wait.....",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black54,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    await _audioPlayer.play(widget.audio.audioUrl);
                                  }),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            IconButton(
                              icon: Icon(Icons.stop,color: Colors.red,),
                              onPressed: () {
                                _audioPlayer.stop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: Icon(Icons.videocam),
                          ),
                        ),
                        onTap: () {
                          downloadFile();
                          _audioPlayer.stop();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Center(
                                  child: Column(
                                    children: <Widget>[
                                      CircularProgressIndicator(),
                                      Text("Downloading audio please wait...",style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );


                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),

          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
