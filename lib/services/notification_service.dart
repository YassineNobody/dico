import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ------------------------------------------------------
  // 🧩 Initialisation
  // ------------------------------------------------------
  Future<void> init() async {
    // ✅ Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // ✅ iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // ✅ Linux
    final linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Ouvrir',
      defaultIcon: AssetsLinuxIcon('assets/icon/app_icon.png'),
    );

    // ✅ Fusion multiplateforme
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // 🔹 Demande la permission (utile sur Android/iOS)
    await requestPermissionIfNeeded();
  }

  // ------------------------------------------------------
  // 🔒 Vérifie et demande les permissions si nécessaire
  // ------------------------------------------------------
  Future<void> requestPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final areEnabled = await androidPlugin?.areNotificationsEnabled();

      if (areEnabled == false) {
        final status = await Permission.notification.request();
        if (!status.isGranted && kDebugMode) {
          print("⚠️ Permission de notification refusée sur Android.");
        }
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (granted == false && kDebugMode) {
        print("⚠️ Permission de notification refusée sur iOS.");
      }
    }
  }

  // ------------------------------------------------------
  // 📨 Affiche une notification locale
  // ------------------------------------------------------
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await requestPermissionIfNeeded();

    const androidDetails = AndroidNotificationDetails(
      'update_channel',
      'Mises à jour',
      channelDescription: 'Notifications locales de Dico',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const linuxDetails = LinuxNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
