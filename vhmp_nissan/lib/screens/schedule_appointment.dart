import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'home_car_owner.dart';

import 'loginPage.dart';
import '../utils/constants.dart' as Constants;
import '../utils/alert_util.dart';
import '../utils/get_my_past_appointment_list.dart';

class ScheduleAnAppointment extends StatefulWidget {
  String user_id;
  String name;
  String mobileNum;
  String username;
  String role;
  String vehicleModel;
  String currentCarIssue;
  String errorCode;
  String errorDescription;
  String serviceCenterName;
  String serviceCenterId;

  ScheduleAnAppointment(
      this.user_id,
      this.name,
      this.mobileNum,
      this.username,
      this.role,
      this.vehicleModel,
      this.currentCarIssue,
      this.errorCode,
      this.errorDescription,
      this.serviceCenterName,
      this.serviceCenterId);

  @override
  State<StatefulWidget> createState() {
    return new ScheduleAnAppointmentState();
  }
}

class ScheduleAnAppointmentState extends State<ScheduleAnAppointment> {
  TimeOfDay _startTime;
  DateTime _date;
  TextEditingController startTimeController;
  TextEditingController dateInputController;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    startTimeController = new TextEditingController(
      text: "",
    );
    dateInputController = new TextEditingController(text: "");
  }

  void _onPickedStartTime(TimeOfDay startTime) {
    setState(() {
      _startTime = startTime;
    });
  }

  void _setButtonState() {
    setState(() {
      if (_date != null && _startTime != null) {
        print("setButtonState: Button enabled");
        isButtonEnabled = true;
      } else {
        print("setButtonState: Button diabled");
        isButtonEnabled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Container carErrorInformation(String errorCode, String errorDescription) {
      return Container(
        margin: EdgeInsets.only(top: 5.0),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: ListTile(
          title: Text(errorCode),
          subtitle: Text(errorDescription),
        ),
      );
    }

    final srartTimePicker = Container(
      padding: EdgeInsets.only(left: 32.0, right: 32.0, top: 8.0),
      child: new Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                print("onTap start");
                _showStartTimeDialog();
              },
              child: Icon(Icons.access_time),
            ),
          ),
          Container(
            child: new Flexible(
                child: new TextField(
                    decoration: InputDecoration(
                        hintText: "Schedule Time",
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    maxLines: 1,
                    controller: startTimeController)),
          ),
        ],
      ),
    );

    final dateInput = Container(
      padding: EdgeInsets.only(left: 32.0, right: 32.0, top: 8.0),
      child: new Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                print("onTap dateInput");
                _showDatePicker();
              },
              child: Icon(Icons.date_range),
            ),
          ),
          Container(
            child: new Flexible(
                child: new TextField(
                    decoration: InputDecoration(
                        hintText: "Schedule Date",
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    maxLines: 1,
                    controller: dateInputController)),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: new ListTile(
          title: new Text("Schedule Appointment"),
          subtitle: new Text("${widget.serviceCenterName}"),
        ),
//            Text("Schedule Appointment", style: TextStyle(color: Colors.white)),
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
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            carErrorInformation(widget.errorCode, widget.errorDescription),
            dateInput,
            srartTimePicker,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(10.0),
                    shadowColor: isButtonEnabled
                        ? Colors.orangeAccent.shade100
                        : Colors.grey.shade100,
                    elevation: 2.0,
                    child: MaterialButton(
                      minWidth: 200.0,
                      height: 42.0,
                      onPressed: () {
                        if (isButtonEnabled) {
                          print(
                              'startTimeController----- ${startTimeController.text}');
                          print(
                              'dateInputController---- ${dateInputController.text}');
                          print("-----------------$_startTime, $_date, ");
                          submitScheduleAppointment(
                              dateInputController.text,
                              startTimeController.text,
                              widget.currentCarIssue,
                              widget.serviceCenterId,
                              widget.user_id);
                        }
                      },
                      color: isButtonEnabled ? Colors.blueAccent : Colors.grey,
                      child: Text("Schedule Service",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  submitScheduleAppointment(
      String selectedDate,
      String selectedTime,
      String currentCarIssue,
      String serviceCenterId,
      String requesterCarOwner) async {
    print("Called submitScheduleAppointment()----$selectedDate, $selectedTime");
    Map data = {
      'currentCarIssue': currentCarIssue,
      'selectedServiceCenter': serviceCenterId,
      'requesterCarOwner': requesterCarOwner,
      'selectedDate': selectedDate,
      'selectedTime': selectedTime
    };
    var jsonResponse = null;

    var response =
        await http.post("${Constants.BACKEND_URL}/api/car/issue", body: data);
    print('status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (jsonResponse != null) {
//        setState(() {
//          _isLoading = false;
//        });
        showMyDialog("Schedule Appointment Success!",
            "Thankyou, Your appointment is confirmed!", context);
      }
    } else {
//      setState(() {
//        _isLoading = false;
//      });
      showMyDialog(
          "Schedule Appointment Error!",
          "We are sorry, There is server error, please try after some time.",
          context);
      print(response.body);
    }
  }

  Future<Null> _showStartTimeDialog() async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      setState(() {
        _startTime = picked;
        startTimeController =
            new TextEditingController(text: "${picked.hour}:${picked.minute}");
      });
      _setButtonState();
    }
  }

  Future<Null> _showDatePicker() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 1, 1),
        lastDate: DateTime(DateTime.now().year, 12));

    if (picked != null) {
      setState(() {
        _date = picked;
        dateInputController = new TextEditingController(
            text: "${picked.year}-${picked.month}-${picked.day}");
      });
    }
  }
}
