import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'home_car_owner.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'nearby_service_center_list.dart';
import 'loginPage.dart';
import '../utils/constants.dart' as Constants;
import '../utils/alert_util.dart';
import '../utils/get_my_past_appointment_list.dart';

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
            "OAM System", "We do not find nearby any service center!", context);
      } else {
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => NearByServiceCenterList(
                user_id,
                name,
                mobileNum,
                username,
                role,
                vehicleModel,
                carIssueId,
                errorCode,
                errorDescription,
                jsonResponse),
          ),
        );
      }
    } else {
      // place error alert
      showMyDialog("OAM System",
          "There is server error, please try after some time!", context);
    }
  }

  _launchURL(String errorCode) async {
    if (Platform.isIOS) {
      if (await canLaunch(
          'youtube://www.youtube.com/results?search_query=$errorCode')) {
        await launch(
            'youtube://www.youtube.com/results?search_query=$errorCode',
            forceSafariVC: false);
      } else {
        if (await canLaunch(
            'https://www.youtube.com/results?search_query=$errorCode')) {
          await launch(
              'https://www.youtube.com/results?search_query=$errorCode');
        } else {
          throw 'Could not launch https://www.youtube.com/results?search_query=$errorCode';
        }
      }
    } else {
      String url = 'https://www.youtube.com/results?search_query=$errorCode';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issue Details", style: TextStyle(color: Colors.white)),
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
                    ),
                  ),
                ],
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('Search in Youtube'),
                    onPressed: () => _launchURL(diagnoseJsonResponseItem[index]
                        ["carErrorDetails"]["errorCode"]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
