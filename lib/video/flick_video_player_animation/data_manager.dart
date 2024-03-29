import 'dart:async';
import 'package:flick_video_player/flick_video_player.dart';


class AnimationPlayerDataManager {
  bool inAnimation = false;
  final FlickManager flickManager;
  final List items;
  int currentIndex = 0;
  Timer videoChangeTimer;

  AnimationPlayerDataManager(this.flickManager, this.items);

  String getCurrentVideoTitle() {
    if (currentIndex != -1) {
      return items[currentIndex]['title'];
    } else {
      return items[items.length - 1]['title'];
    }
  }

  String getNextVideoTitle() {
    if (currentIndex != items.length - 1) {
      return items[currentIndex + 1]['title'];
    } else {
      return items[0]['title'];
    }
  }

  String getCurrentPoster() {
    if (currentIndex != -1) {
      return items[currentIndex]['image'];
    } else {
      return items[items.length - 1]['image'];
    }
  }
}
