import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'choose_breed_dialog.dart';
import 'img.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';

final greenColor = Color(0xff7FA432);
final blueColor = Color(0xff4C8BF5);

class EditPuppy extends StatefulWidget {
  EditPuppyState editPuppyState;

  PuppyDetails puppyDetails;
  EditPuppy(PuppyDetails puppyDetails) {
    this.puppyDetails = new PuppyDetails(
        puppyDetails.puppyId,
        puppyDetails.puppyName,
        puppyDetails.puppyPrice,
        puppyDetails.shippingCost,
        puppyDetails.description,
        puppyDetails.image,
        puppyDetails.gallery,
        puppyDetails.gender,
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
        puppyDetails.vetReport,
        puppyDetails.flightTicket,
        puppyDetails.isChampionBloodline,
        puppyDetails.isFamilyRaised,
        puppyDetails.isKidFriendly,
        puppyDetails.isMicrochipped,
        puppyDetails.isSocialized
    );
  }
  @override
  EditPuppyState createState() {
    return editPuppyState = new EditPuppyState();
  }
}

class EditPuppyState extends State<EditPuppy> {
  DateTime dateOfBirth = DateTime.now();
  String dateOfBirthString = '';
  String _chooseBreed = '';
  bool _isBreedSelectedOnce = false;
  List<Asset> imageAssets = List<Asset>();
  Future<List<Image>> futureAllImages ;
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

  List<Image> allImages = new List<Image>();
  List<Image> oldImages;

  bool isFirstTime = true;

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

   Future<List<Image>> addNewImages() async {
    List<Image> newImages = new List<Image>();
    for(Asset item in imageAssets){
        ByteData byteData = await item.getByteData();
        List<int> imageData = byteData.buffer.asUint8List();
        newImages.add(Image.memory(imageData));
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => isFirstTime = false);

  }
  Future<List<Image>>getImages() async {

    oldImages = new List<Image>();
    for(ImageCustom galleryItem in widget.puppyDetails.gallery){
      var data = await http.get(galleryItem.src);
      var bytes = data.bodyBytes;
      oldImages.add(Image.memory(bytes, fit: BoxFit.cover));
    }
    return oldImages;
  }

  Future<List<Image>>syncNewImages() async {
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
        maxImages: maxImageNo - widget.puppyDetails.imageCount() > 0 ? 6 - widget.puppyDetails.imageCount(): 0,
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
        fontFamily: 'NunitoSans', fontSize: 14.0, color: Color(0xff707070));
    TextStyle hintStyle =
        TextStyle(fontFamily: 'NunitoSans', fontSize: 14.0, color: hintColor);
    TextStyle labelStyle = TextStyle(
      fontFamily: 'NunitoSans',
      color: greenColor,
      fontSize: 12,
    );
    var maleColor = Color(0xff5cbaed);
    var femaleColor = Color(0xfff25fa3);
    return Scaffold(
        key: globalKey,
        backgroundColor: Colors.transparent,
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: greenColor),
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

                        SizedBox(height: 24),
                        Center(
                          child: Container(
                            height: _width -120,
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
                                        color: greenColor,
                                        size: 50.0,
                                      ),
                                    );
                                    break;
                                  case ConnectionState.done:
                                    if (snapshot.hasError) {
                                      // return whatever you'd do for this case, probably an error

                                    }
                                    var data = snapshot.data as List<Image>;
                                    return new ListView.builder(
                                      reverse: false,
                                      scrollDirection: Axis.horizontal,
                                      itemCount:  data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) => Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                                            child: data[index],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                Positioned(
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
                                                )
                                              ],
                                            ),
                                          ),
                                    );
                                    break;
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 14),  /*maxImageNo - (widget.puppyDetails.gallery.length+imageAssets.length) > 0 ?*/
                        Center(
                          child: new RaisedButton.icon(
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  side: BorderSide(color: greenColor, width: 2.0)
                              ),
                              onPressed: loadAssets,
                              color: Color(0xffffffff),
                              icon: new Icon(Icons.image, color:greenColor, size:16),
                              label: new Text("Add Images", style: TextStyle(color:greenColor,fontFamily:"NunitoSans", fontWeight: FontWeight.bold, fontSize: 13),)),
                        ),
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
                              initialValue: widget.puppyDetails.puppyName,
                              textAlign: TextAlign.start,
                              style: style,
                              onChanged: (String value) {
                                widget.puppyDetails.puppyName = value;
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Puppy Name',
                                  labelStyle: labelStyle,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 3.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: InkWell(
                            onTap: () {
                              chooseBreedDialog != null &&
                                      chooseBreedDialog
                                              .allDuplicateItems.length !=
                                          0
                                  ? showDialog(
                                      context: context,
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 2.0, sigmaY: 2.0),
                                        child: chooseBreedDialog,
                                      ),
                                    )
                                  : showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 2.0, sigmaY: 2.0),
                                        // child: chooseBreedDialog = ChooseBreedDialog(widget.editPuppyState),
                                      ),
                                    );
                            },
                            child: Container(
                              width: _width,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: new BorderRadius.circular(30),
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
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          width: 2.0, color: greenColor)),
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
                                        padding: const EdgeInsets.fromLTRB(
                                            00, 0, 20, 0),
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: _isBreedSelectedOnce
                                              ? Icon(Icons.check,
                                                  color: Colors.green)
                                              : Icon(Icons.format_list_bulleted,
                                                  color: greenColor),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: InkWell(
                            onTap: () {
                              _selectDateOfBirth(context);
                            },
                            child: Container(
                              width: _width,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: new BorderRadius.circular(30),
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
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          width: 2.0, color: greenColor)),
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
                                        padding: const EdgeInsets.fromLTRB(
                                            00, 0, 20, 0),
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: Icon(Icons.calendar_today,
                                              color: greenColor),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: (_width - 44) / 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  child: RaisedButton.icon(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0),
                                      ),
                                      onPressed: isFemale ? toggleState : null,
                                      color: Color(0xffEBEBE4),
                                      disabledColor: maleColor,
                                      disabledElevation: 3.0,
                                      elevation: 0,
                                      icon: !isFemale
                                          ? Icon(Icons.check_box,
                                              color: Colors.white, size: 14)
                                          : Icon(null, size: 0),
                                      label: new Text(
                                        "Male",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "NunitoSans",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      )),
                                ),
                                Container(
                                  width: (_width - 44) / 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  child: RaisedButton.icon(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0),
                                      ),
                                      onPressed: !isFemale ? toggleState : null,
                                      color: Color(0xffEBEBE4),
                                      disabledColor: femaleColor,
                                      disabledElevation: 3.0,
                                      elevation: 0,
                                      icon: isFemale
                                          ? Icon(Icons.check_box,
                                              color: Colors.white, size: 14)
                                          : Icon(null, size: 0),
                                      label: new Text(
                                        "Female",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "NunitoSans",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Container(
                            width: _width,
                            height: 80,
                            decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius:
                                    new BorderRadius.circular(borderRadius)),
                            child: TextFormField(
                              initialValue: widget.puppyDetails.description,
                              onChanged: (String value) {
                                widget.puppyDetails.description = value;
                              },
                              textAlign: TextAlign.start,
                              style: style,
                              maxLines: 4,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Description',
                                  labelStyle: labelStyle,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 3.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: (_width - 44) / 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius: new BorderRadius.circular(
                                          borderRadius)),
                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    initialValue: widget.puppyDetails.color,
                                    onChanged: (String value) {
                                      widget.puppyDetails.color = value;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Color',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        )),
                                  ),
                                ),
                                Container(
                                  width: (_width - 44) / 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius: new BorderRadius.circular(
                                          borderRadius)),
                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    initialValue: widget.puppyDetails.puppyWeight,
                                    onChanged: (String value) {
                                      widget.puppyDetails.puppyWeight = value;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: 'Weight',
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: (_width - 44) / 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius: new BorderRadius.circular(
                                          borderRadius)),
                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    initialValue: widget.puppyDetails.puppyDadWeight,
                                    onChanged: (String value) {
                                      widget.puppyDetails.puppyDadWeight = value;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: "Dad's Weight",
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        )),
                                  ),
                                ),
                                Container(
                                  width: (_width - 44) / 2,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius: new BorderRadius.circular(
                                          borderRadius)),
                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    initialValue: widget.puppyDetails.puppyMomWeight,
                                    onChanged: (String value) {
                                      widget.puppyDetails.puppyMomWeight = value;
                                    },
                                    style: style,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        labelText: "Mom's Weight",
                                        labelStyle: labelStyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 3.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: greenColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Container(
                            width: _width,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius:
                                    new BorderRadius.circular(borderRadius)),
                            child: TextFormField(
                              textAlign: TextAlign.start,
                              initialValue: widget.puppyDetails.puppyPrice,
                              onChanged: (String value) {
                                widget.puppyDetails.puppyPrice = value;
                              },
                              style: style,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Asking Price',
                                  labelStyle: labelStyle,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 3.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Container(
                            width: _width,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius:
                                    new BorderRadius.circular(borderRadius)),
                            child: TextFormField(
                              textAlign: TextAlign.start,
                              initialValue: widget.puppyDetails.shippingCost,
                              onChanged: (String value) {
                                widget.puppyDetails.shippingCost = value;
                              },
                              style: style,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Shipping Cost',
                                  labelStyle: labelStyle,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 3.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Container(
                            width: _width,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius:
                                    new BorderRadius.circular(borderRadius)),
                            child: TextFormField(
                              textAlign: TextAlign.start,
                              initialValue: "TO-DO",
                              onChanged: (String value) {
                                //widget.puppyDetails.description = value;
                              },
                              style: style,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Vet Name',
                                  labelStyle: labelStyle,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 3.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Container(
                            width: _width,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius:
                                    new BorderRadius.circular(borderRadius)),
                            child: TextFormField(
                              textAlign: TextAlign.start,
                              initialValue: "TO-DO",
                              onChanged: (String value) {
                                //widget.puppyDetails.description = value;
                              },                              style: style,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  labelText: 'Vet Address',
                                  labelStyle: labelStyle,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 3.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greenColor, width: 2.0),
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Container(
                            width: _width,
                            decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius:
                                    new BorderRadius.circular(borderRadius)),
                            child: Column(
                              children: <Widget>[
                                MergeSemantics(
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      'Champion Bloodline',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isChampionBloodline
                                              ? greenColor
                                              : Color(0xffA9A9A9)),
                                    ),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isChampionBloodline,
                                        onChanged: (bool value) {
                                          setState(() {
                                            isChampionBloodline = value;
                                          });
                                        },
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        isChampionBloodline =
                                            !isChampionBloodline;
                                      });
                                    },
                                  ),
                                ),
                                MergeSemantics(
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      'Family Raised',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isFamilyRaised
                                              ? greenColor
                                              : Color(0xffA9A9A9)),
                                    ),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isFamilyRaised,
                                        onChanged: (bool value) {
                                          setState(() {
                                            isFamilyRaised = value;
                                          });
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
                                    title: Text(
                                      'Kid Friendly',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isKidFriendly
                                              ? greenColor
                                              : Color(0xffA9A9A9)),
                                    ),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isKidFriendly,
                                        onChanged: (bool value) {
                                          setState(() {
                                            isKidFriendly = value;
                                          });
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
                                    title: Text(
                                      'Microchipped',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isMicrochipped
                                              ? greenColor
                                              : Color(0xffA9A9A9)),
                                    ),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isMicrochipped,
                                        onChanged: (bool value) {
                                          setState(() {
                                            isMicrochipped = value;
                                          });
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
                                    title: Text(
                                      'Socialized',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isSocialized
                                              ? greenColor
                                              : Color(0xffA9A9A9)),
                                    ),
                                    trailing: Transform.scale(
                                      scale: 0.75,
                                      child: CupertinoSwitch(
                                        value: isSocialized,
                                        onChanged: (bool value) {
                                          setState(() {
                                            isSocialized = value;
                                          });
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
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: FlatButton.icon(
                            color: maleColor,
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
                                EdgeInsets.fromLTRB(120.0, 24.0, 120.0, 24.0),
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

  void onSave(BuildContext context) {
    Toast.show("Save, to-do", context);
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
        lastDate: new DateTime.now().add(new Duration(days: 365)),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: Theme.of(context).copyWith(
              primaryColor: Colors.amber, //Head background
              accentColor: Colors.amber, //color you want at header
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch(
                    accentColor: Colors.amber, primarySwatch: Colors.amber),
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
      isFemale = !isFemale;
    });
  }


}
