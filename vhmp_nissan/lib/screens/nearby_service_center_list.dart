import 'package:flutter/material.dart';
import 'schedule_appointment.dart';
import 'loginPage.dart';

class NearByServiceCenterList extends StatelessWidget {
  String currentCarIssue;
  String name;
  String username;
  String errorCode;
  String errorDescription;
  List<dynamic> nearByServiceCenterList;

  NearByServiceCenterList(this.currentCarIssue, this.name, this.username,
      this.errorCode, this.errorDescription, this.nearByServiceCenterList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Service Centers",
            style: TextStyle(color: Colors.white)),
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
        itemCount: nearByServiceCenterList == null
            ? 0
            : nearByServiceCenterList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(
                nearByServiceCenterList[index]["name"],
              ),
              subtitle: Text(
                'Contact: ${nearByServiceCenterList[index]["mobileNum"]} \nAddress: ${nearByServiceCenterList[index]["address"]} \nDistance: ${(nearByServiceCenterList[index]["dis"] / 1000).toStringAsFixed(2)} KM ',
              ),
              trailing: Icon(Icons.schedule),
              onTap: () => Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => ScheduleAnAppointment(
                      name,
                      username,
                      currentCarIssue,
                      errorCode,
                      errorDescription,
                      nearByServiceCenterList[index]["name"],
                      nearByServiceCenterList[index]["_id"]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
