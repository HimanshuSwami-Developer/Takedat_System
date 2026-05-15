class SignedDocumentsModel {

  final int? id;

  final String userId;

  final String? signedAuthenticationUrl;

  final String? signedScreeningUrl;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  SignedDocumentsModel({

    this.id,

    required this.userId,

    this.signedAuthenticationUrl,

    this.signedScreeningUrl,

    this.createdAt,

    this.updatedAt,
  });

  factory SignedDocumentsModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return SignedDocumentsModel(

      id: json['id'],

      userId: json['user_id'],

      signedAuthenticationUrl:
          json['signed_authentication_url'],

      signedScreeningUrl:
          json['signed_screening_url'],

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

      if (id != null)
        "id": id,

      "user_id": userId,

      "signed_authentication_url":
          signedAuthenticationUrl,

      "signed_screening_url":
          signedScreeningUrl,
    };
  }
}