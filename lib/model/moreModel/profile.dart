class ProfileModel {
  bool? success;
  String? message;
  String? redirect;
  User? user;

  ProfileModel({this.success, this.message, this.redirect, this.user});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    redirect = json['redirect'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['redirect'] = this.redirect;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? username;
  String? email;
  String? firebaseEmail;
  String? mobile;
  String? photo;
  int? role;
  String? thumbnail;
  String? theme;
  String? locale;
  int? userType;
  int? accountType;
  int? isOnline;
  int? status;
  String? androidDeviceId;
  String? iosDeviceId;
  String? webDeviceId;
  String? createdAt;
  String? updatedAt;
  Null? reason;
  UserDetail? userDetail;

  User(
      {this.id,
        this.name,
        this.username,
        this.email,
        this.firebaseEmail,
        this.mobile,
        this.photo,
        this.role,
        this.thumbnail,
        this.theme,
        this.locale,
        this.userType,
        this.accountType,
        this.isOnline,
        this.status,
        this.androidDeviceId,
        this.iosDeviceId,
        this.webDeviceId,
        this.createdAt,
        this.updatedAt,
        this.reason,
        this.userDetail});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    firebaseEmail = json['firebase_email'];
    mobile = json['mobile'];
    photo = json['photo'];
    role = json['role'];
    thumbnail = json['thumbnail'];
    theme = json['theme'];
    locale = json['locale'];
    userType = json['user_type'];
    accountType = json['account_type'];
    isOnline = json['is_online'];
    status = json['status'];
    androidDeviceId = json['android_device_id'];
    iosDeviceId = json['ios_device_id'];
    webDeviceId = json['web_device_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    reason = json['reason'];
    userDetail = json['user_detail'] != null
        ? new UserDetail.fromJson(json['user_detail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['firebase_email'] = this.firebaseEmail;
    data['mobile'] = this.mobile;
    data['photo'] = this.photo;
    data['role'] = this.role;
    data['thumbnail'] = this.thumbnail;
    data['theme'] = this.theme;
    data['locale'] = this.locale;
    data['user_type'] = this.userType;
    data['account_type'] = this.accountType;
    data['is_online'] = this.isOnline;
    data['status'] = this.status;
    data['android_device_id'] = this.androidDeviceId;
    data['ios_device_id'] = this.iosDeviceId;
    data['web_device_id'] = this.webDeviceId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['reason'] = this.reason;
    if (this.userDetail != null) {
      data['user_detail'] = this.userDetail!.toJson();
    }
    return data;
  }
}

class UserDetail {
  int? id;
  int? userId;
  CityId? cityId;
  ExpenseTypeId? expenseTypeId;
  String? instaLink;
  String? twitterLink;
  String? contactNo;
  String? whatsapp;
  String? website;
  String? location;
  String? locationLat;
  String? locationLng;

  UserDetail(
      {this.id,
        this.userId,
        this.cityId,
        this.expenseTypeId,
        this.instaLink,
        this.twitterLink,
        this.contactNo,
        this.whatsapp,
        this.website,
        this.location,
        this.locationLat,
        this.locationLng});

  UserDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    cityId =
    json['city_id'] != null ? new CityId.fromJson(json['city_id']) : null;
    expenseTypeId = json['expense_type_id'] != null
        ? new ExpenseTypeId.fromJson(json['expense_type_id'])
        : null;
    instaLink = json['insta_link'];
    twitterLink = json['twitter_link'];
    contactNo = json['contact_no'];
    whatsapp = json['whatsapp'];
    website = json['website'];
    location = json['location'];
    locationLat = json['location_lat'];
    locationLng = json['location_lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    if (this.cityId != null) {
      data['city_id'] = this.cityId!.toJson();
    }
    if (this.expenseTypeId != null) {
      data['expense_type_id'] = this.expenseTypeId!.toJson();
    }
    data['insta_link'] = this.instaLink;
    data['twitter_link'] = this.twitterLink;
    data['contact_no'] = this.contactNo;
    data['whatsapp'] = this.whatsapp;
    data['website'] = this.website;
    data['location'] = this.location;
    data['location_lat'] = this.locationLat;
    data['location_lng'] = this.locationLng;
    return data;
  }
}

class CityId {
  int? id;
  Name? name;

  CityId({this.id, this.name});

  factory CityId.fromJson(dynamic json) {
    try {
      print('[CityId] Parsing city data: $json');

      if (json == null) {
        print('[CityId] Null input, returning empty CityId');
        return CityId();
      }

      if (json is Map<String, dynamic>) {
        print('[CityId] Parsing as Map');
        return CityId(
          id: _parseId(json['id']),
          name: _parseName(json['name']),
        );
      } else if (json is int || json is String) {
        print('[CityId] Parsing as ID only');
        return CityId(
          id: json is int ? json : int.tryParse(json),
        );
      } else {
        print('[CityId] Unknown format, returning empty');
        return CityId();
      }
    } catch (e) {
      print('[CityId] Error parsing city: $e');
      return CityId();
    }
  }

  static int? _parseId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    return int.tryParse(id.toString());
  }

  static Name? _parseName(dynamic nameData) {
    try {
      if (nameData == null) {
        print('[CityId] Name is null');
        return null;
      }

      if (nameData is Map<String, dynamic>) {
        print('[CityId] Parsing name as Map');
        return Name.fromJson(nameData);
      }

      if (nameData is String) {
        print('[CityId] Parsing name as String');
        return Name(en: nameData, ar: nameData);
      }

      print('[CityId] Unknown name format: $nameData');
      return null;
    } catch (e) {
      print('[CityId] Error parsing name: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name?.toJson(),
    };
  }
}

class Name {
  String? ar;
  String? en;

  Name({this.ar, this.en});

  Name.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ar'] = this.ar;
    data['en'] = this.en;
    return data;
  }
}

class ExpenseTypeId {
  int? id;
  String? expenseName;
  String? expenseNameAr;

  ExpenseTypeId({this.id, this.expenseName, this.expenseNameAr});

  ExpenseTypeId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    expenseName = json['expense_name'];
    expenseNameAr = json['expense_name_ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['expense_name'] = this.expenseName;
    data['expense_name_ar'] = this.expenseNameAr;
    return data;
  }
}