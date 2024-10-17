import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TextToSpeechState { playing, stopped, paused, continued }

abstract class TextToSpeechService {
  Future<void> initialize();
  Future<TextToSpeechState> speak(String? text);
  Future<TextToSpeechState> stopSpeaking();
}

class TextToSpeechServiceImpl implements TextToSpeechService {
  TextToSpeechServiceImpl({FlutterTts? textToSpeech})
      : _textToSpeech = textToSpeech ?? FlutterTts();
  final FlutterTts _textToSpeech;

  final _defaultText = '''Hello I'm Tom, How are you''';

  @override
  Future<void> initialize() async {
    await _textToSpeech.setIosAudioCategory(
      IosTextToSpeechAudioCategory.ambient,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
    await _textToSpeech.awaitSpeakCompletion(true);
    await _textToSpeech.setVolume(1.0);
    await _textToSpeech.setPitch(1.5);
    // await _textToSpeech.setVoice({"name": "Kate", "locale": "en-US"});
    // final voice = await flutterTts.getDefaultVoice;
    // print(voice);
  }

  @override
  Future<TextToSpeechState> speak(String? text) async {
    //  _textToSpeech?.change(true);
    var result = await _textToSpeech.speak(text ?? _defaultText);
    if (result == 1) {
      return TextToSpeechState.playing;
      // _talkValue?.change(false);
    }
    return TextToSpeechState.stopped;
  }

  @override
  Future<TextToSpeechState> stopSpeaking() async {
    var result = await _textToSpeech.stop();
    if (result == 1) {
      return TextToSpeechState.stopped;
    }
    return TextToSpeechState.paused;
  }
}

final ttsServiceProvider = Provider<TextToSpeechService>((ref) {
  return TextToSpeechServiceImpl();
});
