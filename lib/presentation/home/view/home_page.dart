import 'package:devfest_ilorin_example/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:rive/rive.dart';

enum TtsState { playing, stopped, paused, continued }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StateMachineController _controller;
  String stateChangeMessage = '';
  SMIBool? _talkValue;
  SMIBool? _hearValue;
  SMIBool? _checkValue;
  SMITrigger? _successTrigger;
  SMITrigger? _failTrigger;

  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    onTtsInit();
  }

  Future<void> onTtsInit() async {
    await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers
        ],
        IosTextToSpeechAudioMode.voicePrompt);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.5);
    await flutterTts.setVoice({"name": "Kate", "locale": "en-US"});
    // final voice = await flutterTts.getDefaultVoice;
    // print(voice);
  }

  void onInit(Artboard artboard) async {
    _controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
      onStateChange: _onStateChange,
    )!;
    artboard.addController(_controller);
    _talkValue = _controller.getBoolInput('Talk');
    _hearValue = _controller.getBoolInput('Hear');
    _checkValue = _controller.getBoolInput('Check');
    _successTrigger = _controller.getTriggerInput('success');
    _failTrigger = _controller.getTriggerInput('fail');
  }

  Future _speak() async {
    _talkValue?.change(true);
    var result =
        await flutterTts.speak("Hello Tom, How are you, Hope you are okay");
    print(result);
    if (result == 1) {
      _talkValue?.change(false);
    }
    // if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    // if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  void _onStateChange(String stateMachineName, String stateName) => setState(
        () => stateChangeMessage =
            'State Changed in $stateMachineName to $stateName',
      );

  @override
  void dispose() {
    _controller.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  stateChangeMessage,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SwitchListTile.adaptive(
              value: _talkValue?.value ?? false,
              title: const Text('Talk'),
              onChanged: (value) {
                _talkValue?.change(value);
              },
            ),
            SwitchListTile.adaptive(
              value: _hearValue?.value ?? false,
              title: const Text('Hear'),
              onChanged: (value) {
                _hearValue?.change(value);
              },
            ),
            SwitchListTile.adaptive(
              value: _checkValue?.value ?? false,
              title: const Text('Check'),
              onChanged: (value) {
                _checkValue?.change(value);
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _successTrigger?.fire();
                  },
                  child: const Text('Success'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _failTrigger?.fire();
                  },
                  child: const Text('Fail'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _speak();
                  },
                  child: const Text('Speak'),
                ),
              ],
            ),
            Expanded(
              child: RiveAnimation.asset(
                Assets.rive.talkingTom,
                onInit: onInit,
              ),
            )
          ],
        ),
      ),
    );
  }
}
