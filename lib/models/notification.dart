// notification_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationModel {
  Future<void> sendNotification() async {
    final url = Uri.parse('https://api.onesignal.com');
    final apiKey = 'kdiowtqr6eb2ummcd43c5r5le';
    final appId = '8f8cdaab-a211-4b80-ae3d-d196988e6a78';

    final data = {
      'app_id': appId,
      'contents': {
        'en': 'Hello, World',
      },
      'included_segments': ['All Subscribers'],
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Key $apiKey',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully!');
      } else {
        debugPrint('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
