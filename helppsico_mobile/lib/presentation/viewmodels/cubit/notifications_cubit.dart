import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/data/repositories/notifications_repository.dart';
import 'package:helppsico_mobile/presentation/viewmodels/bloc/notifications_state.dart';



class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  Future<void> fetchNotifications() async {
    try {
      emit(NotificationsLoading());
      final notifications = await _repository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }
}