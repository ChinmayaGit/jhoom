import 'package:jhoom/pages/components/post_screen.dart';
import 'package:flutter/material.dart';
import 'package:jhoom/widgets/post.dart';

class PostTile extends StatefulWidget {
  final Post post;

  PostTile(this.post);

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  showPost(context) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: widget.post.postId,
          userId: widget.post.ownerId,
        ),
      ),
    );
  }
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: Image(image: AssetImage('assets/images/Profile/play.jpg'),)
    );
  }
}

