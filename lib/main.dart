import 'package:camera/camera.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:jhoom/pages/CapturePage.dart';
import 'package:jhoom/pages/home.dart';
import 'package:jhoom/pages/timeline.dart';
import 'package:jhoom/video/Videcamera.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras;
const debug = true;
Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: debug);
  cameras = await availableCameras();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  static const String id = "MyApp";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jhoom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Color(0xffCB2B5E),

      ),
      routes: {
        MyApp.id:(context)=> MyApp(),
        CapturePage.id:(context)=> CapturePage(cameras),
        CameraMusic.id:(context)=> CameraMusic(cameras,null,null,null),
        FormStep1.id:(context)=> FormStep1(),
      },
      home: Home(cameras:cameras),
    );
  }
}
