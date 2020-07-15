import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http_parser/http_parser.dart';
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
import 'package:one_bark_plaza/homepage.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:one_bark_plaza/util/utility.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'choose_breed_dialog.dart';
import 'img.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:path_provider/path_provider.dart';

final obpBlueColor = Color(0XFF3DB6C6);
final blueColor = Color(0xff4C8BF5);

class EditPuppy extends StatefulWidget {
  EditPuppyState editPuppyState;
  String reason;
  PuppyDetails puppyDetails;
  EditPuppy(PuppyDetails puppyDetails, String reason) {
    this.reason = reason;
    this.puppyDetails = new PuppyDetails.deepCopy(
        puppyDetails.puppyId,
        puppyDetails.puppyName,
        puppyDetails.puppyPrice,
        puppyDetails.shippingCost,
        puppyDetails.description,
        puppyDetails.gallery,
        puppyDetails.gender,
        puppyDetails.dobString,
        puppyDetails.dob,
        puppyDetails.ageInWeeks,
        puppyDetails.color,
        puppyDetails.puppyWeight,
        puppyDetails.puppyDadWeight,
        puppyDetails.puppyMomWeight,
        puppyDetails.registry,
        puppyDetails.status,
        puppyDetails.categoryId,
        puppyDetails.categoryName,
        puppyDetails.categoryLink,
        puppyDetails.vetName,
        puppyDetails.vetAddress,
        puppyDetails.vetReport,
        puppyDetails.checkUpDateString,
        puppyDetails.checkupDate,
        puppyDetails.flightTicket,
        puppyDetails.isChampionBloodline,
        puppyDetails.isFamilyRaised,
        puppyDetails.isKidFriendly,
        puppyDetails.isMicrochipped,
        puppyDetails.isSocialized,
        puppyDetails.isSoldByObp(),
        puppyDetails.coverPic
    );
  }
  @override
  EditPuppyState createState() {
    return editPuppyState = new EditPuppyState();
  }
}

class EditPuppyState extends State<EditPuppy> {
  bool _isLoading = false;
  DateTime dateOfBirth = DateTime.now();
  DateTime dateOfCheckup = DateTime.now();
  String dateOfBirthString = '';
  String dateOfCheckupString = '';
  String _chooseBreed = '';
  int _selectedBreedId = 0;
  bool _isBreedSelectedOnce = false;
  List<Asset> imageAssets = List<Asset>();
  Future<List<ImageWithId>> futureAllImages ;
  String _error = 'No Error Dectected';
  String _platformMessage = 'No Error';
  List images2;
  int maxImageNo = 6;
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
  List<ImageWithId> allImages = new List<ImageWithId>();
  List<ImageWithId> oldImages;
  String _vetReportPath;
  String _flightTicketPath;
  int vetFileType = Constants.FILE_TYPE_OTHER;
  int flightFileType = Constants.FILE_TYPE_OTHER;
  MultipartFile vetReport;
  MultipartFile flightTicketFile;
  bool isFirstTime = true;


  List<ImageWithId> newImages;

  List<String> deletedImagesIdList = new List<String>() ;

  bool isBreedEditAllowed = false;
  bool isGenderEditAllowed = false;
  bool isBadgeEditAllowed = false;

  TextStyle labelStyle(bool isEnableColor){
     return TextStyle(
      fontFamily: 'Lato',
      color: isEnableColor? obpBlueColor : Colors.grey,
      fontSize: 12,
    );
  }

  Future<Widget> buildGridView() async {

    return GridView.count(
      crossAxisCount: imagesInGridRow,
      children: List.generate(imageAssets.length, (index) {
        Asset asset = imageAssets[index];
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: Colors.black12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: FittedBox(
                    child: AssetThumb(
                        asset: asset,
                        width: thumbnailSize,
                        height: thumbnailSize),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
        );
      }),
    );
  }
   Future<List<ImageWithId>> addNewImages() async {
    List<ImageWithId> newImages = new List<ImageWithId>();
    for(Asset item in imageAssets){
        ByteData byteData = await item.getByteData();
        List<int> imageData = byteData.buffer.asUint8List();
        newImages.add(ImageWithId.name(null, Image.memory(imageData)));
    }
    return newImages;
  }
  isBreedSelectedOnce(bool value) {
    _isBreedSelectedOnce = value;
  }

  BuildContext context;
  final globalKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    dateOfBirth = widget.puppyDetails.dob;
    dateOfCheckup = widget.puppyDetails.checkupDate;
    dateOfBirthString = widget.puppyDetails.dobString;
    dateOfCheckupString = widget.puppyDetails.checkUpDateString;
    _chooseBreed = widget.puppyDetails.categoryName;
    _selectedBreedId = widget.puppyDetails.categoryId;
    isFemale = widget.puppyDetails.isFemale;
    isMicrochipped = widget.puppyDetails.isMicrochipped;
    isSocialized = widget.puppyDetails.isSocialized;
    isChampionBloodline = widget.puppyDetails.isChampionBloodline;
    isFamilyRaised = widget.puppyDetails.isFamilyRaised;
    isKidFriendly = widget.puppyDetails.isKidFriendly;
    _vetReportPath = widget.puppyDetails.vetReport;
    _flightTicketPath = widget.puppyDetails.flightTicket;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => isFirstTime = false);

  }
  Future<List<ImageWithId>>getImages() async {

    oldImages = new List<ImageWithId>();
    for(ImageCustom galleryItem in widget.puppyDetails.gallery){
      var data = await http.get(galleryItem.src);
      var bytes = data.bodyBytes;
      oldImages.add(ImageWithId.name(galleryItem.id, Image.memory(bytes, fit: BoxFit.cover)));
    }
    return oldImages;
  }

  Future<List<ImageWithId>>syncNewImages() async {
    if(allImages!=null) {
      allImages.clear();
      allImages.addAll(oldImages);
      allImages.addAll(await addNewImages());
      return allImages;
    }
  }
  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: maxImageNo - oldImages.length > 0 ? maxImageNo -  oldImages.length: 0,
        enableCamera: true,
        selectedAssets: imageAssets,
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


    setState(() {
      imageAssets = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    futureAllImages = isFirstTime? getImages():syncNewImages();
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final borderRadius = 30.0;
    final hintColor = Color(0xffA9A9A9);

    TextStyle style = TextStyle(
        fontFamily: 'Lato', fontSize: 14.0, color: Color(0xff707070));
    TextStyle hintStyle =
        TextStyle(fontFamily: 'Lato', fontSize: 14.0, color: hintColor);

    var maleColor = Color(0xff5cbaed);
    var femaleColor = Color(0xfff25fa3);
    return _isLoading? Container(
        color: Colors.white,
        width: _width,
        height: _height,
        alignment: Alignment.bottomCenter,
        child: SpinKitRipple(
          borderWidth: 100.0,
          color: obpBlueColor,
          size: 120,
        )):Scaffold(
        key: globalKey,
        backgroundColor: Colors.transparent,
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: obpBlueColor),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                new Text(
                  "Edit Puppy",
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
          backgroundColor: Color(0xffffffff),
        ),
        body: SingleChildScrollView(
            child: Stack(
          overflow: Overflow.visible,
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
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
                        SizedBox(
                          height: 8,
                        ),

                        SizedBox(height: 0),
                        Center(
                          child: Container(

                            width: _width -60,
                            child: FutureBuilder(
                              future: futureAllImages,
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
                                      child: SpinKitRing(
                                        lineWidth: 2,
                                        color: obpBlueColor,
                                        size: 50.0,
                                      ),
                                    );
                                    break;
                                  case ConnectionState.done:
                                    if (snapshot.hasError) {
                                      // return whatever you'd do for this case, probably an error

                                    }
                                    var data = snapshot.data as List<ImageWithId>;
                                    return data.length>0?Container(
                                      height: _width -120,
                                      child: ListView.builder(
                                        reverse: false,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:  data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) => Padding(
                                              padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                      height:_width-120,
                                                      width: _width - 120,
                                                      decoration: BoxDecoration(
                                                        color: Color(0xffffffff),
                                                        borderRadius:BorderRadius.all(Radius.circular(16)),
                                                        border: Border.all(color: Colors.black12),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(0.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                          BorderRadius.circular(16.0),
                                                          child:Padding(
                                                            padding: const EdgeInsets.all(0.0),
                                                            child: FittedBox(
                                                              child: data[index].photo,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                  widget.reason==Constants.PHOTO_CHANGE?Positioned(
                                                    top:12.0,
                                                    right: 14.0,
                                                    child: Container(

                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        //color: Color(0xffFFFFFF),
                                                        borderRadius:
                                                        BorderRadius.all(Radius.circular(16)),
                                                      ),

                                                      child: InkWell(
                                                          onTap: (){
                                                            showDialog<void>(
                                                              context: context,
                                                              barrierDismissible: false, // user must tap button!
                                                              builder: (BuildContext context) {
                                                                return CupertinoAlertDialog(
                                                                  title: Text('Are you sure?'),
                                                                  content: Text('\nYou want to delete this image?'),
                                                                  actions: <Widget>[
                                                                    CupertinoDialogAction(
                                                                      child: Text('No'),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                    ),
                                                                    CupertinoDialogAction(
                                                                      child: Text('Yes'),
                                                                      onPressed: () async{
                                                                        Navigator.of(context).pop();
                                                                        if(data[index].photoId==null){
                                                                          if(oldImages.length>0) {
                                                                            imageAssets.removeAt(index - oldImages.length);
                                                                          } else{
                                                                            imageAssets.removeAt(index);
                                                                          }
                                                                          setState(() {

                                                                          });
                                                                        } else{
                                                                            deletedImagesIdList.add(data[index].photoId);
                                                                            oldImages.removeWhere((element) => element.photoId==data[index].photoId);
                                                                            setState(() {

                                                                            });
                                                                        }
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                            },
                                                          child: Icon(Icons.cancel, size:32)
                                                      ),
                                                    ),
                                                  ):SizedBox()
                                                ],
                                              ),
                                            ),
                                      ),
                                    ) :
                                    widget.reason==Constants.PHOTO_CHANGE?Container(
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
                                                    border: Border.all(color:obpBlueColor, width: 3.0, ),
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
                                                    child: Image.asset("assets/images/ic_dp.png", color: obpBlueColor,),
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

                                    ):SizedBox();
                                    break;
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        widget.reason==Constants.PHOTO_CHANGE && maxImageNo - oldImages.length  > 0 ?
                        Center(
                          child: new RaisedButton.icon(
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  side: BorderSide(color: obpBlueColor, width: 2.0)
                              ),
                              onPressed: loadAssets,
                              color: Color(0xffffffff),
                              icon: new Icon(Icons.image, color:obpBlueColor, size:16),
                              label: new Text("Add Images", style: TextStyle(color:obpBlueColor,fontFamily:"Lato", fontWeight: FontWeight.bold, fontSize: 13),)),
                        ):SizedBox(height: 0,),
                        SizedBox(height: 24),
                        Center(
                          child: Container(
                            width: _width,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius:
                                    new BorderRadius.circular(borderRadius)),
                            child: TextFormField(
                              enabled: false,
                              initialValue: widget.puppyDetails.puppyName,
                              textAlign: TextAlign.start,
                              style: style,
                              onChanged: (String value) {
                                widget.puppyDetails.puppyName = value;
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Puppy Name',
                                  labelStyle: labelStyle(false),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: obpBlueColor, width: 3.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: obpBlueColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: obpBlueColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(height: 24,),
                        Center(
                          child: InkWell(
                          //No removing this unreachable code, Just in case if we enable editing in breed selection in future
                            onTap: isBreedEditAllowed ? () {

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
                                  child: chooseBreedDialog = ChooseBreedDialog(widget.editPuppyState),
                                ),
                              )
                              ;
                            }: null,
                            child: Container(
                              width: _width,
                              height: 60,
                              decoration: isBreedEditAllowed?BoxDecoration(
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
                              ):BoxDecoration(),


                              child: InputDecorator(
                                decoration: new InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Breed',
                                  labelStyle: labelStyle(isBreedEditAllowed),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: isBreedEditAllowed?obpBlueColor:Color(0xffE3E3E3))),
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
                                          color: isBreedEditAllowed?obpBlueColor:Colors.grey),
                                    ),
                                    Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            00, 0, 00, 0),
                                        child: isBreedEditAllowed?Container(
                                          height: 40,
                                          width: 40,
                                          child: _isBreedSelectedOnce?Icon(Icons.check, color: Colors.green):Icon(Icons.format_list_bulleted, color: obpBlueColor),
                                        ):SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24,),
                        Center(
                          child: InkWell(
                            onTap: widget.reason==Constants.DATE_CORRECTION ? () {
                              FocusScope.of(context).unfocus();
                              _selectDateOfBirth(context);
                            } : null,
                            child: Container(
                              width: _width,
                              height: 64,
                              decoration: widget.reason==Constants.DATE_CORRECTION ?BoxDecoration(
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
                              ):BoxDecoration(),
                              child: InputDecorator(
                                decoration: new InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Date of Birth',
                                  labelStyle: labelStyle(widget.reason==Constants.DATE_CORRECTION),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: widget.reason==Constants.DATE_CORRECTION ?obpBlueColor:Color(0xffE3E3E3))),
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
                                          color:  widget.reason==Constants.DATE_CORRECTION ?obpBlueColor:Colors.grey),
                                    ),
                                    Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            00, 0, 0, 0),
                                        child:  widget.reason==Constants.DATE_CORRECTION?Container(
                                          height: 40,
                                          width: 40,
                                          child: Icon(Icons.calendar_today, color: obpBlueColor),
                                        ):SizedBox()),
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
                            child: isGenderEditAllowed
                                ? Row(
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
                            )
                                :Row(
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

                                      onPressed: null,
                                      color:Color(0xffEBEBE4),
                                      disabledColor: !isFemale?maleColor:Color(0xffEBEBE4),
                                      disabledElevation: 3.0,
                                      elevation: 0,
                                      icon: !isFemale? Icon(Icons.lock, color: Colors.white, size:14): Icon(null, size:0),
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
                                      onPressed:null,
                                      color:Color(0xffEBEBE4),
                                      disabledColor: isFemale?femaleColor:Color(0xffEBEBE4),
                                      disabledElevation: 3.0,
                                      elevation: 0,
                                      icon: isFemale? Icon(Icons.lock, color: Colors.white, size:14): Icon(null, size:0),
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
                              initialValue: widget.puppyDetails.description,
                              textAlign: TextAlign.start,
                              enabled: false,
                              style: style,
                              onChanged: (String value) {
                                widget.puppyDetails.description = value;
                              },
                              maxLines: 4,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Description',
                                  labelStyle: labelStyle(false),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                                    enabled: false,
                                    initialValue: widget.puppyDetails.color,
                                    textAlign: TextAlign.start,
                                    style: style,
                                    onChanged: (String value) {
                                      widget.puppyDetails.color = value;
                                    },
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Color',
                                        labelStyle: labelStyle(false),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                                    initialValue: widget.puppyDetails.puppyWeight,
                                    enabled: false,
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    onChanged: (String value) {
                                      widget.puppyDetails.puppyWeight = value;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Weight',
                                        labelStyle: labelStyle(false),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                                    initialValue: widget.puppyDetails.puppyDadWeight,
                                    enabled: false,
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    onChanged: (String value) {
                                      widget.puppyDetails.puppyDadWeight = value;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: "Dad's Weight",
                                        labelStyle: labelStyle(false),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                                    initialValue: widget.puppyDetails.puppyMomWeight,
                                    enabled: false,
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    onChanged: (String value) {
                                      widget.puppyDetails.puppyMomWeight = value;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: "Mom's Weight",
                                        labelStyle: labelStyle(false),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                              enabled: widget.reason==Constants.PRICE_CHANGE,
                              keyboardType: TextInputType.number,
                              initialValue: widget.puppyDetails.puppyPrice,
                              onChanged: (String value) {
                                widget.puppyDetails.puppyPrice = value;
                              },
                              style: style,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Asking Price',
                                  labelStyle: labelStyle(widget.reason==Constants.PRICE_CHANGE),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                              enabled: widget.reason==Constants.PRICE_CHANGE,
                              keyboardType: TextInputType.number,
                              initialValue: widget.puppyDetails.shippingCost,
                              onChanged: (String value) {
                                widget.puppyDetails.shippingCost = value;
                              },
                              style: style,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Shipping Cost',
                                  labelStyle: labelStyle(widget.reason==Constants.PRICE_CHANGE),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                              enabled: false,
                              initialValue: widget.puppyDetails.registry,
                              onChanged: (String value) {
                                widget.puppyDetails.registry = value;
                              },
                              style: style,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Registry',
                                  labelStyle: labelStyle(false),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  )
                              ),
                            ),
                          ),
                        ),


                        widget.puppyDetails.statusString==Constants.SOLD_BY_OBP && widget.reason==Constants.PREFLIGHT_HELTH_CERT?
                        Column(
                          children: <Widget>[
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
                                  initialValue: widget.puppyDetails.vetName,
                                  textAlign: TextAlign.start,
                                  onChanged: (String value) {
                                    widget.puppyDetails.vetName = value;
                                  },
                                  style: style,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(20),
                                      labelText: 'Vet Name',
                                      labelStyle: labelStyle(true),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                        borderRadius: BorderRadius.circular(borderRadius),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                        borderRadius: BorderRadius.circular(borderRadius),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                                  enabled: true,
                                  initialValue: widget.puppyDetails.vetAddress,
                                  textAlign: TextAlign.start,
                                  onChanged: (String value) {
                                    widget.puppyDetails.vetAddress = value;
                                  },
                                  style: style,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(20),
                                      labelText: 'Vet Address',
                                      labelStyle: labelStyle(true),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: obpBlueColor, width: 3.0),
                                        borderRadius: BorderRadius.circular(borderRadius),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: obpBlueColor, width: 2.0),
                                        borderRadius: BorderRadius.circular(borderRadius),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: obpBlueColor, width: 2.0),
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
                                }
                               ,
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
                                      labelStyle: labelStyle(true),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width: 2.0, color: obpBlueColor)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[

                                        Text(
                                          "${dateOfCheckupString}",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontFamily: "Lato",
                                              fontSize: 14,
                                              color: obpBlueColor),
                                        ),
                                        Padding(
                                            padding:
                                            const EdgeInsets.fromLTRB(
                                                00, 0, 0, 0),
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              child: Icon(Icons.calendar_today, color: obpBlueColor),
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
                                      labelStyle: labelStyle(true),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width:2.0, color:  obpBlueColor)),
                                    ),
                                    child: Container(

                                      child: _vetReportPath!=null && _vetReportPath.trim()!=""
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
                                                      Toast.show("Vet report removed", context,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
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
                                                        try{
                                                        showDialog(context: context,child:  BackdropFilter(
                                                          filter: ImageFilter.blur(sigmaX:2.0,sigmaY:2.0),
                                                          child: SpinKitRing(
                                                            lineWidth: 2,
                                                            color: obpBlueColor,
                                                            size: 50,
                                                          ),
                                                        ),
                                                        );

                                                        if(_vetReportPath == widget.puppyDetails.vetReport){
                                                          var data = await http.get(_vetReportPath);
                                                          var bytes = data.bodyBytes;
                                                          var dir = await getApplicationDocumentsDirectory();
                                                          var ext = _vetReportPath.substring(_vetReportPath.lastIndexOf(".")+1);
                                                          if(ext!=null && ext != "")
                                                            ext = "."+ext;
                                                          else
                                                            ext="";
                                                          File file  = File("${dir.path}/vetReport"+ext);
                                                          File assetFile = await file.writeAsBytes(bytes);
                                                          Navigator.of(context).pop();
                                                          await OpenFile.open("${dir.path}/vetReport"+ext);
                                                        } else{
                                                          Navigator.of(context).pop();
                                                          await OpenFile.open(_vetReportPath);
                                                        }

                                                      }catch(exception){
                                                        Navigator.of(context).pop();
                                                        Toast.show("Error while fetching vet report", context,duration:Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
                                                      }
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
                                                child: Text("Upload", style:labelStyle(true)),
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(24.0),
                                                child:Padding(
                                                  padding: const EdgeInsets.fromLTRB(0,0,12 ,0),
                                                  child: Icon(Icons.file_upload, color: obpBlueColor,),
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
                                      labelStyle: labelStyle(true),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderRadius:  new BorderRadius.circular(30), borderSide: BorderSide(width:2.0, color: obpBlueColor)),
                                    ),
                                    child: Container(

                                      child: _flightTicketPath!=null && _flightTicketPath.trim()!=""
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
                                                      Toast.show("Flight Ticket selection cancelled", context,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
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
                                                        try{
                                                          showDialog(context: context,child:  BackdropFilter(
                                                            filter: ImageFilter.blur(sigmaX:2.0,sigmaY:2.0),
                                                            child: SpinKitRing(
                                                              lineWidth: 2,
                                                              color: obpBlueColor,
                                                              size: 50,
                                                            ),
                                                          ),
                                                          );

                                                          if(_flightTicketPath == widget.puppyDetails.flightTicket){
                                                            var data = await http.get(_flightTicketPath);
                                                            var bytes = data.bodyBytes;
                                                            var dir = await getApplicationDocumentsDirectory();
                                                            var ext = _flightTicketPath.substring(_flightTicketPath.lastIndexOf(".")+1);
                                                            if(ext!=null && ext != "")
                                                              ext = "."+ext;
                                                            else
                                                              ext="";
                                                            File file  = File("${dir.path}/flight"+ext);
                                                            File assetFile = await file.writeAsBytes(bytes);
                                                            Navigator.of(context).pop();
                                                            await OpenFile.open("${dir.path}/flight"+ext);
                                                          } else{
                                                            Navigator.of(context).pop();
                                                            await OpenFile.open(_flightTicketPath);
                                                          }
                                                        }catch(exception){
                                                          Navigator.of(context).pop();
                                                          Toast.show("Error while fetching flight ticket", context,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19),duration:Toast.LENGTH_LONG);
                                                        }


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
                                          child:  Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(16,0,0,0),
                                                child: Text("Upload ..", style:labelStyle(true)),
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(24.0),
                                                child:Padding(
                                                  padding: const EdgeInsets.fromLTRB(0,0,12 ,0),
                                                  child: Icon(Icons.file_upload, color: obpBlueColor,),
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
                          ],
                        ):Container(),



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
                                    title: Text('Champion Bloodline', style: TextStyle(fontSize: 13,  color:  isChampionBloodline?obpBlueColor : Color(0xffA9A9A9)),),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isChampionBloodline,
                                        onChanged:isBadgeEditAllowed ?(bool value) {
                                          setState(() {
                                            isChampionBloodline = value;
                                          }
                                          );
                                        }:null,
                                      ),
                                    ),
                                    onTap: isBadgeEditAllowed ? () {
                                      setState(() {
                                        isChampionBloodline = !isChampionBloodline;
                                      });
                                    }: null,
                                  ),
                                ),
                                MergeSemantics(
                                  child: ListTile(
                                    dense: true,
                                    title: Text('Family Raised', style: TextStyle(fontSize: 13,  color:  isFamilyRaised?obpBlueColor : Color(0xffA9A9A9)),),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isFamilyRaised,
                                        onChanged:isBadgeEditAllowed ? (bool value) {
                                          setState(() {
                                            isFamilyRaised = value;
                                          }
                                          );
                                        }: null,
                                      ),
                                    ),
                                    onTap: isBadgeEditAllowed? () {
                                      setState(() {
                                        isFamilyRaised = !isFamilyRaised;
                                      });
                                    }:null,
                                  ),
                                ),
                                MergeSemantics(
                                  child: ListTile(
                                    dense: true,
                                    title: Text('Kid Friendly', style: TextStyle(fontSize: 13,  color:  isKidFriendly?obpBlueColor : Color(0xffA9A9A9)),),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isKidFriendly,
                                        onChanged:isBadgeEditAllowed ? (bool value) {
                                          setState(() {
                                            isKidFriendly = value;
                                          }
                                          );
                                        }: null,
                                      ),
                                    ),
                                    onTap: isBadgeEditAllowed?() {
                                      setState(() {
                                        isKidFriendly = !isKidFriendly;
                                      });
                                    }:null,
                                  ),
                                ),
                                MergeSemantics(
                                  child: ListTile(
                                    dense: true,
                                    title: Text('Microchipped', style: TextStyle(fontSize: 13,  color:  isMicrochipped?obpBlueColor : Color(0xffA9A9A9)),),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isMicrochipped,
                                        onChanged: isBadgeEditAllowed ? (bool value) {
                                          setState(() {
                                            isMicrochipped = value;
                                          }
                                          );
                                        }: null,
                                      ),
                                    ),
                                    onTap: isBadgeEditAllowed? () {
                                      setState(() {
                                        isMicrochipped = !isMicrochipped;
                                      });
                                    }:null,
                                  ),
                                ),
                                MergeSemantics(
                                  child: ListTile(
                                    dense: true,
                                    title: Text('Socialized', style: TextStyle(fontSize: 13,  color:  isSocialized?obpBlueColor : Color(0xffA9A9A9)),),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isSocialized,
                                        onChanged: isBadgeEditAllowed ? (bool value) {
                                          setState(() {
                                            isSocialized = value;
                                          }
                                          );
                                        }: null,
                                      ),
                                    ),
                                    onTap:isBadgeEditAllowed? () {
                                      setState(() {
                                        isSocialized = !isSocialized;
                                      });
                                    }:null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),
                        Center(
                          child: FlatButton.icon(
                            color: obpBlueColor,
                            icon: Icon(Icons.save, color:Colors.white, size: 20,),
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.only(
                                  bottomLeft: Radius.circular(40.0),
                                  topRight: Radius.circular(40.0),
                                  topLeft: Radius.circular(40.0),
                                  bottomRight: Radius.circular(40.0),
                                ),
                                side: BorderSide(
                                  color: Colors.white,
                                )),
                            padding:
                                EdgeInsets.fromLTRB(120.0, 16.0, 120.0, 16.0),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              onSave(context);
                            },
                            label: Text(
                              "Save",
                              textAlign: TextAlign.center,
                              style: style.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14),
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

  void onSave(BuildContext context) async{
    setState(() {
      _isLoading = true;
    });
    List<MultipartFile> multipart = List<MultipartFile>();
    for (int i = 0; i < imageAssets.length; i++) {
      var path = await FlutterAbsolutePath.getAbsolutePath(imageAssets[i].identifier);
      final mimeTypeData = lookupMimeType(path, headerBytes: [0xFF, 0xD8]).split('/');
      ByteData byteData = await imageAssets[i].getByteData(quality: 60);
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
    Toast.show("New Images "+multipart.length.toString() + ", Deleted: " +deletedImagesIdList.length.toString(), context,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19), duration: Toast.LENGTH_LONG);

    var dio = Dio();
    FormData formData;
    if(widget.puppyDetails.isSoldByObp()){
      formData = new FormData.fromMap({
        "puppy-name": Utility.capitalize(widget.puppyDetails.puppyName.trim()),
        "puppy_id": widget.puppyDetails.puppyId,
        "description": Utility.capitalize(widget.puppyDetails.description.trim()),
        "categories": _selectedBreedId,
        "user_id": userId,
        "selling-price": widget.puppyDetails.puppyPrice.trim(),
        "shipping-cost": widget.puppyDetails.shippingCost.trim(),
        "date-of-birth": dateOfBirth.millisecondsSinceEpoch.toString(),
        "date-available-new": dateOfBirthString,
        "age-in-week": calculateAgeInWeeks(),
        "color": Utility.capitalize(widget.puppyDetails.color.trim()),
        "puppy-weight": widget.puppyDetails.puppyWeight.trim(),
        "dad-weight": widget.puppyDetails.puppyDadWeight.trim(),
        "mom-weight": widget.puppyDetails.puppyMomWeight.trim(),
        "registry": widget.puppyDetails.registry.trim(),
        "vet-name": widget.puppyDetails.vetName.trim(),
        "vet-address": widget.puppyDetails.vetAddress.trim(),
        "checkup-date": dateOfCheckup.millisecondsSinceEpoch.toString(),
        "kid-friendly": isKidFriendly?"1":"0",
        "socialized": isSocialized?"1":"0",
        "family-raised":isFamilyRaised?"1":"0",
        "champion-bloodlines": isChampionBloodline?"1":"0",
        "microchipped": isMicrochipped?"1":"0",
        "gender": isFemale?"Female":"Male",
        "gallery_images": [multipart],
        "deleted_imgs_ids": deletedImagesIdList,
        "report-copy" :_vetReportPath!=null && _vetReportPath.trim()!=""
            ? _vetReportPath == widget.puppyDetails.vetReport
            ? widget.puppyDetails.vetReport
            : vetReport
            : "",
        "flight-doc" : _flightTicketPath!=null && _flightTicketPath.trim()!=""
            ? _flightTicketPath == widget.puppyDetails.flightTicket
            ? widget.puppyDetails.flightTicket
            : flightTicketFile
            : "",
      });
    } else{
      formData = new FormData.fromMap({
        "puppy-name": Utility.capitalize(widget.puppyDetails.puppyName.trim()),
        "puppy_id": widget.puppyDetails.puppyId,
        "description": Utility.capitalize(widget.puppyDetails.description.trim()),
        "categories": _selectedBreedId,
        "user_id": userId,
        "selling-price": widget.puppyDetails.puppyPrice.trim(),
        "shipping-cost": widget.puppyDetails.shippingCost.trim(),
        "date-of-birth": dateOfBirth.millisecondsSinceEpoch.toString(),
        "date-available-new": dateOfBirthString,
        "age-in-week": calculateAgeInWeeks(),
        "color": Utility.capitalize(widget.puppyDetails.color.trim()),
        "puppy-weight": widget.puppyDetails.puppyWeight.trim(),
        "dad-weight": widget.puppyDetails.puppyDadWeight.trim(),
        "mom-weight": widget.puppyDetails.puppyMomWeight.trim(),
        "registry": widget.puppyDetails.registry.trim(),
        "kid-friendly": isKidFriendly?"1":"0",
        "socialized": isSocialized?"1":"0",
        "family-raised":isFamilyRaised?"1":"0",
        "champion-bloodlines": isChampionBloodline?"1":"0",
        "microchipped": isMicrochipped?"1":"0",
        "gender": isFemale?"Female":"Male",
        "gallery_images": [multipart],
        "deleted_imgs_ids": deletedImagesIdList,
      });
    }

    try{
      dynamic response = await dio.post("https://onebarkplaza.com/wp-json/obp/v1/update_puppy",data:formData);
      if (response.statusCode == 200) {
        dynamic responseList = jsonDecode(response.toString());
        if (responseList["success"] == "Puppy successfully updated!") {
          Toast.show("Edit request successful" , context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
        }else{
          Toast.show("Edit Puppy Failed "+response.toString(), context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
        }

      } else {
        Toast.show("Edit Puppy Failed "+response.toString(), context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
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
  calculateAgeInWeeks() {
    return ((DateTime.now().difference(dateOfBirth).inDays)/7).round();
  }
  double calculateGridHeight() {
    double numRowsReq =
        imageAssets.length == 1 ? 1 : ((imageAssets.length - 1) / imagesInGridRow) + 1;
    return thumbnailSize * numRowsReq.toInt() + 16.0;
  }

  Future<Null> _selectDateOfBirth(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: dateOfBirth,
        firstDate: DateTime(dateOfBirth.year),
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


  Future<Null> _selectDateOfCheckup(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: dateOfCheckup,
        firstDate: DateTime(dateOfBirth.year),
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
      isFemale = !isFemale;
    });
  }

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
            filename: 'vet_report.' +  _vetReportPath.substring(_vetReportPath.lastIndexOf(".")+1),
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



}


class ImageWithId{
  Image _photo;

  Image get photo => _photo;

  set photo(Image value) {
    _photo = value;
  }

  String _photoId;

  ImageWithId.name(this._photoId, this._photo);

  String get photoId => _photoId;

  set photoId(String value) {
    _photoId = value;
  }

}