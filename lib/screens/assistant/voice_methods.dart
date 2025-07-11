import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../expenses/add_expense_screen.dart';
import '../home_screen.dart';

class VoiceMethods {
  static void handleCommand(String cmd, BuildContext ctx) {
    if (cmd.contains('test') || cmd.contains('peki')) {
      Navigator.of(
        ctx,
      ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
    } else if (cmd.contains('ana sayfaya dön')) {
      Navigator.of(ctx).popUntil((r) => r.isFirst);
    }
    if (cmd.contains('pc uyut')) {
      final homeState = HomeScreen.globalKey.currentState;
      if (homeState != null) {
        homeState.sleepPc();
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Uygulama durumu hazır değil.')),
        );
      }
    } else if (cmd.contains('pc aç')) {
      final homeState = HomeScreen.globalKey.currentState;
      if (homeState != null) {
        homeState.wakePc();
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Uygulama durumu hazır değil.')),
        );
      }
    } else if (cmd.contains('uygulamayı kapat') ||
        cmd.contains('uygulamayi kapat') ||
        cmd.contains('çıkış yap') ||
        cmd.contains('kapat')) {
      // Android ve iOS'ta uygulamayı kapatır
      SystemNavigator.pop();
      exit(0);
      // Eğer tam olarak süreci sonlandırmak istersen şu satırı da ekleyebilirsin:
      // exit(0);else {
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Ne dediğini anlayamadım: "$cmd"')),
      );
    }
  }
}
