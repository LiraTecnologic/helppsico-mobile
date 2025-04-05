// lib/screens/sessoes_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/data/models/session_model.dart';
import 'package:helppsico_mobile/presentation/widgets/notifications/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/sessions/session_card_widget.dart';
import 'package:helppsico_mobile/presentation/widgets/sessions/session_tab_bar_widget.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/sessions_cubit.dart';
import 'package:helppsico_mobile/presentation/viewmodels/bloc/sessions_state.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({Key? key}) : super(key: key);

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch sessions when page loads
    context.read<SessionsCubit>().fetchSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(),
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
            
          
            Expanded(
              child: BlocBuilder<SessionsCubit, SessionsState>(
                builder: (context, state) {
                  if (state is SessionsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is SessionsError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar sessões: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is SessionsLoaded) {
                    final sessions = state.sessions;
                    
                    if (sessions.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma sessão encontrada'),
                      );
                    }
                    
                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: _buildSessionsList(sessions),
                    );
                  } else {
                    return const Center(
                      child: Text('Carregue as sessões para visualizar'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSessionsList(List<SessionModel> allSessions) {
    
    List<SessionModel> filteredSessions;
    
    switch (_selectedTabIndex) {
      case 0: // Em Aberto
        filteredSessions = allSessions
            .where((session) => !session.finalizada)
            .toList();
        
        filteredSessions.sort((a, b) => a.data.compareTo(b.data));
        break;
        
      case 1: // Finalizadas
        filteredSessions = allSessions
            .where((session) => session.finalizada)
            .toList();
       
        filteredSessions.sort((a, b) => b.data.compareTo(a.data));
        break;
        
      default:
        filteredSessions = [];
        break;
    }
    
    
    return filteredSessions.map((session) {
      return SessionCardWidget(
        session: session,
      );
    }).toList();
  }
}