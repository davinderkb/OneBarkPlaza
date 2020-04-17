import 'dart:convert';
import 'dart:ui';

import 'img.dart';

class PuppyDetails {
  int _puppyId, _categoryId;
  ImageCustom _image;
  List<ImageCustom> _gallery;
  String _puppyName,
      _puppyPrice,
      _shippingCost,
      _description,
      _gender,
      _dob,
      _ageInWeeks,
      _color,
      _puppyWeight,
      _puppyDadWeight,
      _puppyMomWeight,
      _registry,
      _status,
      _categoryName,
      _categoryLink,
      _vetReport,
      _flightTicket
      ;

  get flightTicket => _flightTicket;

  set flightTicket(value) {
    _flightTicket = value;
  }

  get vetReport => _vetReport;

  set vetReport(value) {
    _vetReport = value;
  }

  bool _isChampionBloodline;
  bool _isFamilyRaised;
  bool _isKidFriendly;
  bool _isMicrochipped;
  bool _isSocialized;


  set puppyId(int value) {
    _puppyId = value;
  }

  PuppyDetails(
      this._puppyId,
      this._puppyName,
      this._puppyPrice,
      this._shippingCost,
      this._description,
      this._image,
      this._gallery,
      this._gender,
      this._dob,
      this._ageInWeeks,
      this._color,
      this._puppyWeight,
      this._puppyDadWeight,
      this._puppyMomWeight,
      this._registry,
      this._status,
      this._categoryId,
      this._categoryName,
      this._categoryLink,
      this._vetReport,
      this._flightTicket,
      this._isChampionBloodline,
      this._isFamilyRaised,
      this._isKidFriendly,
      this._isMicrochipped,
      this._isSocialized);

  factory PuppyDetails.fromJson(dynamic json) {
    Map<String,dynamic> categoryDetails = (json['categories'][0] as Map<String,dynamic>);
    Map<String,dynamic> productImage = null;
    ImageCustom featuredImage = null;
    try {
      productImage = (json['product-image'] as Map<String, dynamic>);
      featuredImage = ImageCustom(productImage["id"], productImage["src"]);
    }catch(e) {}

    List<ImageCustom> galleryImages = new List<ImageCustom>();
    if(featuredImage!= null)
      galleryImages.add(featuredImage);
    try {
      for(dynamic items in json['gallery-images']){
        var item = (items as Map<String, dynamic>);
        for (int i=0; i< item.length;i++){
                    galleryImages.add(ImageCustom(item["id"].toString(), item["src"]));
        }
      }
    }catch(e){}

      return PuppyDetails(
        int.parse(json['ID'].toString()) as int,
        json['name'] as String,
        json['price'].toString().trim() == "" ? "0" : json['price'].toString().trim(),
        json['shipping_cost'] as String,
        json['description'] as String,
        featuredImage,
        galleryImages,
        json['gender'] as String,
        /*json['date_of_birth'] as String*/"Feb 23, 2020",
        json['age_in_weeks'] as String,
        json['color'] as String,
        json['puppy_weight'] as String,
        json['puppy_dad_weight'] as String,
        json['puppy_mom_weight'] as String,
        json['registry'] as String,
        json['status'] as String,
        categoryDetails["id"].toString().trim() == "" ? 0 : categoryDetails["id"],
        categoryDetails["name"] as String,
        categoryDetails["link"] as String,
        json["report-copy"] as String,
        json["upload-documentations"] as String,
        json['champion-bloodlines'].toString() == '1',
        json['family-raised'].toString() == '1',
        json['kid-friendly'].toString() == '1',
        json['microchipped'].toString() == '1',
        json['socialized'].toString() == '1',

      );
    }


  get categoryLink => _categoryLink;

  get categoryName => _categoryName;

  get status => _status;

  get registry => _registry;

  get puppyMomWeight => _puppyMomWeight;

  get puppyDadWeight => _puppyDadWeight;

  get puppyWeight => _puppyWeight;

  get color => _color;

  get ageInWeeks{
    try{
      return int.parse(_ageInWeeks).toString();
    }catch(e){
      return "0";
    }

  }

  get dob => _dob;

  get gender => _gender;

  List<ImageCustom> get gallery => _gallery;

  ImageCustom get image => _image;

  get description => _description;

  get shippingCost => _shippingCost;

  get puppyPrice => _puppyPrice;

  String get puppyName => _puppyName;

  get categoryId => _categoryId;

  int get puppyId => _puppyId;

  set categoryId(value) {
    _categoryId = value;
  }

  set categoryLink(value) {
    _categoryLink = value;
  }

  set categoryName(value) {
    _categoryName = value;
  }

  set status(value) {
    _status = value;
  }

  set registry(value) {
    _registry = value;
  }

  set puppyMomWeight(value) {
    _puppyMomWeight = value;
  }

  set puppyDadWeight(value) {
    _puppyDadWeight = value;
  }

  set puppyWeight(value) {
    _puppyWeight = value;
  }

  set color(value) {
    _color = value;
  }

  set ageInWeeks(value) {
    _ageInWeeks = value;
  }

  set dob(value) {
    _dob = value;
  }

  set gender(value) {
    _gender = value;
  }

  set gallery(value) {
    _gallery = value;
  }

  set image(value) {
    _image = value;
  }

  set description(value) {
    _description = value;
  }

  set shippingCost(value) {
    _shippingCost = value;
  }

  set puppyPrice(value) {
    if(_puppyPrice.trim()=="")
      value = "0";
    _puppyPrice = value;
  }

  set puppyName(String value) {
    _puppyName = value;
  }

  bool get isFamilyRaised => _isFamilyRaised;

  bool get isKidFriendly => _isKidFriendly;

  bool get isMicrochipped => _isMicrochipped;

  bool get isSocialized => _isSocialized;

  bool get isChampionBloodline => _isChampionBloodline;

}
