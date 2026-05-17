/// ======================================================
/// SHIFT MODEL
/// ======================================================

class ShiftModel {

  final int? id;

  final String shiftName;

  final String shiftType;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  ShiftModel({

    this.id,

    required this.shiftName,

    required this.shiftType,

    this.createdAt,

    this.updatedAt,
  });

  /// ====================================================
  /// FROM JSON
  /// ====================================================

  factory ShiftModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return ShiftModel(

      id: json['id'],

      shiftName:
          json['shift_name'] ?? '',

      shiftType:
          json['shift_type'] ?? '',

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

  /// ====================================================
  /// TO JSON
  /// ====================================================

  Map<String, dynamic> toJson() {

    return {

      if (id != null)
        'id': id,

      'shift_name': shiftName,

      'shift_type': shiftType,
    };
  }
}