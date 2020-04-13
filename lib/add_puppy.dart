import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mime/mime.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:one_bark_plaza/add_puppy_success.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:one_bark_plaza/util/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:image/image.dart' as I;
import 'choose_breed_dialog.dart';
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
  bool _isLoading = false;
  DateTime dateOfBirth = DateTime.now();
  String dateOfBirthString = '';
  String _chooseBreed = '';
  int _selectedBreedId = 0;
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
  String _vetReportPath;
  int fileType = Constants.FILE_TYPE_OTHER;
  ChooseBreedDialog chooseBreedDialog = null;

  bool isFemale = false;

  Image vetReportThumbnail;

  PDFPageImage pageImage;
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
                color: Color(0xffffffff),
                borderRadius:BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: Colors.black12),
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(16.0),
                child:Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: FittedBox(
                    child: AssetThumb(
                        asset: asset,
                        width: thumbnailSize,
                        height: thumbnailSize
                    ),
                    fit: BoxFit.cover,
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
  TextEditingController registryText = new TextEditingController();
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
      print (e);
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


  void loadVetReport() async {
    try {
      String filePath = await FilePicker.getFilePath(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],);
      if (filePath == '') {
        return;
      }
      if(filePath.substring(filePath.lastIndexOf(".") + 1) == "pdf"){
        fileType = Constants.FILE_TYPE_PDF;
        final document = await PDFDocument.openFile(filePath);
        final page = await document.getPage(1);
        pageImage = await page.render(width: page.width, height: page.height);
        await page.close();
      } else if (filePath.substring(filePath.lastIndexOf(".") + 1) == "jpg"
          || filePath.substring(filePath.lastIndexOf(".") + 1) == "jpeg"
          || filePath.substring(filePath.lastIndexOf(".") + 1) == "png" ){
        fileType = Constants.FILE_TYPE_IMAGE;
      } else{
        fileType = Constants.FILE_TYPE_OTHER;
      }

      setState((){
        this._vetReportPath = filePath;
      });
    } on Exception catch (e) {
      print("Error while picking the file: " + e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final borderRadius = 30.0;
    final hintColor = Color(0xffA9A9A9);


    TextStyle style = TextStyle(fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff707070));
    TextStyle hintStyle = TextStyle(
        fontFamily: 'NunitoSans', fontSize: 14.0, color: hintColor);
    TextStyle labelStyle = TextStyle(
      fontFamily: 'NunitoSans', color: greenColor, fontSize: 12,);
    var maleColor = Color(0xff5cbaed);
    var femaleColor = Color(0xfff25fa3);
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
          backgroundColor: Color(0xffffffff),
        ),
        body: _isLoading? Container(
            color: Colors.white,
            width: _width,
            height: _height,
            alignment: Alignment.bottomCenter,
            child: SpinKitRipple(
              borderWidth: 100.0,
              color: greenColor,
              size: 120,
            )):
        SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                color: Color(0xffffffff),

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

                          SizedBox(height: 8,),
                          Container(
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
                                      InkWell(
                                        onTap:loadAssets,
                                        child: Container(
                                            height:120,
                                            width: 115,
                                            decoration: BoxDecoration(
                                                color: Color(0xffffffff),
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(24)),
                                                border: Border.all(color:greenColor, width: 3.0, ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 3.0, // soften the shadow
                                                    offset: Offset(
                                                      1.0, // Move to right 10  horizontally
                                                      1.0, // Move to bottom 10 Vertically
                                                    ),
                                                  )
                                                ]
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(24.0),
                                              child:Padding(
                                                padding: const EdgeInsets.fromLTRB(35,27,27,27),
                                                child: Image.asset("assets/images/ic_dp.png", color: greenColor,),
                                              ),
                                            )),
                                      ),
                                      SizedBox(height:12),
                                      new Text('You can add upto 6 photos',
                                        style: TextStyle(fontFamily:"NunitoSans",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.bold),
                                      ),
                                      new Text('First photo of your selection will be cover photo',
                                        style: TextStyle(fontFamily:"NunitoSans",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.normal),
                                      ),SizedBox(height:12),
                                    ],

                                  ),

                                ):
                                Column(
                                  children: <Widget>[
                                    Container(
                                        height: calculateGridHeight(),
                                        width: _width -60,
                                        child: Container(child: buildGridView())
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0,0,0,0),
                                      child: new RaisedButton.icon(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(30.0),
                                              side: BorderSide(color: greenColor, width: 2.0)
                                          ),
                                          onPressed: loadAssets,
                                          color: Color(0xffffffff),
                                          icon: new Icon(Icons.image, color:greenColor, size:16),
                                          label: new Text("Add / Preview", style: TextStyle(color:greenColor,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),)),
                                    ),
                                  ],
                                ),


                              ],
                            ),
                          ),
                          SizedBox(height: 24,),

                          Center(
                            child: Container(
                              width: _width,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius:  new BorderRadius.circular(borderRadius)
                              ),


                              child: TextField(
                                textAlign: TextAlign.start,
                                controller: puppyNameText,
                                autofocus: false,
                                style: style,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    labelText: 'Puppy Name',
                                    labelStyle: labelStyle,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 3.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    )
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24,),
                          Center(
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
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
                                  color: Color(0xffffffff),
                                  borderRadius:  new BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 1.0, // soften the shadow
                                      offset: Offset(
                                        1.0, // Move to right 10  horizontally
                                        1.0, // Move to bottom 10 Vertically
                                      ),
                                    )
                                  ],
                                ),


                                child: InputDecorator(
                                  decoration: new InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    labelText: 'Breed',
                                    labelStyle: labelStyle,
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: greenColor) ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[

                                      Text(
                                        "${_chooseBreed}",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: "NunitoSans",
                                            fontSize: 14,
                                            color: greenColor),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              00, 0, 20, 0),
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            child: _isBreedSelectedOnce?Icon(Icons.check, color: Colors.green):Icon(Icons.format_list_bulleted, color: greenColor),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 24,),
                          Center(
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                _selectDateOfBirth(context);
                              },
                              child: Container(
                                width: _width,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius:  new BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 1.0, // soften the shadow
                                      offset: Offset(
                                        1.0, // Move to right 10  horizontally
                                        1.0, // Move to bottom 10 Vertically
                                      ),
                                    )
                                  ],
                                ),


                                child: InputDecorator(

                                  decoration: new InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    labelText: 'Date of Birth',
                                    labelStyle: labelStyle,
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: greenColor)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[

                                      Text(
                                        "${dateOfBirthString}",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: "NunitoSans",
                                            fontSize: 14,
                                            color: greenColor),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              00, 0, 20, 0),
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            child: Icon(Icons.calendar_today, color: greenColor),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24,),
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
                                        color: Color(0xffffffff),
                                        borderRadius:  new BorderRadius.circular(30.0)
                                    ),


                                    child: RaisedButton.icon(

                                        shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(30.0),


                                        ),

                                        onPressed: isFemale?toggleState:null,
                                        color:Color(0xffEBEBE4),
                                        disabledColor: maleColor,
                                        disabledElevation: 3.0,
                                        elevation: 0,
                                        icon: !isFemale? Icon(Icons.check_box, color: Colors.white, size:14): Icon(null, size:0),
                                        label: new Text("Male", style: TextStyle(color:Colors.white,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),)),
                                  ),
                                  Container(
                                    width: (_width - 44)/ 2,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                        borderRadius:  new BorderRadius.circular(30.0)

                                    ),


                                    child: RaisedButton.icon(

                                        shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(30.0),
                                        ),
                                        onPressed: !isFemale?toggleState:null,
                                        color:Color(0xffEBEBE4),
                                        disabledColor: femaleColor,
                                        disabledElevation: 3.0,
                                        elevation: 0,
                                        icon: isFemale? Icon(Icons.check_box, color: Colors.white, size:14): Icon(null, size:0),
                                        label: new Text("Female", style: TextStyle(color:Colors.white,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24,),
                          Center(
                            child: Container(
                              width: _width,
                              height: 80,
                              decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius:  new BorderRadius.circular(borderRadius)
                              ),


                              child: TextField(
                                textAlign: TextAlign.start,
                                controller: puppyDescriptionText,
                                style: style,
                                maxLines: 4,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    labelText: 'Description',
                                    labelStyle: labelStyle,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 3.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    )
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24,),
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
                                        color: Color(0xffffffff),
                                        borderRadius:  new BorderRadius.circular(borderRadius)
                                    ),


                                    child: TextField(
                                      textAlign: TextAlign.start,
                                      controller: puppyColorText,
                                      style: style,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(20),
                                          labelText: 'Color',
                                          labelStyle: labelStyle,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 3.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 2.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 2.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          )
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: (_width - 44)/ 2,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                        borderRadius:  new BorderRadius.circular(borderRadius)
                                    ),

                                    child: TextField(
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.number,
                                      controller: puppyWeightText,
                                      style: style,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(20),
                                          labelText: 'Weight',
                                          labelStyle: labelStyle,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 3.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 2.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 2.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          )
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 24,),
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
                                        color: Color(0xffffffff),
                                        borderRadius:  new BorderRadius.circular(borderRadius)
                                    ),


                                    child: TextField(
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.number,
                                      controller: puppyDadWeightText,
                                      style: style,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(20),
                                          labelText: "Dad's Weight",
                                          labelStyle: labelStyle,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 3.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 2.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 2.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          )
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: (_width - 44)/ 2,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                        borderRadius:  new BorderRadius.circular(borderRadius)
                                    ),


                                    child: TextField(
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.number,
                                      controller: puppyMomWeightText,
                                      style: style,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(20),
                                          labelText: "Mom's Weight",
                                          labelStyle: labelStyle,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 3.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 2.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: greenColor, width: 2.0),
                                            borderRadius: BorderRadius.circular(borderRadius),
                                          )
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24,),
                          Center(
                            child: Container(
                              width: _width,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius:  new BorderRadius.circular(borderRadius)
                              ),


                              child: TextField(
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.number,
                                controller: askingPriceText,
                                style: style,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    labelText: 'Asking Price',
                                    labelStyle: labelStyle,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 3.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    )
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24,),
                          Center(
                            child: Container(
                              width: _width,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius:  new BorderRadius.circular(borderRadius)
                              ),


                              child: TextField(
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.number,
                                controller: shippingCostText,
                                style: style,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    labelText: 'Shipping Cost',
                                    labelStyle: labelStyle,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 3.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    )
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24,),
                          Center(
                            child: Container(
                              width: _width,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius:  new BorderRadius.circular(borderRadius)
                              ),

                              child: TextField(
                                textAlign: TextAlign.start,
                                controller: registryText,
                                style: style,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    labelText: 'Registry',
                                    labelStyle: labelStyle,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 3.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: greenColor, width: 2.0),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    )
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24,),
                          Container(
                            alignment: Alignment.center,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: _width,
                                  child: Column(
                                    children: <Widget>[
                                      InkWell(
                                        onTap:loadVetReport,
                                        child: _vetReportPath!=null
                                            ? fileType==Constants.FILE_TYPE_PDF
                                            ?  Container(
                                            height:120,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                color: Color(0xffffffff),
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(24)),
                                                border: Border.all(color:greenColor, width: 3.0, ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 3.0, // soften the shadow
                                                    offset: Offset(
                                                      1.0, // Move to right 10  horizontally
                                                      1.0, // Move to bottom 10 Vertically
                                                    ),
                                                  )
                                                ]
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(24.0),
                                              child: Image(
                                                image: MemoryImage(pageImage.bytes),
                                              ),
                                            ))//pdf
                                            : fileType == Constants.FILE_TYPE_IMAGE
                                            ? Container(
                                            height:120,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                color: Color(0xffffffff),
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(24)),
                                                border: Border.all(color:greenColor, width: 3.0, ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 3.0, // soften the shadow
                                                    offset: Offset(
                                                      1.0, // Move to right 10  horizontally
                                                      1.0, // Move to bottom 10 Vertically
                                                    ),
                                                  )
                                                ]
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(24.0),
                                              child: Image.file(File(_vetReportPath), fit: BoxFit.cover,),
                                            )) //image
                                            : Container(
                                            height:120,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                color: Color(0xffffffff),
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(24)),
                                                border: Border.all(color:greenColor, width: 3.0, ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 3.0, // soften the shadow
                                                    offset: Offset(
                                                      1.0, // Move to right 10  horizontally
                                                      1.0, // Move to bottom 10 Vertically
                                                    ),
                                                  )
                                                ]
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(24.0),
                                              child: Image.file(File(_vetReportPath), fit: BoxFit.cover,),
                                            ))  //others
                                            : Container(
                                            height:70,
                                            width: _width,
                                            decoration: BoxDecoration(
                                                color: Color(0xffffffff),
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(24)),
                                                border: Border.all(color:greenColor, width: 3.0, ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 3.0, // soften the shadow
                                                    offset: Offset(
                                                      1.0, // Move to right 10  horizontally
                                                      1.0, // Move to bottom 10 Vertically
                                                    ),
                                                  )
                                                ]
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(24.0),
                                              child:Padding(
                                                padding: const EdgeInsets.fromLTRB(35,20,35,20),
                                                child: Image.asset("assets/images/ic_upload.png", color: greenColor,),
                                              ),
                                            )),
                                      ),
                                      SizedBox(height:12),
                                      new Text('Vet Check Report',
                                        style: TextStyle(fontFamily:"NunitoSans",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height:12),
                                    ],

                                  ),

                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 24,),
                          Center(
                            child: Container(
                              width: _width,

                              decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius:  new BorderRadius.circular(borderRadius)
                              ),


                              child: Column(
                                children: <Widget>[
                                  MergeSemantics(
                                    child: ListTile(
                                      dense: true,
                                      title: Text('Champion Bloodline', style: TextStyle(fontSize: 13,  color:  isChampionBloodline?greenColor : Color(0xffA9A9A9)),),
                                      trailing: Transform.scale(
                                        scale: 0.75,
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
                                      dense: true,
                                      title: Text('Family Raised', style: TextStyle(fontSize: 13,  color:  isFamilyRaised?greenColor : Color(0xffA9A9A9)),),
                                      trailing: Transform.scale(
                                        scale: 0.75,
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
                                      dense: true,
                                      title: Text('Kid Friendly', style: TextStyle(fontSize: 13,  color:  isKidFriendly?greenColor : Color(0xffA9A9A9)),),
                                      trailing: Transform.scale(
                                        scale: 0.75,
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
                                      dense: true,
                                      title: Text('Microchipped', style: TextStyle(fontSize: 13,  color:  isMicrochipped?greenColor : Color(0xffA9A9A9)),),
                                      trailing: Transform.scale(
                                        scale: 0.75,
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
                                      dense: true,
                                      title: Text('Socialized', style: TextStyle(fontSize: 13,  color:  isSocialized?greenColor : Color(0xffA9A9A9)),),
                                      trailing: Transform.scale(
                                        scale: 0.75,
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
                          SizedBox(height: 30,),
                          Center(
                            child:  CupertinoButton(
                              color: maleColor,
                              borderRadius: BorderRadius.circular(100),
                              padding: EdgeInsets.fromLTRB(120.0, 24.0, 120.0,24.0),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                onFinishClick(context);
                              },
                              child: Text("Finsih",
                                textAlign: TextAlign.center,
                                style: style.copyWith(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 14),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  void onFinishClick(BuildContext context) {
    initiateAddPuppy(context);
  }
  Future<void> initiateAddPuppy(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId =  prefs.getString(Constants.SHARED_PREF_USER_ID);
    var dio = Dio();
    var addPuppyUrl = 'https://obpdevstage.wpengine.com/wp-json/obp-api/create_puppy';
    FormData formData = new FormData.fromMap({
      "name": Utility.capitalize(puppyNameText.text.trim()),
      "description": Utility.capitalize(puppyDescriptionText.text.trim()),
      "categories": [ { "id" : _selectedBreedId }],
      "user_id": userId,
      "price": askingPriceText.text.trim(),
      "shipping_cost": shippingCostText.text.trim(),
      "date_of_birth": dateOfBirthString,
      "age_in_weeks": calculateAgeInWeeks(),
      "color": Utility.capitalize(puppyColorText.text.trim()),
      "puppy_weight": puppyWeightText.text.trim(),
      "puppy_dad_weight": puppyDadWeightText.text.trim(),
      "puppy_mom_weight": puppyMomWeightText.text.trim(),
      "registry": "AKC"
    });
    try{
      dynamic response = await dio.post(addPuppyUrl, data: formData);
      if (response.toString() != '[]') {
        dynamic responseList = jsonDecode(response.toString());
        if (responseList["success"] == "Puppy successfully created!") {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AddPuppySuccessful(responseList["puppy_id"])));
        } else {
          Toast.show("Add Puppy Failed " +response.toString(), context);
        }
      } else {
        Toast.show("Add Puppy Failed "+response.toString(), context);
      }
      setState(() {
        _isLoading = false;
      });
    }catch(exception){
      Toast.show("Request Failed. "+exception.toString(), context,
      );
      setState(() {
        _isLoading = false;
      });
    }

  }

  double calculateGridHeight() {
    double numRowsReq = images.length==1? 1 :  ((images.length -1)  / imagesInGridRow) +1;
    return thumbnailSize * numRowsReq.toInt() + 16.0;
  }


  Future<Null> _selectDateOfBirth(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: dateOfBirth,
        firstDate: DateTime(dateOfBirth.year - 20),
        lastDate: new DateTime.now(),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.blue,//Head background
              accentColor: Colors.blue,
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch(accentColor: Colors.blue, primarySwatch: Colors.blue),
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

  setSelectedBreedId(int value) {
    _selectedBreedId = value;
  }
  void toggleState() {
    setState(() {
      isFemale = !isFemale ;
    });
  }

  calculateAgeInWeeks() {
    return ((DateTime.now().difference(dateOfBirth).inDays)/7).round();
  }
}