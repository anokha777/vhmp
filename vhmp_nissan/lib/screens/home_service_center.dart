import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'loginPage.dart';

import '../utils/constants.dart' as Constants;

class HomeServiceCenter extends StatefulWidget {
  String user_id;
  String name;
  String mobileNum;
  String username;
  String role;
  String address;
  List<dynamic> carIssueList;

  HomeServiceCenter(this.user_id, this.name, this.mobileNum, this.username,
      this.role, this.address, this.carIssueList);

  @override
  _HomeServiceCenterState createState() => _HomeServiceCenterState();
}

class _HomeServiceCenterState extends State<HomeServiceCenter> {
  SharedPreferences sharedPreferences;
  String currentAppointmentState = '';

  updateAppointmentState(
      String carIssueRequestModelId, String updateState) async {
    Map data = {'requestState': updateState};
    var jsonResponse = null;

    var response = await http.put(
        "${Constants.BACKEND_URL}/api/car/appointmentupdate/$carIssueRequestModelId",
        body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        currentAppointmentState = jsonResponse["requestState"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments list", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              setState(() {
                currentAppointmentState = '';
              });
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
                builder: (BuildContext context) => HomeServiceCenter(
                    widget.user_id,
                    widget.name,
                    widget.mobileNum,
                    widget.username,
                    widget.role,
                    widget.address,
                    widget.carIssueList),
              )),
            ),
          ],
        ),
      ),
      body: new ListView.builder(
        itemCount: widget.carIssueList == null ? 0 : widget.carIssueList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(
                '${widget.carIssueList[index]["carOwnerDatails"]["name"]} | ${widget.carIssueList[index]["carOwnerDatails"]["mobileNum"]}',
              ),
              subtitle: Text(
                'Car Model: ${widget.carIssueList[index]["carOwnerDatails"]["vehicleModel"]} '
                '\nIssue: ${widget.carIssueList[index]["carErrorDetails"]["errorCode"]}- ${widget.carIssueList[index]["carErrorDetails"]["description"]} '
                '\nRequest Date/Time: ${widget.carIssueList[index]["selectedDate"]} | ${widget.carIssueList[index]["selectedTime"]} ',
              ),
              trailing: FlatButton(
                child: Text(currentAppointmentState == ''
                    ? widget.carIssueList[index]["requestState"]
                    : currentAppointmentState),
                onPressed: () {
                  setState(() {
                    if (currentAppointmentState == Constants.WAITING) {
                      currentAppointmentState = Constants.APPROVED;
                      updateAppointmentState(
                          widget.carIssueList[index]["carIssueRequestModelId"],
                          Constants.APPROVED);
                    } else if (currentAppointmentState == Constants.APPROVED) {
                      currentAppointmentState = Constants.UN_APPROVED;
                      updateAppointmentState(
                          widget.carIssueList[index]["carIssueRequestModelId"],
                          Constants.UN_APPROVED);
                    } else {
                      currentAppointmentState = Constants.APPROVED;
                      updateAppointmentState(
                          widget.carIssueList[index]["carIssueRequestModelId"],
                          Constants.APPROVED);
                    }
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
