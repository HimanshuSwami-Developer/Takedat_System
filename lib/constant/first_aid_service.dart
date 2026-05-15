import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Conditional import: ML Kit on mobile, stub on web.
import 'sia_ocr_mobile.dart'
    if (dart.library.html) 'sia_ocr_stub.dart' as platform;

class FirstAidCertOCR {
  static const _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const _groqModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';

  // ── Public entry point ──────────────────────────────────────
  // Returns: { holderName, awardedDate, certificateNumber, centre, fullText }
  static Future<Map<String, String>> extractFromImage(
    XFile imageFile,
  ) async {
    if (kIsWeb) {
      return _extractViaGroq(imageFile);
    } else {
      return _extractWithMLKit(imageFile);
    }
  }

  // ── Web path: Groq Vision API ───────────────────────────────
  static Future<Map<String, String>> _extractViaGroq(
    XFile imageFile,
  ) async {
    const apiKey = String.fromEnvironment('GROQ_API_KEY');

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final ext = imageFile.name.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final response = await http.post(
      Uri.parse(_groqUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _groqModel,
        'max_tokens': 256,
        'temperature': 0,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
              {
                'type': 'text',
                'text':
                    'This is a First Aid at Work Awareness certificate.\n'
                    'Extract exactly:\n'
                    '1. Holder name — the full name in bold near the top  e.g. ARMAN KHAN\n'
                    '2. Awarded date — the date next to the AWARDED label  e.g. 2 December 2025\n'
                    '3. Certificate number — the number next to CERTIFICATE NUMBER label  e.g. 1002855-176-463-3892\n'
                    '4. Centre — the code next to CENTRE label  e.g. MT56BA\n\n'
                    'Reply ONLY with valid JSON, no markdown fences:\n'
                    '{"holderName":"...","awardedDate":"...","certificateNumber":"...","centre":"..."}',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Groq API error ${response.statusCode}: ${response.body}',
      );
    }

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final raw = (data['choices'] as List)
        .first['message']['content'] as String;

    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

    return {
      'holderName':         parsed['holderName']         as String? ?? '',
      'awardedDate':        parsed['awardedDate']        as String? ?? '',
      'certificateNumber':  parsed['certificateNumber']  as String? ?? '',
      'centre':             parsed['centre']             as String? ?? '',
      'fullText': cleaned,
    };
  }

  // ── Mobile path: ML Kit ─────────────────────────────────────
  static Future<Map<String, String>> _extractWithMLKit(
    XFile imageFile,
  ) async {
    final result = await platform.extractWithMLKit(imageFile);
    final raw = result['fullText'] ?? '';

    return {
      'holderName':        _extractHolderName(raw),
      'awardedDate':       _extractAwardedDate(raw),
      'certificateNumber': _extractCertificateNumber(raw),
      'centre':            _extractCentre(raw),
      'fullText': raw,
    };
  }

  // ── Holder name ───────────────────────────────────────────────
  // Printed in bold ALL CAPS below the title  e.g. "ARMAN KHAN"
  // Appears before "has successfully completed"
  static String _extractHolderName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Look for an ALL CAPS line that is just a name (no digits,
    // no special chars) before the word "has"
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(r'^[A-Z][A-Z\s]{2,}$').hasMatch(line) &&
          !line.contains('FIRST') &&
          !line.contains('WORK') &&
          !line.contains('AWARENESS') &&
          !line.contains('AWARDED') &&
          !line.contains('CENTRE') &&
          !line.contains('CERTIFICATE')) {
        return line.trim();
      }
    }

    return '';
  }

  // ── Awarded date ──────────────────────────────────────────────
  // Printed as "2 December 2025" next to "AWARDED" label.
  static String _extractAwardedDate(String text) {
    // After "AWARDED" keyword
    final afterAwarded = RegExp(
      r'AWARDED\s+(\d{1,2}\s+[A-Za-z]+\s+\d{4})',
      caseSensitive: false,
    );
    final m1 = afterAwarded.firstMatch(text);
    if (m1 != null) return m1.group(1)!.trim();

    // Fallback: any "D Month YYYY" pattern
    final longDate = RegExp(
      r'\b(\d{1,2})\s+(January|February|March|April|May|June|July|'
      r'August|September|October|November|December)\s+(\d{4})\b',
      caseSensitive: false,
    );
    final m2 = longDate.firstMatch(text);
    if (m2 != null) return m2.group(0)!;

    return '';
  }

  // ── Certificate number ────────────────────────────────────────
  // Format: "1002855-176-463-3892" — digits separated by hyphens.
  static String _extractCertificateNumber(String text) {
    // After "CERTIFICATE NUMBER" label
    final afterLabel = RegExp(
      r'CERTIFICATE\s+NUMBER\s+([\d\-]+)',
      caseSensitive: false,
    );
    final m1 = afterLabel.firstMatch(text);
    if (m1 != null) return m1.group(1)!.trim();

    // Fallback: hyphenated digit string e.g. "1002855-176-463-3892"
    final certRegex = RegExp(r'\b\d{7}-\d{3}-\d{3}-\d{4}\b');
    final m2 = certRegex.firstMatch(text);
    if (m2 != null) return m2.group(0)!;

    return '';
  }

  // ── Centre ────────────────────────────────────────────────────
  // Format: "MT56BA" — alphanumeric code next to CENTRE label.
  static String _extractCentre(String text) {
    final afterLabel = RegExp(
      r'CENTRE\s+([A-Z0-9]{4,10})',
      caseSensitive: false,
    );
    final m = afterLabel.firstMatch(text);
    if (m != null) return m.group(1)!.trim().toUpperCase();

    return '';
  }
}