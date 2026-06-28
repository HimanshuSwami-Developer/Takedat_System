import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'package:takedat_app/models/signed_document_model.dart';
import 'package:takedat_app/models/users_model.dart';
import 'package:takedat_app/models/act_certificate_model.dart';

import 'package:takedat_app/screens/auth/register/bloc/register_event.dart';
import 'package:takedat_app/screens/auth/register/bloc/register_state.dart';

import '../../../../constant/session_keys.dart';
import '../../../../constant/session_manager.dart';
import '../../../../repository/user_repo.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository repository;

  RegisterBloc(this.repository) : super(RegisterInitial()) {
    /// =====================================================
    /// REGISTER USER
    /// =====================================================

    on<RegisterUserEvent>((event, emit) async {
      emit(RegisterLoading());

      try {
        final user = UserModel(
          empId: event.empId,
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          address: event.address,
          companyCode: event.companyCode,
          isActive: false,
          role: 'employee',
        );

        final registeredUser = await repository.registerUser(user);

        await SessionManager.saveBool(SessionKeys.isLoggedIn, true);
        await SessionManager.saveString(
          SessionKeys.userId,
          registeredUser.id ?? "",
        );
        await SessionManager.saveString(
          SessionKeys.email,
          registeredUser.email,
        );
        await SessionManager.saveString(
          SessionKeys.fullName,
          registeredUser.fullName,
        );

        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });

    /// =====================================================
    /// SAVE SIA
    /// =====================================================

    on<SaveSiaLicenceEvent>((event, emit) async {
      emit(RegisterLoading());

      try {
        final path = "${event.userEmail}/sia_lic.png";

        /// Upload — picks bytes (web) or file (mobile) automatically
        final url = await repository.uploadDocument(
          file: event.file,
          bytes: event.bytes,
          fileName: event.fileName,
          bucket: "documents",
          path: path,
        );

        final expiry1m = DateTime(
          event.expiry.year,
          event.expiry.month - 1,
          event.expiry.day,
        );
        final expiry2m = DateTime(
          event.expiry.year,
          event.expiry.month - 2,
          event.expiry.day,
        );
        final expiry3m = DateTime(
          event.expiry.year,
          event.expiry.month - 3,
          event.expiry.day,
        );

        final model = SiaLicenceModel(
          userId: event.userId,
          url: url,
          siaHolderName: event.holderName,
          siaLicenceNumber: event.licenceNumber,
          siaLicenceExpiry: event.expiry,
          siaLicenceExpiry1m: expiry1m,
          siaLicenceExpiry2m: expiry2m,
          siaLicenceExpiry3m: expiry3m,
        );

        await repository.saveSiaLicence(model);

        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });

    /// =====================================================
    /// SAVE ACT
    /// =====================================================

    on<SaveActCertificateEvent>((event, emit) async {
      emit(RegisterLoading());

      try {
        String? orangeUrl;
        String? blueUrl;

        if (kIsWeb) {
          /// WEB — upload using Uint8List bytes
          if (event.orangeBytes != null) {
            orangeUrl = await repository.uploadDocument(
              bytes: event.orangeBytes,
              fileName: event.orangeFileName,
              bucket: "documents",
              path: "${event.userEmail}/orange_act.png",
            );
          }

          if (event.blueBytes != null) {
            blueUrl = await repository.uploadDocument(
              bytes: event.blueBytes,
              fileName: event.blueFileName,
              bucket: "documents",
              path: "${event.userEmail}/blue_act.png",
            );
          }
        } else {
          /// MOBILE — upload using File
          if (event.orangeFile != null) {
            orangeUrl = await repository.uploadDocument(
              file: event.orangeFile,
              bucket: "documents",
              path: "${event.userEmail}/orange_act.png",
            );
          }

          if (event.blueFile != null) {
            blueUrl = await repository.uploadDocument(
              file: event.blueFile,
              bucket: "documents",
              path: "${event.userEmail}/blue_act.png",
            );
          }
        }

        final orange15d = event.orangeExpiry?.subtract(
          const Duration(days: 15),
        );
        final blue15d = event.blueExpiry?.subtract(const Duration(days: 15));

        final model = ActCertificateModel(
          userId: event.userId,
          actOrangeUrl: orangeUrl,
          actBlueUrl: blueUrl,
          orangeHolderName: event.orangeHolderName,
          blueHolderName: event.blueHolderName,
          actOrangeExpiry: event.orangeExpiry,
          actBlueExpiry: event.blueExpiry,
          actOrangeExpiry15d: orange15d,
          actBlueExpiry15d: blue15d,
        );

        await repository.saveActCertificate(model);

        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });

    /// =====================================================
    /// SAVE SHARECODE + FIRSTAID
    /// =====================================================

    on<SaveSharecodeFirstAidEvent>((event, emit) async {
      emit(RegisterLoading());

      try {
        String? sharecodeUrl;
        String? firstAidUrl;

        if (kIsWeb) {
          /// WEB — upload using Uint8List bytes
          if (event.sharecodeBytes != null) {
            sharecodeUrl = await repository.uploadDocument(
              bytes: event.sharecodeBytes,
              fileName: event.sharecodeFileName,
              bucket: "documents",
              path: "${event.userEmail}/sharecode.png",
            );
          }

          if (event.firstAidBytes != null) {
            firstAidUrl = await repository.uploadDocument(
              bytes: event.firstAidBytes,
              fileName: event.firstAidFileName,
              bucket: "documents",
              path: "${event.userEmail}/first_aid.png",
            );
          }
        } else {
          /// MOBILE — upload using File
          if (event.sharecodeFile != null) {
            sharecodeUrl = await repository.uploadDocument(
              file: event.sharecodeFile,
              bucket: "documents",
              path: "${event.userEmail}/sharecode.png",
            );
          }

          if (event.firstAidFile != null) {
            firstAidUrl = await repository.uploadDocument(
              file: event.firstAidFile,
              bucket: "documents",
              path: "${event.userEmail}/first_aid.png",
            );
          }
        }

        final share15d = event.sharecodeExpiry?.subtract(
          const Duration(days: 15),
        );

        DateTime? firstAid1m;
        if (event.firstAidExpiry != null) {
          firstAid1m = DateTime(
            event.firstAidExpiry!.year,
            event.firstAidExpiry!.month - 1,
            event.firstAidExpiry!.day,
          );
        }

        final model = SharecodeFirstAidModel(
          userId: event.userId,
          shareCodeUrl: sharecodeUrl,
          shareCodeNumber: event.sharecodeNumber,
          shareCodeHolderName: event.sharecodeHolderName,
          shareCodeExpiry: event.sharecodeExpiry,
          shareCodeExpiry15d: share15d,
          firstAidUrl: firstAidUrl,
          firstAidHolderName: event.firstAidHolderName,
          firstAidExpiry: event.firstAidExpiry,
          firstAidExpiry1m: firstAid1m,
        );

        await repository.saveSharecodeFirstAid(model);

        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });

    /// =====================================================
    /// SAVE SIGNED DOCUMENTS
    /// =====================================================

    on<SaveSignedDocumentsEvent>((event, emit) async {
      emit(RegisterLoading());

      try {
        String? authUrl;
        String? screeningUrl;

        /// ===============================================
        /// AUTH UPLOAD
        /// ===============================================

        if (event.authBytes != null) {
          authUrl = await repository.uploadDocument(
            bytes: event.authBytes!,

            fileName: event.authFileName,

            bucket: "documents",

            path: "${event.userEmail}/signed_authentication.png",
          );
        }

        /// ===============================================
        /// SCREENING UPLOAD
        /// ===============================================

        if (event.screeningBytes != null) {
          screeningUrl = await repository.uploadDocument(
            bytes: event.screeningBytes!,

            fileName: event.screeningFileName,

            bucket: "documents",

            path: "${event.userEmail}/signed_screening.png",
          );
        }

        print("AUTH URL => $authUrl");

        print("SCREENING URL => $screeningUrl");

        /// ===============================================
        /// SAVE DB
        /// ===============================================

        final model = SignedDocumentsModel(
          userId: event.userId,

          signedAuthenticationUrl: authUrl,

          signedScreeningUrl: screeningUrl,
        );

        await repository.saveSignedDocuments(model);

        emit(RegisterSuccess());
      } catch (e) {
        print("SIGNED DOC ERROR => $e");

        emit(RegisterFailure(e.toString()));
      }
    });
  }
}
