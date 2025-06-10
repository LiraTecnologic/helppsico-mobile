import 'package:flutter/material.dart';

enum DocumentType {
  ATESTADO,
  DECLARACAO,
  RELATORIO_PSICOLOGICO,
  LAUDO_PSICOLOGICO,
  PARECER_PSICOLOGICO
}

class DocumentModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String fileSize;
  final String fileType;
  final DocumentType type;
  bool isFavorite; 
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
    this.isFavorite = false, 
    required this.patientId,
    required this.patientName,
    required this.fileUrl,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    return DocumentModel(
      id: json['id'] ?? '',
      title: json['finalidade'] ?? '', 
      description: json['descricao'] ?? '',
      date: DateTime.tryParse(json['dataEmissao'] ?? '') ?? DateTime.now(),
      fileSize: '', 
      fileType: '', 
      type: _mapDocumentTypeFromJson(json['finalidade'] ?? ''),
      isFavorite: isFavorite, 
      patientId: json['paciente']?['id'] ?? '',
      patientName: json['paciente']?['nome'] ?? '',
      fileUrl: '', 
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


DocumentType _mapDocumentTypeFromJson(String finalidade) {
  switch (finalidade.toUpperCase()) {
    case 'ATESTADO':
      return DocumentType.ATESTADO;
    case 'DECLARACAO':
      return DocumentType.DECLARACAO;
    case 'RELATORIO PSICOLOGICO': 
    case 'RELATÓRIO PSICOLÓGICO':
      return DocumentType.RELATORIO_PSICOLOGICO;
    case 'LAUDO PSICOLOGICO': 
    case 'LAUDO PSICOLÓGICO':
      return DocumentType.LAUDO_PSICOLOGICO;
    case 'PARECER PSICOLOGICO': 
    case 'PARECER PSICOLÓGICO':
      return DocumentType.PARECER_PSICOLOGICO;
    default:
     
      print("Tipo de documento desconhecido: '$finalidade', usando PARECER_PSICOLOGICO como padrão.");
      return DocumentType.PARECER_PSICOLOGICO; 
  }
}