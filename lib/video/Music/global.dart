import 'package:flutter/material.dart';

Color bgColor = Color(0xfff5f5f5);

class Categories {
  final String title;
  final int id;
  final List<SubCategories> subCat;
  Categories({this.title, this.id, this.subCat});
}

class SubCategories {
  final String title;
  final int id;
  final String ico;
  SubCategories({this.title, this.id,this.ico});
}

List<Categories> categories = [
  Categories(
    title: 'English',
    id: 0,
    subCat: [
      SubCategories(id: 0, title: 'Music',ico: "assets/images/Upload/MusicIcons/fire.png"),
      SubCategories(id: 1, title: 'Dialogs',ico: "assets/images/Upload/MusicIcons/water.png"),
      SubCategories(id: 2, title: 'Background Music',ico:"assets/images/Upload/MusicIcons/grass.png"),
    ],
  ),
  Categories(
    title: 'Hindi',
    id: 1,
    subCat: [
      SubCategories(id: 0, title: 'Music(संगीत)',ico: "assets/images/Upload/MusicIcons/fire.png"),
      SubCategories(id: 1, title: 'Dialogs(संवाद)',ico: "assets/images/Upload/MusicIcons/water.png"),
      SubCategories(id: 2, title: 'Background Music(पार्श्व संगीत)',ico:"assets/images/Upload/MusicIcons/grass.png"),
    ],
  ),
  Categories(
    title: 'Odia',
    id: 2,
    subCat: [
      SubCategories(id: 0, title: 'Music(ସଙ୍ଗୀତ)',ico: "assets/images/Upload/MusicIcons/fire.png"),
      SubCategories(id: 1, title: 'Dialog(ସଂଳାପ)',ico: "assets/images/Upload/MusicIcons/water.png"),
      SubCategories(id: 2, title: 'Background Music(ପଛ ସଂଗୀତ)',ico:"assets/images/Upload/MusicIcons/grass.png"),
    ],
  ),
];