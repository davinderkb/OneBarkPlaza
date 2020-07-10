import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:one_bark_plaza/edit_puppy.dart';
import 'package:one_bark_plaza/puppy_details.dart';

final obpBlueColor = Color(0XFF3DB6C6);
final NO_SELECT = '-- Not Selected --';
final PRICE_CHANGE = 'Price Change';
final SOLD_BY_BREEDER = 'Sold By Breeder';
final DATE_CORRECTION = 'Date correction';
final PHOTO_CHANGE = 'Photo Update/Change';
final PREFLIGHT_HELTH_CERT = 'Preflight Health Cert';
final OTHER = 'Other';
class EditPuppyReason extends StatefulWidget{
  PuppyDetails data;
  EditPuppyReason(PuppyDetails data){
    this.data = data;
  }

  @override
  EditPuppyReasonState createState() {
      return EditPuppyReasonState();
  }

}

class EditPuppyReasonState extends State<EditPuppyReason> {
 String reason;
  List<String> reasonsList = [
    NO_SELECT,
    PRICE_CHANGE,
    SOLD_BY_BREEDER,
    DATE_CORRECTION,
    PHOTO_CHANGE,
    PREFLIGHT_HELTH_CERT,
    OTHER
  ];
  EditPuppyReasonState() {
    reason = NO_SELECT;
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
    ),
    elevation: 0.0,
    backgroundColor: Colors.transparent,
    child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(

        padding: EdgeInsets.only(
          top: Consts.padding ,
          bottom: Consts.padding,
          left: Consts.padding,
          right: Consts.padding,
        ),
        margin: EdgeInsets.only(top: Consts.padding),
        decoration: new BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(Consts.padding),

        ),
        child: Column(
          mainAxisSize: MainAxisSize.max, // To make the card compact
          children: <Widget>[

            Container(


              padding: const EdgeInsets.fromLTRB(8,8,8,8,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(12.0)),
                color: Color(0xffFEF8F5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 1.0,
                  ),
                ],
              ),
              child:  new Column(
                children: <Widget>[
                  new SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: new Text(
                      "Reason for edit",
                      style: new TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: obpBlueColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  Container(height: 0.5, color:Color(0xff3db6c6)),
                  new SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: DropdownButton<String>(
                      elevation: 2,
                       isExpanded: true,

                      iconEnabledColor:  Color(0xff3db6c6),
                      value: reason,
                      onChanged: (String newValue) {
                        setState(() {
                          reason = newValue;
                        });
                      },
                      items: reasonsList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child:  Padding(
                            padding: const EdgeInsets.fromLTRB(8,0,0,0),
                            child: Text(value, style: const TextStyle(fontFamily: "Lato", fontSize: 14, color: Colors.black87,fontWeight: FontWeight.bold)),
                          ),
                        );
                      })
                          .toList(),
                    ),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    height: 42,
                    width: _width / 2.5,
                    child: FlatButton(
                      child: Text(
                        'Proceed',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      onPressed: reason == NO_SELECT?
                      null : () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditPuppy(widget.data)));
                      },
                      disabledColor: Color(0xffd3d3d3),
                      color: obpBlueColor,
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
                ],
              ),
            ),


            SizedBox(height: 12.0),

          ],
        ),
      ),
    );
  }
}
class Consts {
  Consts._();

  static const double padding = 0.0;
}