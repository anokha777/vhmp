import 'package:flutter/material.dart';
import 'home_car_owner.dart';
import 'schedule_appointment.dart';
import 'loginPage.dart';
import '../utils/get_my_past_appointment_list.dart';

class NearByServiceCenterList extends StatelessWidget {
  String user_id;
  String name;
  String mobileNum;
  String username;
  String role;
  String vehicleModel;

  String currentCarIssue;
  String errorCode;
  String errorDescription;
  List<dynamic> nearByServiceCenterList;

  NearByServiceCenterList(
      this.user_id,
      this.name,
      this.mobileNum,
      this.username,
      this.role,
      this.vehicleModel,
      this.currentCarIssue,
      this.errorCode,
      this.errorDescription,
      this.nearByServiceCenterList);

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
                this.user_id,
                this.name,
                this.mobileNum,
                this.username,
                this.role,
                this.vehicleModel,
                context,
              ),
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
                      user_id,
                      name,
                      mobileNum,
                      username,
                      role,
                      vehicleModel,
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
