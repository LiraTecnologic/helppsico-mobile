import 'package:flutter/material.dart';

enum DocumentType {
  anamnese,
  avaliacao,
  relatorio,
  atestado,
  encaminhamento,
  outros
}

class DocumentModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String fileSize;
  final String fileType;
  final DocumentType type;
  final bool isFavorite;
  final String patientId;
  final String patientName;
  final String fileUrl;

  DocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.fileSize,
    required this.fileType,
    required this.type,
    required this.isFavorite,
    required this.patientId,
    required this.patientName,
    required this.fileUrl,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      fileSize: json['fileSize'],
      fileType: json['fileType'],
      type: DocumentType.values.firstWhere(
        (e) => e.toString() == 'DocumentType.${json['type']}',
      ),
      isFavorite: json['isFavorite'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      fileUrl: json['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'fileSize': fileSize,
      'fileType': fileType,
      'type': type.toString().split('.').last,
      'isFavorite': isFavorite,
      'patientId': patientId,
      'patientName': patientName,
      'fileUrl': fileUrl,
    };
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? fileSize,
    String? fileType,
    DocumentType? type,
    bool? isFavorite,
    String? patientId,
    String? patientName,
    String? fileUrl,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
} 