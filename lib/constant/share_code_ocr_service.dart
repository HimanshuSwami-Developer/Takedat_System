import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takedat_app/constant/groq_service.dart';
import 'sia_ocr_mobile.dart'
    if (dart.library.html) 'sia_ocr_stub.dart' as platform;

class ShareCodeOCR {
  static Future<Map<String, String>> extractFromImage(XFile imageFile) async {
    if (kIsWeb) {
      final data = await callGroqProxy(imageFile: imageFile, certType: 'sharecode');
      return {
        'shareCode':  data['shareCode']  as String? ?? '',
        'validUntil': data['validUntil'] as String? ?? '',
        'fullText':   data['fullText']   as String? ?? '',
      };
    } else {
      return _extractWithMLKit(imageFile);
    }
  }

  static Future<Map<String, String>> _extractWithMLKit(XFile imageFile) async {
    final result = await platform.extractWithMLKit(imageFile);
    final raw = result['fullText'] ?? '';
    return {
      'shareCode':  _extractShareCode(raw),
      'validUntil': _extractValidUntil(raw),
      'fullText':   raw,
    };
  }

  static String _extractShareCode(String text) {
    final m1 = RegExp(r'\b([A-Z0-9]{3})\s([A-Z0-9]{3})\s([A-Z0-9]{3})\b').firstMatch(text.toUpperCase());
    if (m1 != null) return m1.group(0)!;
    final m2 = RegExp(r'\b([A-Z0-9]{3})([A-Z0-9]{3})([A-Z0-9]{3})\b').firstMatch(text.toUpperCase());
    if (m2 != null) return '${m2.group(1)} ${m2.group(2)} ${m2.group(3)}';
    return '';
  }

  static String _extractValidUntil(String text) {
    final m1 = RegExp(r'valid until\s+(\d{1,2}\s+[A-Za-z]+\s+\d{4})', caseSensitive: false).firstMatch(text);
    if (m1 != null) return m1.group(1)!.trim();
    final m2 = RegExp(r'\b(\d{1,2})\s+(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{4})\b', caseSensitive: false).firstMatch(text);
    if (m2 != null) return m2.group(0)!;
    return '';
  }
}