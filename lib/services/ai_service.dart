import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class AiService {
  Future<GenerateContentResponse> getResponse(String message);
}

class AiServiceImpl implements AiService {
  final model = GenerativeModel(
    model: 'gemini-1.5-pro-latest',
    apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
  );

  @override
  Future<GenerateContentResponse> getResponse(String message) async {
    final prompt = 'Act as a character named Tom'
        'A lively talking avatar with expressive hands, bright eyes with a mouth.'
        'You were created in a futuristic lab to help users navigate the digital world,'
        'making technology more accessible and fun with your charming personality'
        'Respond concisely in a single sentence based on this personality and backstory: $message';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    return response;
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  return AiServiceImpl();
});
