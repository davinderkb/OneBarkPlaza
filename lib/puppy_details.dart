import 'dart:convert';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:one_bark_plaza/util/constants.dart';

import 'img.dart';

class PuppyDetails {
  int _puppyId, _categoryId;
  List<ImageCustom> _gallery;
  DateTime _dob,_checkupDate;
  bool _isSoldByObp;
  String _puppyName,
      _puppyPrice,
      _shippingCost,
      _description,
      _gender,
      _dobString,
      _ageInWeeks,
      _color,
      _puppyWeight,
      _puppyDadWeight,
      _puppyMomWeight,
      _registry,
      _status,
      _categoryName,
      _categoryLink,
      _vetName,
      _vetAddress,
      _vetReport,
      _checkUpDateString,
      _flightTicket
      ;

  bool get isSoldByObpPrivate => _isSoldByObp;
  bool get isSold{
    if (_status=="sold" || _status == "soldobp"){
      return true;
    }
    return false;
  }

  /**
   * This method need occured to support old entries when soldobp status was not introduced
   * and we used to rely on status="sold" and "sold-by-obp" bool to findout if it Sold By OBP. statusString message takes care of this backward compatibility
   * So here we customized getter based on statuString result
   */
  bool isSoldByObp(){
    return statusString==Constants.SOLD_BY_OBP;
  }

  set isSoldByObpPrivate(bool value) {
    _isSoldByObp = value;
  }

  ImageCustom _coverPic;

  ImageCustom get coverPic => _coverPic;

  bool get isFemale {
    return this._gender.toLowerCase() == "female";
  }

  set coverPic(ImageCustom value) {
    _coverPic = value;
  }

  get vetName => _vetName;

  set vetName(value) {
    _vetName = value;
  }

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
      this._gallery,
      this._gender,
      this._dobString,
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
      this._vetName,
      this._vetAddress,
      this._vetReport,
      this._checkUpDateString,
      this._flightTicket,
      this._isChampionBloodline,
      this._isFamilyRaised,
      this._isKidFriendly,
      this._isMicrochipped,
      this._isSocialized,
      this._isSoldByObp){
    try{
      this._dob = new DateTime.fromMillisecondsSinceEpoch(_dobString.contains(".")?int.parse(_dobString.substring(0,_dobString.indexOf("."))):int.parse(_dobString));
      this._dobString = new DateFormat("MMM dd, yyyy").format(_dob);
    }catch(e){
      this._dobString = "";
      this._dob = DateTime.now();
    }
    try{
      this._checkupDate = new DateTime.fromMillisecondsSinceEpoch(_checkUpDateString.contains(".")?int.parse(_checkUpDateString.substring(0,_checkUpDateString.indexOf("."))):int.parse(_checkUpDateString));
      this._checkUpDateString = new DateFormat("MMM dd, yyyy").format(_checkupDate);
    }catch(e){
      this._checkUpDateString = "";
      this._checkupDate = DateTime.now();
    }
    if(_gallery.length>0){
      for(ImageCustom item in _gallery){
        if(item.isCoverPic){
          coverPic = item;
          break;
        }
      }
     if(coverPic == null){
       coverPic = _gallery[0];
     }
    }

  }



  PuppyDetails.deepCopy(
      this._puppyId,
      this._puppyName,
      this._puppyPrice,
      this._shippingCost,
      this._description,
      this._gallery,
      this._gender,
      this._dobString,
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
      this._vetName,
      this._vetAddress,
      this._vetReport,
      this._checkUpDateString,
      this._checkupDate,
      this._flightTicket,
      this._isChampionBloodline,
      this._isFamilyRaised,
      this._isKidFriendly,
      this._isMicrochipped,
      this._isSocialized,
      this._isSoldByObp,
      this._coverPic);

  factory PuppyDetails.fromJson(dynamic json) {
    Map<String,dynamic> categoryDetails = (json['categories'][0] as Map<String,dynamic>);

    List<ImageCustom> galleryImages = new List<ImageCustom>();

    try {
      for(dynamic items in json['gallery-images']){
        var item = (items as Map<String, dynamic>);
        galleryImages.add(ImageCustom(item["id"].toString(), item["src"], item["isCoverPic"]));
      }
    }catch(e){}

      return PuppyDetails(
        int.parse(json['ID'].toString()) as int,
        json['name'] as String,
        json['price'].toString().trim() == "" ? "0" : json['price'].toString().trim(),
        json['shipping_cost'] as String,
        json['description'] as String,
        galleryImages,
        json['gender'] as String,
        json['date_of_birth'] is int || json['date_of_birth'] is String || json['date_of_birth'] is double? json['date_of_birth'].toString(): "",
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
        json["vet-name"] as String,
        json["vet-address"] as String,
        json["report-copy"] as String,
        json['checkup-date'] is int || json['checkup-date'] is String? json['checkup-date'].toString(): "",
        json["flight-doc"] as String,
        json['champion-bloodlines'].toString() == '1',
        json['family-raised'].toString() == '1',
        json['kid-friendly'].toString() == '1',
        json['microchipped'].toString() == '1',
        json['socialized'].toString() == '1',
        json['sold-by-obp'].toString() == '1',

      );
    }


  get categoryLink => _categoryLink;

  get categoryName => _categoryName;


  get registry => _registry;

  get puppyMomWeight => _puppyMomWeight;

  get puppyDadWeight => _puppyDadWeight;

  get status => _status;
  get statusString {
    String statusString = status;
    switch (statusString) {
      case "pending":
        statusString= "Pending for Approval";
        break;
      case "draft":
        statusString=  "Draft";
        break;
      case "pricechange":
        statusString=  "Price Change, Pending for Approval";
        break;
      case "soldobp":
        statusString= Constants.SOLD_BY_OBP;
        break;
        //In Old entries we may not get soldbyobp, So we'll rely on status="sold" & sold-by-opb value together from API response
      case "sold":
        if (!isSoldByObpPrivate)
          statusString=  "Sold By Breeder";
        else
          statusString= Constants.SOLD_BY_OBP;
        break;
      case "healthissue":
        statusString=  "Health Issue, Pending for Approval";
        break;
      case "datacorrection":
        statusString=  "Data Correction, Pending for Approval";
        break;
      case "photochange":
        statusString=  "Pic changed, Pending for Approval";
        break;
      case "duplicatepuppy":
        statusString=  "Duplicate";
        break;
      case "reviewpuppy":
        statusString=  "Pending for review with Breeder";
        break;
      case "upcoming_litters":
        statusString=  "Upcoming Litters";
        break;
    }
    return statusString;
  }

  get puppyWeight => _puppyWeight;

  get color => _color;

  get ageInWeeks{
    try{
      return int.parse(_ageInWeeks).toString();
    }catch(e){
      return "0";
    }

  }

  DateTime get checkupDate {
    return _checkupDate;
  }
  get checkUpDateString {
    return  _checkUpDateString;
  }

  DateTime get dob {
    return _dob;
  }
  get dobString {
   return  _dobString;
  }

  get gender => _gender;

  List<ImageCustom> get gallery => _gallery;

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

  int imageCount() {
    int count = 0;
    if(_gallery!=null)
      count = count + _gallery.length;
    return count;
  }

  get vetAddress => _vetAddress;

  set vetAddress(value) {
    _vetAddress = value;
  }

}
