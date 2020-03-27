import 'dart:convert';
import 'dart:ui';

class PuppyDetails {
  int _puppyId, _categoryId;
  String _puppyName,
      _puppyPrice,
      _shippingCost,
      _description,
      _images,
      _gallery,
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
      _categoryLink;

  PuppyDetails(
      this._puppyId,
      this._puppyName,
      this._puppyPrice,
      this._shippingCost,
      this._description,
      this._images,
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
      this._categoryLink);

  factory PuppyDetails.fromJson(dynamic json) {
    Map<String,dynamic> categoryDetails = (json['categories'][0] as Map<String,dynamic>);

    return PuppyDetails(
        json['ID'] as int,
        json['name'] as String,
        json['price'] as String,
        json['shipping_cost'] as String,
        json['description'] as String,
        json['images'] as String,
        json['gallery'] as String,
        json['gender'] as String,
        json['date_of_birth'] as String,
        json['age_in_weeks'] as String,
        json['color'] as String,
        json['puppy_weight'] as String,
        json['puppy_dad_weight'] as String,
        json['puppy_mom_weight'] as String,
        json['registry'] as String,
        json['status'] as String,
        categoryDetails["id"] as int,
        categoryDetails["name"] as String,
        categoryDetails["link"] as String);
  }

  get categoryLink => _categoryLink;

  get categoryName => _categoryName;

  get status => _status;

  get registry => _registry;

  get puppyMomWeight => _puppyMomWeight;

  get puppyDadWeight => _puppyDadWeight;

  get puppyWeight => _puppyWeight;

  get color => _color;

  get ageInWeeks => _ageInWeeks;

  get dob => _dob;

  get gender => _gender;

  get gallery => _gallery;

  get images => _images;

  get description => _description;

  get shippingCost => _shippingCost;

  get puppyPrice => _puppyPrice;

  String get puppyName => _puppyName;

  get categoryId => _categoryId;

  int get puppyId => _puppyId;
}
