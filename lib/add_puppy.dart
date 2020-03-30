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

class AddPuppy extends StatefulWidget {
  AddPuppyState addPuppyState;
  @override
  AddPuppyState createState() {
    return addPuppyState = new AddPuppyState();
  }
}

class AddPuppyState extends State<AddPuppy> {

  String _chooseBreed = 'Choose';
  bool _isSelectedOnce = false;

  isSelectedOnce(bool value) {
    _isSelectedOnce = value;
  }

  BuildContext context;
  final globalKey = GlobalKey<ScaffoldState>();

  TextEditingController reason = new TextEditingController();

  TextEditingController searchTextController = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;


    TextStyle style = TextStyle(
        fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff707070));
    return Scaffold(
        key: globalKey,
        backgroundColor: Colors.transparent,
        appBar: new AppBar(

          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Color(0xff7FA432)),
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
                      color: Color(0xff7FA432)),
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
              height: _height -48,
              child: Column(
                children: <Widget>[
                  new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: _height/2.75,
                            width: _width,
                            child: ClipRRect(child: Image.asset("assets/images/bg_add_puppy.jpg", fit: BoxFit.fill,),  borderRadius: BorderRadius.only(bottomRight: Radius.circular(60.0), bottomLeft: Radius.circular(60.0))),
                          ),
                          SizedBox(height: 70),

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
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(30.0)),
                                  color: Color(0xffFEF8F5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[

                                    Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          35, 0, 0, 0),
                                      child: Text(
                                        "${_chooseBreed}",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff707070)),
                                      ),
                                    ), 
                                    Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            00, 0, 20, 0),
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: _isSelectedOnce?Icon(Icons.check, color: Colors.green):Icon(Icons.format_list_bulleted, color: Color(0xff707070)),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: _height/2.75 - 30,

              child:  Center(
                child: Container(
                  width: _width - 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(30.0)),
                    color: Colors.white,

                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: <Widget>[

                      Text(
                        "Choose breed",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff7FA432)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        )));
  }

  chooseBreed(String value) {
   setState(() {
     _chooseBreed = value;
   });
  }



}
