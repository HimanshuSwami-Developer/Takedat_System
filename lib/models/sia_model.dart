class SiaLicenceModel {

  final int? id;

  final String userId;

  final String url;

  final String siaHolderName;

  final String siaLicenceNumber;

  final DateTime siaLicenceExpiry;

  final DateTime? siaLicenceExpiry3m;
  final DateTime? siaLicenceExpiry2m;
  final DateTime? siaLicenceExpiry1m;

  final int mailCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  SiaLicenceModel({

    this.id,

    required this.userId,

    required this.url,

    required this.siaHolderName,

    required this.siaLicenceNumber,

    required this.siaLicenceExpiry,

    this.siaLicenceExpiry3m,
    this.siaLicenceExpiry2m,
    this.siaLicenceExpiry1m,

    this.mailCount = 0,

    this.createdAt,
    this.updatedAt,
  });

  factory SiaLicenceModel.fromJson(
      Map<String, dynamic> json) {

    return SiaLicenceModel(

      id: json['id'],

      userId: json['user_id'],

      url: json['url'],

      siaHolderName:
          json['sia_holder_name'],

      siaLicenceNumber:
          json['sia_licence_number'],

      siaLicenceExpiry:
          DateTime.parse(
            json['sia_licence_expiry'],
          ),

      siaLicenceExpiry3m:
          json['sia_licence_expiry_3m'] != null
              ? DateTime.parse(
                  json['sia_licence_expiry_3m'],
                )
              : null,

      siaLicenceExpiry2m:
          json['sia_licence_expiry_2m'] != null
              ? DateTime.parse(
                  json['sia_licence_expiry_2m'],
                )
              : null,

      siaLicenceExpiry1m:
          json['sia_licence_expiry_1m'] != null
              ? DateTime.parse(
                  json['sia_licence_expiry_1m'],
                )
              : null,

      mailCount:
          json['mail_count'] ?? 0,

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

      "url": url,

      "sia_holder_name":
          siaHolderName,

      "sia_licence_number":
          siaLicenceNumber,

      "sia_licence_expiry":
          siaLicenceExpiry
              .toIso8601String(),

      "sia_licence_expiry_3m":
          siaLicenceExpiry3m
              ?.toIso8601String(),

      "sia_licence_expiry_2m":
          siaLicenceExpiry2m
              ?.toIso8601String(),

      "sia_licence_expiry_1m":
          siaLicenceExpiry1m
              ?.toIso8601String(),

      "mail_count":
          mailCount,

    };
  }
}