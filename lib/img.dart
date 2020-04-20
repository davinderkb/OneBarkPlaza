class ImageCustom{
  String _id, _src;
  bool _isCoverPic = false;

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  bool get isCoverPic => _isCoverPic;

  set isCoverPic(bool value) {
    _isCoverPic = value;
  }

  ImageCustom(this._id, this._src, this._isCoverPic);

  get src => _src;

  set src(value) {
    _src = value;
  }

}