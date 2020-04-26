import 'dart:convert';
import 'dart:ffi';
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
import 'package:one_bark_plaza/util/constants.dart';
import 'package:one_bark_plaza/view_puppy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:one_bark_plaza/main.dart';
import 'package:one_bark_plaza/util/utility.dart';

import 'edit_puppy.dart';
import 'filter.dart';
final customColor = Color(0xff7FA432);//Color(0xff4C8BF5);
TextStyle style = TextStyle(
    fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff707070));
class HomePage extends StatefulWidget {
  HomePageState homePageState;
  bool isRedirectedFromDelete = false;
  HomePage() {
    this.isRedirectedFromDelete = false;
  }
  HomePage.redirectedFromDelete(){
    this.isRedirectedFromDelete = true;
  }
  @override
  HomePageState createState() {
    return homePageState = HomePageState();
  }
}

var puppyDetailsUrl =
    'https://obpdevstage.wpengine.com/wp-json/obp/v1/puppies/';
Future<List<PuppyDetails>> _puppiesList(BuildContext context) async {
  var dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId =  prefs.getString(Constants.SHARED_PREF_USER_ID);
  if(userId!=null && userId!=''){
    FormData formData = new FormData.fromMap({
      "user_id": userId,
    });
    final list = List<PuppyDetails>();
    dynamic response = await dio.post(puppyDetailsUrl,data:formData);
    Map<String, dynamic> responseList = jsonDecode(response.toString());
    for (dynamic item in responseList["breeder_puppies"]) {
      list.add(PuppyDetails.fromJson(item));
    }
    return list;
  } else{
    Toast.show("Something went wrong, Try logout and re-login", context);
  }

}

class HomePageState extends State<HomePage> {
  bool _isLoading = false;
  Future<List<PuppyDetails>> futureListOfPuppies;
  Set<String> setOfPuppies = new Set<String>();
  Set<String> filterBreedSet;
  RefreshController _refreshControllerOnErrorReload =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var isSortPriceHighToLow = false;
  var isSortPriceLowToHigh = false;
  var isSortAgeHighToLow = false;
  var isSortAgeLowToHigh = false;

  final greenColor = Color(0xff7FA432);

  Filter filter;

  double minPrice;
  double maxPrice;

  bool isDeleteSuccess = false;



  @override
  void initState() {
    super.initState();
    futureListOfPuppies = _puppiesList(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.isRedirectedFromDelete){
        widget.isRedirectedFromDelete = false;
        Toast.show("Puppy Deleted Successfully", context);
      }
    } );

  }
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final puppyDetailsFontSize = 11.0;

    minPrice = 0.0;
    maxPrice = 10000.0;


    return _isLoading? Container(
        color: Colors.white,
        width: _width,
        height: _height,
        alignment: Alignment.bottomCenter,
        child: SpinKitRipple(
          borderWidth: 100.0,
          color: customColor,
          size: 120,
        ))
        : isDeleteSuccess
        ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage.redirectedFromDelete()))
        : Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          //iconTheme: new IconThemeData(color: Color(0xff262B31)),
          iconTheme: new IconThemeData(color: customColor),
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
                    disabledColor: customColor,
                    color: customColor,
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
                          color: customColor),
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
                                  color: customColor,
                                  size: 50.0,
                                ),
                              );
                              break;
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                // return whatever you'd do for this case, probably an error
                                return SmartRefresher(
                                  child:Container(
                                    width: _width,

                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset("assets/images/ic_noInternet.png", height: 60,width:70, color: Color(0xffebebeb),),
                                        SizedBox(height: 24),
                                        Text("You're offline", style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 16.0, color:  Color(0xff707070))),
                                        SizedBox(height: 12),
                                        Text("Connect to the internet and try again", style: TextStyle(fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff707070))),
                                        SizedBox(height: 36,),
                                        new RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: new BorderRadius.circular(30.0),
                                                side: BorderSide(color: greenColor, width: 2.0)
                                            ),
                                            onPressed: () async { checkConnectivityAndRefresh(context);},
                                            color:Colors.white,
                                            disabledColor: Colors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(8.0,0,8,0),
                                              child: new Text("Try Again", style: TextStyle(color:greenColor,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),),
                                            )),
                                        SizedBox(height: 60),
                                      ],
                                    ),
                                  ),
                                  controller: _refreshControllerOnErrorReload,
                              onRefresh: ()async{
                                                await checkConnectivityAndRefresh(context);
                                                _refreshControllerOnErrorReload.refreshCompleted();
                                                }

                                );
                              }
                              var data = snapshot.data as List<PuppyDetails>;
                              getMinMaxPrice(data);
                              data = applyBreedFilter(data);
                              data = applyGenderFilter(data);
                              data = applyPriceRangeFilter(data);
                              applySorting(data);

                              for(PuppyDetails item in data){
                                setOfPuppies.add(item.categoryName.toString());
                              }
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0,8,0,8),
                                                child: Container(
                                                    height: _height>_width? _height/6 : _width/4,
                                                    width:  _height>_width? _width/3.5 : _height/2,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffFEF8F5),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  24), ),
                                                     // border: Border.all(color: Color(0xffA9A9A9))
                                                      //color: Colors.green,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            data[index].coverPic != null?data[index].coverPic.src:"",
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                SpinKitCircle(
                                                          color: customColor,
                                                          size: 30.0,
                                                        ),
                                                        errorWidget: (context,url, error) =>
                                                        Container(
                                                            margin: EdgeInsets.all(10),
                                                            child: new Image.asset("assets/images/noImageIcon.png",color: Colors.white)
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
                                                                      14,
                                                                  color:
                                                                      Colors.black87,
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
                                                                          onPressed: () async{
                                                                            Navigator.of(context).pop();
                                                                            setState(() {
                                                                              _isLoading = true;
                                                                            });
                                                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                            String userId =  prefs.getString(Constants.SHARED_PREF_USER_ID);
                                                                            var dio = Dio();
                                                                            var deletePuppyUrl = 'https://obpdevstage.wpengine.com/wp-json/obp-api/delete_puppy';
                                                                            FormData formData = new FormData.fromMap({
                                                                              "user_id": userId,
                                                                              "puppy_id": data[index].puppyId,
                                                                            });
                                                                            try{
                                                                              dynamic response = await dio.post(deletePuppyUrl, data: formData);
                                                                              dynamic responseList = jsonDecode(response.toString());
                                                                              if (responseList.length > 0 && responseList[0] == "success"){
                                                                                setState(() {
                                                                                  _isLoading = false;
                                                                                  isDeleteSuccess = true;
                                                                                });
                                                                              } else{
                                                                                setState(() {
                                                                                  _isLoading = false;
                                                                                });
                                                                                Toast.show("Request Failed. " + response.toString(), context);
                                                                                Navigator.of(context).pop();
                                                                              }
                                                                            }catch(exception){
                                                                              setState(() {
                                                                                _isLoading = false;
                                                                              });
                                                                              Toast.show("Request Failed. "+exception.toString(), context);

                                                                            }
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditPuppy(data[index])));
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
                                                              width: _height>_width?_width/10 : _height/10,
                                                              height:_height>_width?_width/10 : _height/8,
                                                              child: Image.asset(
                                                                "assets/images/ic_menuOverflow.png",
                                                                height: 16, color: customColor,),
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
                                                                12,
                                                            color: customColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
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
                                                                        .bold)),

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
                                                                        .bold)),

                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: _width / 3,
                                                      child: FlatButton(
                                                        child: Text(
                                                          'View',
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(fontSize: 12, color: Colors.white),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>ViewPuppy(data[index],false)));
                                                        },
                                                        disabledColor: customColor,
                                                        color: customColor,
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
                                                    ),

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
                      if(setOfPuppies !=null && setOfPuppies.length>0){
                        onSortClick(context);
                      } else{
                        Toast.show("Let the page loading finish and then try this option", context);
                      }
                      },
                    child: Container(
                        width: _width / 2 - 1,
                        height: 50,
                        child:Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.sort, size: 18,color:customColor),
                            SizedBox(width: 12,),
                            Text(
                              "Sort",
                              style: new TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: customColor),
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
                      if(setOfPuppies !=null && setOfPuppies.length>0){
                        if(filter == null){
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>filter = Filter(setOfPuppies, widget.homePageState, minPrice, maxPrice)));;
                        }
                        else{
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>filter));
                        }
                      } else{
                          Toast.show("Let the page loading finish and then try this option", context);
                      }


                    },
                    child: Container(
                        width: _width / 2 - 1,
                        height: 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset("assets/images/ic_filter.png", color: customColor, width: 18,),
                            SizedBox(width: 12,),
                            Text(
                              "Filter",
                              style: new TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: customColor),
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

  Future checkConnectivityAndRefresh(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>HomePage()));
    }
    else {
        Toast.show("Internet is still down.. Keep trying", context);
    }
  }

  void applySorting(List<PuppyDetails> data) {
    if(isSortPriceHighToLow)
        data.sort((a, b) => double.parse(b.puppyPrice).compareTo(double.parse(a.puppyPrice)));
    if(isSortPriceLowToHigh)
      data.sort((a, b) => double.parse(a.puppyPrice).compareTo(double.parse(b.puppyPrice)));
    if(isSortAgeHighToLow)
      data.sort((a, b) => int.parse(b.ageInWeeks).compareTo(int.parse(a.ageInWeeks)));
    if(isSortAgeLowToHigh)
      data.sort((a, b) => int.parse(a.ageInWeeks).compareTo(int.parse(b.ageInWeeks)));
  }

  List<PuppyDetails> applyPriceRangeFilter(List<PuppyDetails> data) {
    if(filter!=null && (filter.chosenMinPrice!=minPrice || filter.chosenMaxPrice != maxPrice)){
      var filteredData = new List<PuppyDetails>();
      for(PuppyDetails item in data){
        if(double.parse(item.puppyPrice)>= filter.priceRangeFilter.changedMinValue && double.parse(item.puppyPrice)<= filter.priceRangeFilter.changedMaxValue){
          filteredData.add(item);
        }
      }
      data = filteredData;

    }
    return data;
  }

  List<PuppyDetails> applyGenderFilter(List<PuppyDetails> data) {
    if(filter != null && filter.selectedGender.length>0 ){
      var filteredData = new List<PuppyDetails>();
      for(PuppyDetails item in data){
        if(filter.selectedGender.contains(Utility.capitalize(item.gender.toString()))){
          filteredData.add(item);
        }
      }
      data =filteredData;
    }
    return data;
  }

  List<PuppyDetails> applyBreedFilter(List<PuppyDetails> data) {
    if(filter != null && filter.selectedSetOfBreeds.length>0 ){
      var filteredData = new List<PuppyDetails>();
      for(PuppyDetails item in data){
        if(filter.selectedSetOfBreeds.contains(item.categoryName.toString())){
          filteredData.add(item);
        }
      }
      data =filteredData;
    }
    return data;
  }

  void onSortClick(BuildContext context) {
      final act = CupertinoActionSheet(

          title: Container(alignment:Alignment.topLeft,child: Text('SORT BY', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.left,)),
          actions: <Widget>[
            CupertinoActionSheetAction(

              child: Padding(
                padding: const EdgeInsets.fromLTRB(30,0,0,0),
                child: Container(alignment:Alignment.topLeft,child: Text('Price - high to low', style:style.copyWith(fontWeight: isSortPriceHighToLow ? FontWeight.bold:FontWeight.bold),textAlign: TextAlign.left, )),
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
                child: Container(alignment:Alignment.topLeft,child: Text('Price - low to high', style:style.copyWith(fontWeight: isSortPriceLowToHigh ? FontWeight.bold:FontWeight.bold),textAlign: TextAlign.left)),
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
                child: Container(alignment:Alignment.topLeft,child: Text('Age - high to low', style:style.copyWith(fontWeight: isSortAgeHighToLow ? FontWeight.bold:FontWeight.bold),textAlign: TextAlign.left)),
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
                child: Container(alignment:Alignment.topLeft,child: Text('Age - low to high', style:style.copyWith(fontWeight: isSortAgeLowToHigh ? FontWeight.bold:FontWeight.bold),textAlign: TextAlign.left)),
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

  void getMinMaxPrice(List<PuppyDetails> data) {
    Set<double> priceSet = new Set<double>();
    for (PuppyDetails item in data){
      priceSet.add( double.parse(item.puppyPrice.toString()));
    }
    minPrice = priceSet.reduce((curr, next) => curr < next? curr: next);
    maxPrice = priceSet.reduce((curr, next) => curr > next? curr: next);

  }






}


