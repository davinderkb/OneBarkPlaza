import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:one_bark_plaza/add_puppy.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:dynamic_widget/dynamic_widget/basic/row_column_widget_parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:one_bark_plaza/view_puppy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:one_bark_plaza/main.dart';
import 'package:one_bark_plaza/util/utility.dart';
TextStyle style = TextStyle(
    fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff707070));
class HomePage extends StatefulWidget {
  HomePage() {}

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

var puppyDetailsUrl =
    'https://obpdevstage.wpengine.com/wp-json/obp-api/products/';
Future<List<PuppyDetails>> _puppiesList() async {
  var dio = Dio();
  FormData formData = new FormData.fromMap({
    "user_id": "125",
  });
  final list = List<PuppyDetails>();
  dynamic response = await dio.post(puppyDetailsUrl, data: formData);
  Map<String, dynamic> responseList = jsonDecode(response.toString());
  for (dynamic item in responseList["breeder_puppies"]) {
    list.add(PuppyDetails.fromJson(item));
  }
  return list;
}

class HomePageState extends State<HomePage> {
  Future<List<PuppyDetails>> futureListOfPuppies;
  List<PuppyDetails> listOfPuppies;
  RefreshController _refreshControllerOnErrorReload =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var isSortPriceHighToLow = false;
  var isSortPriceLowToHigh = false;
  var isSortAgeHighToLow = false;
  var isSortAgeLowToHigh = false;

  final greenColor = Color(0xff7FA432);



  @override
  void initState() {
    super.initState();
    futureListOfPuppies = _puppiesList();
  }
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final puppyDetailsFontSize = 11.0;
    final greenColor = Color(0xff7FA432);
    final blueColor = Color(0xff4C8BF5);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          //iconTheme: new IconThemeData(color: Color(0xff262B31)),
          iconTheme: new IconThemeData(color: blueColor),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 60,
                ),
                //Icon(Icons.home, size: 40,color: blueColor,),
                SizedBox(
                  height: 42,
                  width: _width / 2.5,
                  child: FlatButton(
                    child: Text(
                      'Add Puppy',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddPuppy()));
                    },
                    disabledColor: blueColor,
                    color: blueColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                          bottomLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                          topLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(40.0),
                        ),
                        side: BorderSide(
                          color: Colors.white,
                        )),
                  ),
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
              new SizedBox(
                height: 05,
              ),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    new SizedBox(
                      width: 32,
                    ),
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
              new SizedBox(
                height: 16,
              ),
              Container(
                height: _height - 180,
                width: _width - 20,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: FutureBuilder(
                        future: futureListOfPuppies,
                        // ignore: missing_return
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
                                child: SpinKitFadingCircle(
                                  color: blueColor,
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
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "Pull Down To Refresh",
                                        style: TextStyle(
                                            fontFamily: 'NunitoSans',
                                            fontSize: 13,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  controller: _refreshControllerOnErrorReload,
                                  onRefresh: () async {
                                    var connectivityResult =
                                        await (Connectivity()
                                            .checkConnectivity());
                                    if (connectivityResult ==
                                            ConnectivityResult.mobile ||
                                        connectivityResult ==
                                            ConnectivityResult.wifi) {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  HomePage()));
                                    } else {
                                      Toast.show(
                                          "Internet is still not up yet.. Try again",
                                          context,
                                          textColor: Colors.white,
                                          duration: Toast.LENGTH_LONG,
                                          gravity: Toast.BOTTOM,
                                          backgroundColor: Colors.blue,
                                          backgroundRadius: 16);
                                    }
                                    _refreshControllerOnErrorReload
                                        .refreshCompleted();
                                  },
                                );
                              }
                              var data = snapshot.data as List<PuppyDetails>;
                              if(isSortPriceHighToLow)
                                  data.sort((a, b) => b.puppyPrice.compareTo(a.puppyPrice));
                              if(isSortPriceLowToHigh)
                                data.sort((a, b) => a.puppyPrice.compareTo(b.puppyPrice));
                              if(isSortAgeHighToLow)
                                data.sort((a, b) => int.parse(b.ageInWeeks).compareTo(int.parse(a.ageInWeeks)));
                              if(isSortAgeLowToHigh)
                                data.sort((a, b) => int.parse(a.ageInWeeks).compareTo(int.parse(b.ageInWeeks)));
                              return new ListView.builder(
                                reverse: false,
                                scrollDirection: Axis.vertical,
                                itemCount: data.length,
                                itemBuilder:
                                    (BuildContext context, int index) => Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(8.0),
                                  ),
                                  child: Container(
                                    width: _width - 60 ,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,

                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0,8,0,8),
                                                child: Container(
                                                    height: _height/6,
                                                    width: _width/3.5,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffFEF8F5),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  24)),
                                                      //border: Border.all()
                                                      //color: Colors.green,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            data[index].images,
                                                        placeholder:
                                                            (context, url) =>
                                                                SpinKitCircle(
                                                          color: blueColor,
                                                          size: 30.0,
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          "assets/images/bulldog"+(index+1).toString()+".jpg", fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              SizedBox(width: 12,),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment:CrossAxisAlignment.start,
                                                  mainAxisAlignment:MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Container(
                                                          child: Text(
                                                              data[index]
                                                                  .puppyName,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'NunitoSans',
                                                                  fontSize:
                                                                      15,
                                                                  color:
                                                                      blueColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          child: PopupMenuButton<String>(
                                                            color: Color(0xfffff3e0),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: new BorderRadius.only(
                                                                  bottomLeft: Radius.circular(12.0),
                                                                  topRight: Radius.circular(0.0),
                                                                  topLeft: Radius.circular(12.0),
                                                                  bottomRight: Radius.circular(12.0),
                                                                ),
                                                                side: BorderSide(
                                                                  color: greenColor,
                                                                )),
                                                            // ignore: missing_return
                                                            onSelected: (String value) {
                                                              if(value == "Delete"){
                                                                showDialog<void>(
                                                                  context: context,
                                                                  barrierDismissible: false, // user must tap button!
                                                                  builder: (BuildContext context) {
                                                                    return CupertinoAlertDialog(
                                                                      title: Text('Are you sure?'),
                                                                      content: Text('\nYou want to delete this puppy?'),
                                                                      actions: <Widget>[
                                                                        CupertinoDialogAction(
                                                                          child: Text('No'),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                        CupertinoDialogAction(
                                                                          child: Text('Yes'),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              } else {

                                                              }
                                                              setState(() {
                                                                //_selection = value;
                                                              });
                                                            },
                                                            child: Container(
                                                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                              decoration: BoxDecoration(
                                                                color: Colors.transparent,
                                                                //color: Color(0xffFFFFFF),
                                                                borderRadius:
                                                                BorderRadius.all(Radius.circular(16)),
                                                              ),
                                                              width: _width/10,
                                                              height: _width/10,
                                                              child: Image.asset(
                                                                "assets/images/ic_menuOverflow.png",
                                                                height: 16, color: blueColor,),
                                                            ),
                                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                                              PopupMenuItem<String>(
                                                                height: 24,
                                                                value: 'Edit',
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    Icon(Icons.edit, color: const Color(0xff7FA432), size: 15),
                                                                    SizedBox(width: 12,),
                                                                    Text('Edit', style: const TextStyle(fontFamily: "NunitoSans", fontSize: 12, color: const Color(0xff7FA432), fontWeight: FontWeight.bold)),
                                                                  ]
                                                                ),
                                                              ),
                                                              PopupMenuDivider(),
                                                              PopupMenuItem<String>(
                                                                height: 24,
                                                                value: 'Delete',
                                                                child: Row(
                                                                    children: <Widget>[
                                                                      Icon(Icons.delete, color: Colors.redAccent, size: 15),
                                                                      SizedBox(width: 12,),
                                                                      Text('Delete', style: const TextStyle(fontFamily: "NunitoSans", fontSize: 12, color: Colors.redAccent,fontWeight: FontWeight.bold)),
                                                                    ]
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                        data[index]
                                                                .categoryName,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'NunitoSans',
                                                            fontSize:
                                                                13,
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                    Utility.capitalize(data[index].gender)+"  |  "+data[index].ageInWeeks + " weeks Old",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'NunitoSans',
                                                                fontSize:
                                                                    puppyDetailsFontSize,
                                                                color:
                                                                Color(0xff707070),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),

                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                            "\$ " +
                                                                double.parse(data[index].puppyPrice).toString(),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'NunitoSans',
                                                                fontSize:
                                                                    puppyDetailsFontSize,
                                                                color:
                                                                    Color(0xff707070),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),

                                                      ],
                                                    ),
                                                    FlatButton(
                                                      padding: EdgeInsets.fromLTRB(40,0,40,0),
                                                      child: Text(
                                                        'Preview',
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(fontFamily:"NunitoSans",fontSize: 10, color: Colors.white),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>ViewPuppy(data[index])));
                                                      },
                                                      disabledColor: blueColor,
                                                      color: blueColor,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: new BorderRadius.only(
                                                            bottomLeft: Radius.circular(40.0),
                                                            topRight: Radius.circular(40.0),
                                                            topLeft: Radius.circular(40.0),
                                                            bottomRight: Radius.circular(40.0),
                                                          ),
                                                          ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              break;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: _width, height: 2, color:Color(0xffF3F3F3)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      onSortClick(context);
                      },
                    child: Container(
                        width: _width / 2 - 1,
                        height: 50,
                        child:Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.sort, size: 18,color:blueColor),
                            SizedBox(width: 12,),
                            Text(
                              "Sort",
                              style: new TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: blueColor),
                              textAlign: TextAlign.center,
                            )
                          ],
                        )
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(height: 2,),
                      Container(width: 2, height: 45, color: Color(0xffF3F3F3)),
                    ],
                  ),
                  InkWell(
                    onTap: (){
                      onFilterClick(context);
                    },
                    child: Container(
                        width: _width / 2 - 1,
                        height: 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset("assets/images/ic_filter.png", color: blueColor, width: 18,),
                            SizedBox(width: 12,),
                            Text(
                              "Filter",
                              style: new TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: blueColor),
                              textAlign: TextAlign.center,
                            )
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void onSortClick(BuildContext context) {
      final act = CupertinoActionSheet(

          title: Container(alignment:Alignment.topLeft,child: Text('SORT BY', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.left,)),
          actions: <Widget>[
            CupertinoActionSheetAction(

              child: Padding(
                padding: const EdgeInsets.fromLTRB(30,0,0,0),
                child: Container(alignment:Alignment.topLeft,child: Text('Price - high to low', style:style.copyWith(fontWeight: isSortPriceHighToLow ? FontWeight.bold:FontWeight.normal),textAlign: TextAlign.left, )),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                    setAllSortingFalse();
                    isSortPriceHighToLow = true;
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30,0,0,0),
                child: Container(alignment:Alignment.topLeft,child: Text('Price - low to high', style:style.copyWith(fontWeight: isSortPriceLowToHigh ? FontWeight.bold:FontWeight.normal),textAlign: TextAlign.left)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  setAllSortingFalse();
                  isSortPriceLowToHigh = true;
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30,0,0,0),
                child: Container(alignment:Alignment.topLeft,child: Text('Age - high to low', style:style.copyWith(fontWeight: isSortAgeHighToLow ? FontWeight.bold:FontWeight.normal),textAlign: TextAlign.left)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  setAllSortingFalse();
                  isSortAgeHighToLow = true;
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30,0,0,0),
                child: Container(alignment:Alignment.topLeft,child: Text('Age - low to high', style:style.copyWith(fontWeight: isSortAgeLowToHigh ? FontWeight.bold:FontWeight.normal),textAlign: TextAlign.left)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  setAllSortingFalse();
                  isSortAgeLowToHigh = true;
                });
              },
            ),
          ],
        );
      showCupertinoModalPopup(

          context: context,
          builder: (BuildContext context) => act);
  }

  void setAllSortingFalse() {
     isSortPriceHighToLow = false;
    isSortPriceLowToHigh = false;
    isSortAgeHighToLow = false;
    isSortAgeLowToHigh = false;
  }

  void onFilterClick(BuildContext context) {
    final act = CupertinoActionSheet(
      title: Container(alignment:Alignment.topLeft,child: Text('FILTER BY BREED', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.left,)),

    );
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => act);
  }
}
