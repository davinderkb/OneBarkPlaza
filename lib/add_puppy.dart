import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_multiple_image_picker/flutter_multiple_image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'breeds.dart';
import 'customdialog.dart';
final greenColor = Color(0xff7FA432);
final blueColor = Color(0xff4C8BF5);
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
  bool _isBreedSelectedOnce = false;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  String _platformMessage = 'No Error';
  List images2;
  int maxImageNo = 10;
  bool selectSingleImage = false;
  int imagesInGridRow = 3;
  int thumbnailSize = 100;
  bool isChampionBloodline = false;
  bool isFamilyRaised = false;
  bool isKidFriendly = false;
  bool isMicrochipped = false;
  bool isSocialized = false;

  ChooseBreedDialog chooseBreedDialog = null;

  bool isFemale = false;
  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: imagesInGridRow,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return  Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
              height:100,
              width: 100,
              decoration: BoxDecoration(
                color: Color(0xffFEF8F5),
                borderRadius:BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: Colors.black12),
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(16.0),
                child:Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AssetThumb(
                    asset: asset,
                    width: thumbnailSize,
                    height: thumbnailSize,
                  ),
                ),
              )),
        );
      }),
    );
  }

  isBreedSelectedOnce(bool value) {
    _isBreedSelectedOnce = value;
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

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: true,

        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#000000",
          actionBarTitle: "One Bark Plaza App",
          allViewTitle: "Select Photos",
          useDetailsView: true,
          selectCircleStrokeColor: "#ffffff",

        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  initMultiPickUp() async {
    setState(() {
      images2 = null;
      _platformMessage = 'No Error';
    });
    List resultList;
    String error;
    try {
      resultList = await FlutterMultipleImagePicker.pickMultiImages(
          maxImageNo, selectSingleImage);
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images2 = resultList;
      if (error == null) _platformMessage = 'No Error Dectected';
    });
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final borderRadius = 12.0;
    const leftPadding = 12.0;
    final hintColor = Color(0xffA9A9A9);

    final finishButton = Material(
      borderRadius: BorderRadius.circular(30.0),

      color: Colors.teal,
      child: MaterialButton(
        minWidth: _width - 60,
        padding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0),
        onPressed: () {
          FocusScope.of(context).unfocus();
        },
        child: Text("Finish",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'NunitoSans',color: Colors.white, fontSize: 14)),
      ),
    );

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
                              chooseBreedDialog != null && chooseBreedDialog.allDuplicateItems.length!=0?
                              showDialog(
                                context: context,
                                child:  BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX:2.0,sigmaY:2.0),
                                  child: chooseBreedDialog,
                                ),
                              )
                              :
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX:2.0,sigmaY:2.0),
                                  child: chooseBreedDialog = ChooseBreedDialog(widget.addPuppyState),
                                ),
                              )
                              ;
                            },
                            child: Container(
                              width: _width,
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
                                          child: _isBreedSelectedOnce?Icon(Icons.check, color: Colors.green):Icon(Icons.format_list_bulleted, color: hintColor),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        new Container(
                          alignment: Alignment.center,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              images.length == 0 ?
                              Container(
                                width: _width,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        height:100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Color(0xffFEF8F5),
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                          //border: Border.all(),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(4.0),
                                          child:Padding(
                                            padding: const EdgeInsets.fromLTRB(16,8,8,8),
                                            child: Image.asset("assets/images/ic_dp.png"),
                                          ),
                                        )),
                                    SizedBox(height:4),
                                    new Text('You can add upto 6 photos',
                                      style: TextStyle(fontFamily:"NunitoSans",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.bold),
                                    ),
                                    new Text('First photo of your selection will be cover photo',
                                      style: TextStyle(fontFamily:"NunitoSans",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.normal),
                                    ),
                                  ],

                                ),

                              ):
                              Container(
                                  height: calculateGridHeight(),
                                  width: _width -60,
                                  child: Expanded(child: Container(child: buildGridView()),)
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,0,0),
                                child: new RaisedButton.icon(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(12.0),
                                        side: BorderSide(color: Colors.white)
                                    ),
                                    onPressed: loadAssets,
                                    color: greenColor,
                                    icon: new Icon(Icons.image, color:Colors.white),
                                    label: new Text("Add Images", style: TextStyle(color:Colors.white,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            width: _width,
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
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0 ,0,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: (_width - 44)/ 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffFEF8F5),
                                      borderRadius:  new BorderRadius.circular(borderRadius)
                                  ),


                                  child: RaisedButton.icon(

                                      shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(12.0),
                                          side: BorderSide(color: Colors.white)
                                      ),
                                      onPressed: isFemale?toggleState:null,
                                      color:Color(0xffEBEBE4),
                                      disabledColor: Colors.amber,
                                      disabledElevation: 3.0,
                                      elevation: 0,
                                      icon: !isFemale? Icon(Icons.check_box, color: Colors.white, size:14): Icon(null, size:0),
                                      label: new Text("Male", style: TextStyle(color:Colors.white,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),)),
                                ),
                                Container(
                                  width: (_width - 44)/ 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffFEF8F5),
                                      borderRadius:  new BorderRadius.circular(borderRadius)
                                  ),


                                  child: RaisedButton.icon(

                                      shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(12.0),
                                          side: BorderSide(color: Colors.white)
                                      ),
                                      onPressed: !isFemale?toggleState:null,
                                      color:Color(0xffEBEBE4),
                                      disabledColor: Colors.amber,
                                      disabledElevation: 3.0,
                                      elevation: 0,
                                      icon: isFemale? Icon(Icons.check_box, color: Colors.white, size:14): Icon(null, size:0),
                                      label: new Text("Female", style: TextStyle(color:Colors.white,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),)),
                                ),
                              ],
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
                              width: _width,
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
                            padding: const EdgeInsets.fromLTRB(0.0, 0 ,0,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: (_width - 44)/ 2,
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
                                  width: (_width - 44)/ 2,
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
                            width: _width,
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
                            padding: const EdgeInsets.fromLTRB(0.0, 0 ,0,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: (_width - 44)/ 2,
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
                                  width: (_width - 44)/ 2,
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
                            width: _width,
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
                            width: _width,
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
                            width: _width,
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
                            width: _width,
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
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            width: _width,

                            decoration: BoxDecoration(
                                color: Color(0xffFEF8F5),
                                borderRadius:  new BorderRadius.circular(borderRadius)
                            ),


                            child: InputDecorator(
                              decoration: new InputDecoration(
                                labelText: 'Puppy Badges',
                                labelStyle: labelStyle,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(borderRadius), borderSide: BorderSide(color: greenColor) ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  MergeSemantics(
                                    child: ListTile(
                                      title: Text('Champion Bloodline', style: TextStyle(fontSize: 14, fontFamily: "Nunito Sans", color:  isChampionBloodline?greenColor : Color(0xffEBEDD9),fontWeight:FontWeight.bold),),
                                      trailing: Transform.scale(
                                        scale: 1,
                                        child: CupertinoSwitch(
                                          value: isChampionBloodline,
                                          onChanged: (bool value) {
                                            setState(() {
                                              isChampionBloodline = value;
                                            }
                                            );
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isChampionBloodline = !isChampionBloodline;
                                        });
                                      },
                                    ),
                                  ),
                                  MergeSemantics(
                                    child: ListTile(
                                      title: Text('Family Raised', style: TextStyle(fontSize: 14, fontFamily: "Nunito Sans", color:  isFamilyRaised?greenColor : Color(0xffEBEDD9),fontWeight:FontWeight.bold),),
                                      trailing: Transform.scale(
                                        scale: 1,
                                        child: CupertinoSwitch(
                                          value: isFamilyRaised,
                                          onChanged: (bool value) {
                                            setState(() {
                                              isFamilyRaised = value;
                                            }
                                            );
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isFamilyRaised = !isFamilyRaised;
                                        });
                                      },
                                    ),
                                  ),
                                  MergeSemantics(
                                    child: ListTile(
                                      title: Text('Kid Friendly', style: TextStyle(fontSize: 14, fontFamily: "Nunito Sans", color:  isKidFriendly?greenColor : Color(0xffEBEDD9),fontWeight:FontWeight.bold),),
                                      trailing: Transform.scale(
                                        scale: 1,
                                        child: CupertinoSwitch(
                                          value: isKidFriendly,
                                          onChanged: (bool value) {
                                            setState(() {
                                              isKidFriendly = value;
                                            }
                                            );
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isKidFriendly = !isKidFriendly;
                                        });
                                      },
                                    ),
                                  ),
                                  MergeSemantics(
                                    child: ListTile(
                                      title: Text('Microchipped', style: TextStyle(fontSize: 14, fontFamily: "Nunito Sans", color:  isMicrochipped?greenColor : Color(0xffEBEDD9),fontWeight:FontWeight.bold),),
                                      trailing: Transform.scale(
                                        scale: 1,
                                        child: CupertinoSwitch(
                                          value: isMicrochipped,
                                          onChanged: (bool value) {
                                            setState(() {
                                              isMicrochipped = value;
                                            }
                                            );
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isMicrochipped = !isMicrochipped;
                                        });
                                      },
                                    ),
                                  ),
                                  MergeSemantics(
                                    child: ListTile(
                                      title: Text('Socialized', style: TextStyle(fontSize: 14, fontFamily: "Nunito Sans", color:  isSocialized?greenColor : Color(0xffEBEDD9),fontWeight:FontWeight.bold),),
                                      trailing: Transform.scale(
                                        scale: 1,
                                        child: CupertinoSwitch(
                                          value: isSocialized,
                                          onChanged: (bool value) {
                                            setState(() {
                                              isSocialized = value;
                                            }
                                            );
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isSocialized = !isSocialized;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Center(child: finishButton)
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        )));
  }

  double calculateGridHeight() {
    double numRowsReq = images.length==1? 1 :  ((images.length -1)  / imagesInGridRow) +1;
    return thumbnailSize * numRowsReq.toInt() + 16.0;
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


  void toggleState() {
    setState(() {
      isFemale = !isFemale ;
    });
  }
}
