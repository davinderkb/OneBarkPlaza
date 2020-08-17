import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:one_bark_plaza/homepage.dart';
import 'package:one_bark_plaza/image_picker_handler.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:one_bark_plaza/util/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
final customColor = Color(0XFF3DB6C6);
var updateProfileUrl = 'https://onebarkplaza.com/wp-json/obp/v1/profile';

class UpdateProfile extends StatefulWidget {
  String profilePic, gender, name, firstName, lastName;
  UpdateProfile({Key key, this.profilePic,this.gender, this.name, this.firstName, this.lastName}) : super(key: key);

  @override
  UpdateProfileState createState() {
    return new UpdateProfileState();
  }
}

class UpdateProfileState extends State<UpdateProfile> with TickerProviderStateMixin,ImagePickerListener{
  var lastName="";
  var firstName="";
  File _image ;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  bool _isLoading = false;


  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }
  @override
  void initState() {
    super.initState();
     lastName = widget.lastName;
     firstName = widget.firstName;
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker=new ImagePickerHandler(this,_controller);
    imagePicker.init();
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final borderRadius = 12.0;
    final hintColor = Color(0xffA9A9A9);


    TextStyle style = TextStyle(fontFamily: 'Lato', fontSize: 14.0, color: Color(0xff707070));
    TextStyle labelStyle = TextStyle(fontFamily: 'Lato',  fontSize: 12, color: Color(0xff707070));

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: new AppBar(
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: customColor),
                onPressed: () {
                  if(isAnyFieldChanged()){
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: Text('Are you sure?'),
                          content: Text("\nAll unsaved changes would be lost. Do you want to exit this page?"),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text('No',style: TextStyle(color:customColor, fontWeight:FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text('Yes', style: TextStyle(color:customColor, fontWeight:FontWeight.bold)),
                              onPressed: (){
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else{
                    Navigator.of(context).pop();
                  }
                }
            ),
            title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Text(
                    "Edit Profile",
                    style: new TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customColor),
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
                color: customColor,
                size: 120,
              )):
          SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Container(
                  height: _height-100,
                  alignment: Alignment.center,
                  color: Color(0xffffffff),

                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            SizedBox(height: 8,),
                            Center(
                              child: Stack(
                                children: <Widget>[
                                  InkWell(
                                    onTap:(){
                                      imagePicker.showDialog(context);
                                    },
                                    child: Container(
                                        height: 180,
                                        width: 180,
                                        child: ClipRRect(
                                          borderRadius:BorderRadius.circular(300.0),
                                          child: _image != null?
                                          Image.file(_image):
                                          FadeInImage.assetNetwork(
                                              placeholder:widget.gender=="Female"
                                                  ? "assets/images/ic_profile_female.png"
                                                  : "assets/images/ic_profile_male.png",
                                              image:widget.profilePic,
                                              fit: BoxFit.cover),
                                        ),
                                        decoration: new BoxDecoration(
                                          color: Color(0xffFEF8F5),
                                          shape: BoxShape.circle,
                                          border:  Border.all(width: 3, color: customColor),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 2.0,
                                            ),
                                          ],
                                        )
                                    ),
                                  ),
                                  Positioned(
                                    width: 42,
                                    height: 42,
                                    bottom: 1,
                                    right: 1,
                                    child: InkWell(
                                        onTap:(){
                                          imagePicker.showDialog(context);
                                        },
                                      child: Container(
                                          height: 42,
                                          width: 42,
                                          child: Icon(Icons.edit, color: customColor,),
                                          decoration: new BoxDecoration(
                                            color: Color(0xffFEF8F5),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset: Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 48,),
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
                                  initialValue: firstName,
                                  onChanged: (String value) {
                                    firstName = value;
                                  },
                                  style: style,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(20),
                                      labelText: 'First Name',
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
                                  initialValue: lastName,
                                  onChanged: (String value) {
                                    lastName = value;
                                  },
                                  style: style,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(20),
                                      labelText: 'Last Name',
                                      labelStyle: labelStyle,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide( width: 1.0),
                                        borderRadius: BorderRadius.circular(borderRadius),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide( width: 1.0),
                                        borderRadius: BorderRadius.circular(borderRadius),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide( width: 1.0),
                                        borderRadius: BorderRadius.circular(borderRadius),
                                      )
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30,),
                            Center(
                              child:  Container(
                                width: _width-60,
                                child: CupertinoButton(
                                  color: customColor,
                                  disabledColor: Color(0xffD3D3D3),
                                  borderRadius: BorderRadius.circular(30),
                                  padding: EdgeInsets.fromLTRB(0.0, 24.0, 0.0,24.0),
                                  onPressed: isSaveEnable()?() {
                                    FocusScope.of(context).unfocus();
                                    onFinishClick(context);
                                  }:null,
                                  child: Text("Save",
                                    textAlign: TextAlign.center,
                                    style: style.copyWith(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 14),
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
              ))),
    );
  }

  void onFinishClick(BuildContext context) {
    saveProfile(context);
  }
  Future<void> saveProfile(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    MultipartFile multipartFile = null;
    if(_image!=null){
      final mimeTypeData = lookupMimeType(_image.path, headerBytes: [0xFF, 0xD8]).split('/');

      List<int> imageData = await _image.readAsBytes();
      multipartFile = MultipartFile.fromBytes(
        imageData,
        filename: 'image',
        contentType: MediaType("image", mimeTypeData[1]),
      );
    }



    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId =  prefs.getString(Constants.SHARED_PREF_USER_ID);

    var dio = Dio();

    FormData formData = _image!=null?
      new FormData.fromMap({
      "first_name": Utility.capitalize(firstName),
      "user_id": userId,
      "last_name": Utility.capitalize(lastName),
      "profile_image": multipartFile,
      }):
    new FormData.fromMap({
      "first_name": Utility.capitalize(firstName),
      "user_id": userId,
      "last_name": Utility.capitalize(lastName),
    })
    ;
    try{
      dynamic response = await dio.post(updateProfileUrl, data:formData);
      if (response.statusCode == 200) {
        dynamic responseList = jsonDecode(response.toString());
        prefs.setString(Constants.SHARED_PREF_PROFILE_IMAGE, responseList["success"]["profile_image"]);
        prefs.setString(Constants.SHARED_PREF_NAME, responseList["success"]["first_name"] +" "+ responseList["success"]["last_name"]);
        prefs.setString(Constants.SHARED_PREF_PROFILE_IMAGE, responseList["success"]["profile_image"]);
        prefs.setString(Constants.SHARED_PREF_USER_FIRST_NAME, responseList["success"]["first_name"]);
        Toast.show("Profile Updated Successfully" , context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      } else {
        Toast.show("Profile Updation Failed ", context,duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
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

  Future<bool> _onBackPressed() {
    if(isAnyFieldChanged()){
      return  showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Are you sure?'),
            content: Text("\nAll unsaved changes would be lost. Do you want to exit this page?"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('No', style: TextStyle(color:customColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text('Yes', style: TextStyle(color:customColor),),
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
   return _image != null ||
       lastName != widget.lastName||
       firstName != widget.firstName;
  }

  bool isSaveEnable() {
   if(lastName.trim()=="" || firstName.trim()=="")
     return false;

    return isAnyFieldChanged();
  }
}