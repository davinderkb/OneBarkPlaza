
import 'package:intl/intl.dart';
import 'package:one_bark_plaza/util/utility.dart';

class OrderDetails{
  OrderDetails(this._orderId,
      this._vendorEarning,
      this._orderStatus,
      this._orderDateString,
      this._paymentMethod,
      this._billingAddress,
      this._shippingAddress,
      jsonItems){

    evaluateDate();
    this._items = new List<OrderItem>();
    for(dynamic item in jsonItems){
      this._items.add(
          OrderItem(item["sku"],
              item["name"],
              item["img_url"],
              item["cost"].toString(),
              item["qty"].toString(),
              item["price"].toString(),
              item["tax"].toString(),
              item["commission"].toString()));
    }
    

  }

  void evaluateDate() {
    try{
      this._orderDate = new DateTime.fromMillisecondsSinceEpoch(_orderDateString.contains(".")?int.parse(_orderDateString.substring(0,_orderDateString.indexOf("."))):int.parse(_orderDateString));
      this._orderDateString = new DateFormat("MMM dd, yyyy").format(_orderDate);
    }catch(e){
      this._orderDateString = "";
      this._orderDate = DateTime.now();
    }
  }

  String _orderId,_orderStatus,_paymentMethod, _orderDateString ;
  double  _vendorEarning;

  String get orderId => _orderId;
  AddressDetails _billingAddress, _shippingAddress;
  DateTime _orderDate;
  List<OrderItem> _items;


  factory OrderDetails.fromJson(String orderId, double vendorEarning, String orderStatus, String dateString, dynamic json) {
    return
      OrderDetails(orderId,
          vendorEarning,
          orderStatus,
          dateString,
          json["payment_method"] as String,
        new AddressDetails(json["billing_address"]["first_name"] as String,
            json["billing_address"]["last_name"] as String,
            json["billing_address"]["company"] as String,
            json["billing_address"]["address_1"] + " "+json["billing_address"]["address_2"] ,
            json["billing_address"]["city"] as String,
            json["billing_address"]["state"] as String,
            json["billing_address"]["postcode"] as String,
            json["billing_address"]["country"] as String,
            json["billing_address"]["email"] as String,
            json["billing_address"]["phone"] as String),
        new AddressDetails(json["shipping_address"]["first_name"] as String,
            json["shipping_address"]["last_name"] as String,
            json["shipping_address"]["company"] as String,
            json["shipping_address"]["address_1"] + " "+json["billing_address"]["address_2"] ,
            json["shipping_address"]["city"] as String,
            json["shipping_address"]["state"] as String,
            json["shipping_address"]["postcode"] as String,
            json["shipping_address"]["country"] as String,
            json["shipping_address"]["email"] as String,
            json["shipping_address"]["phone"] as String),
       json["items"]
    );
  }

  get orderStatus => _orderStatus;

  get paymentMethod => _paymentMethod;

  get orderDateString => _orderDateString;

  double get vendorEarning => _vendorEarning;

  AddressDetails get billingAddress => _billingAddress;

  get shippingAddress => _shippingAddress;

  DateTime get orderDate => _orderDate;

  List<OrderItem> get items => _items;
}

class AddressDetails{
  String _firstName,
  _lastName,
  _company,
  _address,
  _city,
  _state,
  _postcode,
  _country,
  _email,
  _phone;

  String get firstName => _firstName;

  AddressDetails(this._firstName, this._lastName, this._company,
      this._address, this._city, this._state, this._postcode, this._country,
      this._email, this._phone);

  get lastName => _lastName;

  get company => _company;

  get address => _address;

  get city => _city;

  get state => _state;

  get postcode => _postcode;

  get country => _country;

  get email => _email;

  get phone => _phone;


}

class OrderItem{
  String _stockUnitId, _name, _image, _cost, _quantity, _price, _tax, _commission, _totalPrice;



  OrderItem(this._stockUnitId, this._name, this._image, this._cost,
      this._quantity, this._price, this._tax, this._commission){
    try {
      this._totalPrice = (price + tax + commission).toString();
    }catch(e){
      this._totalPrice = "0.0";
    }
  }

  String get stockUnitId => _stockUnitId;

  get name => _name;

  get image => _image;

  double get cost {
    try{
      return double.parse(_cost);
    }catch(e){
      return 0.0;
    }
  }

  get quantity => _quantity;

  double get price {
    try{
      return double.parse(_price);
    }catch(e){
      return 0.0;
    }
  }

  double get tax {
    try{
      return double.parse(_tax);
    }catch(e){
      return 0.0;
    }
  }

  double get commission {
    try{
      return double.parse(_commission);
    }catch(e){
      return 0.0;
    }
  }

  get totalPrice => _totalPrice;


}