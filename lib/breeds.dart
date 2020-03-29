import 'dart:convert';
import 'dart:ui';

class Breed {
  int _categoryId, _parentId, _count;
  String _name,_slug,_description,_display,_image,_menuOrder,_links;

  Breed(
      this._categoryId,
      this._parentId,
      this._count,
      this._name,
      this._slug,
      this._description,
      this._display,
      this._image,
      this._menuOrder,
      this._links);

  factory Breed.fromJson(dynamic json) {
    //Map<String,dynamic> categoryDetails = (json['categories'][0] as Map<String,dynamic>);

    /*return Breed(
        json['id'] as int,
        json['parent'] as int,
        json['count'] as int,
        json['name'] as String,
        json['slug'] as String,
        json['description'] as String,
        json['display'] as String,
        json['image'] as String,
        json['menu_order'] as String,
        json['_links'] as String);*/

    return Breed(
        json['id'] as int,
        json['parent'] as int,
        json['count'] as int,
        json['name'] as String,"","","","","","");
  }

  get links => _links;

  get menuOrder => _menuOrder;

  get image => _image;

  get display => _display;

  get description => _description;

  get slug => _slug;

  String get name => _name;

  get count => _count;

  get parentId => _parentId;

  int get categoryId => _categoryId;


}
