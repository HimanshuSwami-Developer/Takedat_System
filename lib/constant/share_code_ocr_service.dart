import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Conditional import: ML Kit on mobile, stub on web.
import 'sia_ocr_mobile.dart'
    if (dart.library.html) 'sia_ocr_stub.dart' as platform;

class ShareCodeOCR {
  static const _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const _groqModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';

  // ── Public entry point ──────────────────────────────────────
  // Returns: { shareCode, validUntil, fullText }
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
                    'This is a UK "Prove your right to work" Share Code document.\n'
                    'Extract exactly:\n'
                    '1. Share code — 3 groups of letters/numbers separated by spaces  e.g. WHH SBK 6PT\n'
                    '2. Valid until date — the expiry date of the code  e.g. 18 January 2026\n\n'
                    'Reply ONLY with valid JSON, no markdown fences:\n'
                    '{"shareCode":"...","validUntil":"..."}',
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
      'shareCode':  parsed['shareCode']  as String? ?? '',
      'validUntil': parsed['validUntil'] as String? ?? '',
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
      'shareCode':  _extractShareCode(raw),
      'validUntil': _extractValidUntil(raw),
      'fullText': raw,
    };
  }

  // ── Share code ────────────────────────────────────────────────
  // Format: "WHH SBK 6PT" — three alphanumeric groups of 3 chars
  // separated by spaces. Always uppercase on the document.
  static String _extractShareCode(String text) {
    // Primary: "WHH SBK 6PT" with spaces
    final spaced = RegExp(
      r'\b([A-Z0-9]{3})\s([A-Z0-9]{3})\s([A-Z0-9]{3})\b',
    );
    final m1 = spaced.firstMatch(text.toUpperCase());
    if (m1 != null) return m1.group(0)!;

    // Fallback: "WHHSBK6PT" no spaces — reformat
    final compact = RegExp(r'\b([A-Z0-9]{3})([A-Z0-9]{3})([A-Z0-9]{3})\b');
    final m2 = compact.firstMatch(text.toUpperCase());
    if (m2 != null) {
      return '${m2.group(1)} ${m2.group(2)} ${m2.group(3)}';
    }

    return '';
  }

  // ── Valid until date ──────────────────────────────────────────
  // Printed as "This code is valid until 18 January 2026."
  // We extract the full date string after "valid until".
  static String _extractValidUntil(String text) {
    // After "valid until" — capture the date
    final afterUntil = RegExp(
      r'valid until\s+(\d{1,2}\s+[A-Za-z]+\s+\d{4})',
      caseSensitive: false,
    );
    final m1 = afterUntil.firstMatch(text);
    if (m1 != null) return m1.group(1)!.trim();

    // Fallback: "18 January 2026" anywhere
    final longDate = RegExp(
      r'\b(\d{1,2})\s+(January|February|March|April|May|June|July|'
      r'August|September|October|November|December)\s+(\d{4})\b',
      caseSensitive: false,
    );
    final m2 = longDate.firstMatch(text);
    if (m2 != null) return m2.group(0)!;

    return '';
  }
}