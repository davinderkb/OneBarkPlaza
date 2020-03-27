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
    final puppyDetailsFontSize = 14.0;
    final blueColor = Color(0xff4C8BF5);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          //iconTheme: new IconThemeData(color: Color(0xff262B31)),
          iconTheme: new IconThemeData(color: blueColor),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 40,color: blueColor,),
                SizedBox(width: 0,),
                new Text(
                  "",
                  style: new TextStyle(
                      fontFamily: 'NunitoSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blueColor),
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


                    new SizedBox(width: 32,),
                    new Text(
                      "All Puppies",
                      style: new TextStyle(
                          fontFamily: 'NunitoSans',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: blueColor),
                      textAlign: TextAlign.center,
                    )
                  ]),
              new SizedBox(height: 16,),
              Container(
                height: _height - 200 ,
                width: _width - 30,
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
                                  color:  blueColor,
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
                                      Text("Pull Down To Refresh", style: TextStyle(fontFamily: 'NunitoSans',fontSize: 13,color: Colors.blue,fontWeight: FontWeight.bold),),
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
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0),),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0.0,12.0,0,12),
                                          child:  Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                    height:_height/10,
                                                    width: _width/4,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                                      //border: Border.all()
                                                      //color: Colors.green,
                                                    ),
                                                    child:ClipRRect(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                      child:CachedNetworkImage(
                                                        imageUrl: data[index].images,
                                                        placeholder: (context, url) => SpinKitCircle(
                                                          color:  blueColor,
                                                          size: 30.0,
                                                        ),
                                                        errorWidget: (context, url, error) =>Image.asset("assets/images/dummy_image.png",),
                                                      ),

                                                    )
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(8,0,0,0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: <Widget>[
                                                        Text(data[index].puppyName,style: TextStyle(fontFamily: 'NunitoSans',fontSize: 16,color: blueColor,fontWeight: FontWeight.bold)),
                                                        Image.asset("assets/images/ic_menuOverflow.png",  height: 20),
                                                      ],
                                                    ),
                                                    Text("Breed: "+data[index].categoryName,style: TextStyle(fontFamily: 'NunitoSans',fontSize: puppyDetailsFontSize,color: blueColor,fontWeight: FontWeight.normal)),
                                                    Row(
                                                      children: <Widget>[
                                                        Text("Age: "+data[index].ageInWeeks +" weeks",style: TextStyle(fontFamily: 'NunitoSans',fontSize: puppyDetailsFontSize,color: blueColor,fontWeight: FontWeight.normal)),
                                                        Text("  |  ",style: TextStyle(fontFamily: 'NunitoSans',fontSize: puppyDetailsFontSize,color: blueColor,fontWeight: FontWeight.normal)),
                                                        Text("Date of Birth: "+data[index].dob ,style: TextStyle(fontFamily: 'NunitoSans',fontSize: puppyDetailsFontSize,color: blueColor,fontWeight: FontWeight.normal)),

                                                      ],
                                                    ),
                                                    Row(

                                                      children: <Widget>[
                                                        Text("Price: "+data[index].puppyPrice,style: TextStyle(fontFamily: 'NunitoSans',fontSize: puppyDetailsFontSize,color: blueColor,fontWeight: FontWeight.normal)),
                                                        Text("  |  ",style: TextStyle(fontFamily: 'NunitoSans',fontSize: puppyDetailsFontSize,color: blueColor,fontWeight: FontWeight.normal)),
                                                        Text("Availability: In stock",style: TextStyle(fontFamily: 'NunitoSans',fontSize: puppyDetailsFontSize,color: blueColor,fontWeight: FontWeight.normal)),

                                                      ],
                                                    ),




                                                  ],
                                                ),
                                              ),
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