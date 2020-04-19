import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dynamic_widget/dynamic_widget/basic/container_widget_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:one_bark_plaza/edit_puppy.dart';
import 'package:one_bark_plaza/img.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:open_file/open_file.dart';
import 'package:toast/toast.dart';
import 'package:one_bark_plaza/util/utility.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


import 'homepage.dart';
final greenColor = Color(0xff7FA432);
final blueColor = Color(0xff4C8BF5);
final lightPinkBackground = Color(0xffFEF8F5);
class ViewPuppy extends StatefulWidget {
  ViewPuppyState viewPuppyState;
  PuppyDetails puppyDetails;
  bool isRefreshPop;
  List<String> puppyBadges = new List<String>();
  ViewPuppy(PuppyDetails puppyDetails, isRefreshPop){
    this.puppyDetails = puppyDetails;
    this.isRefreshPop = isRefreshPop;
    puppyBadges.clear();
    if(puppyDetails!=null)
      initBadges(puppyDetails);
  }

  void initBadges(PuppyDetails puppyDetails) {
     if(puppyDetails.isChampionBloodline){
        puppyBadges.add("Champion Bloodline");
    }
    if(puppyDetails.isFamilyRaised){
      puppyBadges.add("Family Raised");
    }
    if(puppyDetails.isKidFriendly){
      puppyBadges.add("Kid Friendly");
    }
    if(puppyDetails.isMicrochipped){
      puppyBadges.add("Microchipped");
    }
    if(puppyDetails.isSocialized){
      puppyBadges.add("Socialized");
    }
  }
  @override
  ViewPuppyState createState() {
    return viewPuppyState = new ViewPuppyState();
  }
}

class ViewPuppyState extends State<ViewPuppy> {

  BuildContext context;

  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    List<String> images = getPuppyImages();
    var tableHeaderTextStyle = TextStyle(color: Colors.grey, fontFamily: "NunitoSans", fontSize: 13);
    var tableContentTextStyle = TextStyle(color: Colors.grey, fontFamily: "NunitoSans", fontSize: 13, fontWeight: FontWeight.bold);
    return Scaffold(
        backgroundColor: lightPinkBackground,
        appBar: new AppBar(
          backgroundColor: lightPinkBackground,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: greenColor),
            onPressed: () {
              if(widget.isRefreshPop){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
              } else {
                Navigator.of(context).maybePop();
              }
            }
          ),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 60,
                ),
                //Icon(Icons.home, size: 40,color: blueColor,),
                SizedBox(
                  height: 42,
                  width: _width / 2.5,
                  child: FlatButton.icon(
                    label: Text(
                      'Edit',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontFamily:"NunitoSans",fontSize: 14, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditPuppy(widget.puppyDetails)));
                    },
                    icon: Icon(Icons.edit, color: Colors.white, size: 14,),
                    disabledColor: greenColor,
                    color: greenColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                          bottomLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                          topLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(40.0),
                        ),
                        side: BorderSide(
                          color: Colors.white,
                        )),
                  ),
                )
              ]),
          centerTitle: false,
          elevation: 0.0,

        ),
        body: SingleChildScrollView(
          child: Stack(
          overflow: Overflow.visible,
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
              color: lightPinkBackground,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(height:16),
                  images.length==0?Container():CarouselSlider(
                    height:_height>_width?_height/3: _width/2,
                    viewportFraction: 0.85,
                    items: images.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: Color(0xffFFF3E0),
                              borderRadius: BorderRadius.circular(45),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: Image.network(i, fit: BoxFit.cover,)
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height:30  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0,0,24,0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: <Widget>[
                            Container(
                              width:_width/2,
                              child: Text(
                                  widget.puppyDetails!=null?widget.puppyDetails.categoryName: "",
                                  maxLines: 2,

                                  style: TextStyle(
                                      fontFamily:
                                      'NunitoSans',
                                      fontSize:
                                      18,
                                      color:
                                      greenColor,
                                      fontWeight:
                                      FontWeight
                                          .normal)),
                            ),
                            Text(
                                "\$ "+getStringSafely(widget.puppyDetails.puppyPrice).toString(),
                                style: TextStyle(
                                    fontFamily:
                                    'NunitoSans',
                                    fontSize:
                                    18,
                                    color:
                                    greenColor,
                                    fontWeight:
                                    FontWeight
                                        .normal)),
                          ],
                        ),
                        Text(
                            Utility.capitalize(widget.puppyDetails.gender)+"  |  "+widget.puppyDetails.ageInWeeks + " weeks Old",
                            style: TextStyle(
                                fontFamily:
                                'NunitoSans',
                                fontSize:
                                14,
                                color:
                                Colors.grey,
                                fontWeight:
                                FontWeight
                                    .normal)),

                          SizedBox(height: 24,),
                          Container(height: (_width/2 -24)/5 * (widget.puppyBadges.length /2).round(), child: buildGridView()),

                          widget.puppyBadges.length>0?SizedBox(height: 20,):SizedBox(height: 0,),
                          Text(widget.puppyDetails.puppyName +" is an active, charming, confident, eager to please, easily trained, gentle, intelligent, lovable, loyal, patient, well mannered dog.", style: tableHeaderTextStyle,),
                          SizedBox(height: 20,),
                          Column(
                            children: <Widget>[
                              new Divider(height: 1.0, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Name", style: tableHeaderTextStyle,)
                                    ),
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text(widget.puppyDetails.puppyName, style: tableContentTextStyle,)
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(height: 1.0, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Date of Birth", style: tableHeaderTextStyle,)
                                    ),
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text(widget.puppyDetails.dobString == null ?"Not Available" :widget.puppyDetails.dobString , style: tableContentTextStyle,)
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(height: 1.0, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Color", style: tableHeaderTextStyle,)
                                    ),
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text(widget.puppyDetails.color, style: tableContentTextStyle,)
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(height: 1.0, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Weight", style: tableHeaderTextStyle,)
                                    ),
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text(widget.puppyDetails.puppyWeight+" Kg", style: tableContentTextStyle,)
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(height: 1.0, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Shipping Cost", style: tableHeaderTextStyle,)
                                    ),

                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,

                                        child: Text("\$ "+getStringSafely(widget.puppyDetails.shippingCost), style: tableContentTextStyle,)
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(height: 1.0, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Date of Availbility", style: tableHeaderTextStyle,)
                                    ),
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Apr 02, 2020", style: tableContentTextStyle,)
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(height: 1.0, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Mom's Weight", style: tableHeaderTextStyle,)
                                    ),
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text(widget.puppyDetails.puppyMomWeight+" Kg", style: tableContentTextStyle,)
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(height: 1.0, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text("Dad's Weight", style: tableHeaderTextStyle,)
                                    ),
                                    Container(
                                        width: _width/2 -32,
                                        alignment: Alignment.topLeft,
                                        child: Text(widget.puppyDetails.puppyDadWeight +" Kg", style: tableContentTextStyle,)
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(height: 1.0, color: Colors.grey),
                              SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () async {
                                        if(widget.puppyDetails.vetReport==null || widget.puppyDetails.vetReport.toString().trim() ==""){
                                            Toast.show("File is not available", context,duration:Toast.LENGTH_LONG);
                                        }else {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                            Dio dio = new Dio();
                                            var data = await http.get(widget.puppyDetails.vetReport);

                                            var bytes = data.bodyBytes;
                                            var dir = await getApplicationDocumentsDirectory();

                                            var ext = widget.puppyDetails.vetReport.substring(widget.puppyDetails.vetReport.lastIndexOf(".")+1);
                                            if(ext!=null && ext != "")
                                              ext = "."+ext;
                                            else
                                              ext="";
                                            File file  = File("${dir.path}/vetReport"+ext);
                                            File assetFile = await file.writeAsBytes(bytes);
                                            OpenFile.open("${dir.path}/vetReport"+ext);
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          //  await launch(widget.puppyDetails.vetReport);
                                        }
                                        },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: Color(0xffF69601),
                                          borderRadius: BorderRadius.circular(200),
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
                                        child: _isLoading? SpinKitRing(
                                          lineWidth: 3,
                                          color: Colors.white,
                                          size: 40,
                                        ):Text("Vet Check Report", textAlign: TextAlign.center, style: TextStyle(fontFamily: "NunitoSans", fontSize: 18, color:Colors.white),),
                                      ),
                                    ),

                                    InkWell(
                                      onTap: () async {
                                        if(widget.puppyDetails.flightTicket==null || widget.puppyDetails.flightTicket.toString().trim() ==""){
                                          Toast.show("Flight information not available", context,duration:Toast.LENGTH_LONG);
                                        }else {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          Dio dio = new Dio();
                                          var data = await http.get(widget.puppyDetails.flightTicket);

                                          var bytes = data.bodyBytes;
                                          var dir = await getApplicationDocumentsDirectory();

                                          var ext = widget.puppyDetails.flightTicket.substring(widget.puppyDetails.flightTicket.lastIndexOf(".")+1);
                                          if(ext!=null && ext != "")
                                            ext = "."+ext;
                                          else
                                            ext="";
                                          File file  = File("${dir.path}/flightTicket"+ext);
                                          File assetFile = await file.writeAsBytes(bytes);
                                          OpenFile.open("${dir.path}/flightTicket"+ext);
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          //  await launch(widget.puppyDetails.vetReport);
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: Color(0xffF69601),
                                          borderRadius: BorderRadius.circular(200),
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
                                        child: _isLoading? SpinKitRing(
                                          lineWidth: 3,
                                          color: Colors.white,
                                          size: 40,
                                        ):Text("Flight Information", textAlign: TextAlign.center, style: TextStyle(fontFamily: "NunitoSans", fontSize: 18, color:Colors.white),),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
          ));
  }

  void onFinishClick(BuildContext context) {
    Toast.show("Finish clicked. To-Do", context,
        textColor: Colors.white,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        backgroundColor: Color(0xffeb5050),
        backgroundRadius: 16);
  }


  List<String> getPuppyImages() {
    List<String> images = new List<String>();
    if(widget.puppyDetails.gallery!=null && widget.puppyDetails.gallery.length>0 )
      {
        for(ImageCustom image in widget.puppyDetails.gallery){
          String asset = image.src;
          images.add(asset);
        }
        return images;
      }
    else{
      return images;
    }
  }

  String getStringSafely(val) {
    try{
      return double.parse(val).toString();
    } catch (e){
      return "";
    }

  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 5,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 0.0,
      children: List.generate(widget.puppyBadges.length, (index) {
        String badge = widget.puppyBadges[index];
        return  Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            height: 20,
            child: Row(
              children: <Widget>[
                Image.asset("assets/images/ic_badge.png", height: 20,width: 20,),
                SizedBox(width: 5,),
                Text(badge, style: TextStyle(fontFamily: "NunitoSans", color: greenColor, fontSize: 13),),
              ],
            ),
          ),
        );
      }),
    );
  }

}





