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
  final _paypalFormKey = GlobalKey<FormState>();
  final _zelleFormKey = GlobalKey<FormState>();
  final _bankAccountFormKey = GlobalKey<FormState>();
  Future<PaymentMode> paymentOption;
  bool _isLoading = false;
  RefreshController _refreshControllerOnErrorReload =
      RefreshController(initialRefresh: false);

  final obpBlueColor = Color(0XFF3DB6C6);

  TextStyle labelStyle = TextStyle(fontFamily: 'Lato',  fontSize: 12, color: Color(0xff707070));

  final borderRadius = 12.0;
  PaymentMode updatedPaymentMode;

  PaymentMode originalData;

  FocusNode paypalEmailFocus = new FocusNode();
  FocusNode zelleEmailFocus = new FocusNode();

  FocusNode accountTypeFocus = new FocusNode();
  FocusNode bankAccountNumFocus = new FocusNode();
  FocusNode bankNameFocus = new FocusNode();
  FocusNode abaRoutingNumFocus = new FocusNode();
  FocusNode bankAddressFocus = new FocusNode();
  FocusNode destinationCurrencyFocus = new FocusNode();
  FocusNode ibanNumFocus = new FocusNode();
  FocusNode accountHolderNameFocus = new FocusNode();



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
        : WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: new AppBar(
                //iconTheme: new IconThemeData(color: Color(0xff262B31)),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      new Image.asset("assets/images/onebark_logo_foreground.png", height: 70,),
                    ]),
                iconTheme: new IconThemeData(color: Colors.white),
                centerTitle: true,
                elevation: 0.0,
                backgroundColor: obpBlueColor,
              ),
              drawer: MainNavigationDrawer(),
              body: SingleChildScrollView(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new SizedBox(
                      height: 16,
                    ),
                    new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [

                          Center(
                            child: new Text(
                              "Payment Options",
                              style: new TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: customColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8,),
                          Center(
                            child: new Text(
                              "Choose One",
                              style: new TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff464646)),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ]),
                    new SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: _width,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          FutureBuilder(
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
                                  originalData = data;
                                  if(updatedPaymentMode==null)
                                      updatedPaymentMode = data.deepCopy();
                                  return Column(

                                    children: <Widget>[
                                      Card(
                                        elevation:3.0,
                                        child: Column(
                                          children: <Widget>[

                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  updatedPaymentMode.isPayPal = true;
                                                });
                                              },
                                              child: Container(
                                                width:_width,
                                                decoration: updatedPaymentMode.isPayPal?BoxDecoration(
                                                  border: Border(top: BorderSide(color: obpBlueColor,width: 2,),
                                                    bottom: BorderSide(color: obpBlueColor,width: 2,),
                                                  ),
                                                  color: Color(0xffFFFD19)

                                                ):BoxDecoration(),
                                                child: Row(
                                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,

                                                  children: <Widget>[
                                                    Container(
                                                      alignment: Alignment.centerLeft,
                                                      height: 54,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Image.asset(
                                                              "assets/images/ic_paypal.png",
                                                              height: 24,
                                                            ),
                                                            SizedBox(width:8),
                                                            Text(
                                                              "Paypal",
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
                                                    ),
                                                    updatedPaymentMode.isPayPal?Padding(
                                                      padding: const EdgeInsets.fromLTRB(0,0,16,0),
                                                      child: Container(child: Icon(Icons.check, color: obpBlueColor)),
                                                    ):Container()
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(height: 1, color: Color(0xffF6F6F6)),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  updatedPaymentMode.isZelle = true;
                                                });
                                              },
                                              child: Container(
                                                width:_width,
                                                decoration: updatedPaymentMode.isZelle?BoxDecoration(
                                                  border: Border(top: BorderSide(color: obpBlueColor,width: 2,),
                                                    bottom: BorderSide(color: obpBlueColor,width: 2,),
                                                  ),
                                                  color: Color(0xffFFFD19)

                                                ):BoxDecoration(),
                                                child: Row(
                                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,

                                                  children: <Widget>[
                                                    Container(
                                                      alignment: Alignment.centerLeft,
                                                      height: 54,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Image.asset(
                                                              "assets/images/ic_zelle.png",
                                                              height: 24,
                                                            ),
                                                            SizedBox(width:8),
                                                            Text(
                                                              "Zelle",
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
                                                    ),
                                                    updatedPaymentMode.isZelle?Padding(
                                                      padding: const EdgeInsets.fromLTRB(0,0,16,0),
                                                      child: Container(child: Icon(Icons.check, color: obpBlueColor)),
                                                    ):Container()
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(height: 1, color: Color(0xffF6F6F6)),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  updatedPaymentMode.isDirectBank = true;
                                                });
                                              },
                                              child: Container(
                                                width:_width,
                                                decoration: updatedPaymentMode.isDirectBank?BoxDecoration(
                                                border: Border(top: BorderSide(color: obpBlueColor,width: 2,),
                                                bottom: BorderSide(color: obpBlueColor,width: 2,),
                                                ),
                                                color: Color(0xffFFFD19)

                                                ):BoxDecoration(),
                                                child: Row(
                                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,

                                                  children: <Widget>[
                                                    Container(
                                                        alignment: Alignment.centerLeft,
                                                        height: 54,
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
                                                    ),
                                                    updatedPaymentMode.isDirectBank?Padding(
                                                      padding: const EdgeInsets.fromLTRB(0,0,16,0),
                                                      child: Container(child: Icon(Icons.check, color: obpBlueColor)),
                                                    ):Container()
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(height: 1, color: Color(0xffF6F6F6)),

                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Container(
                                            width: _width,
                                            decoration: BoxDecoration(
                                                color: Color(0xffffffff),
                                                borderRadius:  new BorderRadius.circular(borderRadius)
                                            ),

                                            child: updatedPaymentMode.isPayPal
                                                ? Form(
                                              key:_paypalFormKey,
                                              child: TextFormField(
                                                textAlign: TextAlign.start,
                                                initialValue: data.isPayPal?data.paypal.paypalEmail:"",
                                                onChanged: (String value) {
                                                  updatedPaymentMode.paypal.paypalEmail = value;
                                                },
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    paypalEmailFocus.requestFocus();
                                                    return 'Email cannot be empty';
                                                  }
                                                  else if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                      .hasMatch(value)){
                                                    paypalEmailFocus.requestFocus();
                                                    return 'Enter valid email id';
                                                  }
                                                  return null;
                                                },
                                                style: style,
                                                decoration: InputDecoration(
                                                    contentPadding: EdgeInsets.all(20),
                                                    labelText: 'Paypal Email',
                                                    labelStyle: labelStyle,
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1.0),
                                                      borderRadius: BorderRadius.circular(borderRadius),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide( width: 1.0),
                                                      borderRadius: BorderRadius.circular(borderRadius),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1.0),
                                                      borderRadius: BorderRadius.circular(borderRadius),
                                                    )
                                                ),
                                              ),
                                            )
                                                : updatedPaymentMode.isZelle
                                                ? Form(
                                              key:_zelleFormKey,
                                              child: TextFormField(
                                                textAlign: TextAlign.start,
                                                initialValue: data.isZelle?data.zelle.zelleEmail:"",
                                                onChanged: (String value) {
                                                  updatedPaymentMode.zelle.zelleEmail = value;
                                                },
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    zelleEmailFocus.requestFocus();
                                                    return 'Email cannot be empty';
                                                  }
                                                  else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                      .hasMatch(value)){
                                                    zelleEmailFocus.requestFocus();
                                                    return 'Enter valid email id';
                                                  }
                                                  return null;
                                                },
                                                style: style,
                                                decoration: InputDecoration(
                                                    contentPadding: EdgeInsets.all(20),
                                                    labelText: 'Zelle Email',
                                                    labelStyle: labelStyle,
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1.0),
                                                      borderRadius: BorderRadius.circular(borderRadius),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide( width: 1.0),
                                                      borderRadius: BorderRadius.circular(borderRadius),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1.0),
                                                      borderRadius: BorderRadius.circular(borderRadius),
                                                    )
                                                ),
                                              ),
                                            )
                                                : Form(
                                              key:_bankAccountFormKey,
                                              child: Column(
                                                children: <Widget>[
                                                  TextFormField(
                                                    textAlign: TextAlign.start,
                                                    initialValue: data.isDirectBank?data.bankAccount.bankName:"",
                                                    onChanged: (String value) {
                                                      updatedPaymentMode.bankAccount.bankName = value;
                                                    },
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        bankNameFocus.requestFocus();
                                                        return 'Cannot be empty';
                                                      }
                                                      return null;
                                                    },
                                                    style: style,
                                                    decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.all(20),
                                                        labelText: 'Bank Name',
                                                        labelStyle: labelStyle,
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide( width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        )
                                                    ),
                                                  ),
                                                  SizedBox(height:8),
                                                  TextFormField(
                                                    textAlign: TextAlign.start,
                                                    initialValue: data.isDirectBank?data.bankAccount.abaRoutingNum:"",
                                                    onChanged: (String value) {
                                                      updatedPaymentMode.bankAccount.abaRoutingNum = value;
                                                    },
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        abaRoutingNumFocus.requestFocus();
                                                        return 'Cannot be empty';
                                                      }
                                                      return null;
                                                    },
                                                    style: style,
                                                    decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.all(20),
                                                        labelText: 'ABA Routing Number',
                                                        labelStyle: labelStyle,
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide( width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        )
                                                    ),
                                                  ),

                                                  SizedBox(height:8),
                                                  TextFormField(
                                                    textAlign: TextAlign.start,
                                                    initialValue: data.isDirectBank?data.bankAccount.bankAddress:"",
                                                    onChanged: (String value) {
                                                      updatedPaymentMode.bankAccount.bankAddress = value;
                                                    },

                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        bankAddressFocus.requestFocus();
                                                        return 'Cannot be empty';
                                                      }
                                                      return null;
                                                    },
                                                    style: style,
                                                    decoration: InputDecoration(

                                                        contentPadding: EdgeInsets.all(20),
                                                        labelText: 'Bank Address',
                                                        labelStyle: labelStyle,
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide( width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        )
                                                    ),
                                                  ),

                                                  SizedBox(height:8),
                                                  TextFormField(
                                                    textAlign: TextAlign.start,
                                                    initialValue: data.isDirectBank?data.bankAccount.accountHolderName:"",
                                                    onChanged: (String value) {
                                                      updatedPaymentMode.bankAccount.accountHolderName = value;
                                                    },
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        accountHolderNameFocus.requestFocus();
                                                        return 'Cannot be empty';
                                                      }
                                                      return null;
                                                    },
                                                    style: style,
                                                    decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.all(20),
                                                        labelText: 'Account Holder Name',
                                                        labelStyle: labelStyle,
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide( width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        )
                                                    ),
                                                  ),

                                                  SizedBox(height:8),
                                                  TextFormField(
                                                    textAlign: TextAlign.start,
                                                    initialValue: data.isDirectBank?data.bankAccount.bankAccountNum:"",
                                                    onChanged: (String value) {
                                                      updatedPaymentMode.bankAccount.bankAccountNum = value;
                                                    },
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        bankAccountNumFocus.requestFocus();
                                                        return 'Cannot be empty';
                                                      }
                                                      return null;
                                                    },
                                                    style: style,
                                                    decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.all(20),
                                                        labelText: 'Account Number',
                                                        labelStyle: labelStyle,
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide( width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1.0),
                                                          borderRadius: BorderRadius.circular(borderRadius),
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ),
                                        ),
                                      ),
                                      SizedBox(height:8),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 54,
                                            width:  _width / 2,
                                            child: FlatButton(
                                              child: Text(
                                                'Save',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(fontFamily:"Lato",fontSize: 14, color: Colors.white, fontWeight:FontWeight.bold),
                                              ),
                                              onPressed:  updatedPaymentMode!=null && !updatedPaymentMode.equals(originalData )?() {
                                                if (updatedPaymentMode.isPayPal && _paypalFormKey.currentState.validate()) {
                                                      Toast.show("Yes, Paypal", context);
                                                }
                                                if (updatedPaymentMode.isZelle && _zelleFormKey.currentState.validate()) {
                                                  Toast.show("Yes, Zelle", context);
                                                }
                                                if (updatedPaymentMode.isDirectBank && _bankAccountFormKey.currentState.validate()) {
                                                  Toast.show("Yes, Bank", context);
                                                }
                                              }:null,
                                              disabledColor: Color(0xFFEBEBEB),
                                              color: obpBlueColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: new BorderRadius.only(
                                                    bottomLeft: Radius.circular(40.0),
                                                    topRight: Radius.circular(40.0),
                                                    topLeft: Radius.circular(12.0),
                                                    bottomRight: Radius.circular(40.0),
                                                  ),
                                                  side: BorderSide(
                                                    color: Colors.white,
                                                  )),
                                            ),
                                          ),

                                        ],
                                      ),
                                      SizedBox(height:24),
                                    ],
                                  );

                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        );
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

  Future<bool> _onBackPressed() {
    if(updatedPaymentMode!=null && !updatedPaymentMode.equals(originalData)){
      return  showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Are you sure?'),
            content: Text("\nDiscard the changes & go back?"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('No', style: TextStyle(color:dividerColor),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text('Yes', style: TextStyle(color:dividerColor),),
                onPressed: (){
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ) ??
          false;
    }else{
      Navigator.of(context).pop();
    }

    }
}
