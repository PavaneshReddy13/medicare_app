import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/prescription_model.dart';
import 'package:intl/intl.dart';

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});

class ReminderService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ReminderService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleAllReminders(List<PrescriptionModel> prescriptions) async {
    await cancelAllReminders();

    int notificationId = 0;

    for (var prescription in prescriptions) {
      for (var rawMed in prescription.medicines) {
        final med = rawMed as Map<String, dynamic>;
        final String name = med['name'] ?? 'Medicine';
        final String dosage = med['dosage'] ?? '';
        final List<dynamic> times = med['times'] ?? []; // Expected: ["08:00", "20:00"]

        for (var timeStr in times) {
          try {
            final parsedTime = DateFormat("HH:mm").parse(timeStr.toString());
            await _scheduleDailyNotification(
              id: notificationId++,
              title: "💊 Time for your Medicine",
              body: "Please take $name - $dosage.",
              time: tz.TZDateTime.local(2026, 1, 1, parsedTime.hour, parsedTime.minute),
            );
          } catch (e) {
            // parsing logic skips mapping if standard time string fails
          }
        }
      }
    }
  }

  Future<void> _scheduleDailyNotification({required int id, required String title, required String body, required tz.TZDateTime time}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1)); // schedule for next occurrence naturally
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminders',
          'Medicine Reminders',
          channelDescription: 'Daily medicine intake reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllReminders() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelReminderForPrescription(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
