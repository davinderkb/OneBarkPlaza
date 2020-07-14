
import 'package:dio/dio.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:one_bark_plaza/edit_puppy.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
class EditPuppyReason extends StatefulWidget{
  PuppyDetails data;
  List<String> reasonsList;
  EditPuppyReason(PuppyDetails data){
    this.data = data;
    reasonsList = data.isSoldByObp ?[
      Constants.NO_SELECT,
      Constants.PRICE_CHANGE,
      Constants.HEALTH_ISSUE,
      Constants.SOLD_BY_BREEDER,
      Constants.DATE_CORRECTION,
      Constants.PHOTO_CHANGE,
      Constants.PREFLIGHT_HELTH_CERT,
      Constants.OTHER
    ] :
    [
      Constants.NO_SELECT,
      Constants.PRICE_CHANGE,
      Constants.HEALTH_ISSUE,
      Constants.SOLD_BY_BREEDER,
      Constants.DATE_CORRECTION,
      Constants.PHOTO_CHANGE,
      Constants.OTHER
    ];
  }

  @override
  EditPuppyReasonState createState() {
      return EditPuppyReasonState();
  }

}

class EditPuppyReasonState extends State<EditPuppyReason> {
  bool _isLoading = false;
  bool _isReasonOther = false;
  TextStyle style = TextStyle(fontFamily: 'Lato', fontSize: 14.0, color: Color(0xff707070));
  final _otherReasonFormKey = GlobalKey<FormState>();
  String reason;


  TextEditingController otherReasonText = new TextEditingController();
  FocusNode otherReasonFocusNode = new FocusNode();
  EditPuppyReasonState() {
    reason = Constants.NO_SELECT;
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
    ),
    elevation: 0.0,
    backgroundColor: Colors.transparent,
    child:  _isLoading? Container(
        color: Colors.transparent,

        alignment: Alignment.center,
        child: SpinKitCircle(
          color: obpBlueColor,
          size: 30.0,
        )):dialogContent(context),
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
                          if(reason==Constants.OTHER)
                            _isReasonOther= true;
                          else
                            _isReasonOther = false;
                        });
                      },
                      items: widget.reasonsList.map<DropdownMenuItem<String>>((String value) {
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
                  _isReasonOther?Column(
                    children: <Widget>[
                      Form(
                        key: _otherReasonFormKey,
                          child: TextFormField(
                          textAlign: TextAlign.start,
                          controller: otherReasonText,
                          focusNode: otherReasonFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              otherReasonFocusNode.requestFocus();
                              return 'Enter valid reason';
                            }
                            return null;
                          },
                          style: style,
                          maxLines: 2,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                labelText: 'Reason*',
                                labelStyle: TextStyle(fontFamily: 'Lato', color: obpBlueColor, fontSize: 12,),
                                focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: obpBlueColor, width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: obpBlueColor, width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                ),
                                border: OutlineInputBorder(
                                      borderSide: BorderSide(color: obpBlueColor, width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                )
                            ),
                          ),
                        ),
                      new SizedBox(
                        height: 16,
                      ),
                    ],
                  ):SizedBox(),
                  SizedBox(
                    height: 42,
                    width: _width / 2.5,
                    child: FlatButton(
                      child: Text(
                        'Proceed',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      onPressed: reason == Constants.NO_SELECT?
                      null : () async {
                        if (reason == Constants.HEALTH_ISSUE ||
                            reason == Constants.SOLD_BY_BREEDER) {

                          setState(() {
                            _isLoading = true;
                          });
                          SharedPreferences prefs = await SharedPreferences
                              .getInstance();
                          String userId = prefs.getString(
                              Constants.SHARED_PREF_USER_ID);
                          var dio = Dio();
                          var soldByBreederUrl = 'https://onebarkplaza.com/wp-json/obp/v1/update_puppy';
                          FormData formData = new FormData.fromMap({
                            "user_id": userId,
                            "puppy_id": widget.data.puppyId,
                            "status": reason == Constants.HEALTH_ISSUE
                                ? "healthissue"
                                : "sold"
                          });
                          try {
                            dynamic response = await dio.post(soldByBreederUrl, data: formData);
                            dynamic responseList = jsonDecode(response.toString());
                            if (response.statusCode == 200) {
                              Toast.show("Status update request sucessful", context, duration: Toast.LENGTH_LONG,backgroundColor: Colors.black87, textColor: Color(0xffFFFd19));
                              setState(() {
                                _isLoading = false;
                              });
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                _isLoading = false;
                              });
                              Toast.show("Status update request failed", context,
                                  backgroundColor: Colors.black87,duration: Toast.LENGTH_LONG,
                                  textColor: Color(0xffFFFd19));
                            }
                          } catch (exception) {
                            setState(() {
                              _isLoading = false;
                            });
                            Toast.show("Status update request failed" + exception
                                .toString(), context,
                                backgroundColor: Colors.black87,duration: Toast.LENGTH_LONG,
                                textColor: Color(0xffFFFd19));
                          }
                        } else if (reason == Constants.OTHER) {
                              if (_otherReasonFormKey.currentState.validate()) {
                                Navigator.pop(context);
                                final Email email = Email(
                                  body: 'Puppy Id: '+widget.data.puppyId.toString()
                                      + '\nReason: ' + otherReasonText.text,
                                  subject: 'Edit Puppy request' ,
                                  recipients: ['davinder.bansal@bonafidetech.com'],
                                  isHTML: false,
                                );

                                await FlutterEmailSender.send(email);

                              }


                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditPuppy(widget.data, reason)));
                        }
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