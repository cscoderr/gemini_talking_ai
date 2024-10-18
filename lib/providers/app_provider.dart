import 'dart:async';

import 'package:devfest_ilorin_example/services/ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotifier extends AsyncNotifier<String?> {
  AppNotifier();

  @override
  FutureOr<String?> build() {
    return null;
  }

  Future<void> getResponse(String message) async {
    state = const AsyncLoading();
    final aiService = ref.read(aiServiceProvider);
    final response = await aiService.getResponse(message);
    state = AsyncData(response.text ?? '');
  }
}

final appProvider =
    AsyncNotifierProvider<AppNotifier, String?>(AppNotifier.new);
