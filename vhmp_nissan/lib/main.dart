import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:appnode/view/addProducts.dart';
//import 'package:appnode/view/listProducts.dart';
import 'screens/loginPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "VHM & P",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SharedPreferences sharedPreferences;
  String id;
  String name;
  String mobileNum;
  String username;
  String role;
  String address;
  String vehicleModel;

  @override
  void initState() {
    super.initState();
//    checkLoginStatus();
  }

//  checkLoginStatus() async {
//    sharedPreferences = await SharedPreferences.getInstance();
//    if (sharedPreferences.getString("token") == null) {
//      Navigator.of(context).pushAndRemoveUntil(
//          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
//          (Route<dynamic> route) => false);
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VHM & P", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
//              sharedPreferences.clear();
//              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                  (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(child: Text("Main Page")),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text('VHM & P'),
              accountEmail: new Text('codigoalphacol@gmail.com'),
            ),
            new ListTile(
              title: new Text("List Products"),
              trailing: new Icon(Icons.help),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Text("Hi"),
              )),
            ),
            new ListTile(
              title: new Text("Add Products"),
              trailing: new Icon(Icons.help),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Text("jjkjk"),
              )),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Register user"),
              trailing: new Icon(Icons.fitness_center),
              onTap: () => {},
            ),
          ],
        ),
      ),
    );
  }
}
