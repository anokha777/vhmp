import 'package:flutter/material.dart';
import 'home_car_owner.dart';
import 'loginPage.dart';

class MyPastAppointmentList extends StatelessWidget {
  String user_id;
  String name;
  String mobileNum;
  String username;
  String role;
  String vehicleModel;
  List<dynamic> myPastAppointmentList;

  MyPastAppointmentList(this.user_id, this.name, this.mobileNum, this.username,
      this.role, this.vehicleModel, this.myPastAppointmentList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("My Past Appointments", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
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
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => MyPastAppointmentList(
                    user_id,
                    name,
                    mobileNum,
                    username,
                    role,
                    vehicleModel,
                    myPastAppointmentList),
              )),
            ),
          ],
        ),
      ),
      body: new ListView.builder(
        itemCount:
            myPastAppointmentList == null ? 0 : myPastAppointmentList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(
                myPastAppointmentList[index]["selectedServiceCenter"]["name"],
              ),
              subtitle: Text(
                '${myPastAppointmentList[index]["carErrorDetails"]["description"]} (${myPastAppointmentList[index]['selectedDate']} | ${myPastAppointmentList[index]['selectedTime']})',
              ),
              trailing: Text(myPastAppointmentList[index]['requestState']),
            ),
          );
        },
      ),
    );
  }
}
