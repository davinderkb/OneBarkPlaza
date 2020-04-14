import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:one_bark_plaza/add_puppy.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:one_bark_plaza/view_puppy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'homepage.dart';

final greenColor = Color(0xff7FA432);
final blueColor = Color(0xff4C8BF5);
class AddPuppySuccessful extends StatefulWidget {
int puppyId;

  PuppyDetails puppyDetails;
  AddPuppySuccessful(puppyId){
    this.puppyId = puppyId;
  }
  @override
  AddPuppySuccessfulState createState() {
    return AddPuppySuccessfulState();
  }
}

class AddPuppySuccessfulState extends State<AddPuppySuccessful> {
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    getPuppyDetails(context);
  }


  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          leading: new Container(),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                new Image.asset("assets/images/onebark_logo_foreground.png", height: 70,),
              ]),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: greenColor,
        ),
        body: _isLoading? Container(
            color: Colors.white,
            width: _width,
            height: _height,
            alignment: Alignment.bottomCenter,
            child: SpinKitRipple(
              borderWidth: 100.0,
              color: greenColor,
              size: 120,
            )):Center(
          child: Container(

            width: _width,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/images/ic_success.png", height: 60, color: greenColor,),
                SizedBox(height: 12),
                Text("Congratulations", style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 16.0, color:  greenColor)),
                SizedBox(height: 12),
                Text("Your puppy has been added Successfully", style: TextStyle(fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff6C6D6A))),
                SizedBox(height: 48,),
                ButtonTheme(
                  minWidth: 200.0,
                  child: new RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                          side: BorderSide(color: greenColor, width: 2.0)
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => ViewPuppy(widget.puppyDetails, true)));
                      },
                      color:Colors.white,
                      disabledColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32.0,12,32,12),
                        child: new Text("Preview Ad", style: TextStyle(color:greenColor,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),),
                      )),
                ),
                SizedBox(height:16),
                ButtonTheme(
                  minWidth: 200.0,
                  child: new RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                          side: BorderSide(color: greenColor, width: 2.0)
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AddPuppy()));
                      },
                      color:Colors.white,
                      disabledColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20.0,12,20,12),
                        child: new Text("Add New Puppy", style: TextStyle(color:greenColor,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),),
                      )),
                ),
                SizedBox(height:16),
                ButtonTheme (
                  minWidth: 200.0,
                  child: new RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                          side: BorderSide(color: greenColor, width: 2.0)
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
                      },
                      color:Colors.white,
                      disabledColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20.0,12,20,12),
                        child: new Text("Home Page", style: TextStyle(color:greenColor,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),),
                      )),
                ),

              ],
            ),
          ),
        ));
  }

  getPuppyDetails(context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId =  prefs.getString(Constants.SHARED_PREF_USER_ID);
    var dio = Dio();
    var getPuppyUrl = 'https://obpdevstage.wpengine.com/wp-json/obp-api/product';
    FormData formData = new FormData.fromMap({
      "user_id": userId,
      "pid": widget.puppyId,
    });
    try{
      dynamic response = await dio.post(getPuppyUrl, data: formData);
      widget.puppyDetails = PuppyDetails.fromJson(jsonDecode(response.toString()));
      setState(() {
        _isLoading = false;
      });
    }catch(exception){
      Toast.show("Request Failed. "+exception.toString(), context,);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
