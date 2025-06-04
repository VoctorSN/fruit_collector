// File: notification_service.dart
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

  /// Initialize the plugin, request permissions (iOS y Android 13+),
  /// y preparar datos de zona horaria.
  Future<void> initialize() async {
    if (_initialized) return;

    // 1) Inicializar datos de zona horaria
    tz.initializeTimeZones();
    final String localTimeZone = tz.local.name;
    tz.setLocalLocation(tz.getLocation(localTimeZone));

    // 2) Configuración para Android (sin const en v19.2.1)
    final AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('ic_notification');

    // 3) Configuración para iOS (Darwin): pedimos permisos de Alert, Badge, Sound
    final DarwinInitializationSettings darwinSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 4) Inicializar plugin con ambas configuraciones
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // 5) Después de inicializar, pedir permiso en Android 13+ (si aplica)
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

  /// Cancela todas las notificaciones pendientes.
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Programa una notificación [id] para que se dispare en [scheduledDate].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Asegurarnos de haber inicializado y pedido permisos
    print(1);
    await initialize();

    // Detalles de Android
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

    // Detalles de iOS (Darwin)
    final DarwinNotificationDetails darwinDetails =
    const DarwinNotificationDetails();

    // Configuración combinada
    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // Convertir a TZDateTime en zona local
    final tz.TZDateTime scheduled =
    tz.TZDateTime.from(scheduledDate, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      platformDetails,
      // Exacto aunque el dispositivo esté en Doze o inactivo
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // No repetir automáticamente
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}