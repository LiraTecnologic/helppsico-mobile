class SessionModel {
  final String id;
  final String psicologoId;
  final String pacienteId;
  final DateTime data; 
  final String valor;
  final String endereco;
  final bool finalizada;

  SessionModel({
    required this.id,
    required this.psicologoId,
    required this.pacienteId,
    required this.data,
    required this.valor,
    required this.endereco,
    required this.finalizada,
  });


  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      psicologoId: json['psicologoId'],
      pacienteId: json['pacienteId'],
      data: DateTime(json['data'].toDate().year, json['data'].toDate().month, json['data'].toDate().day, json['data'].toDate().hour),
      valor: json['valor'],
      endereco: json['endereco'],
      finalizada: bool.parse(json['finalizada']),
    );
  }



}