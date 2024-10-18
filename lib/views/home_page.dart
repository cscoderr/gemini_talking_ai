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
        _messageController.text = result.recognizedWords;
        setState(() {});

        if (result.isFinalResult) {
          _riveService.onChange(AvatarRiveSMI.hear.text, false);
          _riveService.onChange(AvatarRiveSMI.check.text, true);
          ref.read(appProvider.notifier).getResponse(result.recognizedWords);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    ref.listen(
      appProvider,
      (previous, next) {
        _riveService.onChange(AvatarRiveSMI.check.text, false);
        next.whenData(
          (value) async {
            _riveService.onChange(AvatarRiveSMI.talk.text, true);
            await _ttsService.speak(value);
            _riveService.onChange(AvatarRiveSMI.talk.text, false);
            _messageController.clear();
            setState(() {});
          },
        );
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
            Expanded(
              child: Column(
                children: [
                  state.maybeWhen(
                      orElse: () => const SizedBox(),
                      data: (data) {
                        if (data != null) {
                          return ChatBubble(text: data);
                        }
                        return const SizedBox();
                      })
                ],
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
                      _riveService.onChange(AvatarRiveSMI.hear.text, true);

                      await _startListeningToSpeech();
                      setState(() {});
                    } else {
                      _riveService.onChange(AvatarRiveSMI.hear.text, false);
                      await _sttService.stopListening();
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    controller: _messageController,
                    hintText: 'Your message',
                    maxLines: 2,
                    readOnly: true,
                  ),
                ),
              ],
            ),
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
      flex: 2,
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
