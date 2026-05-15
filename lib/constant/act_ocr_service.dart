import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Conditional import: ML Kit on mobile, stub on web.
import 'sia_ocr_mobile.dart'
    if (dart.library.html) 'sia_ocr_stub.dart' as platform;

class ACTCertificateOCR {
  static const _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const _groqModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';

  // ── Public entry point ──────────────────────────────────────
  // Returns: { holderName, completionDate, fullText }
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
                    'This is an ACT (Action Counters Terrorism) Awareness e-Learning certificate.\n'
                    'Extract exactly:\n'
                    '1. Holder name — the full name printed in bold near the top  e.g. Arman Khan\n'
                    '2. Date of completion — printed as DD.MM.YYYY  e.g. 19.10.2025\n\n'
                    'Reply ONLY with valid JSON, no markdown fences:\n'
                    '{"holderName":"...","completionDate":"..."}',
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
      'holderName':      parsed['holderName']      as String? ?? '',
      'completionDate':  parsed['completionDate']  as String? ?? '',
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
      'holderName':     _extractHolderName(raw),
      'completionDate': _extractCompletionDate(raw),
      'fullText': raw,
    };
  }

  // ── Holder name ───────────────────────────────────────────────
  // The name appears on its own line directly after
  // "ACT Awareness e-Learning&" header line.
  // Pattern: one or more capitalised words e.g. "Arman Khan"
  static String _extractHolderName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.replaceAll('&', '').trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Find the line that contains the cert title,
    // then the very next non-empty line is the name.
    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i].toLowerCase().contains('awareness e-learning')) {
        final candidate = lines[i + 1];
        // Must look like a proper name: "Firstname Lastname"
        if (RegExp(r'^[A-Z][a-z]+(\s[A-Z][a-z]+)+$')
            .hasMatch(candidate)) {
          return candidate;
        }
      }
    }

    // Fallback: any "Firstname Lastname" capitalised line
    for (final line in lines) {
      if (RegExp(r'^[A-Z][a-z]+(\s[A-Z][a-z]+)+$')
          .hasMatch(line)) {
        return line;
      }
    }

    return '';
  }

  // ── Completion date ───────────────────────────────────────────
  // Printed as "Date of completion: 19.10.2025"
  // ML Kit may append "&" so we strip it.
  static String _extractCompletionDate(String text) {
    // "19.10.2025" — DD.MM.YYYY
    final ddmmyyyy = RegExp(
      r'\b(\d{2})\.(\d{2})\.(\d{4})\b',
    );
    final m1 = ddmmyyyy.firstMatch(text);
    if (m1 != null) return m1.group(0)!;

    // Fallback: "19/10/2025"
    final slashed = RegExp(
      r'\b(\d{2})\/(\d{2})\/(\d{4})\b',
    );
    final m2 = slashed.firstMatch(text);
    if (m2 != null) return m2.group(0)!;

    return '';
  }
}