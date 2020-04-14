import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:one_bark_plaza/add_puppy.dart';
import 'package:one_bark_plaza/puppy_details.dart';
import 'package:one_bark_plaza/util/constants.dart';
import 'package:one_bark_plaza/view_puppy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

final greenColor = Color(0xff7FA432);
final blueColor = Color(0xff4C8BF5);
class Preview extends StatefulWidget {

  String filePath ;
  bool isPdf = false, isImage = false, isOther = false;
  Preview(filePath, int fileType){
      this.filePath = filePath;
      initializeFiteType(fileType);
  }
  @override
  PreviewState createState() {
    return PreviewState();
  }

  void initializeFiteType(int fileType) {
    if(fileType == Constants.FILE_TYPE_PDF)
      isPdf = true;
    else if(fileType == Constants.FILE_TYPE_IMAGE)
      isImage = true;
    else
      isOther = true;
  }
}

class PreviewState extends State<Preview> {
  bool _isLoading = true;
  Future<List<PDFPageImage>> futurePageImages;
  @override
  void initState() {
    super.initState();
    if(widget.isPdf) {
      futurePageImages = getPdfFile();
    }
  }

  Future<List<PDFPageImage>> getPdfFile() async {
    final document = await PDFDocument.openFile(widget.filePath);
    final list = List<PDFPageImage>();
    for(int i =1 ; i<= document.pagesCount; i++){
      final page = await document.getPage(i);
      list.add(await page.render(width: page.width, height: page.height));
      await page.close();
    }
    return list;
  }


  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    var pdfRenderingScaffold = Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(

          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).maybePop();
              }
          ),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                new Image.asset("assets/images/onebark_logo_foreground.png", height: 70,),
              ]),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: greenColor,
        ),
        body:
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                child: FutureBuilder(
                  future: futurePageImages,
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
                          child: SpinKitFadingCircle(
                            color: blueColor,
                            size: 50.0,
                          ),
                        );
                        break;
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                        }
                        var data = snapshot.data as List<PDFPageImage>;
                        return new ListView.builder(
                          reverse: false,
                          scrollDirection: Axis.vertical,
                          itemCount: data.length,
                          itemBuilder:
                              (BuildContext context, int index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                                  border: Border.all(color:greenColor, width: 1.0, ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 3.0, // soften the shadow
                                      offset: Offset(
                                        1.0, // Move to right 10  horizontally
                                        1.0, // Move to bottom 10 Vertically
                                      ),
                                    )
                                  ]
                              ),
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(24.0),
                                child: Image(
                                  image: MemoryImage(data[index].bytes),
                                ),
                              ),
                            ),
                          ),
                        );
                        break;
                    }
                  },
                )
            )));
    var imageRenderingScaffold = Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(

          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).maybePop();
              }
          ),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                new Image.asset("assets/images/onebark_logo_foreground.png", height: 70,),
              ]),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: greenColor,
        ),
        body:
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius:
                      BorderRadius.all(Radius.circular(24)),
                      border: Border.all(color:greenColor, width: 1.0, ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 3.0, // soften the shadow
                          offset: Offset(
                            1.0, // Move to right 10  horizontally
                            1.0, // Move to bottom 10 Vertically
                          ),
                        )
                      ]
                  ),
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(24.0),
                    child: Image.file(File(widget.filePath), fit: BoxFit.cover,),
                  ),
                )
            )));
    return widget.isPdf
        ? pdfRenderingScaffold
        : widget.isImage
        ? imageRenderingScaffold
        : Container();
  }

}
