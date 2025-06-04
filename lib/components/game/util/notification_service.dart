import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton service to manage local notifications (v19.2.1 + timezone v0.10.1).
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final String localTimeZone = tz.local.name;
    tz.setLocalLocation(tz.getLocation(localTimeZone));

    final AndroidInitializationSettings androidSettings =
    const AndroidInitializationSettings('ic_notification');

    final DarwinInitializationSettings darwinSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    await _requestAndroidNotificationPermission();

    _initialized = true;
  }

  Future<void> _requestAndroidNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await initialize();

    final AndroidNotificationDetails androidDetails =
    const AndroidNotificationDetails(
      'reminder_channel_id',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        'notification_sound',
      ),
      icon: 'ic_notification',
    );

    final DarwinNotificationDetails darwinDetails =
    const DarwinNotificationDetails();

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final tz.TZDateTime scheduled =
    tz.TZDateTime.from(scheduledDate, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}