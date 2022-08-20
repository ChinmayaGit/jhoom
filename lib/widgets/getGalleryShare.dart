// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:jhoom_test/video/Upload.dart';
// import 'dart:async';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   StreamSubscription _intentDataStreamSubscription;
//   List<SharedMediaFile> _sharedFiles;
//   String _sharedText;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // For sharing images coming from outside the app while the app is in the memory
//     _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
//         .listen((List<SharedMediaFile> value) {
//       setState(() {
//         _sharedFiles = value;
//         print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
//         File file=File(_sharedFiles?.map((f)=> f.path)?.join(",") ?? "");
//         Navigator.push(
//             context, MaterialPageRoute(
//             builder: (context) =>Upload(videoPath:_sharedFiles?.map((f)=> f.path)?.join(",") ?? "",videoFile: file,audioName: "null",audioUrl: "null",)));
//       });
//     }, onError: (err) {
//       print("getIntentDataStream error: $err");
//     });
//
//     // For sharing images coming from outside the app while the app is closed
//     ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
//       setState(() {
//         _sharedFiles = value;
//         print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
//         File file=File(_sharedFiles?.map((f)=> f.path)?.join(",") ?? "");
//         Navigator.push(
//             context, MaterialPageRoute(
//             builder: (context) =>Upload(videoPath:_sharedFiles?.map((f)=> f.path)?.join(",") ?? "",videoFile: file,audioName: "null",audioUrl: "null",)));
//       });
//     });
//
//
//   }
//
//   @override
//   void dispose() {
//     _intentDataStreamSubscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const textStyleBold = const TextStyle(fontWeight: FontWeight.bold);
//     return
//       Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: Column(
//             children: <Widget>[
//               Text("Shared files:", style: textStyleBold),
//               Text(_sharedFiles?.map((f)=> f.path)?.join(",") ?? ""),
//               RaisedButton(onPressed: (){
//                 File file=File(_sharedFiles?.map((f)=> f.path)?.join(",") ?? "");
//                 Navigator.push(
//                     context, MaterialPageRoute(
//                     builder: (context) =>Upload(videoPath:_sharedFiles?.map((f)=> f.path)?.join(",") ?? "",videoFile: file,audioName: "null",audioUrl: "null",)));
//               })
//             ],
//           ),
//         ),
//       );
//
//   }
// }