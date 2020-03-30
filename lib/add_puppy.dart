import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'breeds.dart';
import 'customdialog.dart';
final greenColor = Color(0xff7FA432);//Color(0xff4C8BF5);
class AddPuppy extends StatefulWidget {
  AddPuppyState addPuppyState;
  @override
  AddPuppyState createState() {
    return addPuppyState = new AddPuppyState();
  }
}

class AddPuppyState extends State<AddPuppy> {
  DateTime dateOfBirth = DateTime.now();
  String dateOfBirthString = 'Click here to choose ...';
  String _chooseBreed = 'Choose';
  bool _isSelectedOnce = false;

  isSelectedOnce(bool value) {
    _isSelectedOnce = value;
  }

  BuildContext context;
  final globalKey = GlobalKey<ScaffoldState>();

  TextEditingController puppyDescriptionText = new TextEditingController();
  TextEditingController puppyNameText = new TextEditingController();
  TextEditingController puppyColorText = new TextEditingController();
  TextEditingController puppyWeightText = new TextEditingController();
  TextEditingController puppyDadWeightText = new TextEditingController();
  TextEditingController puppyMomWeightText = new TextEditingController();
  TextEditingController askingPriceText = new TextEditingController();
  TextEditingController shippingCostText = new TextEditingController();
  TextEditingController vetNameText = new TextEditingController();
  TextEditingController vetAddressText = new TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final borderRadius = 12.0;
    const leftPadding = 12.0;


    final hintColor = Color(0xffA9A9A9);
   

    TextStyle style = TextStyle(
        fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff707070));
    TextStyle hintStyle = TextStyle(
        fontFamily: 'NunitoSans', fontSize: 14.0, color: hintColor);
    TextStyle labelStyle = TextStyle(
        fontFamily: 'NunitoSans', color: greenColor);
    return Scaffold(
        key: globalKey,
        backgroundColor: Colors.transparent,
        appBar: new AppBar(

          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: greenColor),
            onPressed: () =>Navigator.of(context).maybePop(),
          ),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                new Text(
                  "Add Puppy",
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
        body: SingleChildScrollView(
            child: Stack(
          overflow: Overflow.visible,
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
              color: Colors.white,

              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Center(
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX:2.0,sigmaY:2.0),
                                  child: ChooseBreedDialog(widget.addPuppyState),
                                ),
                              );
                            },
                            child: Container(
                              width: _width - 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(0xffF3F8FF),
                                  borderRadius:  new BorderRadius.circular(borderRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 3.0, // soften the shadow
                                    offset: Offset(
                                      1.0, // Move to right 10  horizontally
                                      1.0, // Move to bottom 10 Vertically
                                    ),
                                  )
                                ],
                              ),


                              child: InputDecorator(
                                decoration: new InputDecoration(
                                    labelText: 'Breed',
                                    labelStyle: labelStyle,
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[

                                    Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          leftPadding, 0, 0, 0),
                                      child: Text(
                                        "${_chooseBreed}",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: hintColor),
                                      ),
                                    ),
                                    Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            00, 0, 20, 0),
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: _isSelectedOnce?Icon(Icons.check, color: Colors.green):Icon(Icons.format_list_bulleted, color: hintColor),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            width: _width - 60,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffFEF8F5),
                                borderRadius:  new BorderRadius.circular(borderRadius)
                            ),


                            child: InputDecorator(
                              decoration: new InputDecoration(
                                labelText: 'Puppy Name',
                                labelStyle: labelStyle,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(
                                    leftPadding, 0, 0, 0),
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  controller: puppyNameText,
                                  style: style,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: InkWell(
                            onTap: () {
                              _selectDateOfBirth(context);
                            },
                            child: Container(
                              width: _width - 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xffF3F8FF),
                                  borderRadius:  new BorderRadius.circular(borderRadius),
                                boxShadow: [
                                BoxShadow(
                                color: Colors.grey,
                                blurRadius: 3.0, // soften the shadow
                                offset: Offset(
                                  1.0, // Move to right 10  horizontally
                                  1.0, // Move to bottom 10 Vertically
                                ),
                              )
                              ],
                              ),


                              child: InputDecorator(
                                decoration: new InputDecoration(
                                  labelText: 'Date of Birth',
                                  labelStyle: labelStyle,
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[

                                    Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          leftPadding, 0, 0, 0),
                                      child: Text(
                                        "${dateOfBirthString}",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: hintColor),
                                      ),
                                    ),
                                    Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            00, 0, 20, 0),
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: Icon(Icons.calendar_today, color: hintColor),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0 ,16,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: (_width - 84)/ 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffFEF8F5),
                                      borderRadius:  new BorderRadius.circular(borderRadius)
                                  ),


                                  child: InputDecorator(
                                    decoration: new InputDecoration(
                                      labelText: 'Color',
                                      labelStyle: labelStyle,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          leftPadding, 0, 0, 0),
                                      child: TextField(
                                        textAlign: TextAlign.start,
                                        controller: puppyColorText,
                                        style: style,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: (_width - 84)/ 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffFEF8F5),
                                      borderRadius:  new BorderRadius.circular(borderRadius)
                                  ),


                                  child: InputDecorator(
                                    decoration: new InputDecoration(
                                      labelText: 'Weight',
                                      labelStyle: labelStyle,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          leftPadding, 0, 0, 0),
                                      child: TextField(
                                        textAlign: TextAlign.start,
                                        controller: puppyWeightText,
                                        style: style,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            width: _width - 60,
                            height: 80,
                            decoration: BoxDecoration(
                                color: Color(0xffFEF8F5),
                                borderRadius:  new BorderRadius.circular(borderRadius)
                            ),


                            child: InputDecorator(
                              decoration: new InputDecoration(
                                labelText: 'Description',
                                labelStyle: labelStyle,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(
                                    leftPadding, 0, 0, 0),
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  controller: puppyDescriptionText,
                                  style: style,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0 ,16,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: (_width - 84)/ 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffFEF8F5),
                                      borderRadius:  new BorderRadius.circular(borderRadius)
                                  ),


                                  child: InputDecorator(
                                    decoration: new InputDecoration(
                                      labelText: "Dad's Weight",
                                      labelStyle: labelStyle,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          leftPadding, 0, 0, 0),
                                      child: TextField(
                                        textAlign: TextAlign.start,
                                        controller: puppyDadWeightText,
                                        style: style,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: (_width - 84)/ 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffFEF8F5),
                                      borderRadius:  new BorderRadius.circular(borderRadius)
                                  ),


                                  child: InputDecorator(
                                    decoration: new InputDecoration(
                                      labelText: "Mom's Weight",
                                      labelStyle: labelStyle,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          leftPadding, 0, 0, 0),
                                      child: TextField(
                                        textAlign: TextAlign.start,
                                        controller: puppyMomWeightText,
                                        style: style,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            width: _width - 60,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffFEF8F5),
                                borderRadius:  new BorderRadius.circular(borderRadius)
                            ),


                            child: InputDecorator(
                              decoration: new InputDecoration(
                                labelText: 'Asking Price',
                                labelStyle: labelStyle,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(
                                    leftPadding, 0, 0, 0),
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  controller: askingPriceText,
                                  style: style,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            width: _width - 60,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffFEF8F5),
                                borderRadius:  new BorderRadius.circular(borderRadius)
                            ),


                            child: InputDecorator(
                              decoration: new InputDecoration(
                                labelText: 'Shipping Cost',
                                labelStyle: labelStyle,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(
                                    leftPadding, 0, 0, 0),
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  controller: shippingCostText,
                                  style: style,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            width: _width - 60,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffFEF8F5),
                                borderRadius:  new BorderRadius.circular(borderRadius)
                            ),


                            child: InputDecorator(
                              decoration: new InputDecoration(
                                labelText: 'Vet Name',
                                labelStyle: labelStyle,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(
                                    leftPadding, 0, 0, 0),
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  controller: vetNameText,
                                  style: style,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            width: _width - 60,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffFEF8F5),
                                borderRadius:  new BorderRadius.circular(borderRadius)
                            ),


                            child: InputDecorator(
                              decoration: new InputDecoration(
                                labelText: 'Vet Address',
                                labelStyle: labelStyle,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(
                                    leftPadding, 0, 0, 0),
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  controller: vetAddressText,
                                  style: style,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        )));
  }

  Future<Null> _selectDateOfBirth(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: dateOfBirth,
        firstDate: DateTime(dateOfBirth.year),
        lastDate: new DateTime.now().add(new Duration(days: 365)),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: Theme.of(context).copyWith(
              primaryColor: Colors.amber,//Head background
              accentColor: Colors.amber,//color you want at header
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch(accentColor: Colors.amber, primarySwatch: Colors.amber),
              ),
            ),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        dateOfBirth = picked;
        dateOfBirthString = new DateFormat("MMM dd, yyyy").format(picked);
      });
  }

  chooseBreed(String value) {
   setState(() {
     _chooseBreed = value;
   });
  }



}
