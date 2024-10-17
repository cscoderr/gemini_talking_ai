import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum SpeechToTextStatus {
  listening,
  notListening,
  unknown;
}

class SpeechToTextResult {
  const SpeechToTextResult({
    this.recognizedWords = '',
    this.isFinalResult = false,
  });
  final String recognizedWords;
  final bool isFinalResult;
}

extension SpeechToTextStatusEx on SpeechToTextStatus {
  bool get isListening => this == SpeechToTextStatus.listening;
  bool get isNotListening => this == SpeechToTextStatus.notListening;
  bool get isUnknown => this == SpeechToTextStatus.unknown;
}

abstract class SpeechToTextService {
  Future<void> initialize();

  Future<void> startListening({void Function(SpeechToTextResult)? onResult});

  bool get isSpeechEnabled;

  Future<void> stopListening();

  SpeechToTextStatus get status;

  Stream<SpeechToTextStatus> get statusListener;
}

class SpeechToTextServiceImpl extends SpeechToTextService {
  SpeechToTextServiceImpl({SpeechToText? speechToText})
      : _speechToText = speechToText ?? SpeechToText();
  final SpeechToText _speechToText;

  bool _isSpeechEnabled = false;

  @override
  Future<void> initialize() async {
    _isSpeechEnabled = await _speechToText.initialize();
  }

  @override
  bool get isSpeechEnabled => _isSpeechEnabled;

  @override
  Future<void> startListening(
      {void Function(SpeechToTextResult)? onResult}) async {
    if (!_isSpeechEnabled) return;
    await _speechToText.listen(
      onResult: (result) {
        print(result.recognizedWords);
        onResult?.call(SpeechToTextResult(
          recognizedWords: result.recognizedWords,
          isFinalResult: result.finalResult,
        ));
      },
    );
  }

  @override
  Future<void> stopListening() => _speechToText.stop();

  @override
  SpeechToTextStatus get status {
    if (_speechToText.isListening) {
      return SpeechToTextStatus.listening;
    } else if (_speechToText.isNotListening) {
      return SpeechToTextStatus.notListening;
    }
    return SpeechToTextStatus.unknown;
  }

  @override
  Stream<SpeechToTextStatus> get statusListener async* {
    SpeechToTextStatus status = SpeechToTextStatus.unknown;
    _speechToText.statusListener = (listenerStatus) {
      if (listenerStatus == 'listening') {
        status = SpeechToTextStatus.listening;
      }
      status = SpeechToTextStatus.notListening;
    };
    yield status;
  }
}

final sttServiceProvider = Provider<SpeechToTextService>((ref) {
  return SpeechToTextServiceImpl();
});
