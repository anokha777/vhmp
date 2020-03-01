import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'loginPage.dart';
import 'diagnose_response_list.dart';
import '../utils/constants.dart' as Constants;
import '../utils/get_my_past_appointment_list.dart';

class HomeCarOwner extends StatefulWidget {
  String user_id;
  String name;
  String mobileNum;
  String username;
  String role;
  String vehicleModel;

  HomeCarOwner(this.user_id, this.name, this.mobileNum, this.username,
      this.role, this.vehicleModel);

  @override
  _HomeCarOwnerState createState() => _HomeCarOwnerState();
}

class _HomeCarOwnerState extends State<HomeCarOwner> {
  SharedPreferences sharedPreferences;
  SpeechRecognition _speechRecognition;
  bool _isLoading = false;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    diagnoseMyCar(String user_id, BuildContext context) async {
      print("I am commig after call-------------$_isListening, $_isAvailable");
      print("resultText------------------$resultText");

      sleep(const Duration(seconds: 5));

//      if (resultText == "diagnose") {
      var jsonResponse = null;
      var response =
          await http.get("${Constants.BACKEND_URL}/api/car/diagnose/$user_id");
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        print('Response status: ${response.statusCode}');
        print('Response body: $jsonResponse');

        if (jsonResponse != null) {
          setState(() {
            _isLoading = false;
          });
          print('jsonResponse.runtimeType ${jsonResponse.runtimeType}');

          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) {
              return new DiagnoseResponseList(
                  widget.user_id,
                  widget.name,
                  widget.mobileNum,
                  widget.username,
                  widget.role,
                  widget.vehicleModel,
                  jsonResponse);
            },
          ), (Route<dynamic> route) => false);
        }
      }
//      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("OBD AMS", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
//              sharedPreferences.clear();
//              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage(),
                  ),
                  (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text(widget.name),
              accountEmail: new Text(widget.username),
            ),
            new ListTile(
              title: new Text("Home"),
              trailing: new Icon(Icons.home),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => HomeCarOwner(
                    widget.user_id,
                    widget.name,
                    widget.mobileNum,
                    widget.username,
                    widget.role,
                    widget.vehicleModel),
              )),
            ),
            new ListTile(
              title: new Text("Previous Requests"),
              trailing: new Icon(Icons.label_important),
              onTap: () => getMyPastAppointmentList(
                widget.user_id,
                widget.name,
                widget.mobileNum,
                widget.username,
                widget.role,
                widget.vehicleModel,
                context,
              ),
            ),
          ],
        ),
      ),
      body: Container(
//        child: Text(
//          "Main Page for Car owner ${widget.id} ${widget.name} ${widget.mobileNum} ${widget.username} ${widget.role} ${widget.vehicleModel} ",
//        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
//                      FloatingActionButton(
//                        heroTag: 'btn1',
//                        child: Icon(Icons.cancel),
//                        mini: true,
//                        backgroundColor: Colors.deepOrange,
//                        onPressed: () {
//                          if (_isListening)
//                            _speechRecognition.cancel().then(
//                                  (result) => setState(() {
//                                    _isListening = result;
//                                    resultText = "";
//                                  }),
//                                );
//                        },
//                      ),
                      FloatingActionButton(
                        heroTag: 'btn2',
                        child: Icon(Icons.mic),
                        onPressed: () {
//                          setState(() {
//                            _isLoading = true;
//                          });

//                          diagnoseMyCar(widget.user_id);

                          if (_isAvailable & !_isListening)
                            _speechRecognition.listen(locale: "en_US").then(
                                  (result) =>
//                                      print('speech result----- $result'),
                                      diagnoseMyCar(widget.user_id, context),
                                );
                        },
                        backgroundColor: Colors.pink,
                      ),
//                      FloatingActionButton(
//                        heroTag: 'btn3',
//                        child: Icon(Icons.stop),
//                        mini: true,
//                        backgroundColor: Colors.deepPurple,
//                        onPressed: () {
//                          if (_isListening)
//                            _speechRecognition.stop().then(
//                                  (result) =>
//                                      setState(() => _isListening = result),
//                                );
//                        },
//                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent[100],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                    child: Text(
                      resultText,
                      style: TextStyle(fontSize: 24.0),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
