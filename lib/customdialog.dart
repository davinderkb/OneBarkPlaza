import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:one_bark_plaza/add_puppy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import 'breeds.dart';
class ChooseBreedDialog extends StatefulWidget {
  AddPuppyState addPuppyState;
  ChooseBreedDialog(AddPuppyState addPuppyState){
        this.addPuppyState = addPuppyState;
  }

  @override
  ChoosBreedDailogState createState() {
    return ChoosBreedDailogState();
  }

}

class ChoosBreedDailogState extends State<ChooseBreedDialog>{
  Future<List<Breed>> futureListOfCategories;
  TextEditingController searchTextController = new TextEditingController();
  TextStyle style = TextStyle(fontFamily: 'NunitoSans', fontSize: 15.0, color: Color(0xff707070));
  Set<Breed> allDuplicateItems  = Set<Breed>();
  List<Breed> filteredItems = List<Breed>();
  @override
  void initState() {
    super.initState();
    allDuplicateItems.clear();
    futureListOfCategories = getAllBreeds(context);
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
      child: Stack(
        children: <Widget>[
          Container(

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
                  height: _height - 200,
                  width: _width - 60,
                  padding: const EdgeInsets.fromLTRB(12,0,12,12,),
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
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: _width - 60,
                        decoration: BoxDecoration(

                          color: Color(0xffFEF8F5),

                        ),
                        child:   Center(
                          child: TextField(
                            onChanged: (value) {
                              filterSearchResults(value);
                            },
                            textAlign: TextAlign.start,
                            controller: searchTextController,
                            style: TextStyle(fontFamily:"NunitoSans",color: Colors.amber, fontSize: 18,),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Padding(
                                padding: const EdgeInsets.fromLTRB(16.0,2,0,0),
                                child: Icon(Icons.search, color: Colors.amber,),
                              ),
                              contentPadding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                              hintText: "Search",
                              hintStyle: TextStyle(fontFamily:"NunitoSans",color: Colors.amber, fontSize: 18,),

                            ),
                          ),
                        ),
                      ),
                      Container(height: 2.5, color:Colors.amber),
                      SizedBox(height: 8.0),
                      searchTextController.text =="" ?
                      Expanded(
                        child: FutureBuilder(
                          future: futureListOfCategories,
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
                                  child: SpinKitFadingCircle(
                                    color: Colors.amber,
                                    size: 50.0,
                                  ),
                                );
                                break;
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  // return whatever you'd do for this case, probably an error
                                  return Column(
                                    children: <Widget>[
                                      Container(
                                        //height: _height/2 - 80,
                                        alignment: Alignment.topCenter,
                                        width: _width,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),

                                    ],
                                  );
                                }
                                var data = snapshot.data;
                                allDuplicateItems.addAll(data);
                                return new ListView.builder(
                                  reverse: false,
                                  scrollDirection: Axis.vertical,
                                  itemCount: data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) => GestureDetector(
                                        child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        new BorderRadius.circular(8.0),
                                    ),
                                    child: Container(
                                        color: Color(0xffFEF8F5),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                  0.0, 12.0, 0, 12),
                                              child: Text(data[index].name,style: style,),
                                            ),
                                            Divider(height: 2.0, color:Color(0xff707070)),
                                          ],
                                        ),
                                    ),
                                  ),
                                          onTap: () {
                                            widget.addPuppyState.isBreedSelectedOnce(true);
                                            widget.addPuppyState.chooseBreed(data[index].name);
                                            Navigator.pop(context);
                                          },
                                      ),

                                );
                                break;
                            }
                          },
                        ),
                      ) :
                      Expanded(
                        child: ListView.builder(
                          reverse: false,
                          scrollDirection: Axis.vertical,
                          itemCount: filteredItems.length,
                          itemBuilder:
                              (BuildContext context, int index) => GestureDetector(
                                child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                new BorderRadius.circular(8.0),
                            ),
                            child: Container(
                                color: Color(0xffFEF8F5),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 12.0, 0, 12),
                                      child: Text(filteredItems[index].name,style: style,),
                                    ),
                                    Divider(height: 2.0, color:Color(0xff707070)),
                                  ],
                                ),
                            ),
                          ),
                                onTap: () {
                                  widget.addPuppyState.isBreedSelectedOnce(true);
                                  widget.addPuppyState.chooseBreed(filteredItems[index].name);
                                  Navigator.pop(context);
                                },
                              ),
                        ),
                      )
                      ,
                    ],
                  ),
                ),


                SizedBox(height: 12.0),

              ],
            ),
          ),

        ],
      ),
    );
  }
  Future<List<Breed>> getAllBreeds(BuildContext context) async{

    var dio = Dio();
    var allBreedsUrl = 'https://obpdevstage.wpengine.com/wp-json/obp-api/get_categories/';
    FormData formData = new FormData.fromMap({});
    final list = List<Breed>();
    dynamic response = await dio.post(allBreedsUrl, data: formData);
    dynamic responseList = jsonDecode(response.toString());
    for (dynamic item in responseList) {
      list.add(Breed.fromJson(item));
     // allDuplicateItems.add(Breed.fromJson(item));
    }
    if (response.toString() == "[]" || response.toString() == "") {
      Toast.show("Category fetch failed", context,
          textColor: Colors.white,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.transparent,
          backgroundRadius: 16);
    }

    return list;
  }

  void filterSearchResults(String query) {
    Set<Breed> dummySearchList = Set<Breed>();
    dummySearchList.addAll(allDuplicateItems);
    if(query.isNotEmpty) {
      Set<Breed> dummyListData = Set<Breed>();
      dummySearchList.forEach((item) {
        if(item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredItems.clear();
        filteredItems.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        filteredItems.clear();
        filteredItems.addAll(allDuplicateItems);
      });
    }

  }



}
class Consts {
  Consts._();

  static const double padding = 0.0;
}
