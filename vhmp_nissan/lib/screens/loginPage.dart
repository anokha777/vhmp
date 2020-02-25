import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_car_owner.dart';
import '../screens/home_service_center.dart';

import '../utils/constants.dart' as Constants;
import '../utils/alert_util.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _isLoginTabSelected = true;
  bool _showAddressField = false;
  List<String> _roles = ["ROLE_USER", "ROLE_SERVICE_CENTER"];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _selectedRole;

  @override
  void initState() {
    _dropDownMenuItems = buildAndGetDropDownMenuItems(_roles);
    _selectedRole = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> buildAndGetDropDownMenuItems(List roles) {
    List<DropdownMenuItem<String>> items = List();
    for (String role in roles) {
      items.add(DropdownMenuItem(value: role, child: Text(role)));
    }
    return items;
  }

  void changedDropDownItem(String selectedRole) {
    setState(() {
      _selectedRole = selectedRole;
      _showAddressField =
          (selectedRole == "ROLE_SERVICE_CENTER") ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Health Monitoring",
            style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              setState(() {
                _isLoginTabSelected = _isLoginTabSelected ? false : true;
              });
            },
            child: Text(_isLoginTabSelected ? "Signup" : "Login",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  _isLoginTabSelected
                      ? loginHeaderSection()
                      : signupHeaderSection(),
                  _isLoginTabSelected
                      ? loginFormSection()
                      : _showAddressField
                          ? signupForServiceCenterFormSection()
                          : signupForCarOwnerFormSection(),
                  _isLoginTabSelected
                      ? loginButtonSection()
                      : signupButtonSection(),
                ],
              ),
      ),
    );
  }

  login(String username, String password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'username': username, 'password': password};
    var jsonResponse = null;
    var serviceCenterDashboardDataJson = null;

    var response =
        await http.post("${Constants.BACKEND_URL}/api/user/login", body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: $jsonResponse');
      print('Response user role: ${jsonResponse['role']}');
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);

        // get dashboard data if user type is service-center
        if (jsonResponse['role'] == 'ROLE_SERVICE_CENTER') {
          var serviceCenterDashboardData = await http.get(
              "${Constants.BACKEND_URL}/api/car/issue/${jsonResponse['id']}");
          print(
              "serviceCenterDashboardData-----${serviceCenterDashboardData.body == ''}");
          if (serviceCenterDashboardData.body != '') {
            serviceCenterDashboardDataJson =
                json.decode(serviceCenterDashboardData.body);
          } else {
            serviceCenterDashboardDataJson = [];
          }
          print(
              'serviceCenterDashboardDataJson--------$serviceCenterDashboardDataJson');
          print(
              'serviceCenterDashboardDataJson type---------${serviceCenterDashboardDataJson.runtimeType}');
        }

        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (BuildContext context) {
            return jsonResponse['role'] == 'ROLE_SERVICE_CENTER'
                ? new HomeServiceCenter(
                    jsonResponse['id'],
                    jsonResponse['name'],
                    jsonResponse['mobileNum'],
                    jsonResponse['username'],
                    jsonResponse['role'],
                    jsonResponse['address'],
                    serviceCenterDashboardDataJson)
                : new HomeCarOwner(
                    jsonResponse['id'],
                    jsonResponse['name'],
                    jsonResponse['mobileNum'],
                    jsonResponse['username'],
                    jsonResponse['role'],
                    jsonResponse['vehicleModel']);
          },
        ), (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      showMyDialog(
          "Login Failed!", "Please check user id or password!", context);
      print(response.body);
    }
  }

  signup(String name, String mobileNum, String role, String address,
      String vehicleModel, String username, String password) async {
//    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'name': name,
      'mobileNum': mobileNum,
      'role': role,
      'address': address,
      'vehicleModel': vehicleModel,
      'username': username,
      'password': password
    };
    var jsonResponse = null;

    var response = await http.post("${Constants.BACKEND_URL}/api/user/register",
        body: data);
    print('status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
          _isLoginTabSelected = true;
        });
        showMyDialog("Signup Success!",
            "Thankyou, Please login by credential created!", context);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      showMyDialog("Signup Error!",
          "User name already taken, Please try with other.", context);
      print(response.body);
    }
  }

  Container loginButtonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed:
            usernameController.text == "" || passwordController.text == ""
                ? null
                : () {
                    setState(() {
                      _isLoading = true;
                    });
                    login(usernameController.text, passwordController.text);
                  },
        elevation: 0.0,
        color: Colors.purple,
        child: Text("Login", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Container signupButtonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed:
            usernameController.text == "" || passwordController.text == ""
                ? null
                : () {
                    setState(() {
                      _isLoading = true;
                    });
                    signup(
                        nameController.text,
                        mobileNumController.text,
                        _selectedRole,
                        addressController.text,
                        vehicleModelController.text,
                        usernameController.text,
                        passwordController.text);
                  },
        elevation: 0.0,
        color: Colors.purple,
        child: Text("Signup", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container loginFormSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: usernameController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.perm_identity, color: Colors.white70),
              hintText: "User ID",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController nameController = new TextEditingController();
  final TextEditingController mobileNumController = new TextEditingController();
  final TextEditingController addressController = new TextEditingController();
  final TextEditingController vehicleModelController =
      new TextEditingController();

  Container signupForServiceCenterFormSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          Container(
            child: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Please choose role"),
                DropdownButton(
                  value: _selectedRole,
                  items: _dropDownMenuItems,
                  onChanged: changedDropDownItem,
                )
              ],
            )),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: addressController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.home, color: Colors.white70),
              hintText: "Address",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: nameController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.person_pin, color: Colors.white70),
              hintText: "Name",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: mobileNumController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.phone_iphone, color: Colors.white70),
              hintText: "Mobile Number",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: usernameController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.perm_identity, color: Colors.white70),
              hintText: "User ID",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container signupForCarOwnerFormSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          Container(
            child: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Please choose role"),
                DropdownButton(
                  value: _selectedRole,
                  items: _dropDownMenuItems,
                  onChanged: changedDropDownItem,
                )
              ],
            )),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: vehicleModelController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.directions_car, color: Colors.white70),
              hintText: "Vehicle Model",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: nameController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.person_pin, color: Colors.white70),
              hintText: "Name",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: mobileNumController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.phone_iphone, color: Colors.white70),
              hintText: "Mobile Number",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: usernameController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.perm_identity, color: Colors.white70),
              hintText: "User ID",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container loginHeaderSection() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("VHM & P Login",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 30.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container signupHeaderSection() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("VHM & P Signup",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 30.0,
              fontWeight: FontWeight.bold)),
    );
  }
}
