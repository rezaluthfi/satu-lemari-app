import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function untuk background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inisialisasi Firebase jika belum
  // await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback untuk navigasi ketika notifikasi diklik
  Function(String)? onNotificationTap;

  Future<void> initialize() async {
    // Request permission untuk iOS
    await _requestPermissions();

    // Inisialisasi local notifications
    await _initializeLocalNotifications();

    // Setup Firebase messaging handlers
    await _setupFirebaseHandlers();

    print('NotificationService initialized successfully');
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('User granted permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // For critical alerts
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Request notification permissions for Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Buat notification channel untuk Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
      ledColor: Colors.red,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Create additional high priority channel for critical notifications
    const AndroidNotificationChannel criticalChannel =
        AndroidNotificationChannel(
      'critical_channel',
      'Critical Notifications',
      description: 'Critical notifications that require immediate attention',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
      ledColor: Colors.red,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(criticalChannel);
  }

  Future<void> _setupFirebaseHandlers() async {
    // Handler untuk pesan di foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler untuk tap notifikasi saat app di background
    FirebaseMessaging.onMessageOpenedApp
        .listen(_handleNotificationTapFromBackground);

    // Cek initial message (jika app dibuka dari notifikasi)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTapFromTerminated(initialMessage);
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            showWhen: true,
            when: DateTime.now().millisecondsSinceEpoch,
            icon: '@drawable/notification_icon',
            largeIcon: const DrawableResourceAndroidBitmap(
                '@drawable/notification_icon'),
            styleInformation: BigTextStyleInformation(
              notification.body ?? '',
              contentTitle: notification.title,
            ),
            // Additional properties for better visibility
            autoCancel: false, // Don't auto dismiss
            ongoing: false, // Can be dismissed by user
            ticker: notification.title, // Text shown in status bar
            visibility: NotificationVisibility.public,
            // Make notification heads-up (pop up over current app)
            fullScreenIntent: true,
            category: AndroidNotificationCategory.message,
            // Vibration pattern
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            enableLights: true,
            ledColor: Colors.red,
            ledOnMs: 1000,
            ledOffMs: 500,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            // Make it critical to bypass Do Not Disturb
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        payload: _createPayload(message),
      );
    }
  }

  String _createPayload(RemoteMessage message) {
    // Buat payload dari data message untuk navigation
    return message.data['route'] ?? '/notifications';
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null && onNotificationTap != null) {
      onNotificationTap!(payload);
    }
  }

  void _handleNotificationTapFromBackground(RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    final route = message.data['route'] ?? '/notifications';
    if (onNotificationTap != null) {
      onNotificationTap!(route);
    }
  }

  void _handleNotificationTapFromTerminated(RemoteMessage message) {
    print('App opened from terminated state via notification');
    final route = message.data['route'] ?? '/notifications';
    if (onNotificationTap != null) {
      onNotificationTap!(route);
    }
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Stream<String> onTokenRefresh() {
    return _firebaseMessaging.onTokenRefresh;
  }

  // Method untuk set callback navigasi
  void setOnNotificationTap(Function(String) callback) {
    onNotificationTap = callback;
  }

  // Method untuk menampilkan notifikasi test
  Future<void> showTestNotification() async {
    await _localNotifications.show(
      0,
      'Test Notification',
      'This is a test notification from SatuLemari',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.max, // Changed to max like critical
          playSound: true,
          enableVibration: true,
          icon: '@drawable/notification_icon',
          autoCancel: false,
          ongoing: false,
          ticker: 'Test Notification',
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.message, // Added category
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          enableLights: true,
          ledColor: Colors.red,
          styleInformation: const BigTextStyleInformation(
            // Added style
            'This is a test notification from SatuLemari',
            contentTitle: 'Test Notification',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
          sound: 'default', // Added explicit sound
        ),
      ),
    );
  }

  // Method untuk menampilkan notifikasi critical yang pasti tampil di atas
  Future<void> showCriticalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'critical_channel',
          'Critical Notifications',
          channelDescription:
              'Critical notifications that require immediate attention',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/notification_icon',
          autoCancel: false,
          ongoing: false,
          ticker: title,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
          enableLights: true,
          ledColor: Colors.red,
          ledOnMs: 1000,
          ledOffMs: 500,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
          sound: 'default',
        ),
      ),
      payload: payload,
    );
  }
}
