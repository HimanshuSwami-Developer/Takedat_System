import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takedat_app/constant/groq_service.dart';
import 'sia_ocr_mobile.dart'
    if (dart.library.html) 'sia_ocr_stub.dart' as platform;

class FirstAidCertOCR {
  static Future<Map<String, String>> extractFromImage(XFile imageFile) async {
    if (kIsWeb) {
      final data = await callGroqProxy(imageFile: imageFile, certType: 'firstaid');
      return {
        'holderName':        data['holderName']        as String? ?? '',
        'awardedDate':       data['awardedDate']       as String? ?? '',
        'certificateNumber': data['certificateNumber'] as String? ?? '',
        'centre':            data['centre']            as String? ?? '',
        'fullText':          data['fullText']          as String? ?? '',
      };
    } else {
      return _extractWithMLKit(imageFile);
    }
  }

  static Future<Map<String, String>> _extractWithMLKit(XFile imageFile) async {
    final result = await platform.extractWithMLKit(imageFile);
    final raw = result['fullText'] ?? '';
    return {
      'holderName':        _extractHolderName(raw),
      'awardedDate':       _extractAwardedDate(raw),
      'certificateNumber': _extractCertificateNumber(raw),
      'centre':            _extractCentre(raw),
      'fullText':          raw,
    };
  }

  static String _extractHolderName(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    for (final line in lines) {
      if (RegExp(r'^[A-Z][A-Z\s]{2,}$').hasMatch(line) &&
          !line.contains('FIRST') && !line.contains('WORK') &&
          !line.contains('AWARENESS') && !line.contains('AWARDED') &&
          !line.contains('CENTRE') && !line.contains('CERTIFICATE')) {
        return line.trim();
      }
    }
    return '';
  }

  static String _extractAwardedDate(String text) {
    final m1 = RegExp(r'AWARDED\s+(\d{1,2}\s+[A-Za-z]+\s+\d{4})', caseSensitive: false).firstMatch(text);
    if (m1 != null) return m1.group(1)!.trim();
    final m2 = RegExp(r'\b(\d{1,2})\s+(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{4})\b', caseSensitive: false).firstMatch(text);
    if (m2 != null) return m2.group(0)!;
    return '';
  }

  static String _extractCertificateNumber(String text) {
    final m1 = RegExp(r'CERTIFICATE\s+NUMBER\s+([\d\-]+)', caseSensitive: false).firstMatch(text);
    if (m1 != null) return m1.group(1)!.trim();
    final m2 = RegExp(r'\b\d{7}-\d{3}-\d{3}-\d{4}\b').firstMatch(text);
    if (m2 != null) return m2.group(0)!;
    return '';
  }

  static String _extractCentre(String text) {
    final m = RegExp(r'CENTRE\s+([A-Z0-9]{4,10})', caseSensitive: false).firstMatch(text);
    if (m != null) return m.group(1)!.trim().toUpperCase();
    return '';
  }
}