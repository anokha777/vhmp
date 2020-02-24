import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/my_past_appointment_list.dart';
import '../utils/constants.dart' as Constants;

getMyPastAppointmentList(
    String userId,
    String name,
    String mobileNum,
    String username,
    String role,
    String vehicleModel,
    BuildContext context) async {
  var jsonResponse = null;
  var response = await http
      .get("${Constants.BACKEND_URL}/api/car/issuelistforowner/$userId");
  if (response.statusCode == 200) {
    jsonResponse = json.decode(response.body);
//        print('Response status: ${response.statusCode}');
//        print(
//            'jsonResponse.length---------------: ${jsonResponse.runtimeType}');
    print('Response body in home_car_owner-----------: $jsonResponse');

    if (jsonResponse != null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (BuildContext context) {
          return new MyPastAppointmentList(userId, name, mobileNum, username,
              role, vehicleModel, jsonResponse);
        },
      ), (Route<dynamic> route) => false);
    }
  }
}
