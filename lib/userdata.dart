
import 'package:one_bark_plaza/util/utility.dart';

class UserData{
  String _id, _name, _email, _gender, _profileImage;

  String get gender => _gender;

  get profileImage => _profileImage;

  String get id => _id;

  String get name => _name;


  UserData(this._id, this._name, this._email,String gender, this._profileImage){
    if(gender == null){
      gender = "Male";
    }
    this._gender = Utility.capitalize(gender);
  }




  factory UserData.fromJson(dynamic json) {
    return UserData(json['ID'] as String,json['display_name'] as String, json['user_email'],json['gender'] as String, json["profile_image"] as String);
  }

  get email => _email;




}