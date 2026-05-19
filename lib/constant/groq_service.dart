import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

const _functionUrl =
    'https://ylrjuvqnajsmfwvsqzsm.supabase.co/functions/v1/groq-proxy';
const _anonKey =
    'sb_publishable_A_XrAsxrYA2cI1-zP_oY8A_jpJuOAQT';

/// Compresses image bytes to fit within [targetSizeKB] kilobytes.
/// Tries JPEG quality steps from 85 → 10 until size fits.
/// If still too large, also downscales the image dimensions.
Future<Uint8List> _compressToTargetSize(
  Uint8List originalBytes, {
  int targetSizeKB = 100,
  int minQuality = 10,
}) async {
  final targetBytes = targetSizeKB * 1024;

  // Decode image
  final image = img.decodeImage(originalBytes);
  if (image == null) return originalBytes;

  img.Image workingImage = image;

  // Step 1: Try reducing quality at full resolution
  for (int quality = 85; quality >= minQuality; quality -= 10) {
    final compressed = img.encodeJpg(workingImage, quality: quality);
    if (compressed.length <= targetBytes) {
      return Uint8List.fromList(compressed);
    }
  }

  // Step 2: If still too large, downscale dimensions + compress
  double scale = 0.8;
  while (scale >= 0.2) {
    final resized = img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
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

  // Compress to 60–100 KB range
  final compressedBytes = await _compressToTargetSize(
    originalBytes,
    targetSizeKB: 100, // upper bound; usually lands in 60–100 KB
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