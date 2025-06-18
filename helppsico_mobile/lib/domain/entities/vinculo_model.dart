class VinculoModel {
  final String id;
  final String pacienteId;
  final String pacienteNome;
  final String psicologoId;
  final String psicologoNome;
  final String psicologoCrp;
  final double valorConsulta;
  final String fotoUrl;
  final String status;

  VinculoModel({
    required this.id,
    required this.pacienteId,
    required this.pacienteNome,
    required this.psicologoId,
    required this.psicologoNome,
    required this.psicologoCrp,
    required this.valorConsulta,
    required this.fotoUrl,
    required this.status,
  });

  factory VinculoModel.fromJson(Map<String, dynamic> json) {
    final psicologo = json['psicologo'] ?? {};
    final paciente = json['paciente'] ?? {};

    return VinculoModel(
      id: json['id'] ?? '',
      pacienteId: paciente['id'] ?? '',
      pacienteNome: paciente['nome'] ?? '',
      psicologoId: psicologo['id'] ?? '',
      psicologoNome: psicologo['nome'] ?? '',
      psicologoCrp: psicologo['crp'] ?? '',
      valorConsulta: psicologo['valorConsulta'] != null
          ? double.tryParse(psicologo['valorConsulta'].toString()) ?? 0.0
          : 0.0,
      fotoUrl: psicologo['fotoUrl'] ?? '',
      status: json['status'] ?? 'PENDENTE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente': {
        'id': pacienteId,
        'nome': pacienteNome,
      },
      'psicologo': {
        'id': psicologoId,
        'nome': psicologoNome,
        'crp': psicologoCrp,
        'valorConsulta': valorConsulta,
        'fotoUrl': fotoUrl,
      },
      'status': status,
    };
  }

  VinculoModel copyWith({
    String? id,
    String? pacienteId,
    String? pacienteNome,
    String? psicologoId,
    String? psicologoNome,
    String? psicologoCrp,
    double? valorConsulta,
    String? fotoUrl,
    String? status,
  }) {
    return VinculoModel(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      pacienteNome: pacienteNome ?? this.pacienteNome,
      psicologoId: psicologoId ?? this.psicologoId,
      psicologoNome: psicologoNome ?? this.psicologoNome,
      psicologoCrp: psicologoCrp ?? this.psicologoCrp,
      valorConsulta: valorConsulta ?? this.valorConsulta,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      status: status ?? this.status,
    );
  }
}