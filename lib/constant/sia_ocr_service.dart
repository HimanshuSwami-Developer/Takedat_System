import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takedat_app/constant/groq_service.dart';
import 'sia_ocr_mobile.dart'
    if (dart.library.html) 'sia_ocr_stub.dart' as platform;

class SIALicenceOCR {
  static Future<Map<String, String>> extractFromImage(XFile imageFile) async {
    if (kIsWeb) {
      final data = await callGroqProxy(imageFile: imageFile, certType: 'sia');
      return {
        'documentNumber': data['documentNumber'] as String? ?? '',
        'expiryDate':     data['expiryDate']     as String? ?? '',
        'holderName':     data['holderName']     as String? ?? '',
        'fullText':       data['fullText']       as String? ?? '',
      };
    } else {
      return platform.extractWithMLKit(imageFile);
    }
  }
}