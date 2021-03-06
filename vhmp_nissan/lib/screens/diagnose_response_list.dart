import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'car_issue_history_list.dart';

import 'home_car_owner.dart';
import 'car_issue_detail.dart';
import 'loginPage.dart';
import '../utils/get_my_past_appointment_list.dart';
import '../utils/constants.dart' as Constants;

class DiagnoseResponseList extends StatelessWidget {
  String user_id;
  String name;
  String mobileNum;
  String username;
  String role;
  String vehicleModel;
  List<dynamic> diagnoseJsonResponse;

  DiagnoseResponseList(this.user_id, this.name, this.mobileNum, this.username,
      this.role, this.vehicleModel, this.diagnoseJsonResponse);

  _getCarIssueHistoryListForCarOwner(
      String user_id, BuildContext context) async {
    var jsonResponse = null;
    var response = await http.get(
        "${Constants.BACKEND_URL}/api/car/issuehistorylistforowner/$user_id");

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
//      print('Response status: ${response.statusCode}');
      print('Response body-----------------------: $jsonResponse');

      if (jsonResponse != null) {
        print('jsonResponse.runtimeType----------- ${jsonResponse.length}');

        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (BuildContext context) {
            return new CarIssueHistoryList(user_id, name, mobileNum, username,
                role, vehicleModel, diagnoseJsonResponse, jsonResponse);
          },
        ), (Route<dynamic> route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issues list", style: TextStyle(color: Colors.white)),
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
              accountName: new Text(name),
              accountEmail: new Text(username),
            ),
            new ListTile(
              title: new Text("Home"),
              trailing: new Icon(Icons.home),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => HomeCarOwner(
                    this.user_id,
                    this.name,
                    this.mobileNum,
                    this.username,
                    this.role,
                    this.vehicleModel),
              )),
            ),
            new ListTile(
              title: new Text("Previous Requests"),
              trailing: new Icon(Icons.label_important),
              onTap: () => getMyPastAppointmentList(
                user_id,
                name,
                mobileNum,
                username,
                role,
                vehicleModel,
                context,
              ),
            ),
          ],
        ),
      ),
      body: new ListView.builder(
        itemCount:
            diagnoseJsonResponse == null ? 0 : diagnoseJsonResponse.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(
                diagnoseJsonResponse[index]["carErrorDetails"]["errorCode"],
              ),
              subtitle: Text(
                diagnoseJsonResponse[index]["carErrorDetails"]["description"],
              ),
              trailing: FlatButton(
                child: const Text('Show History'),
                onPressed: () =>
                    _getCarIssueHistoryListForCarOwner(user_id, context),
              ),
//              trailing: Icon(Icons.description),
              onTap: () => Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => CarIssueDetails(
                      user_id,
                      name,
                      mobileNum,
                      username,
                      role,
                      vehicleModel,
                      diagnoseJsonResponse,
                      index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
