import 'package:jhoom/pages/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jhoom/models/user.dart';
import 'package:jhoom/widgets/progress.dart';

import 'Notifications.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName",isGreaterThanOrEqualTo: query)
        .getDocuments();
    Future<QuerySnapshot> userss = usersRef
        .where("username",isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
      searchResultsFuture = userss;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      actions: <Widget>[
        Expanded(
          flex: 8,
          child: Padding(
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
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.only(
                    top: 8.0, bottom: 8.0, left: 10.0, right: 10.0),
                hintStyle:
                TextStyle(color: Colors.black, fontFamily: "WorkSansLight"),
                filled: true,
                fillColor: Colors.white,
                hintText: "Search for a user...",
              ),
              onFieldSubmitted: handleSearch,
            ),
          ),
        ),
      ],
    );
  }

  Container buildNoContent() {

    return Container(
      child:
      Stack(children: <Widget>[
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffCAC2FF), Colors.white],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              Image(
                image: new AssetImage('assets/images/Search/search.gif'),
                fit: BoxFit.cover,
              ),
              Container(
                child: Text(
                  "Find Users",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 60.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: TextFormField(
            style: TextStyle(fontSize: 0),
            controller: searchController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            onFieldSubmitted: handleSearch,
          ),
        ),
      ],

      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(

          children: searchResults,
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // child: Container(
              //   decoration: ShapeDecoration(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: new BorderRadius.circular(25.0),
              //     ),
              //     color: Colors.black38,
              //   ),
              //   child: ListTile(
              //     leading: CircleAvatar(
              //       backgroundColor: Colors.grey,
              //       backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              //     ),
              //     title: Text(
              //       user.displayName,
              //       style: TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //     subtitle: Text(
              //       user.username,
              //     ),
              //   ),
              // ),
              child:Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10,0,10,0),
                    child: Container(
                      child: Container(
                        margin: new EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 16.0),
                        constraints: new BoxConstraints.expand(),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 50),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Container(height: 4.0),
                              Text(
                                user.displayName,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600),
                              ),
                              new Container(height: 4.0),
                              Text(
                                user.username,
                                style: TextStyle(fontSize: 10.0),
                              ),
                              new Container(height: 4.0),
                              new Text(
                                user.email,
                                style: TextStyle(fontSize: 10.0),
                              ),
                              new Container(
                                  margin: new EdgeInsets.symmetric(vertical: 8.0),
                                  height: 2.0,
                                  width: 18.0,
                                  color: new Color(0xff00c6ff)),
                            ],
                          ),
                        ),
                      ),
                      height: 128.0,
                      margin: new EdgeInsets.only(top: 30),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: new BorderRadius.circular(10.0),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10.0,
                            offset: new Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      margin: new EdgeInsets.symmetric(horizontal: 30),
                      alignment: FractionalOffset.centerLeft,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                      )
                  )],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
