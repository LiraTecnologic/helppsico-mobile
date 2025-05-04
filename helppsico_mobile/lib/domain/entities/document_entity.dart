import 'package:flutter/material.dart';

enum DocumentType {
  ATESTADO,
  DECLARACAO,
  RELATORIO_PSICOLOGICO,
  RELATORIO_MULTIPROFISSIONAL,
  LAUDO_PSICOLOGICO,
  PARECER_PSICOLOGICO
}

class DocumentEntity {
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

  DocumentEntity({
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
}