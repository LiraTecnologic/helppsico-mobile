import '../domain/entities/session_model.dart';

class MockSessionRepository {
  static List<SessionModel> _sessions = [
    SessionModel(
      id: '1',
      date: 'Amanhã, 24 fev 2025',
      doctorName: 'Dra. Ana Martins',
      sessionType: 'Terapia Individual',
      timeRange: '14:00 - 15:00',
      status: SessionStatus.pending,
      location: 'Rua das Flores, 123 - Centro',
      crp: '78974-63',
    ),
    SessionModel(
      id: '2',
      date: 'Quinta, 27 fev 2025',
      doctorName: 'Dr. Carlos Silva',
      sessionType: 'Avaliação Psicológica',
      timeRange: '10:30 - 12:00',
      status: SessionStatus.scheduled,
      paymentInfo: 'Pago via Cartão de Crédito',
      location: 'Av. Principal, 456 - Sala 101',
      crp: '45678-90',
    ),
    SessionModel(
      id: '3',
      date: 'Segunda, 3 mar 2025',
      doctorName: 'Dr. Roberto Almeida',
      sessionType: 'Terapia Cognitivo-Comportamental',
      timeRange: '09:00 - 10:00',
      status: SessionStatus.scheduled,
      paymentInfo: 'Pago via PIX',
      location: 'Rua das Palmeiras, 789 - Sala 303',
      crp: '12345-67',
    ),
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