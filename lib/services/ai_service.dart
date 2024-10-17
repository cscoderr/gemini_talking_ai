import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class AiService {
  Future<String> getResponse(String message);
}

class AiServiceImpl implements AiService {
  final model = GenerativeModel(
    model: 'gemini-1.5-pro-latest',
    apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
  );
  @override
  Future<String> getResponse(String message) async {
    print('enter $message');
    const prompt = 'You are to act as a character named Tom.'
        'Your response must be based on your personality. You have this backstory: You are a talking avatar that have two hands, eyes and mouth'
        'The response should be concise and one single sentence only.';
    final question = 'you are ask $message';
    final content = [Content.text(prompt), Content.text(question)];
    final response = await model.generateContent(content);

    print('==================================');
    print(response.text);
    print('==================================');
    return response.text ?? '';
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  return AiServiceImpl();
});
