import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Conditional import: ML Kit on mobile, stub on web.
import 'sia_ocr_mobile.dart'
    if (dart.library.html) 'sia_ocr_stub.dart' as platform;

class SIALicenceOCR {
  static const _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // Groq's vision-capable model
  static const _groqModel = 'meta-llama/llama-4-scout-17b-16e-instruct';

  // ── Public entry point ──────────────────────────────────────
  // Returns: { documentNumber, expiryDate, holderName, fullText }
  static Future<Map<String, String>> extractFromImage(
    XFile imageFile,
  ) async {
    if (kIsWeb) {
      return _extractViaGroq(imageFile);
    } else {
      return platform.extractWithMLKit(imageFile);
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
                    'This is an SIA (Security Industry Authority) licence card.\n'
                    'Extract exactly:\n'
                    '1. Licence number — 16 digits formatted as XXXX XXXX XXXX XXXX\n'
                    '2. Expiry date — formatted as DD MMM YYYY  e.g. 19 JUN 2028\n'
                    '3. Holder name — initial + surname at bottom left  e.g. T. DALAL\n\n'
                    'Reply ONLY with valid JSON, no markdown fences:\n'
                    '{"documentNumber":"...","expiryDate":"...","holderName":"..."}',
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

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Groq follows OpenAI response format:
    // data → choices[0] → message → content
    final raw = (data['choices'] as List)
        .first['message']['content'] as String;

    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

    return {
      'documentNumber': parsed['documentNumber'] as String? ?? '',
      'expiryDate':     parsed['expiryDate']     as String? ?? '',
      'holderName':     parsed['holderName']      as String? ?? '',
      'fullText': cleaned,
    };
  }
}