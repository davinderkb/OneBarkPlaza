import 'dart:convert';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:one_bark_plaza/homepage.dart';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:one_bark_plaza/userdata.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_bark_plaza/util/constants.dart';

class LoginPage extends StatefulWidget {

  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage>{
  TextStyle style = TextStyle(fontFamily: 'NunitoSans', fontSize: 15.0,color: Colors.white);
  TextEditingController passwordController = new TextEditingController();
  TextEditingController userNameController = new TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  void inContact(TapDownDetails details) {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void outContact(TapUpDetails details) {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    final userName = TextField(
      controller: userNameController,
      style: style,
      decoration: InputDecoration(

          contentPadding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0),
          labelText: "Username",
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
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
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          )
      ),
      obscureText: _obscureText,
    );

    final forgotPassword = Text(
      'Forgot Password?',
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 13, color: Color(0xffEEEEEE)),
    );
    final forgotPasswordLink = Text(
      'Click here',
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 14, color: Color(0xffF69601), decoration: TextDecoration.underline,),
    );

    final loginButton = Material(
      borderRadius: BorderRadius.circular(50.0),

      color: Color(0xff308FA4),
      child: MaterialButton(
        minWidth: _width - 100,
        padding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0),
        onPressed: () {
          FocusScope.of(context).unfocus();
          onLoginPress(context);
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.white, fontSize: 15)),
      ),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: _height > _width ? _height : _height * 2,
              width: _width,
              color: Color(0xff002430),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                  ),
                  SizedBox(
                    width: _width-110,

                    child: Image.asset(
                      "assets/images/logo.png",

                    ),
                  ),
                  SizedBox(
                    height: 8,
                    width: MediaQuery.of(context).size.width,
                  ),


                  SizedBox(height: 34.0),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(height: 64, width: 265, child: userName),
                  ),
                  SizedBox(height: 20.0),
                  Stack(children: [
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(height: 64, width: 265, child: passwordField),
                        ),
                        SizedBox(height: 14.0),
                      ],
                    ),
                    Positioned(
                      width: 485 ,
                      top: MediaQuery.of(context).size.width * 0.035 ,
                      child: GestureDetector(
                        onTapDown: inContact,
                        onTapUp: outContact,
                        child: Icon(
                          Icons.remove_red_eye,
                          color: Colors.amber, size:35
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 8.0),
                  Container(height:64,width: 265,child: loginButton),
                  SizedBox(height: 12.0),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(child: forgotPassword),
                        SizedBox(width: 6.0),
                        Container( child: forgotPasswordLink),
                      ],
                    ),
                  ),
                ],
              ), /* add child content here */
            ),
            _isLoading? Positioned(
              width: _width ,
              height: _height,
             //top: MediaQuery.of(context).size.width * 0.5 ,
              child: Container(
                  alignment: Alignment.center,
                  child: SpinKitRipple(
                    borderWidth: 100.0,
                    color: Colors.white,
                    size: 120,
                  )),
            ):SizedBox()
          ],
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
            textColor: Colors.white,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            backgroundColor: Color(0xffeb5050),
            backgroundRadius: 16);
      }
    } else {
      Toast.show("Enter valid email", context,
          textColor: Colors.white,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Color(0xffeb5050),
          backgroundRadius: 16);
    }

  }

  Future<void> initiateLoginRequest(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    var dio = Dio();

    var loginUrl = 'https://obpdevstage.wpengine.com/wp-json/obp/v1/login';
    FormData formData = new FormData.fromMap({
      "username": userNameController.text.trim(),
      "password": passwordController.text
    });
    try{
      dynamic response = await dio.post(loginUrl, data: formData);
      if (response.toString() != '[]') {
        dynamic responseList = jsonDecode(response.toString());
        if (responseList["data"] != null) {
          UserData user = UserData.fromJson(responseList["data"]);
          await saveUserDetailsInSharedPref(user);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
        } else {
          Toast.show("Authentication Failed. " +response.toString(), context,
              textColor: Colors.white,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM,
              backgroundColor: Color(0xffEB5050),
              backgroundRadius: 16);
        }
      } else {
        Toast.show("Authentication Failed "+response.toString(), context,
            textColor: Colors.white,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            backgroundColor: Color(0xffEB5050),
            backgroundRadius: 16);
      }
      setState(() {
        _isLoading = false;
      });
    }catch(exception){
      Toast.show("Request Failed. "+exception.toString(), context,
          textColor: Colors.white,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Color(0xffEB5050),
          backgroundRadius: 16);
      setState(() {
        _isLoading = false;
      });
    }

  }

  Future saveUserDetailsInSharedPref(UserData user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.SHARED_PREF_IS_LOGGED_IN, true);
    prefs.setString(Constants.SHARED_PREF_USER_NAME, userNameController.text.trim());
    prefs.setString(Constants.SHARED_PREF_PASSWORD, passwordController.text);
    prefs.setString(Constants.SHARED_PREF_GENDER, user.gender);
    prefs.setString(Constants.SHARED_PREF_NAME, user.name);
    prefs.setString(Constants.SHARED_PREF_USER_ID, user.id);
  }
}
