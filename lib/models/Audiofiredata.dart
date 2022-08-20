import 'package:cloud_firestore/cloud_firestore.dart';

class AudioFireData {
  final String name;
  final String audioUrl;

  AudioFireData({
    this.name,
    this.audioUrl,
  });

  factory AudioFireData.fromDocument(DocumentSnapshot doc) {
    return AudioFireData(
      name: doc['name'],
      audioUrl: doc['url'],
    );
  }
}
