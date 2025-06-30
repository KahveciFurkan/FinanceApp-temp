import 'package:flutter/material.dart';

void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text(
            "Kullanım Kılavuzu",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Not eklemek için '+' butonunu kullanın"),
              Text("• Notlar arası bağlantı için notlara tıklayın"),
              Text("• Notu silmek için çöp kutusuna sürükleyin"),
              Text("• Bağlantıyı silmek için üzerindeki çarpıya tıklayın"),
              Text("• Notu düzenlemek için uzun basın"),
              Text("• Çoklu seçim için notlara uzun basın"),
              Text("• Grup oluşturmak için grup butonunu kullanın"),
              Text("• Otomatik düzen için düzen butonunu kullanın"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tamam",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
  );
}
