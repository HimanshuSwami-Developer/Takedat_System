import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:takedat_app/models/act_certificate_model.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';

import 'package:takedat_app/repository/profile_repo.dart';
import 'package:takedat_app/repository/user_repo.dart'; // for uploadDocument

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final UserRepository userRepository; // reuse uploadDocument from register flow

  ProfileBloc({
    required this.profileRepository,
    required this.userRepository,
  }) : super(ProfileInitial()) {

    /// =====================================================
    /// LOAD PROFILE
    /// =====================================================

    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());

      try {
        final data = await profileRepository.getProfile(
          userId: event.userId,
        );

        emit(ProfileLoaded(
          user: data['user'] as Map<String, dynamic>,
          actCertificate: data['actCertificate'] as ActCertificateModel?,
          sharecodeFirstAid: data['sharecodeFirstAid'] as SharecodeFirstAidModel?,
          siaLicence: data['siaLicence'] as SiaLicenceModel?,
        ));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    /// =====================================================
    /// UPDATE SIA LICENCE
    ///
    /// - Uploads new image to the SAME path in bucket
    ///   → Supabase Storage overwrites the old file
    /// - Saves updated model to DB
    /// =====================================================

    on<UpdateSiaLicenceEvent>((event, emit) async {
      emit(DocumentUpdating(documentType: "SIA"));

      try {
        // Same path as registration → overwrites existing file in bucket
        final path = "${event.userEmail}/sia_lic.png";

        final url = await userRepository.uploadDocument(
          file: event.file,
          bytes: event.bytes,
          fileName: event.fileName,
          bucket: "documents",
          path: path,
        );

        // Expiry reminder dates (mirrors RegisterBloc logic)
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
          id: int.parse(event.siaId),
          userId: event.userId,
          url: url,
          siaHolderName: event.holderName,
          siaLicenceNumber: event.licenceNumber,
          siaLicenceExpiry: event.expiry,
          siaLicenceExpiry1m: expiry1m,
          siaLicenceExpiry2m: expiry2m,
          siaLicenceExpiry3m: expiry3m,
        );

        await profileRepository.updateSiaLicence(model: model);

        emit(DocumentUpdateSuccess(documentType: "SIA"));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    /// =====================================================
    /// UPDATE ACT CERTIFICATE
    ///
    /// - Only re-uploads whichever card the user picked
    ///   (blue, orange, or both). Null = not changed.
    /// - Same paths as registration → overwrites old files.
    /// =====================================================

    on<UpdateActCertificateEvent>((event, emit) async {
      emit(DocumentUpdating(documentType: "ACT"));

      try {
        String? orangeUrl;
        String? blueUrl;

        if (kIsWeb) {
          if (event.orangeBytes != null) {
            orangeUrl = await userRepository.uploadDocument(
              bytes: event.orangeBytes,
              fileName: event.orangeFileName,
              bucket: "documents",
              path: "${event.userEmail}/orange_act.png",
            );
          }
          if (event.blueBytes != null) {
            blueUrl = await userRepository.uploadDocument(
              bytes: event.blueBytes,
              fileName: event.blueFileName,
              bucket: "documents",
              path: "${event.userEmail}/blue_act.png",
            );
          }
        } else {
          if (event.orangeFile != null) {
            orangeUrl = await userRepository.uploadDocument(
              file: event.orangeFile,
              bucket: "documents",
              path: "${event.userEmail}/orange_act.png",
            );
          }
          if (event.blueFile != null) {
            blueUrl = await userRepository.uploadDocument(
              file: event.blueFile,
              bucket: "documents",
              path: "${event.userEmail}/blue_act.png",
            );
          }
        }

        final orange15d = event.orangeExpiry?.subtract(
          const Duration(days: 15),
        );
        final blue15d = event.blueExpiry?.subtract(
          const Duration(days: 15),
        );

        final model = ActCertificateModel(
          id: int.parse(event.actId),
          userId: event.userId,
          // Only set url if a new file was uploaded, otherwise keep existing
          actOrangeUrl: orangeUrl,
          actBlueUrl: blueUrl,
          orangeHolderName: event.orangeHolderName,
          blueHolderName: event.blueHolderName,
          actOrangeExpiry: event.orangeExpiry,
          actBlueExpiry: event.blueExpiry,
          actOrangeExpiry15d: orange15d,
          actBlueExpiry15d: blue15d,
        );

        await profileRepository.updateActCertificate(model: model);

        emit(DocumentUpdateSuccess(documentType: "ACT"));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    /// =====================================================
    /// UPDATE SHARECODE + FIRST AID
    ///
    /// - Same paths as registration → overwrites old files.
    /// =====================================================

    /// =====================================================
    /// UPDATE USER PROFILE (name, phone, address)
    /// =====================================================

    on<UpdateUserProfileEvent>((event, emit) async {
      emit(DocumentUpdating(documentType: "PROFILE"));
      try {
        await profileRepository.updateBasicProfile(
          userId: event.userId,
          fullName: event.fullName,
          phone: event.phone,
          address: event.address,
        );
        emit(DocumentUpdateSuccess(documentType: "PROFILE"));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<UpdateSharecodeFirstAidEvent>((event, emit) async {
      emit(DocumentUpdating(documentType: "SHARECODE"));

      try {
        String? sharecodeUrl;
        String? firstAidUrl;

        if (kIsWeb) {
          if (event.sharecodeBytes != null) {
            sharecodeUrl = await userRepository.uploadDocument(
              bytes: event.sharecodeBytes,
              fileName: event.sharecodeFileName,
              bucket: "documents",
              path: "${event.userEmail}/sharecode.png",
            );
          }
          if (event.firstAidBytes != null) {
            firstAidUrl = await userRepository.uploadDocument(
              bytes: event.firstAidBytes,
              fileName: event.firstAidFileName,
              bucket: "documents",
              path: "${event.userEmail}/first_aid.png",
            );
          }
        } else {
          if (event.sharecodeFile != null) {
            sharecodeUrl = await userRepository.uploadDocument(
              file: event.sharecodeFile,
              bucket: "documents",
              path: "${event.userEmail}/sharecode.png",
            );
          }
          if (event.firstAidFile != null) {
            firstAidUrl = await userRepository.uploadDocument(
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
          id: int.parse(event.shareFirstAidId),
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

        await profileRepository.updateSharecodeFirstAid(model: model);

        emit(DocumentUpdateSuccess(documentType: "SHARECODE"));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });
  }
}