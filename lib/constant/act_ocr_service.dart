import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takedat_app/constant/groq_service.dart';
import 'sia_ocr_mobile.dart'
    if (dart.library.html) 'sia_ocr_stub.dart' as platform;

class ACTCertificateOCR {
  static Future<Map<String, String>> extractFromImage(XFile imageFile) async {
    if (kIsWeb) {
      final data = await callGroqProxy(imageFile: imageFile, certType: 'act');
      return {
        'holderName':     data['holderName']     as String? ?? '',
        'completionDate': data['completionDate'] as String? ?? '',
        'fullText':       data['fullText']       as String? ?? '',
      };
    } else {
      return _extractWithMLKit(imageFile);
    }
  }

  static Future<Map<String, String>> _extractWithMLKit(XFile imageFile) async {
    final result = await platform.extractWithMLKit(imageFile);
    final raw = result['fullText'] ?? '';
    return {
      'holderName':     _extractHolderName(raw),
      'completionDate': _extractCompletionDate(raw),
      'fullText':       raw,
    };
  }

  static String _extractHolderName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.replaceAll('&', '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i].toLowerCase().contains('awareness e-learning')) {
        final candidate = lines[i + 1];
        if (RegExp(r'^[A-Z][a-z]+(\s[A-Z][a-z]+)+$').hasMatch(candidate)) {
          return candidate;
        }
      }
    }
    for (final line in lines) {
      if (RegExp(r'^[A-Z][a-z]+(\s[A-Z][a-z]+)+$').hasMatch(line)) {
        return line;
      }
    }
    return '';
  }

  static String _extractCompletionDate(String text) {
    final m1 = RegExp(r'\b(\d{2})\.(\d{2})\.(\d{4})\b').firstMatch(text);
    if (m1 != null) return m1.group(0)!;
    final m2 = RegExp(r'\b(\d{2})\/(\d{2})\/(\d{4})\b').firstMatch(text);
    if (m2 != null) return m2.group(0)!;
    return '';
  }
}