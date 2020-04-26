import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:one_bark_plaza/order_details.dart';

import 'main.dart';
final greenColor = Color(0xff7FA432);
class OrderDetailsPage extends StatefulWidget {
  OrderDetails orderDetails;
  OrderDetailsPage(OrderDetails orderDetails){
    this.orderDetails = orderDetails;
  }

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {


  @override
  Widget build(BuildContext context) {
    double totalCommission = 0.0;
    double totalPrice =0.0;
    double totalTax = 0.0;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    for(OrderItem item in widget.orderDetails.items){
          totalCommission = totalCommission + item.commission;
          totalPrice = totalPrice + item.cost;
          totalTax = totalTax + item.tax;
    }
    return  Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          //iconTheme: new IconThemeData(color: Color(0xff262B31)),
          iconTheme: new IconThemeData(color: greenColor),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: greenColor),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                new Text(
                  "Order Details",
                  style: new TextStyle(
                      fontFamily: 'NunitoSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: greenColor),
                  textAlign: TextAlign.center,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text("\$ "+widget.orderDetails.vendorEarning.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:14,color:greenColor, fontWeight:FontWeight.bold)),
                    new Text(
                      "Total Earning",
                      style: new TextStyle(
                          fontFamily: 'NunitoSans',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: greenColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

              ]),
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),

        body: SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20,8,8,8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                            "Order Status",
                            style: TextStyle(
                                fontFamily:
                                'NunitoSans',
                                fontSize:
                                12,
                                color:
                                Color(0xff707070),
                                fontWeight:
                                FontWeight
                                    .bold)),
                        Text(
                             widget.orderDetails.orderStatus,
                            style: TextStyle(
                                fontFamily:
                                'NunitoSans',
                                fontSize:15,
                                color:
                                greenColor,
                                fontWeight:
                                FontWeight
                                    .bold)),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                      width: _width / 2.5,
                      child: FlatButton.icon(
                        label: Text(
                          'Edit Status',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontFamily:"NunitoSans",fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => null));
                        },
                        icon: Icon(Icons.edit, color: Colors.white, size: 11,),
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
                  ],
                ),
              ),
                Card(
                //color: Color(0xffFFF8E1), // FFF8E1 amber , F1F8E9 green, FBE9E7 orange
                elevation:1,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  new BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: _width  ,
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,

                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                             Divider(color:Colors.transparent),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: _width ,

                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                    border: Border.all(color: Colors.transparent, width: 2)
                                  //color: Colors.green,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Container(width:_width/3,child: Text("Order Id ",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold))),
                                                  Text("#"+widget.orderDetails.orderId +" ("+ widget.orderDetails.items.length.toString()+" Items in this Order)",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                                ],
                                              ),

                                              Row(
                                                children: <Widget>[
                                                  Container(width:_width/3,child: Text("Order Date",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold))),
                                                  Text(widget.orderDetails.orderDateString,style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(width:_width/3, child: Text("Billing Address ",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold))),
                                                  Text(widget.orderDetails.billingAddress.firstName +" " +widget.orderDetails.billingAddress.lastName+"\n"
                                                      +widget.orderDetails.billingAddress.address + "\n"
                                                      +widget.orderDetails.billingAddress.city +", "+widget.orderDetails.billingAddress.state +"-"+widget.orderDetails.billingAddress.postcode+"\n"
                                                      +widget.orderDetails.billingAddress.country,
                                                      style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(width:_width/3, child: Text("Shipping Address ",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold))),
                                                  Text(widget.orderDetails.shippingAddress.firstName +" " +widget.orderDetails.shippingAddress.lastName+"\n"
                                                      +widget.orderDetails.shippingAddress.address + "\n"
                                                      +widget.orderDetails.shippingAddress.city +", "+widget.orderDetails.shippingAddress.state +"-"+widget.orderDetails.shippingAddress.postcode+"\n"
                                                      +widget.orderDetails.shippingAddress.country,
                                                      style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),


                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          for (int i=0; i<widget.orderDetails.items.length;i++)
                                            Card(
                                              elevation: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(0,8,8,8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Column(
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(8,0,0,8),
                                                          child: Container(
                                                              height: _height>_width? _height/6 : _width/4,
                                                              width:  _height>_width? _width/3.5 : _height/2,
                                                              decoration: BoxDecoration(
                                                                color: Color(0xffFEF8F5),
                                                                borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        24)),
                                                                //border: Border.all()
                                                                //color: Colors.green,
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    24.0),
                                                                child: CachedNetworkImage(
                                                                  imageUrl:
                                                                  widget.orderDetails.items[i].image,
                                                                  fit: BoxFit.cover,
                                                                  placeholder:
                                                                      (context, url) =>
                                                                      SpinKitCircle(
                                                                        color: greenColor,
                                                                        size: 30.0,
                                                                      ),
                                                                  errorWidget: (context,
                                                                      url, error) =>
                                                                      Container(
                                                                          margin: EdgeInsets.all(10),
                                                                          child: new Image.asset("assets/images/noImageIcon.png",color: Colors.white)
                                                                      ),
                                                                ),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(width: 12,),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.max,
                                                        crossAxisAlignment:CrossAxisAlignment.start,
                                                        mainAxisAlignment:MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: <Widget>[
                                                              Text(
                                                                  widget.orderDetails.items[i].name,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'NunitoSans',
                                                                      fontSize:
                                                                      13,
                                                                      color:
                                                                      Color(0xff707070),
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                              Text(
                                                                  " (SKU #"+widget.orderDetails.items[i].stockUnitId +")",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'NunitoSans',
                                                                      fontSize:11,
                                                                      color:
                                                                      Color(0xff707070),
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold)),


                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text("Price",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                                              Text("\$ "+ widget.orderDetails.items[i].price.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text(
                                                                  "Quantity",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'NunitoSans',
                                                                      fontSize:12,
                                                                      color:
                                                                      Colors.grey,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                              Text(
                                                                  "x " + widget.orderDetails.items[i].quantity,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'NunitoSans',
                                                                      fontSize:12,
                                                                      color:
                                                                      Color(0xff707070),
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text("Commision",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                                              Text("\$ "+totalCommission.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text("Sale Tax",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                                              Text("\$ "+widget.orderDetails.items[i].tax.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                                            ],
                                                          ),
                                                          Divider(),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text("Total",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                                              Text("\$ "+(widget.orderDetails.items[i].price + widget.orderDetails.items[i].commission + widget.orderDetails.items[i].tax).toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.transparent),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: _width ,

                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                    border: Border.all(color: Colors.transparent, width: 2)
                                  //color: Colors.green,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Payment Mode ",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                          Text("Cash on Delivery",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Price",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                          Text("\$ "+totalPrice.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Commision",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                          Text("\$ "+totalCommission.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Total Tax",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                          Text("\$ "+totalTax.toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Total",style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Colors.grey, fontWeight:FontWeight.bold)),
                                          Text("\$ "+(totalPrice+totalTax+totalCommission).toString(),style: TextStyle(fontFamily:'NunitoSans',fontSize:12,color:Color(0xff707070), fontWeight:FontWeight.bold)),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),


                              Divider(color:Colors.transparent)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height:4),
              Row(
                mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 54,
                    width: _width/1.1,
                    child: FlatButton(
                      child: Text(
                        'Refund',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily:"NunitoSans",fontSize: 14, color: Colors.white, fontWeight:FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>null));
                      },
                      disabledColor: greenColor,
                      color: greenColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.only(
                            bottomLeft: Radius.circular(40.0),
                            topRight: Radius.circular(40.0),
                            topLeft: Radius.circular(40.0),
                            bottomRight: Radius.circular(40.0),
                          ),
                          side: BorderSide(
                            color: Colors.white,
                          )),
                    ),
                  ),

                ],
              ),
              Divider(color:Colors.transparent)
            ],
          ),
        ));
  }
}
