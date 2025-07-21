import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Inisialisasi local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            'notification_icon'); // Gunakan nama ikon Anda
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await _localNotifications.initialize(initializationSettings);

    // Menangani notifikasi saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel', // Channel ID
                'High Importance Notifications', // Channel name
                channelDescription:
                    'This channel is used for important notifications.',
                importance: Importance.max,
                priority: Priority.high,
                icon: 'notification_icon',
              ),
            ));
      }
    });

    // TODO: Tambahkan handler untuk onMessageOpenedApp (saat notif diklik dari background)
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Stream<String> onTokenRefresh() {
    return _firebaseMessaging.onTokenRefresh;
  }
}
