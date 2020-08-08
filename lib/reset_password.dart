import 'dart:convert';
import 'dart:ui';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:one_bark_plaza/homepage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:one_bark_plaza/login.dart';
import 'package:one_bark_plaza/reset_password.dart';
import 'package:toast/toast.dart';
import 'package:one_bark_plaza/userdata.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_bark_plaza/util/constants.dart';

class ResetPassword extends StatefulWidget {

  @override
  ResetPasswordState createState() {
    return ResetPasswordState();
  }
}

class ResetPasswordState extends State<ResetPassword>{
  TextStyle style = TextStyle(fontFamily: 'Lato', fontSize: 14.0,color: Colors.white, fontWeight: FontWeight.bold);
  TextEditingController userNameController = new TextEditingController();

  bool _isLoading = false;


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
          hintText: "Enter registered email id",
          hintStyle: TextStyle(color: Colors.blueGrey, fontSize: 12),
          labelStyle: TextStyle(color: Color(0xffFFFd19)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffFFFd19), width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffFFFd19), width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffFFFd19), width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          )
      ),
    );

    final passwordRestButton = Material(
      borderRadius: BorderRadius.circular(50.0),

      color: Color(0xff3db6c6),
      child: MaterialButton(
        minWidth: _width - 100,

        onPressed: () {
          FocusScope.of(context).unfocus();
          onResetPasswordPress(context);
        },
        child: Text("Reset Password",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
      appBar: new AppBar(
        backgroundColor:Color(0xff002430),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
                Navigator.of(context).pop();
            }
        ),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              new Text(
                "Reset Password",
                style: new TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ]),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: _height > _width ? _height - 100 : _height * 2,
              width: _width,
              color: Color(0xff002430),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  SizedBox(


                    child: Image.asset("assets/images/password_change_obp_logo.png",height: 100,

                    ),
                  ),



                  SizedBox(height: 50.0),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(height:54,width: _width/1.4, child: userName),
                  ),
                  SizedBox(height: 28.0),
                  Container(height:54,width: _width/1.4,child: passwordRestButton),


                ],
              ), /* add child content here */
            ),
            _isLoading? Positioned(
              width: _width ,
              height: _height,
              //top: MediaQuery.of(context).size.width * 0.5 ,
              child: Container(
                  alignment: Alignment.center,
                  child: SpinKitFadingCircle(
                    color: customColor,
                    size: 50.0,
                  )),
            ):SizedBox()
          ],
        ),
      ),
    );
  }

  void onResetPasswordPress(BuildContext context) {
    if (userNameController.text.length > 0 &&
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(userNameController.text)) {
        initiatePasswordRest(context);
    } else {
      Toast.show("Enter valid email", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundRadius: 16,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
    }

  }

  Future<void> initiatePasswordRest(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    var dio = Dio();

    var passwordResetUrl = 'https://onebarkplaza.com/wp-json/obp/v1/lostpassword';
    FormData formData = new FormData.fromMap({
      "user_login": userNameController.text.trim(),
    });
    try{
      dynamic response = await dio.post(passwordResetUrl, data: formData);
      if (response.statusCode == 200) {
        dynamic responseList = jsonDecode(response.toString());
        if(responseList["success"]!=null) {
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) =>
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: CupertinoAlertDialog(
                    title: Text('Request Successful\n'),
                    content: Text(
                        "\nPassword reset email has been sent.\nIt may take several minutes to show up in your inbox.\n\nKindly wait for few mins before attempting another Reset.\n"),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('OK', style: TextStyle(
                            color: customColor, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginPage()));
                        },
                      ),
                    ],
                  ),
                ),
          );
        }
        else{
          Toast.show(responseList["error"], context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
        }
      } else {
        Toast.show("Request failed, Please check username entered is correct "+response.toString(), context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
      }
      setState(() {
        _isLoading = false;
      });
    }catch(exception){
      Toast.show("Request Failed. "+exception.toString(), context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19),
          backgroundRadius: 16);
      setState(() {
        _isLoading = false;
      });
    }

  }


}
