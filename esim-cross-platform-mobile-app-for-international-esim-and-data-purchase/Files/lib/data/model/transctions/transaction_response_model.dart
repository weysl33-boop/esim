import '../auth/sign_up_model/registration_response_model.dart';
import '../wallet/single_wallet_details.dart';

class TransactionResponseModel {
  TransactionResponseModel({String? remark, String? status, Message? message, Data? data}) {
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
  }

  TransactionResponseModel.fromJson(dynamic json) {
    _remark = json['remark'];
    _status = json['status'];
    _message = json['message'] != null ? Message.fromJson(json['message']) : null;
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  String? _remark;
  String? _status;
  Message? _message;
  Data? _data;

  String? get remark => _remark;
  String? get status => _status;
  Message? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remark'] = _remark;
    map['status'] = _status;
    if (_message != null) {
      map['message'] = _message?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({Transactions? transactions, List<Remarks>? remarks}) {
    _transactions = transactions;
    _remarks = remarks;
  }

  Data.fromJson(dynamic json) {
    _transactions = json['transactions'] != null ? Transactions.fromJson(json['transactions']) : null;
    if (json['remarks'] != null) {
      _remarks = [];
      json['remarks'].forEach((v) {
        _remarks?.add(Remarks.fromJson(v));
      });
    }
  }

  Transactions? _transactions;
  List<Remarks>? _remarks;

  Transactions? get transactions => _transactions;
  List<Remarks>? get remarks => _remarks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_remarks != null) {
      map['remarks'] = _remarks?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Remarks {
  Remarks({String? remark}) {
    _remark = remark;
  }

  Remarks.fromJson(dynamic json) {
    _remark = json['remark'];
  }
  String? _remark;

  String? get remark => _remark;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remark'] = _remark;
    return map;
  }
}

class Transactions {
  Transactions({List<TransactionSingleData>? data, dynamic nextPageUrl, String? path}) {
    _data = data;
    _nextPageUrl = nextPageUrl;
    _path = path;
  }

  Transactions.fromJson(dynamic json) {
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(TransactionSingleData.fromJson(v));
      });
    }
    _nextPageUrl = json['next_page_url'];
    _path = json['path'];
  }

  List<TransactionSingleData>? _data;
  dynamic _nextPageUrl;
  String? _path;

  List<TransactionSingleData>? get data => _data;
  dynamic get nextPageUrl => _nextPageUrl;
  String? get path => _path;
}
