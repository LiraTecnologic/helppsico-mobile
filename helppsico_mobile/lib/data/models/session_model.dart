import 'package:flutter/material.dart';

enum SessionStatus {
  pending,
  scheduled,
  completed,
  canceled
}

class SessionModel {
  final String id;
  final String date;
  final String doctorName;
  final String sessionType;
  final String timeRange;
  final SessionStatus status;
  final String? paymentInfo;
  final String? location;
  final String? crp;

  SessionModel({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.sessionType,
    required this.timeRange,
    required this.status,
    this.paymentInfo,
    this.location,
    this.crp,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      date: json['date'],
      doctorName: json['doctorName'],
      sessionType: json['sessionType'],
      timeRange: json['timeRange'],
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == 'SessionStatus.${json['status']}',
      ),
      paymentInfo: json['paymentInfo'],
      location: json['location'],
      crp: json['crp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'doctorName': doctorName,
      'sessionType': sessionType,
      'timeRange': timeRange,
      'status': status.toString().split('.').last,
      'paymentInfo': paymentInfo,
      'location': location,
      'crp': crp,
    };
  }
} 