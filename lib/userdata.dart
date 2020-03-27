
class UserData{
  String _id, _name, _email;

  String get id => _id;

  String get name => _name;


  UserData(this._id, this._name, this._email);




  factory UserData.fromJson(dynamic json) {

    return UserData(json['ID'] as String,json['display_name'] as String, json['user_email']);
  }

  get email => _email;




}