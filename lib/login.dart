import 'dart:convert';

import 'package:one_bark_plaza/homepage.dart';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:one_bark_plaza/userdata.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_bark_plaza/util/constants.dart';

class LoginPage extends StatelessWidget {
  TextStyle style = TextStyle(fontFamily: 'NunitoSans', fontSize: 14.0,color: Colors.white);
  TextEditingController passwordController = new TextEditingController();
  TextEditingController userNameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final companyTitle = Text(
      'Dog Lovers',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20, color: Color(0xffEB5050)),
    );
    final companyTagline = Text(
      'Passion | Dedication | Experience',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: Color(0xffEEEEEE)),
    );
    final userName = TextField(
      controller: userNameController,
      style: style,
      decoration: InputDecoration(

          contentPadding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0),
          labelText: "Username",
          labelStyle: TextStyle(color: Colors.orange),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 1.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.circular(30.0),
          )
      ),
    );

    final passwordField = TextField(
      controller: passwordController,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0),
          labelText: "Password",
          labelStyle: TextStyle(color: Colors.orange),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 1.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.circular(30.0),
          )
      ),
      obscureText: true,
    );

    final forgotPassword = Text(
      'Forgot Password?',
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 12, color: Color(0xffEEEEEE)),
    );
    final forgotPasswordLink = Text(
      'Click here',
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 14, color: Color(0xffF69601), decoration: TextDecoration.underline,),
    );

    final loginButton = Material(
      borderRadius: BorderRadius.circular(30.0),

      color: Color(0xff308FA4),
      child: MaterialButton(
        minWidth: 265,
        padding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0),
        onPressed: () {
          FocusScope.of(context).unfocus();
          onLoginPress(context);
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.white, fontSize: 14)),
      ),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: _height > _width ? _height : _height * 2,
          width: _width,
         color: Color(0xff4B4B4A),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 60,
                width: MediaQuery.of(context).size.width,
              ),
              SizedBox(
                width: 158.0,

                child: Image.asset(
                  "assets/images/logo.png",

                ),
              ),
              SizedBox(
                height: 8,
                width: MediaQuery.of(context).size.width,
              ),


              SizedBox(height: 34.0),
              Container(height: 54, width: 265, child: userName),
              SizedBox(height: 12.0),
              Column(children: [
                Container(height: 54, width: 265, child: passwordField),
                SizedBox(height: 14.0),

              ]),
              SizedBox(height: 2.0),
              loginButton,
              SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(child: forgotPassword),
                  SizedBox(width: 6.0),
                  Container( child: forgotPasswordLink),
                ],
              ),
            ],
          ), /* add child content here */
        ),
      ),
    );
  }

  void onLoginPress(BuildContext context) {
    if (userNameController.text.length > 0 &&
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(userNameController.text)) {
      if (passwordController.text.length > 0) {
        initiateLoginRequest(context);
      } else {
        Toast.show("Enter Password", context,
            textColor: Colors.black54,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white,
            backgroundRadius: 16);
      }
    } else {
      Toast.show("Enter valid email", context,
          textColor: Colors.black54,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.white,
          backgroundRadius: 16);
    }
  }

  Future<void> initiateLoginRequest(BuildContext context) async {
    var dio = Dio();
    var loginUrl = 'https://obpdevstage.wpengine.com/wp-json/obp-api/login';
    FormData formData = new FormData.fromMap({
      "username": userNameController.text.trim(),
      "password": passwordController.text
    });



    dynamic response = await dio.post(loginUrl, data: formData);
    if (response.toString() != '[]') {
      dynamic responseList = jsonDecode(response.toString());
      if (responseList["data"] != null) {
        UserData user = UserData.fromJson(responseList["data"]);
        await saveUserDetailsInSharedPref(user);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      } else {
        Toast.show("Authentication Failed", context,
            textColor: Colors.white,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM,
            backgroundColor: Color(0xffEB5050),
            backgroundRadius: 16);
      }
    } else {
      Toast.show("Authentication Failed", context,
          textColor: Colors.white,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.BOTTOM,
          backgroundColor: Color(0xffEB5050),
          backgroundRadius: 16);
    }
  }

  Future saveUserDetailsInSharedPref(UserData user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.SHARED_PREF_IS_LOGGED_IN, true);
    prefs.setString(Constants.SHARED_PREF_USER_NAME, userNameController.text.trim());
    prefs.setString(Constants.SHARED_PREF_PASSWORD, passwordController.text);
    prefs.setString(Constants.SHARED_PREF_NAME, user.name);
    prefs.setString(Constants.SHARED_PREF_USER_ID, user.id);
  }
}
