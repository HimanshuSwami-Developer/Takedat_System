import 'dart:io';
import 'dart:typed_data';

abstract class ProfileEvent {}

/// =====================================================
/// LOAD PROFILE
/// =====================================================

class LoadProfileEvent extends ProfileEvent {
  final String userId;
  LoadProfileEvent({required this.userId});
}

/// =====================================================
/// UPDATE SIA LICENCE
/// =====================================================

class UpdateSiaLicenceEvent extends ProfileEvent {
  final String userId;
  final String userEmail;

  // file data
  final File? file;
  final Uint8List? bytes;
  final String? fileName;

  // ocr extracted fields
  final String holderName;
  final String licenceNumber;
  final DateTime expiry;

  // existing model id (for db update)
  final String siaId;

  UpdateSiaLicenceEvent({
    required this.userId,
    required this.userEmail,
    required this.holderName,
    required this.licenceNumber,
    required this.expiry,
    required this.siaId,
    this.file,
    this.bytes,
    this.fileName,
  });
}

/// =====================================================
/// UPDATE ACT CERTIFICATE
/// =====================================================

class UpdateActCertificateEvent extends ProfileEvent {
  final String userId;
  final String userEmail;
  final String actId;

  // blue act
  final File? blueFile;
  final Uint8List? blueBytes;
  final String? blueFileName;
  final String? blueHolderName;
  final DateTime? blueExpiry;

  // orange act
  final File? orangeFile;
  final Uint8List? orangeBytes;
  final String? orangeFileName;
  final String? orangeHolderName;
  final DateTime? orangeExpiry;

  UpdateActCertificateEvent({
    required this.userId,
    required this.userEmail,
    required this.actId,
    this.blueFile,
    this.blueBytes,
    this.blueFileName,
    this.blueHolderName,
    this.blueExpiry,
    this.orangeFile,
    this.orangeBytes,
    this.orangeFileName,
    this.orangeHolderName,
    this.orangeExpiry,
  });
}

/// =====================================================
/// UPDATE SHARECODE + FIRST AID
/// =====================================================

class UpdateSharecodeFirstAidEvent extends ProfileEvent {
  final String userId;
  final String userEmail;
  final String shareFirstAidId;

  // sharecode
  final File? sharecodeFile;
  final Uint8List? sharecodeBytes;
  final String? sharecodeFileName;
  final String? sharecodeNumber;
  final String? sharecodeHolderName;
  final DateTime? sharecodeExpiry;

  // first aid
  final File? firstAidFile;
  final Uint8List? firstAidBytes;
  final String? firstAidFileName;
  final String? firstAidHolderName;
  final DateTime? firstAidExpiry;

  UpdateSharecodeFirstAidEvent({
    required this.userId,
    required this.userEmail,
    required this.shareFirstAidId,
    this.sharecodeFile,
    this.sharecodeBytes,
    this.sharecodeFileName,
    this.sharecodeNumber,
    this.sharecodeHolderName,
    this.sharecodeExpiry,
    this.firstAidFile,
    this.firstAidBytes,
    this.firstAidFileName,
    this.firstAidHolderName,
    this.firstAidExpiry,
  });
}

/// =====================================================
/// UPDATE USER PROFILE (name, phone, address)
/// =====================================================

class UpdateUserProfileEvent extends ProfileEvent {
  final String userId;
  final String fullName;
  final String phone;
  final String address;

  UpdateUserProfileEvent({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.address,
  });
}