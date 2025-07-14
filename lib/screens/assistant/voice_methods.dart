import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../expenses/add_expense_screen.dart';
import '../home_screen.dart';
import 'tts_service.dart'; // <-- TTS servisini ekledik

class VoiceMethods {
  static final List<_VoiceCommand> _commands = [
    _VoiceCommand(
      keywords: ['harcama ekle', 'harcama'],
      action: (ctx) {
        TTSService.speak("Yeni bir harcama ekliyoruz.");
        Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        );
      },
    ),
    _VoiceCommand(
      keywords: ['ana sayfaya dön', 'ana ekran'],
      action: (ctx) {
        TTSService.speak("Ana sayfaya dönüyorum.");
        Navigator.of(ctx).popUntil((r) => r.isFirst);
      },
    ),
    _VoiceCommand(
      keywords: ['pc uyut', 'bilgisayarı uyut'],
      action: (ctx) {
        final homeState = HomeScreen.globalKey.currentState;
        if (homeState != null) {
          TTSService.speak("Bilgisayarı uyutuyorum.");
          homeState.sleepPc();
        } else {
          _showError(ctx, 'Uygulama durumu hazır değil.');
        }
      },
    ),
    _VoiceCommand(
      keywords: ['pc aç', 'bilgisayarı aç'],
      action: (ctx) {
        final homeState = HomeScreen.globalKey.currentState;
        if (homeState != null) {
          TTSService.speak("Bilgisayarı açıyorum.");
          homeState.wakePc();
        } else {
          _showError(ctx, 'Uygulama durumu hazır değil.');
        }
      },
    ),
    _VoiceCommand(
  keywords: ['uygulamayı kapat', 'uygulamayi kapat', 'çıkış yap', 'kapat'],
  action: (ctx) {
    TTSService.speakAndThen("Uygulamayı kapatıyorum. Hoşça kal.", () {
      SystemNavigator.pop();
      exit(0);
    });
  },
),

  ];

  static void handleCommand(String cmd, BuildContext ctx) {
    final lowerCmd = cmd.toLowerCase();

    for (final command in _commands) {
      if (command.matches(lowerCmd)) {
        command.action(ctx);
        return;
      }
    }

    _showError(ctx, 'Ne dediğini anlayamadım: "$cmd"');
    TTSService.speak("Ne dediğini anlayamadım.");
  }

  static void _showError(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _VoiceCommand {
  final List<String> keywords;
  final void Function(BuildContext ctx) action;

  _VoiceCommand({required this.keywords, required this.action});

  bool matches(String input) {
    return keywords.any((k) => input.contains(k));
  }
}
