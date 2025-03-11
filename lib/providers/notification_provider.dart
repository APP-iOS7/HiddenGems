// notification_provider.dart
import 'package:flutter/material.dart';

import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationModel _notificationModel = NotificationModel();

  Future<void> sendNotification() async {
    await _notificationModel.sendNotification();
    notifyListeners();
  }
}
