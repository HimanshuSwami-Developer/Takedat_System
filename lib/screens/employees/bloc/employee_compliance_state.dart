import 'package:takedat_app/models/act_certificate_model.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'package:takedat_app/models/signed_document_model.dart';
import 'package:takedat_app/models/users_model.dart';

abstract class EmployeeComplianceState {}

class EmployeeComplianceInitial
    extends EmployeeComplianceState {}

class EmployeeComplianceLoading
    extends EmployeeComplianceState {}

class EmployeeComplianceLoaded
    extends EmployeeComplianceState {

  final List<EmployeeComplianceItem> employees;

  final bool hasReachedMax;

  final String search;

  EmployeeComplianceLoaded({

    required this.employees,

    required this.hasReachedMax,

    required this.search,
  });

  EmployeeComplianceLoaded copyWith({

    List<EmployeeComplianceItem>? employees,

    bool? hasReachedMax,

    String? search,
  }) {

    return EmployeeComplianceLoaded(

      employees:
          employees ?? this.employees,

      hasReachedMax:
          hasReachedMax ??
              this.hasReachedMax,

      search:
          search ?? this.search,
    );
  }
}

class EmployeeComplianceError
    extends EmployeeComplianceState {

  final String message;

  EmployeeComplianceError(
    this.message,
  );
}


// MODEL CLASS FOR EMPLOYEE COMPLIANCE ITEM

class EmployeeComplianceItem {

  final UserModel user;

  final ActCertificateModel?
      actCertificate;

  final SharecodeFirstAidModel?
      sharecodeFirstAid;

  final SiaLicenceModel?
      siaLicence;

  final SignedDocumentsModel?
      signedDocuments;

  bool isExpanded;

  EmployeeComplianceItem({

    required this.user,

    this.actCertificate,

    this.sharecodeFirstAid,

    this.siaLicence,

    this.signedDocuments,

    this.isExpanded = false,
  });

  /// =====================================================
  /// COMPLIANCE REQUIRED
  /// =====================================================

  bool get complianceRequired {

    final now = DateTime.now();

    bool expired(DateTime? date) {

      if (date == null) return false;

      return date.isBefore(now);
    }

    return

        expired(
          actCertificate
              ?.actOrangeExpiry,
        ) ||

        expired(
          actCertificate
              ?.actBlueExpiry,
        ) ||

        expired(
          sharecodeFirstAid
              ?.shareCodeExpiry,
        ) ||

        expired(
          sharecodeFirstAid
              ?.firstAidExpiry,
        ) ||

        expired(
          siaLicence
              ?.siaLicenceExpiry,
        );
  }
}
