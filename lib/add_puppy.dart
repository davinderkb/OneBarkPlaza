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
  @override
  AddPuppyState createState() {
    return new AddPuppyState();
  }
}

class AddPuppyState extends State<AddPuppy> {

  Future<List<Breed>> futureListOfCategories;
  String searchText = 'Search';
  String chooseBreed = 'Choose';
  BuildContext context;
  final globalKey = GlobalKey<ScaffoldState>();

  TextEditingController reason = new TextEditingController();

  TextEditingController searchTextController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    futureListOfCategories = getAllBreeds();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;


    String _selectedValue = "Choose";
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
                            child: Container(
                              width: _width - 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(30.0)),
                                color: Color(0xffF3F8FF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: TextField(
                                textAlign: TextAlign.start,
                                controller: searchTextController,
                                style: style,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                    icon: Padding(
                                      padding: const EdgeInsets.fromLTRB(35.0,2,0,0),
                                      child: Icon(Icons.search, color: Color(0xff707070)),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(5.0, 18.0, 18.0, 16.0),
                                    hintText: "Search",
                                    labelStyle: TextStyle(color: Color(0xff707070), fontSize: 14),

                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX:2.0,sigmaY:2.0),
                                    child: CustomDialog(),
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
                                  MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            30, 0, 0, 0),
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: Icon(Icons.format_list_bulleted, color: Color(0xff707070)),
                                        )),
                                    Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(
                                          10, 0, 0, 0),
                                      child: Text(
                                        "${chooseBreed}",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff707070)),
                                      ),
                                    ),
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



  Future<List<Breed>> getAllBreeds() async{

    var dio = Dio();
    var allBreedsUrl = 'https://obpdevstage.wpengine.com/wp-json/obp-api/get_categories/';
    FormData formData = new FormData.fromMap({});
    final list = List<Breed>();
    dynamic response = await dio.post(allBreedsUrl, data: formData);
    dynamic responseList = jsonDecode(response.toString());
    for (dynamic item in responseList) {
      list.add(Breed.fromJson(item));
    }
    if (response.toString() == "[]" || response.toString() == "") {
      Toast.show("Category fetch failed", context,
          textColor: Colors.white,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.transparent,
          backgroundRadius: 16);
    }

    return list;
  }
//Create a Model class to hold key-value pair data



}
