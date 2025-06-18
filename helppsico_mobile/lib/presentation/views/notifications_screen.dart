import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/domain/entities/notification_entity.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/notifications_cubit.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/notifications_state.dart';
import 'package:helppsico_mobile/presentation/widgets/common/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/drawer/custom_drawer.dart';
import 'package:helppsico_mobile/presentation/widgets/notifications/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsCubit _notificationsCubit;

  @override
  void initState() {
    super.initState();
    _notificationsCubit = GetIt.instance<NotificationsCubit>();
    _notificationsCubit.loadNotifications();
  }

  @override
  void dispose() {
    _notificationsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationsCubit,
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: const CustomAppBar(
        
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationsLoaded) {
              return _buildNotificationsList(state.notifications);
            } else if (state is NotificationsError) {
              return Center(child: Text('Erro: ${state.message}'));
            } else {
              return const Center(child: Text('Nenhuma notificação encontrada'));
            }
          },
        ),
        floatingActionButton: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
              return FloatingActionButton(
                onPressed: () {
                  _notificationsCubit.clearNotifications();
                },
                backgroundColor: const Color(0xFF1042CB),
                child: const Icon(Icons.delete_sweep, color: Colors.white),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma notificação encontrada',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: ValueKey<String>('notifications_${notifications.length}_${DateTime.now().millisecondsSinceEpoch}'),
      itemCount: notifications.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        if (index >= notifications.length) return null;

        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.id.toString()),
          direction: DismissDirection.endToStart,
         
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmar'),
                  content: const Text('Deseja remover esta notificação?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Remover'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) async {
            await _notificationsCubit.removeNotification(notification.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificação removida')),
              );
            }
          },
          child: NotificationCard(notification: notification),
        );
      },
    );
  }
}