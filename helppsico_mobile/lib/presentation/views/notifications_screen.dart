import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/data/datasource/notification_data_source.dart';
import 'package:helppsico_mobile/data/repositories/notifications_repository.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/notifications_cubit.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/notifications_state.dart';
import 'package:helppsico_mobile/presentation/widgets/common/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/drawer/custom_drawer.dart';
import 'package:helppsico_mobile/presentation/widgets/notifications/notification_card.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/presentation/views/sessions_wrapper.dart';

final IGenericHttp _http = GenericHttp();
final _notificationDataSource = NotificationDataSource(_http);

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
          
              NotificationsCubit(NotificationRepository(_notificationDataSource))
                ..fetchNotifications(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: CustomAppBar(),
        drawer: const CustomDrawer(),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SessionsWrapper()),
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.calendar_today, size: 20),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificações',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is NotificationsError) {
                        return Center(child: Text(state.message));
                      } else if (state is NotificationsLoaded) {
                        return ListView.builder(
                          itemCount: state.notifications.length,
                          itemBuilder: (context, index) {
                            final notification = state.notifications[index];
                            return NotificationCard(
                              type: _getNotificationType(notification.type),
                              date: _formatDate(notification.createdAt),
                              title: notification.title,
                              description: notification.message,
                              actionText:
                                  notification.actionText ?? 'Ver Detalhes',
                              onActionPressed: () {},
                            );
                          },
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  NotificationType _getNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'appointment':
        return NotificationType.appointment;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.reminder;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int month) {
    const months = [
      'jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez',
    ];
    
    return months[month - 1];
  }
}
