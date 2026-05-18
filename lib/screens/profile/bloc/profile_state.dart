import 'package:takedat_app/models/act_certificate_model.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';

abstract class ProfileState {}

/// =====================================================
/// INITIAL
/// =====================================================

class ProfileInitial extends ProfileState {}

/// =====================================================
/// LOADING
/// =====================================================

class ProfileLoading extends ProfileState {}

/// =====================================================
/// PROFILE LOADED
/// =====================================================

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> user;
  final ActCertificateModel? actCertificate;
  final SharecodeFirstAidModel? sharecodeFirstAid;
  final SiaLicenceModel? siaLicence;

  ProfileLoaded({
    required this.user,
    this.actCertificate,
    this.sharecodeFirstAid,
    this.siaLicence,
  });
}

/// =====================================================
/// DOCUMENT UPDATE IN PROGRESS
/// (separate loading so profile data stays visible)
/// =====================================================

class DocumentUpdating extends ProfileState {
  final String documentType; // "SIA" | "ACT" | "SHARECODE"

  DocumentUpdating({required this.documentType});
}

/// =====================================================
/// DOCUMENT UPDATE SUCCESS
/// =====================================================

class DocumentUpdateSuccess extends ProfileState {
  final String documentType;

  DocumentUpdateSuccess({required this.documentType});
}

/// =====================================================
/// FAILURE
/// =====================================================

class ProfileFailure extends ProfileState {
  final String error;
  ProfileFailure(this.error);
}