import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vertical_tabs/vertical_tabs.dart';

final greenColor = Color(0xff7FA432);
final blueColor = Color(0xff4C8BF5);
final filterKey = GlobalKey<ScaffoldState>();
class Filter extends StatefulWidget {
  FilterState filterState;
  Set<String> setOfPuppies;
  Filter(Set<String> setOfPuppies){
    this.setOfPuppies = setOfPuppies;
  }
  @override
  FilterState createState() {
    return filterState = new FilterState();
  }
}

class FilterState extends State<Filter> {

  BuildContext context;



  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: filterKey,
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
                  "Filter",
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
        body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          alignment:Alignment.topLeft,
          child: Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.white,
                    //height: MediaQuery.of(context).size.height-200,
                    alignment:Alignment.topLeft,
                    child:
                    VerticalTabs(
                      tabsElevation: 1.0,
                      tabsWidth: MediaQuery.of(context).size.width/3,
                      tabs: <Tab>[
                        Tab(child: Container(height: 48, alignment: Alignment.center,child: Text('Breed', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.bold, fontSize: 14, color:blueColor ),))),
                        Tab(child: Container(height: 48, alignment: Alignment.center,child: Text('Gender', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.bold, fontSize: 14, color:blueColor),))),
                        Tab(child: Container(height: 48, alignment: Alignment.center,child: Text('Price', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.bold, fontSize: 14,  color:blueColor),))),

                      ],
                      contents: <Widget>[
                        Container(color:Colors.white, child: getBreeds()),
                        Container(child: Text('Dart'), padding: EdgeInsets.all(20)),
                        Container(child: Text('NodeJS'), padding: EdgeInsets.all(20)),
                      ],
                    ),

                    /*Text('FILTER BY BREED', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.left,)*/

                  ),
                ),
                Container(width: MediaQuery.of(context).size.width, height: 2, color:Color(0xffF3F3F3)),
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width / 2 - 1,
                          height: 50,
                          child:Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.cancel, size: 20,color:blueColor),
                              SizedBox(width: 12,),
                              Text(
                                "Cancel",
                                style: new TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                                textAlign: TextAlign.center,
                              )
                            ],
                          )
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(height: 2,),
                          Container(width: 2, height: 45, color: Color(0xffF3F3F3)),
                        ],
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width / 2 - 1,
                          height: 50,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.check_circle, color: blueColor, size: 20,),
                              SizedBox(width: 12,),
                              Text(
                                "Apply",
                                style: new TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                                textAlign: TextAlign.center,
                              )
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

 /*void onFilterClick(BuildContext context) {
    final act = ;
    showCupertinoModalPopup(
        useRootNavigator: true,
        context: context,
        builder: (BuildContext context) => act);
  } */

  getBreeds() {
    List<String> listOfPuppies = widget.setOfPuppies.toList();
    return new ListView.builder(

      scrollDirection: Axis.vertical,
      itemCount: listOfPuppies.length,
      itemBuilder:
          (BuildContext context, int index) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
          new BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0,0,0,0),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: (){

                },

                child: Container(
                  width:  MediaQuery.of(context).size.width -  (MediaQuery.of(context).size.width/3  + 20),
                  alignment: Alignment.centerLeft,
                  height: 48,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.check, size: 18, color: Colors.grey),
                      SizedBox(width: 12),
                      Flexible(child: Container(child: Text(listOfPuppies[index])))
                    ],
                  ),
                ),
              ),
              new Divider(height: 1.0, color: Colors.grey),
            ],
          ),

        ),
      ),
    );
  }

}
