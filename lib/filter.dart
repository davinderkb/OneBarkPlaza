import 'dart:ui';
import 'package:dynamic_widget/dynamic_widget/basic/container_widget_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:one_bark_plaza/breeds.dart';
import 'package:one_bark_plaza/homepage.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:one_bark_plaza/vertical_tabs.dart';

final greenColor = Color(0xff7FA432);
final blueColor = Color(0xff4C8BF5);
final filterKey = GlobalKey<ScaffoldState>();
class Filter extends StatefulWidget {
  FilterState filterState;
  List<BreedFilter> setOfBreedFilter = new List<BreedFilter>();
  Set<String> _setOfBreeds = new Set<String>();
  HomePageState homePageState;
  Set<String> get setOfBreeds => _setOfBreeds;

  Filter(Set<String> setOfPuppies, HomePageState homePageState){
    this.homePageState = homePageState;
    for(String item in setOfPuppies){
      this.setOfBreedFilter.add(new BreedFilter(item, false));
    }
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: new AppBar(
            //iconTheme: new IconThemeData(color: Color(0xff262B31)),
            iconTheme: new IconThemeData(color: Colors.pinkAccent),
            leading: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10,16,0,0),
                child: new Text(
                  "Filters",
                  style: new TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3b444b)
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0,16,0,0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                new Text(
                "",
                style: new TextStyle(
                    fontFamily: 'NunitoSans',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                textAlign: TextAlign.center,
              ),
                    //Icon(Icons.home, size: 40,color: blueColor,),
                    InkWell(
                      onTap: (){},
                      child: Container(
                        alignment: Alignment.centerRight,
                        height: 42,
                        child: Text(
                          'CLEAR ALL',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 12, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ]),
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white,
          ),
        ),
        body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          alignment:Alignment.topLeft,
          child: Expanded(
            child: Column(
              children: <Widget>[
                Container(width: MediaQuery.of(context).size.width, height: 1, color:Color(0xffF3F3F3)),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    //height: MediaQuery.of(context).size.height-200,
                    alignment:Alignment.topLeft,
                    child:
                    VerticalTab(
                      tabsElevation: 0.0,
                      tabsWidth: MediaQuery.of(context).size.width/3,
                      tabs: <Tab>[
                        Tab(text: "Breed"),
                        Tab(text: "Gender"),
                        Tab(text: "Price"),

                      ],
                      contents: <Widget>[
                        Container(
                            color:Colors.white,
                            child: ListView.builder(

                          scrollDirection: Axis.vertical,
                          itemCount: widget.setOfBreedFilter.length,
                          itemBuilder:
                              (BuildContext context, int index) => Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              new BorderRadius.circular(8.0),
                            ),
                            child: InkWell(
                              onTap: (){
                                widget.setOfBreedFilter[index].toggleSelection();
                                setState(() {

                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8.0,0,0,0),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width:  MediaQuery.of(context).size.width -  (MediaQuery.of(context).size.width/3  + 20),
                                      alignment: Alignment.centerLeft,
                                      height: 48,
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.check, size: 18, color: widget.setOfBreedFilter[index].isSelected? Colors.pink : Colors.grey),
                                          SizedBox(width: 12),
                                          Flexible(child: Container(child: Text(widget.setOfBreedFilter[index].breedName, style: TextStyle(fontSize: 13, color: Colors.black54),)))
                                        ],
                                      ),
                                    ),
                                    new Divider(height: 1.0, color: Colors.grey),
                                  ],
                                ),

                              ),
                            ),
                          ),
                        )
                        ),
                        Container(child: Text('Dart'), padding: EdgeInsets.all(20)),
                        Container(child: Text('NodeJS'), padding: EdgeInsets.all(20)),
                      ],
                    ),

                    /*Text('FILTER BY BREED', style: TextStyle( fontFamily: "NunitoSans", fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.left,)*/

                  ),
                ),
                Container(width: MediaQuery.of(context).size.width, height: 1, color:Color(0xffF3F3F3)),
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          for(BreedFilter filter in widget.setOfBreedFilter){
                            if(filter.isSelected && !widget._setOfBreeds.contains(filter.breedName)){
                              filter.toggleSelection();
                            }
                          }
                          Navigator.of(context).maybePop();
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width / 2 - 1,
                            height: 50,
                            child:Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "CANCEL",
                                  style: new TextStyle(

                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pinkAccent),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(height: 1,),
                          Container(width: 1, height: 45, color: Color(0xffF3F3F3)),
                        ],
                      ),
                      InkWell(
                        onTap:(){
                          for(BreedFilter filter in widget.setOfBreedFilter){
                            if(filter.isSelected){
                              widget._setOfBreeds.add(filter.breedName);
                            }
                            else if(widget._setOfBreeds.contains(filter.breedName)){
                              widget._setOfBreeds.remove(filter.breedName);
                            }
                          }
                          widget.homePageState.setState(() { });
                          Navigator.of(context).maybePop();

                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width / 2 - 1,
                            height: 50,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "APPLY",
                                  style: new TextStyle(

                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pinkAccent),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )
                        ),
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

}

class BreedFilter {
  String _breedName = "";
  bool _isSelected = false;
  BreedFilter(breedName, isSelected){
     this._breedName = breedName;
     this._isSelected = isSelected;
  }

  String get breedName => _breedName;

  bool get isSelected => _isSelected;

  toggleSelection(){
    this._isSelected = !this._isSelected;
  }

}