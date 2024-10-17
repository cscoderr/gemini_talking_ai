import 'dart:async';

import 'package:devfest_ilorin_example/gen/assets.gen.dart';
import 'package:devfest_ilorin_example/providers/providers.dart';
import 'package:devfest_ilorin_example/services/services.dart';
import 'package:devfest_ilorin_example/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String stateChangeMessage = '';

  late TextToSpeechService _ttsService;
  late SpeechToTextService _sttService;
  late RiveService _riveService;

  late StreamSubscription _sttStatusSubscription;
  final String _lastWords = '';
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _ttsService = ref.read(ttsServiceProvider);
    _sttService = ref.read(sttServiceProvider);
    _riveService = ref.read(avatarRiveServiceProvider);

    _sttService.initialize();
    _ttsService.initialize();

    _sttStatusSubscription = _sttService.statusListener.listen(
      (status) {
        print(status);
        if (status == SpeechToTextStatus.listening) {
          _riveService.onChange(AvatarRiveSMI.check.text, true);
        } else {
          _riveService.onChange(AvatarRiveSMI.check.text, false);
        }
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _sttStatusSubscription.cancel();
    _ttsService.stopSpeaking();
    super.dispose();
  }

  Future<void> _startListeningToSpeech() async {
    await _sttService.startListening(
      onResult: (result) {
        print(result.recognizedWords);
        _messageController.text = result.recognizedWords;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      appProvider,
      (previous, next) {
        _riveService.onChange(AvatarRiveSMI.check.text, false);
        if (next.message.isNotEmpty) {
          _riveService.onChange(AvatarRiveSMI.talk.text, true);
          _ttsService.speak(next.message);
          _riveService.onChange(AvatarRiveSMI.talk.text, false);
        }
      },
    );

    return Scaffold(
      appBar: _HomeAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RiveAnimationWidget(riveService: _riveService),
            const SizedBox(height: 15),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ChatBubble(),
                    // if (_lastWords.isNotEmpty)
                    //   ChatBubble(
                    //     text: _lastWords,
                    //   ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                AppIconButton(
                  icon: _sttService.status.isNotListening
                      ? Icons.mic_off
                      : Icons.mic,
                  onPressed: () async {
                    if (_sttService.status.isNotListening ||
                        _sttService.status.isUnknown) {
                      await _startListeningToSpeech();
                      setState(() {});
                    } else {
                      await _sttService.stopListening();
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: AppTextField(
                    hintText: 'Your message',
                    maxLines: 2,
                    readOnly: true,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends AppBar {
  _HomeAppBar()
      : super(
          title: const Text('Tom'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings),
            )
          ],
        );
}

class _RiveAnimationWidget extends StatelessWidget {
  const _RiveAnimationWidget({
    required RiveService riveService,
  }) : _riveService = riveService;

  final RiveService _riveService;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: RiveAnimation.asset(
          Assets.rive.talkingTom,
          onInit: _riveService.onInit,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
