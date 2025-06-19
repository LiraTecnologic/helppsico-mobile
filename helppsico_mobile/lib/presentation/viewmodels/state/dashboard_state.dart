import 'package:helppsico_mobile/domain/entities/document_model.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';

abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DocumentModel? lastDocument;
  final SessionModel? nextSession;

  const DashboardLoaded({
    this.lastDocument,
    this.nextSession,
  });
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);
}