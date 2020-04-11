import 'dart:ui';
import 'package:cupertino_range_slider/cupertino_range_slider.dart';
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
class Filter extends StatefulWidget {
  FilterState filterState;
  RangeSliderItem priceRangeFilter;
  List<BreedFilter> setOfBreedFilter = new List<BreedFilter>();
  Set<String> _selectedSetOfBreeds = new Set<String>();

  double minPrice;
  double maxPrice;
  int _chosenMinPrice;

  Set<String> receivedSetOfBreeds;

  int get chosenMinPrice => _chosenMinPrice;
  int _chosenMaxPrice;
  Set<String> get selectedSetOfBreeds => _selectedSetOfBreeds;
  List<GenderFilter> genderFilter = new List<GenderFilter>();
  Set<String> _selectedGender = new Set<String>();
  Set<String> get selectedGender => _selectedGender;

  HomePageState homePageState;
  Filter(Set<String> receivedSetOfBreeds, HomePageState homePageState, double minPrice, double maxPrice){
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    _chosenMinPrice = this.minPrice.round();
    _chosenMaxPrice = this.maxPrice.round();
    this.homePageState = homePageState;
    this.receivedSetOfBreeds = receivedSetOfBreeds;
    for(String item in receivedSetOfBreeds){
      this.setOfBreedFilter.add(new BreedFilter(item, false));
    }
    genderFilter.add(new GenderFilter("Male", false));
    genderFilter.add(new GenderFilter("Female", false));
  }


  @override
  FilterState createState() {
    return filterState = new FilterState();
  }

  int get chosenMaxPrice => _chosenMaxPrice;
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
                      onTap: (){
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text('Do you want to reset all the filters?'),
                              content: Text('\nAll the filters you applied would be lost. Do you want to proceed?'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('Proceed'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>widget.homePageState.filter = Filter(widget.receivedSetOfBreeds, widget.homePageState, widget.minPrice, widget.maxPrice)));;
                                  },
                                ),
                              ],
                            );
                          },
                        );

                      },
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
                      Container(
                          color:Colors.white,
                          child: ListView.builder(

                            scrollDirection: Axis.vertical,
                            itemCount: 2,
                            itemBuilder:
                                (BuildContext context, int index) => Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                new BorderRadius.circular(8.0),
                              ),
                              child: InkWell(
                                onTap: (){
                                  widget.genderFilter[index].toggleSelection();
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
                                            Icon(Icons.check, size: 18, color: widget.genderFilter[index].isSelected? Colors.pink : Colors.grey),
                                            SizedBox(width: 12),
                                            Flexible(child: Container(child: Text(widget.genderFilter[index].genderType, style: TextStyle(fontSize: 13, color: Colors.black54),)))
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
                      Container(child: widget.priceRangeFilter==null
                          ? widget.priceRangeFilter = RangeSliderItem('Selected Price Range', widget.minPrice.round(), widget.maxPrice.round())
                          : widget.priceRangeFilter) ,
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
                          if((filter.isSelected && !widget._selectedSetOfBreeds.contains(filter.breedName))
                          ||(!filter.isSelected && widget._selectedSetOfBreeds.contains(filter.breedName))){
                            filter.toggleSelection();
                          }
                        }
                        for(GenderFilter filter in widget.genderFilter){
                          if((filter.isSelected && !widget._selectedGender.contains(filter.genderType))
                              ||(!filter.isSelected && widget._selectedGender.contains(filter.genderType))){
                            filter.toggleSelection();
                          }
                        }
                        if(widget.priceRangeFilter!=null) {
                          widget.priceRangeFilter.changedMinValue = widget._chosenMinPrice;
                          widget.priceRangeFilter.changedMaxValue = widget._chosenMaxPrice;
                        }
                        widget.homePageState.setState(() { });
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
                            widget._selectedSetOfBreeds.add(filter.breedName);
                          }
                          else if(widget._selectedSetOfBreeds.contains(filter.breedName)){
                            widget._selectedSetOfBreeds.remove(filter.breedName);
                          }
                        }
                        for(GenderFilter filter in widget.genderFilter){
                          if(filter.isSelected){
                            widget._selectedGender.add(filter.genderType);
                          }
                          else if(widget._selectedGender.contains(filter.genderType)){
                            widget._selectedGender.remove(filter.genderType);
                          }
                        }
                        if(widget.priceRangeFilter!=null) {
                          widget._chosenMinPrice = widget.priceRangeFilter.changedMinValue;
                          widget._chosenMaxPrice = widget.priceRangeFilter.changedMaxValue;
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

class GenderFilter {
  String _genderType = "";
  bool _isSelected = false;

  GenderFilter(genderType, isSelected) {
    this._genderType = genderType;
    this._isSelected = isSelected;
  }

  String get genderType => _genderType;

  bool get isSelected => _isSelected;

  toggleSelection() {
    this._isSelected = !this._isSelected;
  }
}

class RangeSliderItem extends StatefulWidget {
  String title;
  int initialMinValue;
  int initialMaxValue;
  int changedMinValue;
  int changedMaxValue;


  RangeSliderItem(String title, int initialMinValue, int initialMaxValue){
    this.title = title;
    this.initialMaxValue = initialMaxValue;
    this.initialMinValue = initialMinValue;
    changedMinValue = initialMinValue;
    changedMaxValue = initialMaxValue;
  }

  @override
  _RangeSliderItemState createState() => _RangeSliderItemState();
}

class _RangeSliderItemState extends State<RangeSliderItem> {
  int minValue;
  int maxValue;


  @override
  void initState() {
    super.initState();
    minValue = widget.changedMinValue;
    maxValue = widget.changedMaxValue;
  }

  @override
  Widget build(BuildContext context) {
    return FilterItemHolder(
      title: widget.title,
      value: "\$$minValue - \$$maxValue",
      child: CupertinoRangeSlider(
        activeColor: Colors.pinkAccent,

        minValue: minValue.roundToDouble(),
        maxValue: maxValue.roundToDouble(),
        min: widget.initialMinValue.roundToDouble(),
        max: widget.initialMaxValue.roundToDouble(),
        onMinChanged: (minVal){
          setState(() {
            minValue = minVal.round();
            widget.changedMinValue = minValue;
          });
        },
        onMaxChanged: (maxVal){
          setState(() {
            maxValue = maxVal.round();
            widget.changedMaxValue = maxValue;
          });
        },
      ),
    );
  }
}



///
///
///
class FilterItemHolder extends StatelessWidget {
  final String title;
  final String value;
  final Widget child;

  FilterItemHolder({Key key, this.title, this.value = '', this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(16,16,16,4),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: titleTextStyle,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16,16,16,4),
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight:FontWeight.bold, color:Color(0XFF414A4C)),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.all(const Radius.circular(5.0)),

          ),
          child: Container(
            height: 47.0,
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: child,
            ),
          ),
        )
      ],
    );
  }

  final titleTextStyle = TextStyle(fontSize: 13, fontWeight:FontWeight.normal, color:Color(0XFF414A4C));
}