import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final aiQuoteProvider = FutureProvider<String>((ref) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final prompt = 'Generate a short, motivational quote for an athlete about training and perseverance. Keep it under 100 characters.';
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Push your limits every day!';
  } catch (e) {
    // Fallback quote
    return 'Train hard, stay consistent!';
  }
});
