class DataCollection {
  bool? success;
  String? message;
  String? redirect;
  Data? data;

  DataCollection({this.success, this.message, this.redirect, this.data});

  DataCollection.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    redirect = json['redirect'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    data['message'] = this.message;
    data['redirect'] = this.redirect;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Country>? countries;
  List<City>? cities;
  List<ExpenseType>? expenseType;
  List<Language>? languages;

  Data({this.countries, this.cities, this.expenseType, this.languages});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['countries'] != null) {
      countries = <Country>[];
      json['countries'].forEach((v) {
        countries!.add(Country.fromJson(v));
      });
    }
    if (json['cities'] != null) {
      cities = <City>[];
      json['cities'].forEach((v) {
        cities!.add(City.fromJson(v));
      });
    }
    if (json['expense_type'] != null) {
      expenseType = <ExpenseType>[];
      json['expense_type'].forEach((v) {
        expenseType!.add(ExpenseType.fromJson(v));
      });
    }
    if (json['languages'] != null) {
      languages = <Language>[];
      json['languages'].forEach((v) {
        languages!.add(Language.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (countries != null) {
      data['countries'] = countries!.map((v) => v.toJson()).toList();
    }
    if (cities != null) {
      data['cities'] = cities!.map((v) => v.toJson()).toList();
    }
    if (expenseType != null) {
      data['expense_type'] = expenseType!.map((v) => v.toJson()).toList();
    }
    if (languages != null) {
      data['languages'] = languages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Country {
  int? id;
  String? name;
  String? code;
  String? abbr;
  String? flag;
  int? mobileNumberLength;
  String? mobileNumberPlaceholder;
  int? orderBy;
  int? status;

  Country({
    this.id,
    this.name,
    this.code,
    this.abbr,
    this.flag,
    this.mobileNumberLength,
    this.mobileNumberPlaceholder,
    this.orderBy,
    this.status,
  });

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    abbr = json['abbr'];
    flag = json['flag'];
    mobileNumberLength = json['mobile_number_length'];
    mobileNumberPlaceholder = json['mobile_number_placeholder'];
    orderBy = json['order_by'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['abbr'] = abbr;
    data['flag'] = flag;
    data['mobile_number_length'] = mobileNumberLength;
    data['mobile_number_placeholder'] = mobileNumberPlaceholder;
    data['order_by'] = orderBy;
    data['status'] = status;
    return data;
  }
}

class City {
  int? id;
  int? countryId;
  String? name;
  int? status;

  City({
    this.id,
    this.countryId,
    this.name,
    this.status,
  });

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryId = json['country_id'];
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country_id'] = countryId;
    data['name'] = name;
    data['status'] = status;
    return data;
  }
}


class ExpenseType {
  int? id;
  String? expenseName;
  String? expenseNameAr;
  int? orderBy;
  int? status;

  ExpenseType(
      {this.id,
        this.expenseName,
        this.expenseNameAr,
        this.orderBy,
        this.status});

  ExpenseType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    expenseName = json['expense_name'];
    expenseNameAr = json['expense_name_ar'];
    orderBy = json['order_by'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['expense_name'] = this.expenseName;
    data['expense_name_ar'] = this.expenseNameAr;
    data['order_by'] = this.orderBy;
    data['status'] = this.status;
    return data;
  }
}

class Language {
  int? id;
  String? abbr;
  String? name;
  dynamic flag;
  dynamic dateFormat;
  dynamic datetimeFormat;
  String? direction;
  String? status;
  String? isDefault;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;

  Language({
    this.id,
    this.abbr,
    this.name,
    this.flag,
    this.dateFormat,
    this.datetimeFormat,
    this.direction,
    this.status,
    this.isDefault,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  Language.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    abbr = json['abbr'];
    name = json['name'];
    flag = json['flag'];
    dateFormat = json['date_format'];
    datetimeFormat = json['datetime_format'];
    direction = json['direction'];
    status = json['status'];
    isDefault = json['is_default'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['abbr'] = abbr;
    data['name'] = name;
    data['flag'] = flag;
    data['date_format'] = dateFormat;
    data['datetime_format'] = datetimeFormat;
    data['direction'] = direction;
    data['status'] = status;
    data['is_default'] = isDefault;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}