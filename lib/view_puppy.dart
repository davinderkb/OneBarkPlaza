import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:one_bark_plaza/edit_puppy.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:toast/toast.dart';
import 'package:one_bark_plaza/util/utility.dart';
final greenColor = Color(0xff7FA432);
final blueColor = Color(0xff4C8BF5);
final lightPinkBackground = Color(0xffFEF8F5);
class ViewPuppy extends StatefulWidget {
  ViewPuppyState viewPuppyState;
  PuppyDetails puppyDetails;
  ViewPuppy(PuppyDetails puppyDetails){
    this.puppyDetails = puppyDetails;
  }
  @override
  ViewPuppyState createState() {
    return viewPuppyState = new ViewPuppyState();
  }
}

class ViewPuppyState extends State<ViewPuppy> {
  DateTime dateOfBirth = DateTime.now();
  String dateOfBirthString = 'Choose';
  BuildContext context;


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
            onPressed: () =>Navigator.of(context).maybePop(),
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
                  CarouselSlider(
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
                                child: Image.asset(i, fit: BoxFit.cover,)
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
                            Text(
                                widget.puppyDetails.categoryName,
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
                            Text(
                                "\$ "+double.parse(widget.puppyDetails.puppyPrice).toString(),
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
                          Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            width: _width/2 -24,
                                            child: Row(
                                              children: <Widget>[
                                                Image.asset("assets/images/ic_badge.png", height: 20,width: 20,),
                                                SizedBox(width: 5,),
                                                Text("Champion Bloodline", style: TextStyle(fontFamily: "NunitoSans", color: greenColor, fontSize: 13),),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: _width/2 - 24,
                                            child: Row(
                                              children: <Widget>[
                                                Image.asset("assets/images/ic_badge.png", height: 20,width: 20,),
                                                SizedBox(width: 5,),
                                                Text("Family Raised", style: TextStyle(fontFamily: "NunitoSans", color: greenColor, fontSize: 13),),
                                              ],
                                            ),
                                          )
                                        ],),
                          SizedBox(height: 12,),
                          Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: _width/2 -24,
                              child: Row(
                                children: <Widget>[
                                  Image.asset("assets/images/ic_badge.png", height: 20,width: 20,),
                                  SizedBox(width: 5,),
                                  Text("Socialized", style: TextStyle(fontFamily: "NunitoSans", color: greenColor, fontSize: 13),),
                                ],
                              ),
                            ),
                            Container(
                              width: _width/2 -24,
                              child: Row(
                                children: <Widget>[
                                  Image.asset("assets/images/ic_badge.png", height: 20,width: 20,),
                                  SizedBox(width: 5,),
                                  Text("Kid Friendly", style: TextStyle(fontFamily: "NunitoSans", color: greenColor, fontSize: 13),),
                                ],
                              ),
                            )
                          ],),
                          SizedBox(height: 20,),
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
                                        child: Text("Nov 01, 2019", style: tableContentTextStyle,)
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
                                        child: Text("\$ "+double.parse(widget.puppyDetails.shippingCost).toString(), style: tableContentTextStyle,)
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
                                      onTap: (){Toast.show("Download vet check report", context);},
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
                                        child: Text("Vet Check Report", textAlign: TextAlign.center, style: TextStyle(fontFamily: "NunitoSans", fontSize: 18, color:Colors.white),),
                                      ),
                                    ),

                                    InkWell(
                                      onTap: (){Toast.show("Download flight details", context);},
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
                                        child: Text("Flight Information", textAlign: TextAlign.center, style: TextStyle(fontFamily: "NunitoSans", fontSize: 18, color:Colors.white),),
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
    for(int i=1;i<=6;i++){
      String asset = "assets/images/bulldog"+i.toString()+".jpg";
      images.add(asset);
    }
    return images;
  }

}





