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
      id: json['id'],
      psicologoName: json['psicologoId'],
      pacienteId: json['pacienteId'],
      data: DateTime.parse(json['data']),
      valor: json['valor'],
      endereco: json['endereco'],
      finalizada: bool.parse(json['finalizada']),
    );
  }



}