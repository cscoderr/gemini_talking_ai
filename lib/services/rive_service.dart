import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

enum SMIType {
  trigger,
  bool,
  input,
}

abstract class RiveService {
  Future<void> onInit(Artboard artboard);

  bool? onChange(String name, bool value);

  void onFire(String name);
}

enum AvatarRiveSMI {
  talk('Talk', SMIType.bool),
  hear('Hear', SMIType.bool),
  check('Check', SMIType.bool),
  success('success', SMIType.trigger),
  failure('fail', SMIType.trigger);

  const AvatarRiveSMI(this.text, this.smiType);

  final String text;
  final SMIType smiType;
}

class AvatarRiveService implements RiveService {
  AvatarRiveService();

  StateMachineController? _controller;

  SMIBool? _smiBool;
  SMITrigger? _smiTrigger;

  @override
  Future<void> onInit(Artboard artboard) async {
    _controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    )!;
    artboard.addController(_controller!);
  }

  @override
  bool? onChange(String name, bool value) {
    if (_smiBool?.name != name) {
      _smiBool = _controller?.getBoolInput(name);
    }

    return _smiBool?.change(value);
  }

  @override
  void onFire(String name) {
    if (_smiTrigger?.name != name) {
      _smiTrigger = _controller?.getTriggerInput(name);
    }
    _smiTrigger?.fire();
  }
}

final avatarRiveServiceProvider = Provider<RiveService>((ref) {
  return AvatarRiveService();
});
