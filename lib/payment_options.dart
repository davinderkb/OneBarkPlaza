import 'package:intl/intl.dart';
import 'package:one_bark_plaza/util/utility.dart';

/***
 * For every new payment method define these 3 things :
 * 1. initial flag
 * 2. current flag
 * 3. class schema
 */
class PaymentMode {
  bool _isPayPal, _isZelle, _isDirectBank;
  Paypal _paypal;
  Zelle _zelle;
  BankAccount _bankAccount;

  PaymentMode(this._isPayPal, this._isZelle, this._isDirectBank, this._paypal,
      this._zelle, this._bankAccount){


  }

  PaymentMode deepCopy(){
      Paypal paypal = new Paypal("");
      Zelle zelle = new Zelle("");
      BankAccount account = new BankAccount("", "", "","","","","","");
      if(isPayPal){
        paypal.paypalEmail = this.paypal.paypalEmail;
      }
      if(isZelle){
        zelle.zelleEmail = this.zelle.zelleEmail;
      }
      if(isDirectBank){
        account.accountType = this.bankAccount.accountType;
        account.bankAccountNum = this.bankAccount.bankAccountNum;
        account.bankName = this.bankAccount.bankName;
        account.abaRoutingNum = this.bankAccount.abaRoutingNum;
        account.bankAddress = this.bankAccount.bankAddress;
        account.destinationCurrency = this.bankAccount.destinationCurrency;
        account.ibanNum = this.bankAccount.ibanNum;
        account.accountHolderName = this.bankAccount.accountHolderName;
      }
      return new PaymentMode(this.isPayPal, this.isZelle, this.isDirectBank, paypal, zelle, account)  ;
  }

  bool equals(PaymentMode toBeCompared){
    if(!(toBeCompared.isPayPal==isPayPal && toBeCompared.isZelle==isZelle && toBeCompared.isDirectBank==isDirectBank))
      return false;
    if(isPayPal){
      if(paypal.paypalEmail==toBeCompared.paypal.paypalEmail)
       return true;
    }
    if(isZelle){
      if(zelle.zelleEmail==toBeCompared.zelle.zelleEmail)
        return true;
    }
    if(isDirectBank){
     if(bankAccount.accountType == toBeCompared.bankAccount.accountType &&
         bankAccount.bankAccountNum == toBeCompared.bankAccount.bankAccountNum &&
         bankAccount.bankName == toBeCompared.bankAccount.bankName &&
         bankAccount.abaRoutingNum == toBeCompared.bankAccount.abaRoutingNum &&
         bankAccount.bankAddress == toBeCompared.bankAccount.bankAddress &&
         bankAccount.destinationCurrency == toBeCompared.bankAccount.destinationCurrency &&
         bankAccount.ibanNum == toBeCompared.bankAccount.ibanNum &&
         bankAccount.accountHolderName == toBeCompared.bankAccount.accountHolderName){
       return true;
     }
    }
    return false;
  }

  factory PaymentMode.fromJson(dynamic json) {
    if (json["payment_mode"] == "paypal_payout") {
     return PaymentMode(true,
          false,
          false,
          new Paypal(json["paypal_email"] as String),
          new Zelle(""),
          new BankAccount("","","","","","","",""));
    } else if (json["payment_mode"] == "direct_bank") {
      return PaymentMode(false,
          false,
          true,
          new Paypal(""),
          new Zelle(""),
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
          new Paypal(""),
          new Zelle(json["zelle_email"] as String),
          new BankAccount("","","","","","","",""));
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




  BankAccount get bankAccount => _bankAccount;

  Zelle get zelle => _zelle;

  Paypal get paypal => _paypal;


}

class Paypal {
  String _paypalEmail;

  String get paypalEmail => _paypalEmail;

  set paypalEmail(String value) {
    _paypalEmail = value;
  }

  Paypal(this._paypalEmail);
}

class Zelle {
  String _zelleEmail;

  set zelleEmail(String value) {
    _zelleEmail = value;
  }

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

  set accountType(String value) {
    _accountType = value;
  }

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

  set bankAccountNum(value) {
    _bankAccountNum = value;
  }

  set bankName(value) {
    _bankName = value;
  }

  set abaRoutingNum(value) {
    _abaRoutingNum = value;
  }

  set bankAddress(value) {
    _bankAddress = value;
  }

  set destinationCurrency(value) {
    _destinationCurrency = value;
  }

  set ibanNum(value) {
    _ibanNum = value;
  }

  set accountHolderName(value) {
    _accountHolderName = value;
  }
}
