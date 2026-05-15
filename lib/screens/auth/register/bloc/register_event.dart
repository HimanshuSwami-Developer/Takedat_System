import 'dart:io';
import 'dart:typed_data';

abstract class RegisterEvent {}

/// =======================================================
/// REGISTER USER
/// =======================================================
class RegisterUserEvent extends RegisterEvent {
  final String empId;
  final String fullName;
  final String email;
  final String phone;
  final String address;

  RegisterUserEvent({
    required this.empId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
  });
}

/// =======================================================
/// SAVE SIA
/// =======================================================
class SaveSiaLicenceEvent extends RegisterEvent {
  final String userId;
  final String userEmail;

  // mobile
  final File? file;

  // web
  final Uint8List? bytes;
  final String? fileName;

  final String holderName;
  final String licenceNumber;
  final DateTime expiry;

  SaveSiaLicenceEvent({
    required this.userId,
    required this.userEmail,
    this.file,
    this.bytes,
    this.fileName,
    required this.holderName,
    required this.licenceNumber,
    required this.expiry,
  });
}

/// =======================================================
/// SAVE ACT
/// =======================================================
class SaveActCertificateEvent extends RegisterEvent {
  final String userId;
  final String userEmail;

  // mobile
  final File? orangeFile;
  final File? blueFile;

  // web
  final Uint8List? orangeBytes;
  final String?    orangeFileName;
  final Uint8List? blueBytes;
  final String?    blueFileName;

  // metadata
  final String?   orangeHolderName;
  final String?   blueHolderName;
  final DateTime? orangeExpiry;
  final DateTime? blueExpiry;

  SaveActCertificateEvent({
    required this.userId,
    required this.userEmail,
    this.orangeFile,
    this.blueFile,
    this.orangeBytes,
    this.orangeFileName,
    this.blueBytes,
    this.blueFileName,
    this.orangeHolderName,
    this.blueHolderName,
    this.orangeExpiry,
    this.blueExpiry,
  });
}

/// =======================================================
/// SAVE SHARECODE + FIRST AID
/// =======================================================
class SaveSharecodeFirstAidEvent extends RegisterEvent {
  final String userId;
  final String userEmail;

  // mobile
  final File? sharecodeFile;
  final File? firstAidFile;

  // web
  final Uint8List? sharecodeBytes;
  final String?    sharecodeFileName;
  final Uint8List? firstAidBytes;
  final String?    firstAidFileName;

  // metadata
  final String?   sharecodeNumber;
  final String?   sharecodeHolderName;
  final DateTime? sharecodeExpiry;
  final String?   firstAidHolderName;
  final DateTime? firstAidExpiry;

  SaveSharecodeFirstAidEvent({
    required this.userId,
    required this.userEmail,
    this.sharecodeFile,
    this.firstAidFile,
    this.sharecodeBytes,
    this.sharecodeFileName,
    this.firstAidBytes,
    this.firstAidFileName,
    this.sharecodeNumber,
    this.sharecodeHolderName,
    this.sharecodeExpiry,
    this.firstAidHolderName,
    this.firstAidExpiry,
  });
}

/// ======================================================
/// SAVE SIGNED DOCUMENTS
/// ======================================================

class SaveSignedDocumentsEvent
    extends RegisterEvent {

  final String userId;

  final String userEmail;

  /// AUTH DOC
  final dynamic authFile;
  final Uint8List? authBytes;
  final String? authFileName;

  /// SCREENING DOC
  final dynamic screeningFile;
  final Uint8List? screeningBytes;
  final String? screeningFileName;

  SaveSignedDocumentsEvent({

    required this.userId,

    required this.userEmail,

    this.authFile,
    this.authBytes,
    this.authFileName,

    this.screeningFile,
    this.screeningBytes,
    this.screeningFileName,
  });
}