// Mobile-only: compiled on Android & iOS, never on web.
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

Future<Map<String, String>> extractWithMLKit(
  XFile imageFile,
) async {
  final inputImage = InputImage.fromFilePath(imageFile.path);

  final recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  final RecognizedText recognised =
      await recognizer.processImage(inputImage);

  await recognizer.close();

  final raw = recognised.text;

  return {
    'documentNumber': _extractLicenceNumber(raw),
    'expiryDate':     _extractExpiryDate(raw),
    'holderName':     _extractHolderName(raw),
    'fullText': raw,
  };
}

// ── Licence number ────────────────────────────────────────────
String _extractLicenceNumber(String text) {
  // Primary: "1018 1421 2846 6978"
  final spaced =
      RegExp(r'\b(\d{4})\s(\d{4})\s(\d{4})\s(\d{4})\b');
  final m1 = spaced.firstMatch(text);
  if (m1 != null) return m1.group(0)!;

  // Fallback: ML Kit dropped spaces → "1018142128466978"
  final compact =
      RegExp(r'\b(\d{4})(\d{4})(\d{4})(\d{4})\b');
  final m2 = compact.firstMatch(text);
  if (m2 != null) {
    return '${m2.group(1)} ${m2.group(2)} '
        '${m2.group(3)} ${m2.group(4)}';
  }

  return '';
}

// ── Expiry date ───────────────────────────────────────────────
String _extractExpiryDate(String text) {
  const months =
      'JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC';

  // "19 JUN 2028"
  final spaced = RegExp(
    r'\b(\d{1,2})\s(' + months + r')\s(\d{4})\b',
    caseSensitive: false,
  );
  final m1 = spaced.firstMatch(text);
  if (m1 != null) {
    return '${m1.group(1)!.padLeft(2, '0')} '
        '${m1.group(2)!.toUpperCase()} '
        '${m1.group(3)}';
  }

  // Fallback: "19JUN2028" (no spaces)
  final compact = RegExp(
    r'\b(\d{1,2})(' + months + r')(\d{4})\b',
    caseSensitive: false,
  );
  final m2 = compact.firstMatch(text);
  if (m2 != null) {
    return '${m2.group(1)!.padLeft(2, '0')} '
        '${m2.group(2)!.toUpperCase()} '
        '${m2.group(3)}';
  }

  return '';
}

// ── Holder name ───────────────────────────────────────────────
// "T. DALAL" — scan bottom-up since name is in lower-left.
String _extractHolderName(String text) {
  final nameRegex = RegExp(r'\b([A-Z])\.\s([A-Z]{2,20})\b');
  final lines = text.split('\n');

  for (final line in lines.reversed) {
    final m = nameRegex.firstMatch(line);
    if (m != null) return m.group(0)!;
  }

  return nameRegex.firstMatch(text)?.group(0) ?? '';
}