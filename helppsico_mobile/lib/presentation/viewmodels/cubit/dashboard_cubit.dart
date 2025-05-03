import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/data/mock_documents.dart';
import 'package:helppsico_mobile/data/mock_sessions.dart';
import '../state/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final MockDocumentRepository _documentRepository = MockDocumentRepository();
  final MockSessionRepository _sessionRepository = MockSessionRepository();

  DashboardCubit() : super(const DashboardInitial());

  Future<void> loadData() async {
    emit(const DashboardLoading());
    try {
      final documents = await _documentRepository.getDocuments();
      final nextSession = await _sessionRepository.getNextSession();

      emit(DashboardLoaded(
        lastDocument: documents.isNotEmpty ? documents.first : null,
        nextSession: nextSession,
      ));
    } catch (e) {
      emit(DashboardError('Erro ao carregar dados: $e'));
    }
  }
}