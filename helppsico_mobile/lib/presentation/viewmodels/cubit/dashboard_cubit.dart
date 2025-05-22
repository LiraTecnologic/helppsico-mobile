import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import 'package:helppsico_mobile/data/repositories/document_repository.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';

import 'package:helppsico_mobile/data/datasource/documents_datasource.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import '../state/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DocumentRepository _documentRepository = DocumentRepository(DocumentsDataSource(GenericHttp()));
  final SessionRepository _sessionRepository = SessionRepository(SessionsDataSource(GenericHttp()));


  DashboardCubit() : super(const DashboardInitial());

  Future<void> loadData() async {
      if (isClosed) return;

    emit(const DashboardLoading());
    try {
      if (isClosed) return;
      final documents = await _documentRepository.getDocuments();
      if (isClosed) return;
      final nextSession = await _sessionRepository.getNextSession();

      if (isClosed) return;
      emit(DashboardLoaded(
        lastDocument: documents.isNotEmpty ? documents.first : null,
        nextSession: nextSession,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(DashboardError('Erro ao carregar dados: $e'));
    }
  }
}