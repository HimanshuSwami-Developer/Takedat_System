import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const _functionUrl =
    'https://ylrjuvqnajsmfwvsqzsm.supabase.co/functions/v1/groq-proxy';

const _anonKey =
    'sb_publishable_A_XrAsxrYA2cI1-zP_oY8A_jpJuOAQT';

Future<Map<String, dynamic>> callGroqProxy({
  required XFile imageFile,
  required String certType,
}) async {
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);
  final ext = imageFile.name.split('.').last.toLowerCase();
  final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

  final body = jsonEncode({
    'imageBase64': base64Image,
    'mimeType': mimeType,
    'certType': certType,
  });
  print(body);
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