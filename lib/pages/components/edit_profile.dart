import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';

import 'package:jhoom/models/user.dart';
import 'package:jhoom/widgets/progress.dart';
import 'package:jhoom/pages/home.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController upiId = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;


  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(currentUser.id).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    phoneNumber.text = user.phoneNo;
    upiId.text = user.upiId;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
      phoneNumber.text.trim().length > 30
          ? _bioValid = false
          : _bioValid = true;
      upiId.text.trim().length > 30 ? _bioValid = false : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.document(currentUser.id).updateData({
        "displayName": displayNameController.text,
        "bio": bioController.text,
        "PhoneNo": phoneNumber.text,
        "UpiId": upiId.text,
      });
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 16.0,
                          bottom: 8.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageCapture()));
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50.0,
                                backgroundImage:
                                    CachedNetworkImageProvider(user.photoUrl),
                              ),
                              CircleAvatar(
                                child: Icon(
                                  Icons.mode_edit,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          updateProfileData();
                          SnackBar snackbar =
                              SnackBar(content: Text("Profile updated!"));
                          _scaffoldKey.currentState.showSnackBar(snackbar);
                        },
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          onPressed: logout,
                          icon: Icon(Icons.cancel, color: Colors.red),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return SingleChildScrollView(
                                  child: AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Row(
                                        children: [
                                          Text("Monetization"),
                                        IconButton(icon: Icon(Icons.info_outline), onPressed: (){
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // return object of type Dialog
                                              return SingleChildScrollView(
                                                child: AlertDialog(
                                                  backgroundColor: Colors.white,
                                              content:

                                                  Text("If you get 1000 ❤ likes in video you can get upto 5000 cash depending upon videos.",textAlign:TextAlign.center,),



                                                ),
                                              );
                                            },
                                          );
                                        })
                                        ],
                                         ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 12.0),
                                              child: Text(
                                                "Phone Number",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                            TextField(
                                              maxLength: 10,
                                              controller: phoneNumber,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                prefixText: "+91",
                                                hintText: "Update Phone Number",
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 12.0),
                                              child: Text(
                                                "Upi Id",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                            TextField(
                                              maxLength: 20,
                                              controller: upiId,
                                              decoration: InputDecoration(
                                                hintText: "Update Upi Id",
                                              ),
                                            ),
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 30),
                                                child: RaisedButton(
                                                  color: Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                  ),
                                                  onPressed: () {
                                                    updateProfileData();
                                                      SnackBar snackbar =
                                                      SnackBar(content: Text("Monetization updated!"));
                                                      _scaffoldKey.currentState.showSnackBar(snackbar);

                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Update",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                      'assets/images/Profile/money.png',
                                      height: 20.0),
                                ),
                                Text(
                                  "Enable",
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 1, 8, 8),
                                  child: Text(
                                    "Monetization",
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Widget to capture and crop the image
class ImageCapture extends StatefulWidget {
  createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  /// Active image file
  File _imageFile;

  /// Cropper plugin

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    // File selected = await ImagePicker.pickImage(
    //   source: source,
    //   maxHeight: 300,
    //   maxWidth: 300,
    // );
    //
    // setState(() {
    //   _imageFile = selected;
    // });

    final selected = await ImagePicker().getImage(
      source: source,
      maxHeight: 300,
      maxWidth: 300,
    );
    setState(() {
      _imageFile = File(selected.path);
    });
  }

  /// Remove image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Select an image from the camera or gallery
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            Text("|"),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(Icons.photo_library),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ),

      // Preview the image and crop it
      body: ListView(
        children: <Widget>[
          if (_imageFile != null) ...[
            Image.file(_imageFile),

//            Row(
//              children: <Widget>[
//                FlatButton(
//                  child: Icon(Icons.crop),
//                  onPressed: _cropImage,
//                ),
//                FlatButton(
//                  child: Icon(Icons.refresh),
//                  onPressed: _clear,
//                ),
//              ],
//            ),

            Uploader(file: _imageFile)
          ]
        ],
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;

  Uploader({this.file});

  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  /// Starts an upload task
  String userName = currentUser.id;
  File file;

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(widget.file.readAsBytesSync());
    final compressedImageFile = File('$path/img_.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
    await uploadAudioToFirebase(file);
  }

  Future<void> uploadAudioToFirebase(File file) async {
    String profileLocation = "profilePic/$userName";
    final StorageReference storageReference =
        FirebaseStorage().ref().child(profileLocation);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.onComplete;
    _addPathToDatabase(profileLocation);
  }

  Future<void> _addPathToDatabase(String text) async {
    final ref = FirebaseStorage().ref().child(text);
    var profileString = await ref.getDownloadURL();
    await usersRef.document(currentUser.id).updateData({
      "photoUrl": profileString,
    }).then((value) {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Allows user to decide when to start the upload
    return FlatButton.icon(
        label: Text('Upload Your Profile pic'),
        icon: Icon(Icons.cloud_upload),
        onPressed: () {
          compressImage();
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
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
