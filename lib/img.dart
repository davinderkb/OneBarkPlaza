class ImageCustom{
  String _id, _src;

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  ImageCustom(this._id, this._src);

  get src => _src;

  set src(value) {
    _src = value;
  }

}