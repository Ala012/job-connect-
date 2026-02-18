import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    // Request notification permissions for Android 13+
    // (handled by OS permissions dialog)
  }

  // Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jobconnect_channel',
      'Job Connect Notifications',
      channelDescription: 'Notifications for JobConnect app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jobconnect_channel',
      'Job Connect Notifications',
      channelDescription: 'Notifications for JobConnect app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel a notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Show notification for new job application status
  Future<void> showApplicationStatusNotification({
    required String jobTitle,
    required String status,
    required String companyName,
  }) async {
    String title = '';
    String body = '';

    switch (status) {
      case 'accepted':
        title = '🎉 Candidature acceptée!';
        body = 'Félicitations! $companyName a accepté votre candidature pour $jobTitle';
        break;
      case 'rejected':
        title = 'Candidature refusée';
        body = '$companyName a refusé votre candidature pour $jobTitle';
        break;
      case 'in_review':
        title = '👀 Candidature en cours d\'examen';
        body = '$companyName examine votre candidature pour $jobTitle';
        break;
      default:
        title = 'Mise à jour de candidature';
        body = 'Statut mis à jour pour $jobTitle chez $companyName';
    }

    await showNotification(
      id: jobTitle.hashCode,
      title: title,
      body: body,
      payload: jobTitle,
    );
  }

  // Show notification for new job posting
  Future<void> showNewJobNotification({
    required String jobTitle,
    required String companyName,
    required String location,
  }) async {
    await showNotification(
      id: jobTitle.hashCode,
      title: '🎯 Nouvelle offre d\'emploi',
      body: '$companyName recrute pour $jobTitle à $location',
      payload: jobTitle,
    );
  }

  // Show notification for new candidate
  Future<void> showNewCandidateNotification({
    required String candidateName,
    required String jobTitle,
  }) async {
    await showNotification(
      id: candidateName.hashCode,
      title: '📝 Nouvelle candidature',
      body: '$candidateName a postulé pour $jobTitle',
      payload: jobTitle,
    );
  }
}
