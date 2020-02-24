import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'nearby_service_center_list.dart';
import 'loginPage.dart';
import '../utils/constants.dart' as Constants;
import '../utils/alert_util.dart';

class CarIssueDetails extends StatelessWidget {
  String user_id;
  String name;
  String mobileNum;
  String username;
  String role;
  String vehicleModel;
  List<dynamic> diagnoseJsonResponseItem;
  int index;

  CarIssueDetails(this.user_id, this.name, this.mobileNum, this.username,
      this.role, this.vehicleModel, this.diagnoseJsonResponseItem, this.index);

  _getNearbyServiceCenterList(String carIssueId, String errorCode,
      String errorDescription, BuildContext context) async {
    var jsonResponse = null;
    print('carIssueId===============${carIssueId}');
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    print(
        'position-----------------${position.latitude}, ${position.longitude}');

    var response = await http.get(
        "${Constants.BACKEND_URL}/api/nearby/${position.longitude}/${position.latitude}");
    jsonResponse = json.decode(response.body);
    print('jsonResponse---------------- $jsonResponse');
    print(
        'jsonResponse.runtimeType---------------- ${jsonResponse.runtimeType}');
    if (response.statusCode == 200) {
      if (jsonResponse.length < 1) {
        print("No service center---------------------------------------");
        // place alert message here
        showMyDialog(
            "VHM & P", "We do not find nearby any service center!", context);
      } else {
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => NearByServiceCenterList(
                carIssueId,
                name,
                username,
                errorCode,
                errorDescription,
                jsonResponse),
          ),
        );
      }
    } else {
      // place error alert
      showMyDialog("VHM & P",
          "There is server error, please try after some time!", context);
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
              title: new Text("Previous Requests"),
              trailing: new Icon(Icons.label_important),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Text("Hi"),
              )),
            ),
          ],
        ),
      ),
      body: Center(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.report),
                title: Text(
                  diagnoseJsonResponseItem[index]["carErrorDetails"]
                      ["errorCode"],
                ),
                subtitle: Text(
                  diagnoseJsonResponseItem[index]["carErrorDetails"]
                      ["description"],
                ),
              ),
              ListTile(
                title: Text(
                  'Meaning: ${diagnoseJsonResponseItem[index]["carErrorDetails"]["meaning"]} \n',
                ),
                subtitle: Text(
                  'Symptom: ${diagnoseJsonResponseItem[index]["carErrorDetails"]["mainSymptoms"]}',
                ),
              ),
              ListTile(
                title: Text(
                  'Possible Causes: ${diagnoseJsonResponseItem[index]["carErrorDetails"]["possibleCauses"]} \n',
                ),
                subtitle: Text(
                  'Diagnostic Steps: ${diagnoseJsonResponseItem[index]["carErrorDetails"]["diagnosticSteps"]}',
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                      child: const Text('Nearby Service Center'),
                      onPressed: () => _getNearbyServiceCenterList(
                            diagnoseJsonResponseItem[index]["carIssueId"],
                            diagnoseJsonResponseItem[index]["carErrorDetails"]
                                ["errorCode"],
                            diagnoseJsonResponseItem[index]["carErrorDetails"]
                                ["description"],
                            context,
                          )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
