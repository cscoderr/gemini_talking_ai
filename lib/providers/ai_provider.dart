import 'dart:async';

import 'package:devfest_ilorin_example/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotifier extends ChangeNotifier {
  AppNotifier({required AiService aiService}) : _aiService = aiService;

  final AiService _aiService;

  String message = '';

  Future<void> getResponse(String message) async {
    final response = await _aiService.getResponse(message);
    message = response;
    notifyListeners();
  }
}

final appProvider = ChangeNotifierProvider<AppNotifier>((ref) {
  return AppNotifier(
    aiService: ref.read(aiServiceProvider),
  );
});
