import 'package:intl/intl.dart';
import 'package:one_bark_plaza/util/utility.dart';

/***
 * For every new payment method define these 3 things :
 * 1. initial flag
 * 2. current flag
 * 3. class schema
 */
class PaymentMode {
  bool _isPayPal, _isZelle, _isDirectBank, _isInitialPayPal, _isInitialZelle, _isInitialDirectBank;
  Paypal _paypal;
  Zelle _zelle;
  BankAccount _bankAccount;

  PaymentMode(this._isPayPal, this._isZelle, this._isDirectBank, this._paypal,
      this._zelle, this._bankAccount){
    _isInitialDirectBank = _isDirectBank;
    _isInitialZelle = _isZelle;
    _isInitialPayPal = _isPayPal;

  }

  // ignore: missing_return
  factory PaymentMode.fromJson(dynamic json) {
    if (json["payment_mode"] == "paypal_payout") {
     return PaymentMode(true,
          false,
          false,
          new Paypal(json["paypal_email"] as String),
          null,
          null);
    } else if (json["payment_mode"] == "direct_bank") {
      return PaymentMode(false,
          false,
          true,
          null,
          null,
          new BankAccount(
              json["account_type"],
              json["bank_account_number"],
              json["bank_name"],
              json["aba_routing_number"],
              json["bank_address"],
              json["destination_currency"],
              json["iban"],
              json["account_holder_name"],
          )
      );
    } else {
      return PaymentMode(false,
          true,
          false,
          null,
          new Zelle(json["zelle_email"] as String),
          null);
    }
  }

  bool get isPayPal => _isPayPal;

  set isPayPal(bool value) {
    _isPayPal = value;
    if(_isPayPal){
      _isZelle = false;
      _isDirectBank = false;
    }
  }

  get isZelle => _isZelle;

  set isZelle(value) {
    _isZelle = value;
    if(_isZelle){
      _isPayPal = false;
      _isDirectBank = false;
    }
  }

  get isDirectBank => _isDirectBank;

  set isDirectBank(value) {
    _isDirectBank = value;
    if(_isDirectBank){
      _isZelle = false;
      _isPayPal = false;
    }
  }

  bool isSelectionChanged(){
    return _isPayPal==_isInitialPayPal && _isZelle==_isInitialZelle && _isDirectBank == isInitialDirectBank;
  }
  get isInitialPayPal => _isInitialPayPal;

  BankAccount get bankAccount => _bankAccount;

  Zelle get zelle => _zelle;

  Paypal get paypal => _paypal;

  get isInitialDirectBank => _isInitialDirectBank;

  get isInitialZelle => _isInitialZelle;
}

class Paypal {
  String _paypalEmail;

  String get paypalEmail => _paypalEmail;

  Paypal(this._paypalEmail);
}

class Zelle {
  String _zelleEmail;

  String get zelleEmail => _zelleEmail;

  Zelle(this._zelleEmail);
}

class BankAccount {
  String _accountType,
      _bankAccountNum,
      _bankName,
      _abaRoutingNum,
      _bankAddress,
      _destinationCurrency,
      _ibanNum,
      _accountHolderName;

  BankAccount(
      this._accountType,
      this._bankAccountNum,
      this._bankName,
      this._abaRoutingNum,
      this._bankAddress,
      this._destinationCurrency,
      this._ibanNum,
      this._accountHolderName);

  get accountHolderName => _accountHolderName;

  get ibanNum => _ibanNum;

  get destinationCurrency => _destinationCurrency;

  get bankAddress => _bankAddress;

  get abaRoutingNum => _abaRoutingNum;

  get bankName => _bankName;

  get bankAccountNum => _bankAccountNum;

  String get accountType => _accountType;
}
