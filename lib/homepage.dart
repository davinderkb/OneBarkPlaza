import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:dynamic_widget/dynamic_widget/basic/row_column_widget_parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:one_bark_plaza/main.dart';
class HomePage extends StatefulWidget  {

  HomePage() {

  }






  @override
  HomePageState createState() {
    return HomePageState();
  }
}

var puppyDetailsUrl = 'https://obpdevstage.wpengine.com/wp-json/obp-api/products/';
Future<List<PuppyDetails>>_puppiesList() async {
  var dio = Dio();
  FormData formData = new FormData.fromMap({
    "user_id": "125",
  });
  final list = List<PuppyDetails>();
  dynamic response = await dio.post(puppyDetailsUrl, data: formData);
  Map<String,dynamic> responseList = jsonDecode(response.toString());
  for(dynamic item in responseList["breeder_puppies"]){
    list.add(PuppyDetails.fromJson(item));
  }
  return list;
}

class HomePageState extends State<HomePage>{
  Future<List<PuppyDetails>> futureListOfPuppies;
  RefreshController _refreshControllerOnErrorReload = RefreshController(initialRefresh: false);
  RefreshController _refreshController = RefreshController(initialRefresh: false);





  @override
  void initState() {
    super.initState();
    futureListOfPuppies = _puppiesList();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          //iconTheme: new IconThemeData(color: Color(0xff262B31)),
          iconTheme: new IconThemeData(color: Color(0xff696969)),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 40,color: Color(0xff696969),),
                SizedBox(width: 0,),
                new Text(
                  "",
                  style: new TextStyle(
                      fontFamily: 'AvenirNext',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff262B31)),
                  textAlign: TextAlign.center,
                )
              ]),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        drawer: MainNavigationDrawer(),
        body: SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new SizedBox(height: 05,),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    new SizedBox(width: 25,),
                    Image.asset(
                      "assets/images/ic_touch_2.png",
                      height: 30,
                      width: 22,
                    ),
                    new SizedBox(width: 15),
                    new Text(
                      "Employee Services",
                      style: new TextStyle(
                          fontFamily: 'AvenirNext',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff696969)),
                      textAlign: TextAlign.center,
                    )
                  ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0,18,25.0,12),
                child: new RaisedButton(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0),side: BorderSide(color: Color(0xffF4F6F7))),
                  color: Color(0xff0072FF),
                  onPressed: () {
                    //onManageLeavePress(context);
                  },
                  child: new Container(

                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25,0,25,0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[

                          new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text("Manage Leaves",style: TextStyle(fontFamily:'AvenirNext', fontWeight:FontWeight.bold, fontSize:14,color: Colors.white)),
                                new SizedBox(height: 6.15,),
                                new Text("View/ Edit/ Apply Leaves",style: TextStyle(fontFamily:'AvenirNext', fontWeight:FontWeight.bold,fontSize:13,color: Color(0xff9BC7FF))),
                              ]),
                          new Image.asset("assets/images/ic_leaves.png", height: 35, width: 35,),

                        ],
                      ),
                    ),
                  ),

                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0,0,25.0,22),
                child: new RaisedButton(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0),side: BorderSide(color: Color(0xffF4F6F7))),
                  color: Color(0xffEB5050),
                  onPressed: () {
                    //onTimesheetPress(context);
                  },
                  child: new Container(
                    height: 70,

                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25,0,25,0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text("Timesheet",style: TextStyle(fontFamily:'AvenirNext',fontWeight:FontWeight.bold, fontSize:14,color: Colors.white)),
                                new SizedBox(height: 6.15,),
                                new Text("Manage Missing Hours",style: TextStyle(fontFamily:'AvenirNext', fontWeight:FontWeight.bold,fontSize:13,color: Color(0xffF7BBBB))),
                              ]),
                          new Image.asset("assets/images/ic_timesheet.png", height: 35, width: 35,),
                        ],
                      ),
                    ),
                  ),

                ),
              ),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    new SizedBox(width: 25,),
                    Image.asset(
                      "assets/images/ic_announcement.png",
                      height: 34,
                      width: 34,
                    ),
                    new SizedBox(width: 15,),
                    new Text(
                      "Announcements",
                      style: new TextStyle(
                          fontFamily: 'AvenirNext',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff696969)),
                      textAlign: TextAlign.center,
                    )
                  ]),
              new SizedBox(height: 16,),
              Container(
                height: _width ,
                width: _width - 50,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child:FutureBuilder(
                        future: futureListOfPuppies,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return Container(
                                alignment: Alignment.center,
                                child: Text("Error: ${snapshot.error}"),
                              );
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                              return Container(
                                alignment: Alignment.center,
                                child: SpinKitHourGlass(
                                  color:  Color(0xffEB5050),
                                  size: 50.0,
                                ),
                              );
                              break;
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                // return whatever you'd do for this case, probably an error
                                return SmartRefresher(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        //height: _height/2 - 80,
                                        alignment: Alignment.topCenter,
                                        width: _width,

                                      ),

                                      SizedBox(height: 8,),
                                      Text("Pull Down To Refresh", style: TextStyle(fontFamily: 'AvenirNext',fontSize: 13,color: Colors.blue,fontWeight: FontWeight.bold),),
                                    ],
                                  ),

                                  controller: _refreshControllerOnErrorReload,
                                  onRefresh: ()async{
                                    var connectivityResult = await (Connectivity().checkConnectivity());
                                    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>HomePage()));
                                    } else  {
                                      Toast.show("Internet is still not up yet.. Try again", context,
                                          textColor: Colors.white,
                                          duration: Toast.LENGTH_LONG,
                                          gravity: Toast.BOTTOM,
                                          backgroundColor: Colors.blue,
                                          backgroundRadius: 16);
                                    }
                                    _refreshControllerOnErrorReload.refreshCompleted();
                                  },
                                );
                              }
                              var data = snapshot.data;
                              return SmartRefresher(
                                child: new ListView.builder(
                                  reverse: false,
                                  scrollDirection: Axis.vertical,
                                  itemCount: data.length,
                                  itemBuilder: (BuildContext context, int index) => Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(16.0),),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(15.0,15.0,0,0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(data[index].title,style: TextStyle(fontFamily: 'AvenirNext',fontSize: 14,color: Color(0xff393939),fontWeight: FontWeight.bold)),
                                              Text(data[index].subjectLine,style: TextStyle(fontFamily: 'AvenirNext',fontSize: 14,color: Color(0xff666666),fontWeight: FontWeight.normal)),
                                              new SizedBox(width: _width-55,height: 15),

                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                                height:100,
                                                width: _width/2.5,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(64)),
                                                  //border: Border.all()
                                                  //color: Colors.green,
                                                ),
                                                child:ClipRRect(
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  child:CachedNetworkImage(
                                                    imageUrl: data[index].image,
                                                    placeholder: (context, url) => SpinKitCircle(
                                                      color:  Color(0xffEB5050),
                                                      size: 30.0,
                                                    ),
                                                    errorWidget: (context, url, error) =>Image.asset("assets/images/dummy_image.png",),
                                                  ),

                                                )
                                            ),
                                            //data[index].image,
                                          ],),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(15.0,15.0,15.0,25.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new SizedBox(width: _width-50,height: 15),
                                              Container(width: _width - 65,child: Text(data[index].description,style: TextStyle(fontFamily: 'AvenirNext',fontSize: 13,color:Color(0xff666666),fontWeight: FontWeight.normal))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ),
                                controller: _refreshController,
                                onRefresh: ()async{
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>HomePage()));
                                  _refreshController.refreshCompleted();
                                },
                              );
                              break;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}