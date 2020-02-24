import 'package:flutter/material.dart';
import 'car_issue_detail.dart';
import 'loginPage.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      child: Text(
//        'I am in DiagnoseResponseList $id ${diagnoseJsonResponse['carErrorDetails']['errorCode']}',
//      ),
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
              title: new Text("Previous Requests"),
              trailing: new Icon(Icons.label_important),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Text("Hi"),
              )),
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
              trailing: Icon(Icons.description),
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
