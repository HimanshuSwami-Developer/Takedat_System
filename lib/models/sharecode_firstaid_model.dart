class SharecodeFirstAidModel {

  final int? id;

  final String userId;

  final String? shareCodeUrl;
  final String? shareCodeNumber;
  final String? shareCodeHolderName;

  final DateTime? shareCodeExpiry;
  final DateTime? shareCodeExpiry15d;

  final int sharecodeMailCount;

  final String? firstAidUrl;
  final String? firstAidHolderName;

  final DateTime? firstAidExpiry;
  final DateTime? firstAidExpiry1m;

  final int firstAidMailCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  SharecodeFirstAidModel({

    this.id,

    required this.userId,

    this.shareCodeUrl,
    this.shareCodeNumber,
    this.shareCodeHolderName,

    this.shareCodeExpiry,
    this.shareCodeExpiry15d,

    this.sharecodeMailCount = 0,

    this.firstAidUrl,
    this.firstAidHolderName,

    this.firstAidExpiry,
    this.firstAidExpiry1m,

    this.firstAidMailCount = 0,

    this.createdAt,
    this.updatedAt,
  });

  factory SharecodeFirstAidModel.fromJson(
      Map<String, dynamic> json) {

    return SharecodeFirstAidModel(

      id: json['id'],

      userId: json['user_id'],

      shareCodeUrl:
          json['share_code_url'],

      shareCodeNumber:
          json['share_code_number'],

      shareCodeHolderName:
          json['share_code_holder_name'],

      shareCodeExpiry:
          json['share_code_expiry'] != null
              ? DateTime.parse(
                  json['share_code_expiry'],
                )
              : null,

      shareCodeExpiry15d:
          json['share_code_expiry_15d'] != null
              ? DateTime.parse(
                  json['share_code_expiry_15d'],
                )
              : null,

      sharecodeMailCount:
          json['sharecode_mail_count'] ?? 0,

      firstAidUrl:
          json['first_aid_url'],

      firstAidHolderName:
          json['first_aid_holder_name'],

      firstAidExpiry:
          json['first_aid_expiry'] != null
              ? DateTime.parse(
                  json['first_aid_expiry'],
                )
              : null,

      firstAidExpiry1m:
          json['first_aid_expiry_1m'] != null
              ? DateTime.parse(
                  json['first_aid_expiry_1m'],
                )
              : null,

      firstAidMailCount:
          json['first_aid_mail_count'] ?? 0,

      createdAt:
          json['created_at'] != null
              ? DateTime.parse(
                  json['created_at'],
                )
              : null,

      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(
                  json['updated_at'],
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {

    return {

      "user_id": userId,

      "share_code_url":
          shareCodeUrl,

      "share_code_number":
          shareCodeNumber,

      "share_code_holder_name":
          shareCodeHolderName,

      "share_code_expiry":
          shareCodeExpiry
              ?.toIso8601String(),

      "share_code_expiry_15d":
          shareCodeExpiry15d
              ?.toIso8601String(),

      "sharecode_mail_count":
          sharecodeMailCount,

      "first_aid_url":
          firstAidUrl,

      "first_aid_holder_name":
          firstAidHolderName,

      "first_aid_expiry":
          firstAidExpiry
              ?.toIso8601String(),

      "first_aid_expiry_1m":
          firstAidExpiry1m
              ?.toIso8601String(),

      "first_aid_mail_count":
          firstAidMailCount,

    };
  }
}