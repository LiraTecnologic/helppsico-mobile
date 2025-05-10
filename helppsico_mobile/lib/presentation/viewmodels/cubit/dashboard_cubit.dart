import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/data/repositories/document_repository.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';
import 'package:helppsico_mobile/data/datasources/sessions_datasource.dart';
import 'package:helppsico_mobile/data/datasources/documents_datasource.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import '../state/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DocumentRepository _documentRepository = DocumentRepository(DocumentsDataSource(GenericHttp()));
  final SessionRepository _sessionRepository = SessionRepository(SessionsDataSource(GenericHttp()));


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