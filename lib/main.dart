import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String myText = null;
  StreamSubscription<DocumentSnapshot> subscription;
  final DocumentReference documentReference =
      Firestore.instance.document("myData/dummy");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    FirebaseUser user = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken);
    print("User name : ${user.displayName}");
    return user;
  }

  void _singOut() {
    googleSignIn.signOut();
    print('User sign out');
  }

  void _add() {
    Map<String, String> data = <String, String>{
      "name": "Erick Gomes",
      "desc": "mobile developer"
    };
    documentReference.setData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print(e));
  }

  void _delete() {
    documentReference.delete().whenComplete((){
      print("Deleted succefully");
      setState(() {
        
      });
    }).catchError((e) => print(e));
  }

  void _update() {
    Map<String, String> data = <String, String>{
      "name": "Erick Gomez Jimenez",
      "desc": "mobile developer updated"
    };
    documentReference.updateData(data).whenComplete(() {
      print("Document Update");
    }).catchError((e) => print(e));
  }

  void _fetch() {
    documentReference.get().then((datasnapshot){
      if(datasnapshot.exists){
        setState(() {
          myText = datasnapshot.data['desc'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = documentReference.snapshots().listen((datasnapshot){
      if(datasnapshot.exists){
        setState(() {
          myText = datasnapshot.data['desc'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Firebase Demo'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new RaisedButton(
              onPressed: () => _signIn()
                  .then((FirebaseUser user) => print(user))
                  .catchError((e) => print(e)),
              child: new Text('Sign in'),
              color: Colors.green,
              splashColor: Colors.greenAccent,
              animationDuration: Duration(seconds: 10),
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: _singOut,
              child: new Text('Sign out'),
              color: Colors.red,
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: _add,
              child: new Text('Add'),
              color: Colors.cyan,
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: _update,
              child: new Text('Update'),
              color: Colors.lightBlue,
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: _delete,
              child: new Text('Delete'),
              color: Colors.orange,
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: _fetch,
              child: new Text('Fetch'),
              color: Colors.lime,
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
            myText == null
                ? new Container()
                : new Text(
                    myText,
                    style: new TextStyle(fontSize: 20.0),
                  )
          ],
        ),
      ),
    );
  }
}
