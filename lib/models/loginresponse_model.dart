class LoginResponseModel {
  LoginResponseModel({
    required this.statusCode,
    required this.success,
    required this.body,
  });

  final int? statusCode;
  final bool? success;
  final Body? body;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      statusCode: json["statusCode"],
      success: json["success"],
      body: json["body"] == null ? null : Body.fromJson(json["body"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "success": success,
    "body": body?.toJson(),
  };
}

class Body {
  Body({required this.message, required this.data});

  final String? message;
  final Data? data;

  factory Body.fromJson(Map<String, dynamic> json) {
    return Body(
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  Data({required this.accessToken, required this.refreshToken});

  final String? accessToken;
  final String? refreshToken;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
    );
  }

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "refreshToken": refreshToken,
  };
}
