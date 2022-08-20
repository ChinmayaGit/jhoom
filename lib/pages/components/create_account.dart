import 'package:flutter/material.dart';

import 'package:jhoom/widgets/header.dart';
import 'package:jhoom/pages/home.dart';



class CreateAccount extends StatefulWidget {
  const CreateAccount({this.onColorSelect});

  final Home onColorSelect;
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Navigator.pop(context,username);
      // Timer(Duration(seconds: 2), () {
      //   Navigator.pop(context,username);
      //   Navigator.of(context).popUntil((route) => route.isFirst);
      // });

    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return
      // WillPopScope(
      // onWillPop: ()async{
      //   googleSignIn.signOut();
      //   SnackBar snackbar = SnackBar(content: Text("Exiting..."));
      //   _scaffoldKey.currentState.showSnackBar(snackbar);
      //   Timer(Duration(seconds: 1), () {
      //     exit(0);
      //   });
      //   return null;
      //   },
      // child:
    Scaffold(
        key: _scaffoldKey,
        appBar: header(context,
            titleText: "Set up your profile", removeBackButton: true),
        body: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text(
                        "Create a username",
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: Form(
                        key: _formKey,
                        autovalidate: true,
                        child: TextFormField(
                          validator: (val) {
                            if (val.trim().length < 3 || val.isEmpty) {
                              return "Username too short";
                            } else if (val.trim().length > 12) {
                              return "Username too long";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => username = val,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Username",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Must be at least 3 characters",
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50.0,
                      width: 350.0,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Text("Skip",
                          style:
                          TextStyle(color: Colors.white, fontSize: 25)),
                      color: Colors.black54,
                      onPressed: () {
                        Navigator.pop(context,username);
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      // ),
    );
  }
}
