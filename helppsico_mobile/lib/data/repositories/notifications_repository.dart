import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationRepository {
  final String baseUrl = 'http://localhost:7000'; //Adicione o endpoint da api aqui :)

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);//o json retornado tem que ser do tipo lista 
        return jsonList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }
}