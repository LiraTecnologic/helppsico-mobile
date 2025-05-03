import 'package:flutter/material.dart';
import 'package:helppsico_mobile/presentation/widgets/common/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/sessions/session_card_widget.dart';
import 'package:helppsico_mobile/presentation/widgets/sessions/session_tab_bar_widget.dart';
import 'package:helppsico_mobile/data/mock_sessions.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';
import 'package:helppsico_mobile/presentation/widgets/drawer/custom_drawer.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  int _selectedTabIndex = 0;
  final MockSessionRepository _sessionRepository = MockSessionRepository();
  List<SessionModel> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessions = await _sessionRepository.getSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar sessões: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            SessionTabBar(
              selectedIndex: _selectedTabIndex,
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            
            // Sessions List
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _buildSessionsList(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSessionsList() {
    final sessions = _selectedTabIndex == 0
      ? _sessions.where((session) => 
          session.status == SessionStatus.pending || 
          session.status == SessionStatus.scheduled
        ).toList()
      : _sessions.where((session) => 
          session.status == SessionStatus.completed
        ).toList();

    return sessions.map((session) => SessionCardWidget(
      date: session.date,
      doctorName: session.doctorName,
      sessionType: session.sessionType,
      timeRange: session.timeRange,
      status: session.status,
      paymentInfo: session.paymentInfo,
      onReschedule: session.status == SessionStatus.completed ? null : () {},
      onCancel: session.status == SessionStatus.completed ? null : () {},
    )).toList();
  }
}
