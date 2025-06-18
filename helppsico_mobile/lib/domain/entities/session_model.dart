class SessionModel {
  final String id;
  final String psicologoName;
  final String pacienteId;
  final DateTime data;
  final String valor;
  final String endereco;
  final bool finalizada;

  SessionModel({
    required this.id,
    required this.psicologoName,
    required this.pacienteId,
    required this.data,
    required this.valor,
    required this.endereco,
    required this.finalizada,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id']?.toString() ?? '',
      psicologoName: json['psicologoName'] ?? json['psicologoId'] ?? '',
      pacienteId: json['pacienteId']?.toString() ?? '',
      data: DateTime.parse(json['data']),
      valor: json['valor']?.toString() ?? '',
      endereco: json['endereco']?.toString() ?? '',
      finalizada: json['finalizada'] is bool
          ? json['finalizada']
          : (json['finalizada']?.toString().toLowerCase() == 'true'),
    );
  }
}
