import '../domain/entities/session_model.dart';

class MockSessionRepository {
  static List<SessionModel> _sessions = [
   SessionModel(
     id: "1",
     data: DateTime(2023, 1, 1),
     endereco: "Rua 1",
     finalizada: false,
     pacienteId: "2",
     psicologoName: "Dr. João",
     valor: "100.00"
   ),
   SessionModel(
     id: "2", 
     data: DateTime(2023, 1, 15),
     endereco: "Rua 2",
     finalizada: true,
     pacienteId: "3",
     psicologoName: "Dra. Maria",
     valor: "120.00"
   ),
   SessionModel(
     id: "3",
     data: DateTime(2023, 2, 1),
     endereco: "Rua 3",
     finalizada: false,
     pacienteId: "4",
     psicologoName: "Dr. Pedro",
     valor: "150.00"
   ),
   SessionModel(
     id: "4",
     data: DateTime(2023, 2, 15),
     endereco: "Rua 4",
     finalizada: true,
     pacienteId: "5",
     psicologoName: "Dra. Ana",
     valor: "130.00"
   ),
   SessionModel(
     id: "5",
     data: DateTime(2023, 3, 1),
     endereco: "Rua 5",
     finalizada: false,
     pacienteId: "6",
     psicologoName: "Dr. Carlos",
     valor: "140.00"
   ),
   SessionModel(
     id: "6",
     data: DateTime(2023, 3, 15),
     endereco: "Rua 6",
     finalizada: true,
     pacienteId: "7",
     psicologoName: "Dra. Paula",
     valor: "110.00"
   ),
   SessionModel(
     id: "7",
     data: DateTime(2023, 4, 1),
     endereco: "Rua 7",
     finalizada: false,
     pacienteId: "8",
     psicologoName: "Dr. Lucas",
     valor: "160.00"
   ),
   SessionModel(
     id: "8",
     data: DateTime(2023, 4, 15),
     endereco: "Rua 8",
     finalizada: true,
     pacienteId: "9",
     psicologoName: "Dra. Julia",
     valor: "170.00"
   ),
   SessionModel(
     id: "9",
     data: DateTime(2023, 5, 1),
     endereco: "Rua 9",
     finalizada: false,
     pacienteId: "10",
     psicologoName: "Dr. Miguel",
     valor: "180.00"
   ),
   SessionModel(
     id: "10",
     data: DateTime(2023, 5, 15),
     endereco: "Rua 10",
     finalizada: true,
     pacienteId: "11",
     psicologoName: "Dra. Sofia",
     valor: "190.00"
   ),
   SessionModel(
     id: "11",
     data: DateTime(2023, 6, 1),
     endereco: "Rua 11",
     finalizada: false,
     pacienteId: "12",
     psicologoName: "Dr. Rafael",
     valor: "200.00"
   )
  ];

  Future<List<SessionModel>> getSessions() async {
    await Future.delayed(const Duration(seconds: 1));
    return _sessions;
  }

  Future<SessionModel?> getNextSession() async {
    await Future.delayed(const Duration(seconds: 1));
    if (_sessions.isEmpty) return null;
    return _sessions.first; // O primeiro é o mais próximo
  }
} 