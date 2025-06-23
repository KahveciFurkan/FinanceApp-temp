import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class WeatherNotifier {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _timer;

  Future<void> initialize() async {
    await _initNotifications();
    _startPeriodicWeatherCheck();
  }

  Future<void> _initNotifications() async {
    await Permission.notification.request();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await _notificationsPlugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'weather_channel',
      'Hava Durumu Uyarıları',
      description: 'Yağış durumlarına göre bildirimler',
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _startPeriodicWeatherCheck() {
    _timer = Timer.periodic(const Duration(minutes: 180), (_) {
      _checkWeatherAndNotify();
    });

    _checkWeatherAndNotify();
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'weather_channel',
          'Hava Durumu Uyarıları',
          channelDescription: 'Yağış bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

  Future<void> _checkWeatherAndNotify() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final latitude = position.latitude;
      final longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      String city = placemarks.first.administrativeArea ?? "Bilinmeyen şehir";

      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final hourly = data['hourly'];
      final temperatures = hourly['temperature_2m'];
      final times = hourly['time'];

      final now = DateTime.now().toUtc();

      DateTime? closestTime;
      double? temperatureValue;

      for (int i = 0; i < times.length; i++) {
        final time = DateTime.parse(times[i]);
        final diff = (time.difference(now)).inMinutes.abs();

        if (closestTime == null ||
            diff < (closestTime.difference(now)).inMinutes.abs()) {
          closestTime = time;
          temperatureValue = temperatures[i].toDouble();
        }
      }

      if (temperatureValue != null) {
        if (temperatureValue > 30) {
          await _showNotification(
            'Sıcaklık Uyarısı',
            'Dışarısı çok sıcak! Şu an: ${temperatureValue.toStringAsFixed(1)}°C',
          );
        } else if (temperatureValue < 5) {
          await _showNotification(
            'Soğuk Hava Uyarısı',
            'Dışarısı soğuk. Şu an: ${temperatureValue.toStringAsFixed(1)}°C',
          );
        } else {
          await _showNotification(
            'Sıcaklık Uyarısı - $city',
            'Sıcaklık normal: ${temperatureValue.toStringAsFixed(1)}°C',
          );
        }
      }
    } catch (_) {}
  }
}
