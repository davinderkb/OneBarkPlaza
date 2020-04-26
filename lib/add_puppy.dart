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
final greenColor = Color(0xff7FA432);
final customColor = Color(0xff7FA432);//Color(0xff4C8BF5);
var addPuppyUrl = 'https://obpdevstage.wpengine.com/wp-json/obp/v1/create_puppy';

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
  DateTime dateOfCheckup = DateTime.now();
  String dateOfBirthString = '';
  String dateOfCheckupString = '';
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
  String _flightTicketPath;
  int vetFileType = Constants.FILE_TYPE_OTHER;
  int flightFileType = Constants.FILE_TYPE_OTHER;
  ChooseBreedDialog chooseBreedDialog = null;

  bool isFemale = false;

  Image vetReportThumbnail;
  PDFPageImage vetPageImage;
  PDFPageImage flightPageImage;
  MultipartFile vetReport;
  MultipartFile flightTicketFile;
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
  TextEditingController vetNameText = new TextEditingController();


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
  void loadVetReport() async {
    try {
      String filePath = await FilePicker.getFilePath(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc' , 'docx'],);
      if (filePath == '') {
        return;
      }
      if(filePath.substring(filePath.lastIndexOf(".") + 1) == "pdf"){
        vetFileType = Constants.FILE_TYPE_PDF;
      } else if (filePath.substring(filePath.lastIndexOf(".") + 1) == "jpg"
          || filePath.substring(filePath.lastIndexOf(".") + 1) == "jpeg"
          || filePath.substring(filePath.lastIndexOf(".") + 1) == "png" ){
        vetFileType = Constants.FILE_TYPE_IMAGE;
      } else{
        vetFileType = Constants.FILE_TYPE_OTHER;
      }
      this._vetReportPath = filePath;
      if(_vetReportPath!=null){
        List<int> vetFile = await File(_vetReportPath).readAsBytes();
        vetReport= MultipartFile.fromBytes(
            vetFile,
            filename: 'vet_report.'+_vetReportPath.substring(_vetReportPath.lastIndexOf(".")+1),
            contentType: MediaType("vet_report", _vetReportPath.substring(_vetReportPath.lastIndexOf(".")+1))
        );
      }
      setState((){

      });
    } on Exception catch (e) {
      print("Error while picking the file: " + e.toString());
    }
  }

  void loadFlightTicket() async {
    try {
      String filePath = await FilePicker.getFilePath(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc' , 'docx'],);
      if (filePath == '') {
        return;
      }
      if(filePath.substring(filePath.lastIndexOf(".") + 1) == "pdf"){
        flightFileType = Constants.FILE_TYPE_PDF;
      } else if (filePath.substring(filePath.lastIndexOf(".") + 1) == "jpg"
          || filePath.substring(filePath.lastIndexOf(".") + 1) == "jpeg"
          || filePath.substring(filePath.lastIndexOf(".") + 1) == "png" ){
        vetFileType = Constants.FILE_TYPE_IMAGE;
      } else{
        vetFileType = Constants.FILE_TYPE_OTHER;
      }
      this._flightTicketPath = filePath;
      if(_flightTicketPath!=null){
        List<int> flightTicket = await File(_flightTicketPath).readAsBytes();
        flightTicketFile= MultipartFile.fromBytes(
            flightTicket,
            filename: 'flight_ticket.'+_flightTicketPath.substring(_flightTicketPath.lastIndexOf(".")+1),
            contentType: MediaType("flight_ticket", _flightTicketPath.substring(_flightTicketPath.lastIndexOf(".")+1))
        );
      }
      setState((){
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
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          key: globalKey,
          backgroundColor: Colors.transparent,
          appBar: new AppBar(

            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: greenColor),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Text('Are you sure?'),
                      content: Text("\nAny entries in the form would be lost. Do you want to exit this page?"),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: Text('No',style: TextStyle(color:customColor)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text('Yes',style: TextStyle(color:customColor)),
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
                                            label: new Text("Add / View", style: TextStyle(color:greenColor,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),)),
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
                                                00, 0, 00, 0),
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
                                                00, 0, 0, 0),
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
                                  controller: vetNameText,
                                  style: style,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(20),
                                      labelText: 'Vet Name',
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
                                  controller: vetAddressText,
                                  style: style,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(20),
                                      labelText: 'Vet Address',
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
                                  _selectDateOfCheckup(context);
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
                                      labelText: 'Check-up Date',
                                      labelStyle: labelStyle,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: greenColor)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[

                                        Text(
                                          "${dateOfCheckupString}",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontFamily: "NunitoSans",
                                              fontSize: 14,
                                              color: greenColor),
                                        ),
                                        Padding(
                                            padding:
                                            const EdgeInsets.fromLTRB(
                                                00, 0, 0, 0),
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

                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: _width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:  new BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 1, // soften the shadow
                                        offset: Offset(
                                          1, // Move to right 10  horizontally
                                          1.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                  ),
                                  child: InputDecorator(
                                    decoration: new InputDecoration(

                                      labelText: 'Vet Check Report',
                                      labelStyle: labelStyle,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width:2.0, color: greenColor)),
                                    ),
                                    child: Container(

                                      child: _vetReportPath!=null
                                          ? Column(
                                            children: <Widget>[
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:  new BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.transparent,
                                                      blurRadius: 0, // soften the shadow
                                                      offset: Offset(
                                                        0, // Move to right 10  horizontally
                                                        0.0, // Move to bottom 10 Vertically
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          Icon(Icons.attachment, color: Colors.black38, ),
                                                          SizedBox(width: 8,),
                                                          Container(
                                                            width: _width/1.75,
                                                            child: Text(_vetReportPath.substring(_vetReportPath.lastIndexOf("/")+1),textAlign: TextAlign.start,
                                                              maxLines: 2,
                                                              style: TextStyle(fontSize: 14,color: Colors.grey),
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                      InkWell(
                                                        splashColor: Colors.red,
                                                        onTap: (){
                                                          Toast.show("Vet report selection cancelled", context);
                                                          setState(() {
                                                            _vetReportPath = null;
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          width: 40,
                                                          child: Icon(Icons.cancel, color: Colors.redAccent,),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                ),
                                              ),
                                              SizedBox(height: 16,),
                                              Container(
                                                alignment: Alignment.bottomRight,
                                                child: Container(
                                                  width: _width,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: <Widget>[
                                                      InkWell(
                                                          onTap:() async {
                                                            await OpenFile.open(_vetReportPath);
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.only(
                                                              bottom: 0.0, // space between underline and text
                                                            ),
                                                            decoration: BoxDecoration(
                                                                border: Border(bottom: BorderSide(
                                                                  color: Colors.blue,  // Text colour here
                                                                  width: 1.5, // Underline width
                                                                ))
                                                            ),

                                                            child:new Text("VIEW", style: TextStyle(color:Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
                                                          )
                                                      ),
                                                      SizedBox(width: 20,),
                                                      InkWell(
                                                          onTap:(){
                                                            loadVetReport();
                                                          },
                                                          child: Container(
                                                              padding: EdgeInsets.only(
                                                                bottom: 0.0, // space between underline and text
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  border: Border(bottom: BorderSide(
                                                                    color: Colors.blue,  // Text colour here
                                                                    width: 1.5, // Underline width
                                                                  ))
                                                              ),

                                                              child:new Text("CHANGE", style: TextStyle(color:Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
                                                          )
                                                      ),
                                                      SizedBox(width: 8,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                          : InkWell(
                                              onTap:loadVetReport,
                                            child: Container(

                                              child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(16,0,0,0),
                                                  child: Text("Upload", style:labelStyle),
                                                ),
                                                ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(24.0),
                                                  child:Padding(
                                                    padding: const EdgeInsets.fromLTRB(0,0,12 ,0),
                                                    child: Icon(Icons.file_upload, color: greenColor,),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ),
                                          ),

                                    ),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 24,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: _width,
                                  decoration: BoxDecoration(
                                    color: Color(0xffffffff),
                                    borderRadius:  new BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 1, // soften the shadow
                                        offset: Offset(
                                          1, // Move to right 10  horizontally
                                          1.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                  ),
                                  child: InputDecorator(
                                    decoration: new InputDecoration(

                                      labelText: 'Flight Ticket',
                                      labelStyle: labelStyle,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width:2.0, color: greenColor)),
                                    ),
                                    child: Container(

                                      child: _flightTicketPath!=null
                                          ? Column(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:  new BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.transparent,
                                                  blurRadius: 0, // soften the shadow
                                                  offset: Offset(
                                                    0, // Move to right 10  horizontally
                                                    0.0, // Move to bottom 10 Vertically
                                                  ),
                                                )
                                              ],
                                            ),

                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Icon(Icons.attachment, color: Colors.black38, ),
                                                      SizedBox(width: 8,),
                                                      Container(
                                                        width: _width/1.75,
                                                        child: Text(_flightTicketPath.substring(_flightTicketPath.lastIndexOf("/")+1),textAlign: TextAlign.start,
                                                          maxLines: 2,
                                                          style: TextStyle(fontSize: 14,color: Colors.grey),
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                  InkWell(
                                                    splashColor: Colors.red,
                                                    onTap: (){
                                                      Toast.show("Flight Ticket selection cancelled", context);
                                                      setState(() {
                                                        _flightTicketPath = null;
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 40,
                                                      width: 40,
                                                      child: Icon(Icons.cancel, color: Colors.redAccent,),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                            ),
                                          ),
                                          SizedBox(height: 16,),
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                              width: _width,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  InkWell(
                                                      onTap:() async {
                                                          await OpenFile.open(_flightTicketPath);
                                                        },
                                                      child: Container(
                                                          padding: EdgeInsets.only(
                                                            bottom: 0.0, // space between underline and text
                                                          ),
                                                          decoration: BoxDecoration(
                                                              border: Border(bottom: BorderSide(
                                                                color: Colors.blue,  // Text colour here
                                                                width: 1.5, // Underline width
                                                              ))
                                                          ),

                                                          child:new Text("VIEW", style: TextStyle(color:Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
                                                      )
                                                  ),
                                                  SizedBox(width: 20,),
                                                  InkWell(
                                                      onTap:(){
                                                        loadFlightTicket();
                                                      },
                                                      child: Container(
                                                          padding: EdgeInsets.only(
                                                            bottom: 0.0, // space between underline and text
                                                          ),
                                                          decoration: BoxDecoration(
                                                              border: Border(bottom: BorderSide(
                                                                color: Colors.blue,  // Text colour here
                                                                width: 1.5, // Underline width
                                                              ))
                                                          ),

                                                          child:new Text("CHANGE", style: TextStyle(color:Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
                                                      )
                                                  ),
                                                  SizedBox(width: 8,),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                          : InkWell(
                                        onTap:loadFlightTicket,
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(16,0,0,0),
                                                child: Text("Upload ..", style:labelStyle),
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(24.0),
                                                child:Padding(
                                                  padding: const EdgeInsets.fromLTRB(0,0,12 ,0),
                                                  child: Icon(Icons.file_upload, color: greenColor,),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    ),
                                  ),
                                ),

                              ],
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
                                color: greenColor,
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
                    ],
                  ),
                ),
              ))),
    );
  }

  void onFinishClick(BuildContext context) {
    initiateAddPuppy(context);
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
      "vet-name": vetNameText.text.trim(),
      "vet-address": vetAddressText.text.trim(),
      "checkup-date": dateOfCheckup.millisecondsSinceEpoch.toString(),
      "kid-friendly": isKidFriendly?"1":"0",
      "socialized": isSocialized?"1":"0",
      "family-raised":isFamilyRaised?"1":"0",
      "champion-bloodlines": isChampionBloodline?"1":"0",
      "microchipped": isMicrochipped?"1":"0",
      "gender": isFemale?"Female":"Male",
      "gallery_images": [multipart],
      "report-copy" : _vetReportPath!=null?vetReport:"",
      "flight-doc" : _flightTicketPath!=null?flightTicketFile:""
    });
    try{
      dynamic response = await dio.post("https://obpdevstage.wpengine.com/wp-json/obp/v1/create_puppy",data:formData);
      if (response.toString() != '[]') {
        dynamic responseList = jsonDecode(response.toString());
        if (responseList["success"] == "Puppy successfully created!") {
          Toast.show("Add Puppy Successful " +response.toString(), context,duration: Toast.LENGTH_LONG);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AddPuppySuccessful(responseList["puppy_id"])));
        } else {
          Toast.show("Add Puppy Failed " +response.toString(), context, duration: Toast.LENGTH_LONG);
        }
      } else {
        Toast.show("Add Puppy Failed "+response.toString(), context,duration: Toast.LENGTH_LONG);
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
              primaryColor: Colors.green,//Head background
              accentColor: Colors.green,
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch(accentColor: Colors.green, primarySwatch: Colors.green),
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

  Future<Null> _selectDateOfCheckup(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: dateOfCheckup,
        firstDate: DateTime(dateOfBirth.year),
        lastDate: new DateTime.now(),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor:Colors.green,//Head background
              accentColor: Colors.green,
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch(accentColor: Colors.green, primarySwatch: Colors.green),
              ),
            ),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        dateOfCheckup = picked;
        dateOfCheckupString = new DateFormat("MMM dd, yyyy").format(picked);
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
    return  showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Are you sure?'),
          content: Text("\nAny entries in the form would be lost. Do you want to exit this page?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('No', style: TextStyle(color:greenColor),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Yes', style: TextStyle(color:greenColor),),
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
  }
}