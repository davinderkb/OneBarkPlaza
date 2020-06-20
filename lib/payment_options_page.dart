import 'dart:collection';
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
import 'package:one_bark_plaza/payment_options.dart';
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

TextStyle style = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14.0,
    color: Color(0xff707070),
    fontWeight: FontWeight.bold);

class PaymentOptionsPage extends StatefulWidget {
  PaymentOptionsPageState paymentOptionsPageState;
  @override
  PaymentOptionsPageState createState() {
    return paymentOptionsPageState = PaymentOptionsPageState();
  }
}

var getPaymentOptionsUrl =
    'https://onebarkplaza.com/wp-json/obp/v1/payment_options';
Future<PaymentMode> getPaymentMode(BuildContext context) async {
  PaymentMode paymentMode = null;
  var dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString(Constants.SHARED_PREF_USER_ID);
  if (userId != null && userId != '') {
    FormData formData = new FormData.fromMap({
      "user_id": userId,
    });
    PaymentMode paymentMode;
    dynamic response = await dio.post(getPaymentOptionsUrl, data: formData);
    if (response.statusCode == 200) {
      paymentMode = PaymentMode.fromJson(jsonDecode(response.toString()));
    }
    return paymentMode;
  } else {
    Toast.show("Something went wrong, Try again", context,
        backgroundColor: Color(0xff00232F), textColor: Color(0xffFFFd19));
  }
}

class PaymentOptionsPageState extends State<PaymentOptionsPage> {
  Future<PaymentMode> paymentOption;
  bool _isLoading = false;
  RefreshController _refreshControllerOnErrorReload =
      RefreshController(initialRefresh: false);

  final obpBlueColor = Color(0XFF3DB6C6);

  @override
  void initState() {
    super.initState();
    paymentOption = getPaymentMode(context);
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final obpBlueColor = Color(0XFF3DB6C6);

    return _isLoading
        ? Container(
            color: Colors.white,
            width: _width,
            height: _height,
            alignment: Alignment.bottomCenter,
            child: SpinKitRipple(
              borderWidth: 100.0,
              color: obpBlueColor,
              size: 120,
            ))
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: new AppBar(
              //iconTheme: new IconThemeData(color: Color(0xff262B31)),
              iconTheme: new IconThemeData(color: obpBlueColor),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    new Text(
                      "Payment Options",
                      style: new TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: obpBlueColor),
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
                    width: _width,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: FutureBuilder(
                            future: paymentOption,
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
                                      color: obpBlueColor,
                                      size: 50.0,
                                    ),
                                  );
                                  break;
                                case ConnectionState.done:
                                  if (snapshot.hasError) {
                                    // return whatever you'd do for this case, probably an error
                                    return SmartRefresher(
                                        child: Container(
                                          width: _width,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Image.asset(
                                                "assets/images/ic_noInternet.png",
                                                height: 60,
                                                width: 70,
                                                color: Color(0xffebebeb),
                                              ),
                                              SizedBox(height: 24),
                                              Text("You're offline",
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                      color:
                                                          Color(0xff707070))),
                                              SizedBox(height: 12),
                                              Text(
                                                  "Connect to the internet and try again",
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize: 14.0,
                                                      color:
                                                          Color(0xff707070))),
                                              SizedBox(
                                                height: 36,
                                              ),
                                              new RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          new BorderRadius
                                                              .circular(30.0),
                                                      side: BorderSide(
                                                          color: obpBlueColor,
                                                          width: 2.0)),
                                                  onPressed: () async {
                                                    checkConnectivityAndRefresh(
                                                        context);
                                                  },
                                                  color: Colors.white,
                                                  disabledColor: Colors.white,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8.0, 0, 8, 0),
                                                    child: new Text(
                                                      "Try Again",
                                                      style: TextStyle(
                                                          color: obpBlueColor,
                                                          fontFamily: "Lato",
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 13),
                                                    ),
                                                  )),
                                              SizedBox(height: 60),
                                            ],
                                          ),
                                        ),
                                        controller:
                                            _refreshControllerOnErrorReload,
                                        onRefresh: () async {
                                          await checkConnectivityAndRefresh(
                                              context);
                                          _refreshControllerOnErrorReload
                                              .refreshCompleted();
                                        });
                                  }
                                  var data = snapshot.data as PaymentMode;

                                  return Column(

                                    children: <Widget>[
                                      Card(
                                        elevation:3.0,
                                        child: Column(
                                          children: <Widget>[

                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  data.isPayPal = true;
                                                });
                                              },
                                              child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  height: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child:  Row(
                                                      children: <Widget>[
                                                        Image.asset(
                                                          "assets/images/ic_paypal.png",
                                                          height: 24,
                                                        ),
                                                        SizedBox(width:8),
                                                        Text(
                                                          "Paypal",
                                                          style: TextStyle(

                                                              fontFamily: "Lato",
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  decoration: data.isPayPal?BoxDecoration(
                                                      border: Border(top: BorderSide(color: obpBlueColor,width: 2,),
                                                        bottom: BorderSide(color: obpBlueColor,width: 2,),
                                                        ),
                                                    color: Color(0xffFFFD19)
                                                  ):BoxDecoration()
                                              ),
                                            ),

                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  data.isZelle = true;
                                                });
                                              },
                                              child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  height: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child:  Row(
                                                    children: <Widget>[
                                                      Image.asset(
                                                      "assets/images/ic_zelle.png",
                                                      height: 24,
                                                    ),
                                                      SizedBox(width:8),
                                                      Text(
                                                        "Zelle",
                                                        style: TextStyle(

                                                            fontFamily: "Lato",
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                  ),
                                                  decoration: data.isZelle?BoxDecoration(
                                                      border: Border(top: BorderSide(color: obpBlueColor,width: 2,),
                                                        bottom: BorderSide(color: obpBlueColor,width: 2,),
                                                      ),
                                                      color: Color(0xffFFFD19)

                                                  ):BoxDecoration()
                                              ),

                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  data.isDirectBank = true;
                                                });
                                              },
                                              child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  height: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.account_balance, color: Color(0xff00232F),),
                                                        SizedBox(width:8),
                                                        Text(
                                                          "Bank Account",
                                                          style: TextStyle(
                                                              color: Color(0xff00232F),
                                                              fontFamily: "Lato",
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  decoration: data.isDirectBank?BoxDecoration(
                                                      border: Border(top: BorderSide(color: obpBlueColor,width: 2,),
                                                        bottom: BorderSide(color: obpBlueColor,width: 2,),
                                                      ),
                                                      color: Color(0xffFFFD19)

                                                  ):BoxDecoration()
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            alignment: Alignment.center,
                                            //color:Color(0xffFFFD19),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(""),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
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
              ],
            ));
  }

  Future checkConnectivityAndRefresh(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => PaymentOptionsPage()));
    } else {
      Toast.show("Internet is still down.. Keep trying", context,
          backgroundColor: Color(0xff00232F), textColor: Color(0xffFFFd19));
    }
  }
}
