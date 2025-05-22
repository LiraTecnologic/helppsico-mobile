import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/session_notification_cubit.dart';

class SessionNotificationSwitch extends StatefulWidget {
  final SessionModel session;
  
  const SessionNotificationSwitch({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<SessionNotificationSwitch> createState() => _SessionNotificationSwitchState();
}

class _SessionNotificationSwitchState extends State<SessionNotificationSwitch> {
  bool _isEnabled = true;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }
  
  Future<void> _loadNotificationPreference() async {
    final cubit = context.read<SessionNotificationCubit>();
    final enabled = await cubit.isSessionNotificationEnabled(widget.session.id);
    
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.notifications_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: 20,
                child: Switch(
                  value: _isEnabled,
                  onChanged: widget.session.finalizada ? null : _toggleNotification,
                  activeColor: Theme.of(context).primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          );
  }
  
  void _toggleNotification(bool value) async {
    setState(() {
      _isEnabled = value;
      _isLoading = true;
    });
    
    final cubit = context.read<SessionNotificationCubit>();
    await cubit.toggleSessionNotification(widget.session.id, value);
    
    if (value) {
      await cubit.scheduleSessionNotifications(widget.session);
    } else {
      await cubit.cancelSessionNotifications(widget.session.id);
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}