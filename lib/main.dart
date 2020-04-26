import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:one_bark_plaza/add_puppy.dart';
import 'package:one_bark_plaza/orders_page.dart';
import 'package:one_bark_plaza/update_profile.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:one_bark_plaza/homepage.dart';

import 'login.dart';

void main() => runApp(MainActivity());

class MainActivity extends StatefulWidget {

  @override
  MainActivityState createState() {



    return MainActivityState();
  }

}


class MainActivityState extends State<MainActivity>{
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void autoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLogged = prefs.getBool(Constants.SHARED_PREF_IS_LOGGED_IN)??false;

    if (isLogged) {
      setState(() {
        isLoggedIn = true;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Bark Plaza',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,

      ),
      home: isLoggedIn?HomePage():LoginPage(),
    );
  }
}

class MainNavigationDrawer extends StatefulWidget {
  const MainNavigationDrawer({Key key,}) : super(key: key);


  @override
  MainNavigationDrawerState createState() {
    return MainNavigationDrawerState();
  }
}

class MainNavigationDrawerState extends State<MainNavigationDrawer>{
  dynamic user;

  @override
  void initState() {
    super.initState();
    user = _getUserData(context) ;
  }
  @override
  Widget build(BuildContext context) {
    final iconSize = 24.0;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    var drawerContentColor = Colors.white;
    var drawerHeaderColorLightBlue = Colors.black;
    var drawerAvatarBackgroundColor = Color(0xffFEF8F5);
    var drawerBackground = Colors.black;
    TextStyle listTileTextStyle = TextStyle(color:drawerContentColor,fontSize: 14, fontWeight:FontWeight.bold,fontFamily: 'NunitoSans');


    return Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.black),
      child: Container(
        width: _width/1.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(48)),
        ),
        child: new Drawer(
          child: ListTileTheme(
            textColor: drawerContentColor,
            iconColor:  Colors.black87,
            dense:true,
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                FutureBuilder(
                  future: user,
                  // ignore: missing_return
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return Container(
                          alignment: Alignment.center,
                          child: SpinKitFadingCircle (
                            color: Color(0xffFFFFFF),
                            size: 50.0,
                          ),
                        );
                        break;
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          // return whatever you'd do for this case, probably an error
                          return Container(
                            alignment: Alignment.center,
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        var data = snapshot.data;
                        return Stack(
                          children: <Widget>[
                            Container(
                              height: _height>_width? _height/3: _width/3,
                              color: drawerBackground ,
                              child: Column(

                                children: <Widget>[
                                  Container(height:_height>_width? _height/6:_width/6, color:drawerHeaderColorLightBlue),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(height: _height>_width?_height/18 : _width/18),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(data["name"],style: TextStyle(color:Colors.grey,fontSize: 15, fontWeight:FontWeight.bold, fontFamily: 'NunitoSans')),
                                        ],
                                      ),
                                      Text(data["email"],style: TextStyle(color:Colors.grey,fontSize: 12, fontFamily: 'NunitoSans')),
                                    ],
                                  ),

                                ],



                              ),
                            ),
                            Positioned(
                                width: _width/1.2,
                                top: _height>_width? _width * 0.14 : _height *0.14 ,
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: InkWell(
                                          onTap:(){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile(profilePic:data["profilePic"], gender:data["gender"], name:data["name"])))  ;
                                          },
                                          child: Container(
                                            height: 100,
                                            width: 100,
                                            child: ClipRRect(
                                              borderRadius:BorderRadius.circular(300.0),
                                              child: FadeInImage.assetNetwork(
                                                  placeholder: data["gender"]=="Male"
                                                      ? "assets/images/ic_profile_male.png"
                                                      : "assets/images/ic_profile_female.png",
                                                  image: data["profilePic"],
                                                  fit: BoxFit.cover),
                                            ),
                                            decoration: new BoxDecoration(
                                              color: drawerAvatarBackgroundColor,
                                                shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(0.0, 1.0), //(x,y)
                                                  blurRadius: 2.0,
                                                ),
                                              ],
                                            )
                                ),
                                        ),
                                      ),
                                      Positioned(
                                        width: _width/1.2 + 90 ,
                                        top: _height>_width?_width * 0.18 : _height * 0.18 ,
                                        child: InkWell(
                                          onTap:(){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile(profilePic:data["profilePic"], gender:data["gender"], name:data["name"])))  ;
                                          },
                                          child: Container(
                                              height: 25,
                                              width: 25,
                                              child: Icon(Icons.edit, color: greenColor,),
                                              decoration: new BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(-1.0, -1.0), //(x,y)
                                                    blurRadius: 2.0,
                                                  ),
                                                ],
                                              )
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                            )
                          ],
                        );
                        break;
                    }
                  },
                ),
                SizedBox(height: 16,),

                ListTile(
                  title: Text("All Puppies",style: listTileTextStyle,),
                  leading: Image.asset("assets/images/ic_allpuppies.png",  width: iconSize,color: Colors.white,),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>HomePage()));
                  },
                ),
                SizedBox(height: 4,),
                new Divider(height: 1.0, color: greenColor),
                SizedBox(height: 4,),
                ListTile(
                  title: Text("Add Puppy",style: listTileTextStyle,),
                  leading: Image.asset("assets/images/ic_addpuppy.png",  width: iconSize,color: Colors.white,),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>AddPuppy()));
                  },
                ),
                SizedBox(height: 4,),
                new Divider(height: 1.0, color: greenColor),
                SizedBox(height: 4,),
                ListTile(
                  title: Text("Orders",style:listTileTextStyle,),
                  leading: Image.asset("assets/images/ic_orders.png",  width: iconSize,color: Colors.white,),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>Orders()));
                  },
                ),
                SizedBox(height: 4,),
                new Divider(height: 1.0, color: greenColor),
                SizedBox(height: 4,),
                ListTile(
                  title: Text("Payment Options",style: listTileTextStyle,),
                  leading: Image.asset("assets/images/ic_billing.png",  width: iconSize, color: Colors.white,),
                  onTap: () {
                    Toast.show("Payment Options, to-do", context);
                    ;
                  },
                ),SizedBox(height: 4,),
                new Divider(height: 1.0, color: greenColor),
                SizedBox(height: 4,),
                ListTile(
                  title: Text("Payment History",style: listTileTextStyle,),
                  leading:Image.asset("assets/images/ic_payment_history.png",  width: iconSize, color: Colors.white,),
                  onTap: () async {
                    Toast.show("Paymnet History, to-do", context);

                  },
                ),
                SizedBox(height: 4,),
                new Divider(height: 1.0, color: greenColor),
                SizedBox(height: 4,),
                ListTile(
                  title: Text(Constants.LOGOUT,style: listTileTextStyle,),
                  leading: Image.asset("assets/images/ic_logout.png",  width: iconSize, color: Colors.white,),
                  onTap: () async {
                    await cleanUpSharedPref();
                    //Navigator.popUntil(context, ModalRoute.withName('/'));
                    Navigator.pop(context,true);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future cleanUpSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.SHARED_PREF_IS_LOGGED_IN, false);
    prefs.setString(Constants.SHARED_PREF_USER_NAME, null);
    prefs.setString(Constants.SHARED_PREF_GENDER, null);
    prefs.setString(Constants.SHARED_PREF_PROFILE_IMAGE, null);
    prefs.setString(Constants.SHARED_PREF_PASSWORD, null);
    prefs.setString(Constants.SHARED_PREF_NAME, null);
    prefs.setString(Constants.SHARED_PREF_USER_ID, null);
  }

  Future<Map<dynamic,dynamic>> _getUserData(BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email =  prefs.getString(Constants.SHARED_PREF_USER_NAME);
    String name = prefs.getString(Constants.SHARED_PREF_NAME);
    String gender = prefs.getString(Constants.SHARED_PREF_GENDER);
    String profilePic = prefs.getString(Constants.SHARED_PREF_PROFILE_IMAGE);

   try{
      Map<dynamic,dynamic> user = {"email": email,"name": name, "gender": gender,"profilePic": profilePic};
      return user;
    }catch(e) {
      Toast.show("Error while loading navigation header, Try again", context,
          textColor: Colors.white,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Color(0xffEB5050),
          backgroundRadius: 16);
    }
  }

}
