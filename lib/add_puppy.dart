import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:one_bark_plaza/add_puppy_success.dart';
import 'package:one_bark_plaza/main.dart';
import 'package:one_bark_plaza/preview.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:one_bark_plaza/util/utility.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:image/image.dart' as I;
import 'choose_breed_dialog.dart';
final dividerColor =  Color(0xff3db6c6);
final customColor = Color(0XFF3DB6C6);//Color(0xff4C8BF5);
var addPuppyUrl = 'https://onebarkplaza.com/wp-json/obp/v1/create_puppy';

class AddPuppy extends StatefulWidget {
  bool isLittermate = false;
  String littermateBreedName = "";
  int littermateBreedId = 0;
  String littermateDadWeight = "";
  String littermateMomWeight = "";
  State addPuppyState;
  AddPuppy.littermate(String breedName, int breedId, String dadWeight, String momWeight){
    this.isLittermate = true;
    this.littermateBreedId = breedId;
    this.littermateBreedName = breedName;
    this.littermateDadWeight = dadWeight;
    this.littermateMomWeight = momWeight;
  }
  AddPuppy(){
    this.isLittermate = false;
  }
  @override
  State createState() {
    return addPuppyState = isLittermate
        ? new AddPuppyLittermateState()
        : new AddPuppyState();
  }
}

class AddPuppyState extends State<AddPuppy> {
  bool _isLoading = false;
  DateTime dateOfBirth = DateTime.now();
  DateTime dateOfCheckup = DateTime.now();
  String dateOfBirthString = '';
  String _chooseBreed = '';
  int _selectedBreedId = 0;
  bool _isBreedSelectedOnce = false;
  List<Asset> images = List<Asset>();
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
  final _formKey = GlobalKey<FormState>();
  bool isFemale = false;

  String _error = 'No Error Dectected';

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


  FocusNode puppyDescriptionFocus = new FocusNode();
  FocusNode puppyNameFocus = new FocusNode();
  FocusNode puppyColorFocus = new FocusNode();
  FocusNode puppyWeightFocus = new FocusNode();
  FocusNode puppyDadWeightFocus = new FocusNode();
  FocusNode puppyMomWeightFocus = new FocusNode();
  FocusNode askingPriceFocus = new FocusNode();
  FocusNode shippingCostFocus = new FocusNode();
  FocusNode registryFocus = new FocusNode();


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

  /*Future<Map<String, dynamic>> _uploadImage(File image) async {

    final mimeTypeData = lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(addPuppyUrl));
    final file = await http.MultipartFile.fromPath('image', image.path, contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    // Explicitly pass the extension of the image with request body
    // Since image_picker has some bugs due which it mixes up
    // image extension with file name like this filenamejpge
    // Which creates some problem at the server side to manage
    // or verify the file extension
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }
  void _startUploading() async {

    Uri uri = Uri.parse(addPuppyUrl);

// create multipart request
    MultipartRequest request = http.MultipartRequest("POST", uri);

    ByteData byteData = await images[0].getByteData();
    List<int> imageData = byteData.buffer.asUint8List();

    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageData,
      filename: 'onebark_test.jpg',
      contentType: MediaType("image", "jpg"),
    );

// add file to multipart
    request.files.add(multipartFile);
// send
    var response = await request.send();
    print(response);
    // Check if any error occured
    if (response == null || response.toString().contains("error")) {
      Toast.show("Image Upload Failed!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show("Image Uploaded Successfully!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }*/



  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final borderRadius = 30.0;
    final hintColor = Color(0xffA9A9A9);


    TextStyle style = TextStyle(fontFamily: 'Lato', fontSize: 14.0, color: Color(0xff707070));
    TextStyle hintStyle = TextStyle(
        fontFamily: 'Lato', fontSize: 14.0, color: hintColor);
    TextStyle labelStyle = TextStyle(
      fontFamily: 'Lato', color: dividerColor, fontSize: 12,);
    var maleColor = Color(0xff5cbaed);
    var femaleColor = Color(0xfff25fa3);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          key: globalKey,
          backgroundColor: Colors.transparent,
          appBar: new AppBar(

            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: dividerColor),
              onPressed: _onBackPressed
            ),
            title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Text(
                    "Add Puppy",
                    style: new TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dividerColor),
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
                color: dividerColor,
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
                        child: Form(
                          key: _formKey,
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
                                                    border: Border.all(color:dividerColor, width: 3.0, ),
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
                                                    child: Image.asset("assets/images/ic_dp.png", color: dividerColor,),
                                                  ),
                                                )),
                                          ),
                                          SizedBox(height:12),
                                          new Text('You can add upto 6 photos',
                                            style: TextStyle(fontFamily:"Lato",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.bold),
                                          ),
                                          new Text('First photo of your selection will be cover photo',
                                            style: TextStyle(fontFamily:"Lato",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.normal),
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
                                                  side: BorderSide(color: dividerColor, width: 2.0)
                                              ),
                                              onPressed: loadAssets,
                                              color: Color(0xffffffff),
                                              icon: new Icon(Icons.image, color:dividerColor, size:16),
                                              label: new Text("Add / View", style: TextStyle(color:dividerColor,fontFamily:"Lato", fontWeight: FontWeight.bold, fontSize: 13),)),
                                        ),
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                              SizedBox(height: 24,),
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
                                        labelText: 'Breed*',
                                        labelStyle: labelStyle,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: dividerColor) ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[

                                          Text(
                                            "${_chooseBreed}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontFamily: "Lato",
                                                fontSize: 14,
                                                color: dividerColor),
                                          ),
                                          Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  00, 0, 00, 0),
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                child: _isBreedSelectedOnce?Icon(Icons.check, color: Colors.green):Icon(Icons.format_list_bulleted, color: dividerColor),
                                              )),
                                        ],
                                      ),
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


                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    controller: puppyNameText,
                                    focusNode: puppyNameFocus,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        puppyNameFocus.requestFocus();
                                        return 'Enter puppy name';
                                      }
                                      return null;
                                    },
                                    autofocus: false,

                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Puppy Name*',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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
                                        labelText: 'Date of Birth*',
                                        labelStyle: labelStyle,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: dividerColor)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[

                                          Text(
                                            "${dateOfBirthString}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontFamily: "Lato",
                                                fontSize: 14,
                                                color: dividerColor),
                                          ),
                                          Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  00, 0, 0, 0),
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                child: Icon(Icons.calendar_today, color: dividerColor),
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
                                            label: new Text("Male", style: TextStyle(color:Colors.white,fontFamily:"Lato", fontWeight: FontWeight.bold, fontSize: 13),)),
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
                                            label: new Text("Female", style: TextStyle(color:Colors.white,fontFamily:"Lato", fontWeight: FontWeight.bold, fontSize: 13),)),
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


                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    controller: puppyDescriptionText,
                                    focusNode: puppyDescriptionFocus,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        puppyDescriptionFocus.requestFocus();
                                        return 'Enter puppy Description';
                                      }
                                      return null;
                                    },
                                    style: style,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Description*',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          controller: puppyColorText,
                                          style: style,
                                          focusNode: puppyColorFocus,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              puppyColorFocus.requestFocus();
                                              return 'Enter color';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(20),
                                              labelText: 'Color*',
                                              labelStyle: labelStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 3.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
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

                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          keyboardType: TextInputType.number,
                                          controller: puppyWeightText,
                                          focusNode: puppyWeightFocus,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              puppyWeightFocus.requestFocus();
                                              return 'Enter puppy weight';
                                            }
                                            return null;
                                          },
                                          style: style,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(20),
                                              labelText: 'Weight (lbs)*',
                                              labelStyle: labelStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 3.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          keyboardType: TextInputType.number,
                                          controller: puppyDadWeightText,
                                          focusNode: puppyDadWeightFocus,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              puppyDadWeightFocus.requestFocus();
                                              return "Mandatory field";
                                            }
                                            return null;
                                          },
                                          style: style,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(20),
                                              labelText: "Dad's Weight (lbs)*",
                                              labelStyle: labelStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 3.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          keyboardType: TextInputType.number,
                                          controller: puppyMomWeightText,
                                          focusNode: puppyMomWeightFocus,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              puppyMomWeightFocus.requestFocus();
                                              return "Please enter this";
                                            }
                                            return null;
                                          },
                                          style: style,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(20),
                                              labelText: "Mom's Weight (lbs)*",
                                              labelStyle: labelStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 3.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: askingPriceText,
                                    focusNode: askingPriceFocus,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        askingPriceFocus.requestFocus();
                                        return 'Enter price';
                                      }
                                      return null;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Asking Price \$*',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: shippingCostText,
                                    focusNode:shippingCostFocus,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        shippingCostFocus.requestFocus();
                                        return 'Enter shipping cost';
                                      }
                                      return null;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Shipping Cost \$*',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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

                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius:  new BorderRadius.circular(borderRadius)
                                  ),


                                  child: Column(
                                    children: <Widget>[
                                      MergeSemantics(
                                        child: ListTile(
                                          dense: true,
                                          title: Text('Champion Bloodline', style: TextStyle(fontSize: 13,  color:  isChampionBloodline?dividerColor : Color(0xffA9A9A9)),),
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
                                          title: Text('Family Raised', style: TextStyle(fontSize: 13,  color:  isFamilyRaised?dividerColor : Color(0xffA9A9A9)),),
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
                                          title: Text('Kid Friendly', style: TextStyle(fontSize: 13,  color:  isKidFriendly?dividerColor : Color(0xffA9A9A9)),),
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
                                          title: Text('Microchipped', style: TextStyle(fontSize: 13,  color:  isMicrochipped?dividerColor : Color(0xffA9A9A9)),),
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
                                          title: Text('Socialized', style: TextStyle(fontSize: 13,  color:  isSocialized?dividerColor : Color(0xffA9A9A9)),),
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
                                  color: dividerColor,
                                  borderRadius: BorderRadius.circular(100),
                                  padding: EdgeInsets.fromLTRB(120.0, 16.0, 120.0,16.0),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    onFinishClick(context);
                                  },
                                  child: Text("Finish",
                                    textAlign: TextAlign.center,
                                    style: style.copyWith(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 14),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }

  void onFinishClick(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if (_selectedBreedId == 0){
        Toast.show("Breed cannot be empty.. Choose breed", context,
            duration: Toast.LENGTH_LONG, backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
      return;
    }
      if(dateOfBirthString==''){
        Toast.show("Date of birth must be provided", context,
            duration: Toast.LENGTH_LONG, backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
        return;
      }
      if(images.length==0){
        Toast.show("Please upload Pic(s) before proceeding further", context,
            duration: Toast.LENGTH_LONG, backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
        return;
      }
      initiateAddPuppy(context);
    }


  }
  Future<void> initiateAddPuppy(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    List<MultipartFile> multipart = List<MultipartFile>();
    for (int i = 0; i < images.length; i++) {
      var path = await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      final mimeTypeData = lookupMimeType(path, headerBytes: [0xFF, 0xD8]).split('/');
      ByteData byteData = await images[i].getByteData(quality:50);
      List<int> imageData = byteData.buffer.asUint8List();
      MultipartFile multipartFile = MultipartFile.fromBytes(
        imageData,
        filename: 'image',
        contentType: MediaType("image", mimeTypeData[1]),
      );
      multipart.add(multipartFile);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId =  prefs.getString(Constants.SHARED_PREF_USER_ID);

    var dio = Dio();
    FormData formData = new FormData.fromMap({
      "puppy-name": Utility.capitalize(puppyNameText.text.trim()),
      "description": Utility.capitalize(puppyDescriptionText.text.trim()),
      "categories": _selectedBreedId,
      "user_id": userId,
      "selling-price": askingPriceText.text.trim(),
      "shipping-cost": shippingCostText.text.trim(),
      "date-of-birth": dateOfBirth.millisecondsSinceEpoch.toString(),
      "date-available-new": dateOfBirthString,
      "age-in-week": calculateAgeInWeeks(),
      "color": Utility.capitalize(puppyColorText.text.trim()),
      "puppy-weight": puppyWeightText.text.trim(),
      "dad-weight": puppyDadWeightText.text.trim(),
      "mom-weight": puppyMomWeightText.text.trim(),
      "registry": registryText.text.trim(),
      "kid-friendly": isKidFriendly?"1":"0",
      "socialized": isSocialized?"1":"0",
      "family-raised":isFamilyRaised?"1":"0",
      "champion-bloodlines": isChampionBloodline?"1":"0",
      "microchipped": isMicrochipped?"1":"0",
      "gender": isFemale?"Female":"Male",
      "gallery_images": [multipart],
    });
    try{
      dynamic response = await dio.post("https://onebarkplaza.com/wp-json/obp/v1/create_puppy",data:formData);
      if (response.toString() != '[]') {
        dynamic responseList = jsonDecode(response.toString());
        if (responseList["success"] == "Puppy successfully created!") {
          Toast.show("Puppy has been added Successfully", context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AddPuppySuccessful(responseList["puppy_id"])));
        } else {
          Toast.show("Add Puppy Failed " +response.toString(), context, duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
        }
      } else {
        Toast.show("Add Puppy Failed "+response.toString(), context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
      }
      setState(() {
        _isLoading = false;
      });
    }catch(exception){
      Toast.show("Request Failed. "+exception.toString(), context,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19)
      );
      setState(() {
        _isLoading = false;
    });
    }

  }

  double calculateGridHeight() {
    double numRowsReq = images.length==1? 1 :  ((images.length -1)  / imagesInGridRow) +1;
    return thumbnailSize* numRowsReq.toInt() + 16.0;
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
              primaryColor: Color(0xff3db6c6),//Head background
              accentColor: Color(0xff3db6c6),
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch(accentColor:Color(0xff3db6c6), primarySwatch: Colors.lightBlue),
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


  Future<bool> _onBackPressed() {
    if(isAnyFieldChanged()){
      return  showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Are you sure?'),
            content: Text("\nWe see that you have made some inputs which will be lost if you decide to go back.\n\nDo you still want to exit this page?"),
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
      );
    }
    else
      Navigator.of(context).pop();
  }

  bool isAnyFieldChanged() {
    return images.length != 0 ||
        _chooseBreed != '' ||
        puppyNameText.text.trim() != '' ||
        dateOfBirthString != '' ||
        isFemale != false ||
        puppyDescriptionText.text.trim() != '' ||
        puppyColorText.text.trim() != '' ||
        puppyWeightText.text.trim() != '' ||
        puppyDadWeightText.text.trim() != '' ||
        puppyMomWeightText.text.trim() != '' ||
        askingPriceText.text.trim() != '' ||
        shippingCostText.text.trim() != '' ||
        registryText.text.trim() != '' ||
        isChampionBloodline != false ||
        isFamilyRaised != false ||
        isKidFriendly != false ||
        isMicrochipped != false ||
        isSocialized != false;
  }

}

class AddPuppyLittermateState extends State<AddPuppy> {
  bool _isLoading = false;
  DateTime dateOfBirth = DateTime.now();
  DateTime dateOfCheckup = DateTime.now();
  String dateOfBirthString = '';
  List<Asset> images = List<Asset>();
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
  final _formKey = GlobalKey<FormState>();
  bool isFemale = false;

  String _error = 'No Error Dectected';

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

  BuildContext context;
  final globalKey = GlobalKey<ScaffoldState>();

  TextEditingController puppyDescriptionText = new TextEditingController();
  TextEditingController puppyNameText = new TextEditingController();
  TextEditingController puppyColorText = new TextEditingController();
  TextEditingController puppyWeightText = new TextEditingController();
  TextEditingController askingPriceText = new TextEditingController();
  TextEditingController shippingCostText = new TextEditingController();
  TextEditingController registryText = new TextEditingController();


  FocusNode puppyDescriptionFocus = new FocusNode();
  FocusNode puppyNameFocus = new FocusNode();
  FocusNode puppyColorFocus = new FocusNode();
  FocusNode puppyWeightFocus = new FocusNode();
  FocusNode askingPriceFocus = new FocusNode();
  FocusNode shippingCostFocus = new FocusNode();
  FocusNode registryFocus = new FocusNode();


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

  /*Future<Map<String, dynamic>> _uploadImage(File image) async {

    final mimeTypeData = lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(addPuppyUrl));
    final file = await http.MultipartFile.fromPath('image', image.path, contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    // Explicitly pass the extension of the image with request body
    // Since image_picker has some bugs due which it mixes up
    // image extension with file name like this filenamejpge
    // Which creates some problem at the server side to manage
    // or verify the file extension
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }
  void _startUploading() async {

    Uri uri = Uri.parse(addPuppyUrl);

// create multipart request
    MultipartRequest request = http.MultipartRequest("POST", uri);

    ByteData byteData = await images[0].getByteData();
    List<int> imageData = byteData.buffer.asUint8List();

    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageData,
      filename: 'onebark_test.jpg',
      contentType: MediaType("image", "jpg"),
    );

// add file to multipart
    request.files.add(multipartFile);
// send
    var response = await request.send();
    print(response);
    // Check if any error occured
    if (response == null || response.toString().contains("error")) {
      Toast.show("Image Upload Failed!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show("Image Uploaded Successfully!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }*/



  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final borderRadius = 30.0;
    final hintColor = Color(0xffA9A9A9);


    TextStyle style = TextStyle(fontFamily: 'Lato', fontSize: 14.0, color: Color(0xff707070));
    TextStyle hintStyle = TextStyle(
        fontFamily: 'Lato', fontSize: 14.0, color: hintColor);
    TextStyle labelStyle = TextStyle(
      fontFamily: 'Lato', color: dividerColor, fontSize: 12,);
    var maleColor = Color(0xff5cbaed);
    var femaleColor = Color(0xfff25fa3);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          key: globalKey,
          backgroundColor: Colors.transparent,
          appBar: new AppBar(

            leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: dividerColor),
                onPressed: _onBackPressed
            ),
            title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Text(
                    "Add Puppy",
                    style: new TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dividerColor),
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
                color: dividerColor,
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
                        child: Form(
                          key: _formKey,
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
                                                    border: Border.all(color:dividerColor, width: 3.0, ),
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
                                                    child: Image.asset("assets/images/ic_dp.png", color: dividerColor,),
                                                  ),
                                                )),
                                          ),
                                          SizedBox(height:12),
                                          new Text('You can add upto 6 photos',
                                            style: TextStyle(fontFamily:"Lato",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.bold),
                                          ),
                                          new Text('First photo of your selection will be cover photo',
                                            style: TextStyle(fontFamily:"Lato",color: Color(0xff707070), fontSize: 12,fontWeight: FontWeight.normal),
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
                                                  side: BorderSide(color: dividerColor, width: 2.0)
                                              ),
                                              onPressed: loadAssets,
                                              color: Color(0xffffffff),
                                              icon: new Icon(Icons.image, color:dividerColor, size:16),
                                              label: new Text("Add / View", style: TextStyle(color:dividerColor,fontFamily:"Lato", fontWeight: FontWeight.bold, fontSize: 13),)),
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


                                  child: InkWell(
                                    onTap: (){
                                      Toast.show("Breed cannot be different while adding littermate", context,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
                                    },
                                    child: InputDecorator(
                                      decoration: new InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Breed*',
                                        labelStyle: labelStyle,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: dividerColor) ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[

                                          Text(
                                            widget.littermateBreedName,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontFamily: "Lato",
                                                fontSize: 14,
                                                color: dividerColor),
                                          ),
                                          Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  00, 0, 00, 0),
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                child: Icon(Icons.check, color: Colors.green)),
                                              ),
                                        ],
                                      ),
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


                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    controller: puppyNameText,
                                    focusNode: puppyNameFocus,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        puppyNameFocus.requestFocus();
                                        return 'Enter puppy name';
                                      }
                                      return null;
                                    },
                                    autofocus: false,

                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Puppy Name*',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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
                                        labelText: 'Date of Birth*',
                                        labelStyle: labelStyle,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: dividerColor)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[

                                          Text(
                                            "${dateOfBirthString}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontFamily: "Lato",
                                                fontSize: 14,
                                                color: dividerColor),
                                          ),
                                          Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  00, 0, 0, 0),
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                child: Icon(Icons.calendar_today, color: dividerColor),
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
                                            label: new Text("Male", style: TextStyle(color:Colors.white,fontFamily:"Lato", fontWeight: FontWeight.bold, fontSize: 13),)),
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
                                            label: new Text("Female", style: TextStyle(color:Colors.white,fontFamily:"Lato", fontWeight: FontWeight.bold, fontSize: 13),)),
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


                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    controller: puppyDescriptionText,
                                    focusNode: puppyDescriptionFocus,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        puppyDescriptionFocus.requestFocus();
                                        return 'Enter puppy Description';
                                      }
                                      return null;
                                    },
                                    style: style,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Description*',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          controller: puppyColorText,
                                          style: style,
                                          focusNode: puppyColorFocus,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              puppyColorFocus.requestFocus();
                                              return 'Enter color';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(20),
                                              labelText: 'Color*',
                                              labelStyle: labelStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 3.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
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

                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          keyboardType: TextInputType.number,
                                          controller: puppyWeightText,
                                          focusNode: puppyWeightFocus,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              puppyWeightFocus.requestFocus();
                                              return 'Enter puppy weight';
                                            }
                                            return null;
                                          },
                                          style: style,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(20),
                                              labelText: 'Weight (lbs)*',
                                              labelStyle: labelStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 3.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                        child: TextFormField(
                                          enabled: false,
                                          textAlign: TextAlign.start,
                                          initialValue: widget.littermateDadWeight.toString(),
                                          style: style,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(20),
                                              labelText: "Dad's Weight (lbs)*",
                                              labelStyle: labelStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 3.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              disabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                        child: TextFormField(
                                          enabled: false,
                                          textAlign: TextAlign.start,
                                          initialValue: widget.littermateMomWeight.toString(),
                                          style: style,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(20),
                                              labelText: "Mom's Weight (lbs)*",
                                              labelStyle: labelStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 3.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
                                                borderRadius: BorderRadius.circular(borderRadius),
                                              ),
                                              disabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: askingPriceText,
                                    focusNode: askingPriceFocus,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        askingPriceFocus.requestFocus();
                                        return 'Enter price';
                                      }
                                      return null;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Asking Price \$*',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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


                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    controller: shippingCostText,
                                    focusNode:shippingCostFocus,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        shippingCostFocus.requestFocus();
                                        return 'Enter shipping cost';
                                      }
                                      return null;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Shipping Cost \$*',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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
                                          borderSide: BorderSide(color: dividerColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: dividerColor, width: 2.0),
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

                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius:  new BorderRadius.circular(borderRadius)
                                  ),


                                  child: Column(
                                    children: <Widget>[
                                      MergeSemantics(
                                        child: ListTile(
                                          dense: true,
                                          title: Text('Champion Bloodline', style: TextStyle(fontSize: 13,  color:  isChampionBloodline?dividerColor : Color(0xffA9A9A9)),),
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
                                          title: Text('Family Raised', style: TextStyle(fontSize: 13,  color:  isFamilyRaised?dividerColor : Color(0xffA9A9A9)),),
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
                                          title: Text('Kid Friendly', style: TextStyle(fontSize: 13,  color:  isKidFriendly?dividerColor : Color(0xffA9A9A9)),),
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
                                          title: Text('Microchipped', style: TextStyle(fontSize: 13,  color:  isMicrochipped?dividerColor : Color(0xffA9A9A9)),),
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
                                          title: Text('Socialized', style: TextStyle(fontSize: 13,  color:  isSocialized?dividerColor : Color(0xffA9A9A9)),),
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
                                  color: dividerColor,
                                  borderRadius: BorderRadius.circular(100),
                                  padding: EdgeInsets.fromLTRB(120.0, 16.0, 120.0,16.0),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    onFinishClick(context);
                                  },
                                  child: Text("Finish",
                                    textAlign: TextAlign.center,
                                    style: style.copyWith(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 14),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }

  void onFinishClick(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if(dateOfBirthString==''){
        Toast.show("Date of birth must be provided", context,
            duration: Toast.LENGTH_LONG, backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
        return;
      }
      if(images.length==0){
        Toast.show("Please upload Pic(s) before proceeding further", context,
            duration: Toast.LENGTH_LONG, backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
        return;
      }
      initiateAddPuppy(context);
    }


  }
  Future<void> initiateAddPuppy(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    List<MultipartFile> multipart = List<MultipartFile>();
    for (int i = 0; i < images.length; i++) {
      var path = await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      final mimeTypeData = lookupMimeType(path, headerBytes: [0xFF, 0xD8]).split('/');
      ByteData byteData = await images[i].getByteData(quality:50);
      List<int> imageData = byteData.buffer.asUint8List();
      MultipartFile multipartFile = MultipartFile.fromBytes(
        imageData,
        filename: 'image',
        contentType: MediaType("image", mimeTypeData[1]),
      );
      multipart.add(multipartFile);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId =  prefs.getString(Constants.SHARED_PREF_USER_ID);

    var dio = Dio();
    FormData formData = new FormData.fromMap({
      "puppy-name": Utility.capitalize(puppyNameText.text.trim()),
      "description": Utility.capitalize(puppyDescriptionText.text.trim()),
      "categories": widget.littermateBreedId,
      "user_id": userId,
      "selling-price": askingPriceText.text.trim(),
      "shipping-cost": shippingCostText.text.trim(),
      "date-of-birth": dateOfBirth.millisecondsSinceEpoch.toString(),
      "date-available-new": dateOfBirthString,
      "age-in-week": calculateAgeInWeeks(),
      "color": Utility.capitalize(puppyColorText.text.trim()),
      "puppy-weight": puppyWeightText.text.trim(),
      "dad-weight": widget.littermateDadWeight.toString(),
      "mom-weight": widget.littermateDadWeight.toString(),
      "registry": registryText.text.trim(),
      "kid-friendly": isKidFriendly?"1":"0",
      "socialized": isSocialized?"1":"0",
      "family-raised":isFamilyRaised?"1":"0",
      "champion-bloodlines": isChampionBloodline?"1":"0",
      "microchipped": isMicrochipped?"1":"0",
      "gender": isFemale?"Female":"Male",
      "gallery_images": [multipart],
    });
    try{
      dynamic response = await dio.post("https://onebarkplaza.com/wp-json/obp/v1/create_puppy",data:formData);
      if (response.toString() != '[]') {
        dynamic responseList = jsonDecode(response.toString());
        if (responseList["success"] == "Puppy successfully created!") {
          Toast.show("Puppy has been added Successfully", context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AddPuppySuccessful(responseList["puppy_id"])));
        } else {
          Toast.show("Add Puppy Failed " +response.toString(), context, duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
        }
      } else {
        Toast.show("Add Puppy Failed "+response.toString(), context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
      }
      setState(() {
        _isLoading = false;
      });
    }catch(exception){
      Toast.show("Request Failed. "+exception.toString(), context,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19)
      );
      setState(() {
        _isLoading = false;
      });
    }

  }

  double calculateGridHeight() {
    double numRowsReq = images.length==1? 1 :  ((images.length -1)  / imagesInGridRow) +1;
    return thumbnailSize* numRowsReq.toInt() + 16.0;
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
              primaryColor: Color(0xff3db6c6),//Head background
              accentColor: Color(0xff3db6c6),
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch(accentColor:Color(0xff3db6c6), primarySwatch: Colors.lightBlue),
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


  void toggleState() {
    setState(() {
      isFemale = !isFemale ;
    });
  }

  calculateAgeInWeeks() {
    return ((DateTime.now().difference(dateOfBirth).inDays)/7).round();
  }


  Future<bool> _onBackPressed() {
    if(isAnyFieldChanged()){
      return  showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Are you sure?'),
            content: Text("\nWe see that you have made some inputs which will be lost if you decide to go back.\n\nDo you still want to exit this page?"),
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
      );
    }
    else
      Navigator.of(context).pop();
  }

  bool isAnyFieldChanged() {
    return images.length != 0 ||
        puppyNameText.text.trim() != '' ||
        dateOfBirthString != '' ||
        isFemale != false ||
        puppyDescriptionText.text.trim() != '' ||
        puppyColorText.text.trim() != '' ||
        puppyWeightText.text.trim() != '' ||
        askingPriceText.text.trim() != '' ||
        shippingCostText.text.trim() != '' ||
        registryText.text.trim() != '' ||
        isChampionBloodline != false ||
        isFamilyRaised != false ||
        isKidFriendly != false ||
        isMicrochipped != false ||
        isSocialized != false;
  }

}