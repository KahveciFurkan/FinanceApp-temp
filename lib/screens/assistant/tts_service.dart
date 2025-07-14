import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text) async {
  print("🔊 TTS başlatılıyor: $text");
  await _tts.setLanguage("tr-TR");
  await _tts.setSpeechRate(0.5);
  await _tts.setPitch(1.0);

  var result = await _tts.speak(text);
  print("📢 TTS sonucu: $result");
}


  static Future<void> stop() async {
    await _tts.stop();
  }

  /// ✅ Sesli yanıt verdikten sonra bir işlem tetikler
 static Future<void> speakAndThen(String text, Function action) async {
  await _tts.setLanguage("tr-TR");
  await _tts.setSpeechRate(0.5);
  await _tts.setPitch(1.0);

  _tts.setCompletionHandler(() {
    print("✅ TTS tamamlandı, şimdi işlem çalışacak.");
    action();
  });

  await _tts.speak(text);
}

}
