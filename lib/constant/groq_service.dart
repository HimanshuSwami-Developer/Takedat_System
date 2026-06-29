import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

// const _functionUrl =
//     'https://ylrjuvqnajsmfwvsqzsm.supabase.co/functions/v1/groq-proxy';
// const _anonKey =
//     'sb_publishable_A_XrAsxrYA2cI1-zP_oY8A_jpJuOAQT';

  const _functionUrl='https://pbgmovxdwfzvgaskwqlt.supabase.co/functions/v1/groq-proxy';
  const _anonKey='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBiZ21vdnhkd2Z6dmdhc2t3cWx0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjU3MzM3MiwiZXhwIjoyMDk4MTQ5MzcyfQ.C8msQTaX2ZZ5L062jlPnIQdW_ATYDz7x1NsrPhJdsoQ';

// Top-level function so compute() can run it in a background isolate.
Future<Uint8List> _compressToTargetSize(Map<String, dynamic> params) async {
  final Uint8List originalBytes = params['bytes']         as Uint8List;
  final int targetSizeKB        = params['targetSizeKB']  as int;
  final int minQuality          = (params['minQuality']   as int?) ?? 10;
  final targetBytes             = targetSizeKB * 1024;

  final image = img.decodeImage(originalBytes);
  if (image == null) return originalBytes;

  // Step 1: quality only
  for (int quality = 85; quality >= minQuality; quality -= 10) {
    final compressed = img.encodeJpg(image, quality: quality);
    if (compressed.length <= targetBytes) {
      return Uint8List.fromList(compressed);
    }
  }

  // Step 2: downscale + quality
  double scale = 0.8;
  while (scale >= 0.2) {
    final resized = img.copyResize(
      image,
      width:         (image.width  * scale).round(),
      height:        (image.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );

    for (int quality = 85; quality >= minQuality; quality -= 15) {
      final compressed = img.encodeJpg(resized, quality: quality);
      if (compressed.length <= targetBytes) {
        return Uint8List.fromList(compressed);
      }
    }

    scale -= 0.2;
  }

  // Fallback: return best effort at lowest settings
  final fallback = img.encodeJpg(
    img.copyResize(image, width: (image.width * 0.2).round()),
    quality: minQuality,
  );
  return Uint8List.fromList(fallback);
}

Future<Map<String, dynamic>> callGroqProxy({
  required XFile imageFile,
  required String certType,
}) async {
  final originalBytes = await imageFile.readAsBytes();

  // Run compression in a background isolate — keeps the UI spinner animated
  final compressedBytes = await compute(
    _compressToTargetSize,
    {'bytes': originalBytes, 'targetSizeKB': 100, 'minQuality': 10},
  );

  final base64Image = base64Encode(compressedBytes);

  // Always JPEG after compression
  const mimeType = 'image/jpeg';

  final sizeKB = (compressedBytes.length / 1024).toStringAsFixed(1);
  print('Original: ${(originalBytes.length / 1024).toStringAsFixed(1)} KB → '
      'Compressed: $sizeKB KB');

  final body = jsonEncode({
    'imageBase64': base64Image,
    'mimeType': mimeType,
    'certType': certType,
  });

  final response = await http.post(
    Uri.parse(_functionUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_anonKey',
    },
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception(
      'groq-proxy error ${response.statusCode}: ${response.body}',
    );
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (data.containsKey('error')) {
    throw Exception('groq-proxy error: ${data['error']}');
  }

  return data;
}