import 'package:flutter/material.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:ff/screens/assistant/voice_methods.dart';

class PorcupineAssistant {
  PorcupineAssistant._();
  static final instance = PorcupineAssistant._();
  static final navKey = GlobalKey<NavigatorState>();

  PorcupineManager? _manager;

  Future<void> initialize() async {
    const accessKey = '<YOUR_PICOVOICE_ACCESS_KEY>';
    const keywordAsset = 'assets/picovoice/hey_harca.ppn';

    _manager = await PorcupineManager.fromKeywordPaths(
      accessKey,
      [keywordAsset], // list—even for a single wake-word
      _onWakeWordDetected,
      // optional overrides:
      // sensitivities: [0.5],
      // modelPath: 'assets/porcupine_params.pv',
      // errorCallback: (e) => debugPrint('Porcupine error: $e'),
    );

    await _manager?.start();
    debugPrint('🎧 Porcupine listening started');
  }

  void _onWakeWordDetected(int keywordIndex) {
    debugPrint('✅ Hot-word [$keywordIndex] detected');
    final ctx = navKey.currentContext;
    if (ctx != null) VoiceMethods.handleHotword(ctx);
  }

  Future<void> dispose() async {
    await _manager?.stop();
    await _manager?.delete();
  }
}
