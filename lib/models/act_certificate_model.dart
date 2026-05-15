class ActCertificateModel {

  final int? id;

  final String userId;

  final String? actOrangeUrl;
  final String? actBlueUrl;

  final String? orangeHolderName;
  final String? blueHolderName;

  final DateTime? actOrangeExpiry;
  final DateTime? actBlueExpiry;

  final DateTime? actOrangeExpiry15d;
  final DateTime? actBlueExpiry15d;

  final int orangeMailCount;
  final int blueMailCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  ActCertificateModel({

    this.id,

    required this.userId,

    this.actOrangeUrl,
    this.actBlueUrl,

    this.orangeHolderName,
    this.blueHolderName,

    this.actOrangeExpiry,
    this.actBlueExpiry,

    this.actOrangeExpiry15d,
    this.actBlueExpiry15d,

    this.orangeMailCount = 0,
    this.blueMailCount = 0,

    this.createdAt,
    this.updatedAt,
  });

  factory ActCertificateModel.fromJson(
      Map<String, dynamic> json) {

    return ActCertificateModel(

      id: json['id'],

      userId: json['user_id'],

      actOrangeUrl: json['act_orange_url'],

      actBlueUrl: json['act_blue_url'],

      orangeHolderName:
          json['orange_holder_name'],

      blueHolderName:
          json['blue_holder_name'],

      actOrangeExpiry:
          json['act_orange_expiry'] != null
              ? DateTime.parse(
                  json['act_orange_expiry'],
                )
              : null,

      actBlueExpiry:
          json['act_blue_expiry'] != null
              ? DateTime.parse(
                  json['act_blue_expiry'],
                )
              : null,

      actOrangeExpiry15d:
          json['act_orange_expiry_15d'] != null
              ? DateTime.parse(
                  json['act_orange_expiry_15d'],
                )
              : null,

      actBlueExpiry15d:
          json['act_blue_expiry_15d'] != null
              ? DateTime.parse(
                  json['act_blue_expiry_15d'],
                )
              : null,

      orangeMailCount:
          json['orange_mail_count'] ?? 0,

      blueMailCount:
          json['blue_mail_count'] ?? 0,

      createdAt: json['created_at'] != null
          ? DateTime.parse(
              json['created_at'],
            )
          : null,

      updatedAt: json['updated_at'] != null
          ? DateTime.parse(
              json['updated_at'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {

    return {
       if (id != null) "id": id,

      "user_id": userId,

      "act_orange_url": actOrangeUrl,

      "act_blue_url": actBlueUrl,

      "orange_holder_name":
          orangeHolderName,

      "blue_holder_name":
          blueHolderName,

      "act_orange_expiry":
          actOrangeExpiry?.toIso8601String(),

      "act_blue_expiry":
          actBlueExpiry?.toIso8601String(),

      "act_orange_expiry_15d":
          actOrangeExpiry15d
              ?.toIso8601String(),

      "act_blue_expiry_15d":
          actBlueExpiry15d
              ?.toIso8601String(),

      "orange_mail_count":
          orangeMailCount,

      "blue_mail_count":
          blueMailCount,

      if (createdAt != null)"created_at":
          createdAt?.toIso8601String(),

      if (updatedAt != null)"updated_at":
          updatedAt?.toIso8601String(),
    };
  }
}