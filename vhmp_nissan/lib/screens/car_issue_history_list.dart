import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import 'diagnose_response_list.dart';

import 'loginPage.dart';
import 'home_car_owner.dart';

import '../utils/get_my_past_appointment_list.dart';

class CarIssueHistoryList extends StatelessWidget {
  String user_id;
  String name;
  String mobileNum;
  String username;
  String role;
  String vehicleModel;
  List<dynamic> diagnoseJsonResponse;
  List<dynamic> carIssueList;

  CarIssueHistoryList(
      this.user_id,
      this.name,
      this.mobileNum,
      this.username,
      this.role,
      this.vehicleModel,
      this.diagnoseJsonResponse,
      this.carIssueList);

  _backToDiagnoseList(
      String user_id,
      String name,
      String mobileNum,
      String username,
      String role,
      String vehicleModel,
      List<dynamic> diagnoseJsonResponse,
      context) {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
      builder: (BuildContext context) {
        return new DiagnoseResponseList(user_id, name, mobileNum, username,
            role, vehicleModel, diagnoseJsonResponse);
      },
    ), (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issue History", style: TextStyle(color: Colors.white)),
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
        itemCount: carIssueList == null ? 0 : carIssueList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(
                carIssueList[index]["carErrorDetails"]["errorCode"],
              ),
              subtitle: Text(
                Jiffy(carIssueList[index]["createDatetime"])
                    .format("MMMM do yyyy, h:mm:ss a"),
              ),
              trailing: FlatButton(
                child: const Text('Back'),
                onPressed: () => _backToDiagnoseList(
                    user_id,
                    name,
                    mobileNum,
                    username,
                    role,
                    vehicleModel,
                    diagnoseJsonResponse,
                    context),
              ),
            ),
          );
        },
      ),
    );
  }
}
