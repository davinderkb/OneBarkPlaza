import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:one_bark_plaza/order_details.dart';
import 'package:one_bark_plaza/add_puppy.dart';
import 'package:one_bark_plaza/order_details_page.dart';
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
final blueColor = Color(0xff4C8BF5);
TextStyle style = TextStyle(fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff707070));
class Orders extends StatefulWidget {
  OrdersState orderPageState;

  @override
  OrdersState createState() {
    return orderPageState = OrdersState();
  }
}

var getAllOrdersUrl = 'https://obpdevstage.wpengine.com/wp-json/obp/v1/orders';
var getSingleOrderUrl = 'https://obpdevstage.wpengine.com/wp-json/obp/v1/order';
Future<List<OrderDetails>> ordersList(BuildContext context) async {
  var dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId =  prefs.getString(Constants.SHARED_PREF_USER_ID);
  if(userId!=null && userId!=''){
    FormData formData = new FormData.fromMap({
      "user_id": userId,
    });
    final list = new List<OrderDetails>();
    dynamic response = await dio.post(getAllOrdersUrl,data:formData);
    if(response.statusCode == 200){
      dynamic responseList = jsonDecode(response.toString());
      for (dynamic order in responseList) {
        FormData formData = new FormData.fromMap({
          "user_id": userId,
          "order_id": order["order_id"]
        });
        dynamic response = await dio.post(getSingleOrderUrl,data:formData);
        if(response.statusCode == 200){
          dynamic json = jsonDecode(response.toString());
          double vendorEarning = 0.0;
          try{vendorEarning =double.parse(order["vendor_earning"].toString());}catch(e){}
          list.add(OrderDetails.fromJson(
              order["order_id"].toString(),
              vendorEarning,
              order["order_status"],
              order["order_date"] is int || order["order_date"] is String || order["order_date"] is double? order["order_date"].toString(): "",
              json));
        }else
          Toast.show("Error while fetching Order Details for Order "+order["order_id"], context);
      }
      return list;
    }
    else
      Toast.show("Error while fetching Orders", context);
  } else{
    Toast.show("Something went wrong, Try again", context);
  }
}

class OrdersState extends State<Orders> {
  var orderHeaderColor = Colors.black87;
  bool _isLoading = false;
  Future<List<OrderDetails>> futureListOfOrders;
  RefreshController _refreshControllerOnErrorReload = RefreshController(initialRefresh: false);
  RefreshController _refreshController = RefreshController(initialRefresh: false);
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
    futureListOfOrders = ordersList(context);
  }
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final puppyDetailsFontSize = 11.0;
    final greenColor = Color(0xff7FA432);
    minPrice = 0.0;
    maxPrice = 10000.0;


    return _isLoading? Container(
        color: Colors.white,
        width: _width,
        height: _height,
        alignment: Alignment.bottomCenter,
        child: SpinKitRipple(
          borderWidth: 100.0,
          color: greenColor,
          size: 120,
        ))
        : Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          //iconTheme: new IconThemeData(color: Color(0xff262B31)),
          iconTheme: new IconThemeData(color: greenColor),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                new Text(
                  "Orders",
                  style: new TextStyle(
                      fontFamily: 'NunitoSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: greenColor),
                  textAlign: TextAlign.center,
                ),
              ]),
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        drawer: MainNavigationDrawer(),
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new SizedBox(
              height: 05,
            ),

            new SizedBox(
              height: 8,
            ),
            Expanded(
              child: Container(

                width: _width-8,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: FutureBuilder(
                        future: futureListOfOrders,
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
                                  color: greenColor,
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
                                          Text("You're offline", style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.normal, fontSize: 16.0, color:  Color(0xff707070))),
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
                                                child: new Text("Try Again", style: TextStyle(color:greenColor,fontFamily:"NunitoSans", fontWeight: FontWeight.normal, fontSize: 13),),
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
                              var data = snapshot.data as List<OrderDetails>;
                             /* getMinMaxPrice(data);
                              data = applyBreedFilter(data);
                              data = applyGenderFilter(data);
                              data = applyPriceRangeFilter(data);
                              applySorting(data);*/


                              return new ListView.builder(
                                reverse: false,
                                scrollDirection: Axis.vertical,
                                itemCount: data.length,
                                itemBuilder:
                                    (BuildContext context, int index) {

                                      return Column(
                                        children: <Widget>[
                                          InkWell(
                                            onTap:(){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsPage(data[index])));
                                            },
                                            child: Card(
                                              //color: Color(0xffFFF8E1), // FFF8E1 amber , F1F8E9 green, FBE9E7 orange
                                                    elevation:1,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      new BorderRadius.only(
                                                        bottomLeft: Radius.circular(12.0),
                                                        topRight: Radius.circular(0.0),
                                                        topLeft: Radius.circular(0.0),
                                                        bottomRight: Radius.circular(12.0),
                                                      ),
                                                    ),
                                                    child: Container(
                                                      width: _width  ,
                                                      child: Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.center,

                                                              children: <Widget>[
                                                                Container(
                                                                      decoration: BoxDecoration(
                                                                      color: Colors.transparent,

                                                                      border: Border(top: BorderSide(color: Colors.white,width: 0,))
                                                                      //color: Colors.green,
                                                                      ),
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Divider(color: Colors.transparent,),
                                                                      Container(
                                                                        alignment: Alignment.centerLeft,
                                                                        width: _width ,

                                                                          decoration: BoxDecoration(
                                                                            color: Colors.transparent,
                                                                            borderRadius:
                                                                            BorderRadius.all(Radius.circular(12)),
                                                                            border: Border.all(color: Colors.transparent, width: 2)
                                                                            //color: Colors.green,
                                                                          ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: <Widget>[
                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  Row(
                                                                                    children: <Widget>[
                                                                                      Text("Order Id",style:TextStyle(fontFamily:'NunitoSans',fontSize:13,color:Color(0xff707070),fontWeight:FontWeight.bold)),
                                                                                      Text(" #"+data[index].orderId,style:TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey,fontWeight:FontWeight.bold)),
                                                                                    ],
                                                                                  ),

                                                                                  Text("Total Items: "+data[index].items.length.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                                                                ],
                                                                              ),
                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                children: <Widget>[
                                                                                  Text("Received on",style: TextStyle(fontFamily:'NunitoSans',fontSize:13,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                                                                  Text(data[index].orderDateString,style: TextStyle(fontFamily:'NunitoSans',fontSize:11,color:Colors.grey, fontWeight:FontWeight.bold)),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Divider(),
                                                                      IntrinsicHeight(
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.max,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            Expanded(
                                                                              child: Column(
                                                                                children: <Widget>[
                                                                                  for (int i=0; i<data[index].items.length;i++)
                                                                                    Row(
                                                                                      mainAxisAlignment:
                                                                                      MainAxisAlignment.start,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: <Widget>[
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.fromLTRB(8,0,0,8),
                                                                                          child: Container(
                                                                                              height: _height>_width? _height/6 : _width/4,
                                                                                              width:  _height>_width? _width/3.5 : _height/2,
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
                                                                                                  data[index].items[i].image,
                                                                                                  fit: BoxFit.cover,
                                                                                                  placeholder:
                                                                                                      (context, url) =>
                                                                                                      SpinKitCircle(
                                                                                                        color: greenColor,
                                                                                                        size: 30.0,
                                                                                                      ),
                                                                                                  errorWidget: (context,
                                                                                                      url, error) =>
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
                                                                                        data[index].items[i].name,
                                                                                        style: TextStyle(
                                                                                            fontFamily:
                                                                                            'NunitoSans',
                                                                                            fontSize:
                                                                                            13,
                                                                                            color:
                                                                                            Color(0xff707070),
                                                                                            fontWeight:
                                                                                            FontWeight
                                                                                                .bold)),
                                                                                  ),

                                                                                ],
                                                                              ),
                                                                              Row(
                                                                                children: <Widget>[
                                                                                  Text(
                                                                                      "Price: ",
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
                                                                                  Text(
                                                                                      "\$"+double.parse(data[index].items[i].cost.toString()).toString(),
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
                                                                                      "Quantity: " + data[index].items[i].quantity,
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



                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                      child: Container(
                                                                        width: 54,
                                                                            alignment: Alignment.center,
                                                                            child:  Padding(
                                                                              padding: const EdgeInsets.fromLTRB(0,0,8,0),
                                                                              child: Container(width:42,
                                                                                  child: Icon(Icons.navigate_next, color:greenColor, size: 24,),
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  border: Border.all(color: greenColor, width: 2),
                                                                                  borderRadius:BorderRadius.all(Radius.circular(16)),
                                                                                  boxShadow: [
                                                                                    BoxShadow(
                                                                                      color: Colors.grey,
                                                                                      blurRadius: 2, // soften the shadow
                                                                                      offset: Offset(
                                                                                        1, // Move to right 10  horizontally
                                                                                        1.0, // Move to bottom 10 Vertically
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),

                                                                              ),
                                                                            )
                                                                      )
                                                                  ),
                                                                ],
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(),
                                                      Container(
                                                        alignment: Alignment.centerLeft,
                                                        width: _width ,

                                                        decoration: BoxDecoration(
                                                            color: Colors.transparent,
                                                            borderRadius:
                                                            BorderRadius.all(Radius.circular(12)),
                                                            border: Border.all(color: Colors.transparent, width: 2)
                                                          //color: Colors.green,
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: <Widget>[
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Text("Total Earned: ",style: TextStyle(fontFamily:'NunitoSans',fontSize:11,color:Colors.grey, fontWeight:FontWeight.bold)),
                                                                  Text("\$ "+data[index].vendorEarning.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:13,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: <Widget>[
                                                                  Container(
                                                                      alignment: Alignment.center,
                                                                      width:  _height>_width? _width/3.5 : _height/2,
                                                                      padding: EdgeInsets.fromLTRB(0,6,0,6),
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(color: Colors.grey, width: 1.5),
                                                                        borderRadius:BorderRadius.all(Radius.circular(24)),
                                                                      ),

                                                                      child:Text(data[index].orderStatus,style: TextStyle(fontFamily:'NunitoSans',fontSize:13,color:Color(0xff707070), fontWeight:FontWeight.bold))
                                                                  )
                                                                ],
                                                              ),

                                                            ],
                                                          ),
                                                        ),
                                                      ),


                                                      Divider(color:Colors.transparent)
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                                          ),
                                          SizedBox(height: 8,)
                                        ],
                                      );
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
            ),
            Container(width: _width, height: 2, color:Color(0xffF3F3F3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: (){
                    if(false){
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
                          Icon(Icons.sort, size: 18,color:greenColor),
                          SizedBox(width: 12,),
                          Text(
                            "Sort",
                            style: new TextStyle(
                                fontFamily: 'NunitoSans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: greenColor),
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
                    if(false){
                      if(filter == null){
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>filter = Filter(null, null, minPrice, maxPrice)));;
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
                          Image.asset("assets/images/ic_filter.png", color: greenColor, width: 18,),
                          SizedBox(width: 12,),
                          Text(
                            "Filter",
                            style: new TextStyle(
                                fontFamily: 'NunitoSans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: greenColor),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Future checkConnectivityAndRefresh(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>Orders()));
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

      title: Container(alignment:Alignment.topLeft,child: Text('SORT BY', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.normal, fontSize: 12), textAlign: TextAlign.left,)),
      actions: <Widget>[
        CupertinoActionSheetAction(

          child: Padding(
            padding: const EdgeInsets.fromLTRB(30,0,0,0),
            child: Container(alignment:Alignment.topLeft,child: Text('Price - high to low', style:style.copyWith(fontWeight: isSortPriceHighToLow ? FontWeight.normal:FontWeight.normal),textAlign: TextAlign.left, )),
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
            child: Container(alignment:Alignment.topLeft,child: Text('Price - low to high', style:style.copyWith(fontWeight: isSortPriceLowToHigh ? FontWeight.normal:FontWeight.normal),textAlign: TextAlign.left)),
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
            child: Container(alignment:Alignment.topLeft,child: Text('Age - high to low', style:style.copyWith(fontWeight: isSortAgeHighToLow ? FontWeight.normal:FontWeight.normal),textAlign: TextAlign.left)),
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
            child: Container(alignment:Alignment.topLeft,child: Text('Age - low to high', style:style.copyWith(fontWeight: isSortAgeLowToHigh ? FontWeight.normal:FontWeight.normal),textAlign: TextAlign.left)),
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


