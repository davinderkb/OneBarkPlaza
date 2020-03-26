import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    final bool isLogged = prefs.getBool(Constants.SHARED_PREF_IS_LOGGED_IN);

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
        primarySwatch: Colors.orange,
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

    TextStyle listTileTextStyle = TextStyle(color:Colors.white,fontSize: 15, fontWeight:FontWeight.bold,fontFamily: 'NunitoSans');
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.orangeAccent, //This will change the drawer background to blue.
        //other styles
      ),
      child: new Drawer(
        child: ListTileTheme(

          textColor: Color(0xff0072FF),
          iconColor:  Color(0xff0072FF),
          dense:true,


          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              FutureBuilder(
                future: user,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return Container(
                        alignment: Alignment.center,
                        child: SpinKitHourGlass(
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
                      return UserAccountsDrawerHeader(
                        accountName: Text(data["name"],style: TextStyle(color:Color(0xffFFFFFF),fontSize: 18, fontWeight:FontWeight.bold, fontFamily: 'NunitoSans')),
                        accountEmail: Text(data["email"],style: TextStyle(color:Color(0xffFFFFFF),fontSize: 14, fontFamily: 'NunitoSans')),
                        decoration: BoxDecoration(color: Color(0xffEB5050), ),

                      );
                      break;
                  }
                },
              ),
              ListTile(
                title: Text(Constants.HOME,style: listTileTextStyle,),
                leading: Icon(Icons.home,color:Colors.white),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>HomePage()));
                },
              ),
              //new Divider(height: 1.0, color: Colors.white,),
              ListTile(
                title: Text(Constants.MY_REWARDS,style: listTileTextStyle,),
                leading: Icon(Icons.card_giftcard,color:Colors.white),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>null));
                },
              ),

              ListTile(
                title: Text(Constants.ORGANIZATION_PROFILE,style:listTileTextStyle,),
                leading: Icon(Icons.business,color:Colors.white),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>null));
                },
              ),
              ListTile(
                title: Text(Constants.CHANGE_PASSWORD,style: listTileTextStyle,),
                leading: Icon(Icons.settings,color:Colors.white),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>null));
                },
              ),
              ListTile(
                title: Text(Constants.LOGOUT,style: listTileTextStyle,),
                leading: Icon(Icons.launch,color:Colors.white),
                onTap: () async {
                  await cleanUpSharedPref();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                  // Navigator.pop(context,true);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()),);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future cleanUpSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.SHARED_PREF_IS_LOGGED_IN, false);
    prefs.setString(Constants.SHARED_PREF_USER_NAME, null);
    prefs.setString(Constants.SHARED_PREF_PASSWORD, null);
    prefs.setString(Constants.SHARED_PREF_NAME, null);
    prefs.setString(Constants.SHARED_PREF_USER_ID, null);
  }

  Future<Map<dynamic,dynamic>> _getUserData(BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email =  prefs.getString(Constants.SHARED_PREF_USER_NAME);
    String name = prefs.getString(Constants.SHARED_PREF_NAME);
    if(email!=null && email!='' && name !=null && name !=''){
      Map<dynamic,dynamic> user = {"email": email,"name": name,};
      return user;
    }else {
      Toast.show("Error while loading navigation header, Try again", context,
          textColor: Colors.white,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Color(0xffEB5050),
          backgroundRadius: 16);
    }
  }

}
