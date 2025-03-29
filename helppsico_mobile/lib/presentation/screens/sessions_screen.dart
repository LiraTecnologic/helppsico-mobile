// lib/screens/sessoes_page.dart
import 'package:flutter/material.dart';
import 'package:helppsico_mobile/presentation/widgets/notifications/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/sessions/session_card_widget.dart';
import 'package:helppsico_mobile/presentation/widgets/sessions/session_tab_bar_widget.dart';


class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  int _selectedTabIndex = 0;

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
            
            // Sessions List
            Expanded(
              child: ListView(
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
    // Retorna a lista de sessões baseada na aba selecionada
    switch (_selectedTabIndex) {
      case 0: // Próximas
      
        return [
          // Sessão 1 (como mostrado na imagem)
          SessionCardWidget(
            date: 'Amanhã, 24 fev 2025',
            doctorName: 'Dra. Ana Martins',
            sessionType: 'Terapia Individual',
            timeRange: '14:00 - 15:00',
            status: SessionStatus.pending,
            onReschedule: () {},
            onCancel: () {},
          ),
          
          // Sessão 2 (como mostrado na imagem)
          SessionCardWidget(
            date: 'Quinta, 27 fev 2025',
            doctorName: 'Dr. Carlos Silva',
            sessionType: 'Avaliação Psicológica',
            timeRange: '10:30 - 12:00',
            status: SessionStatus.scheduled,
            paymentInfo: 'Pago via Cartão de Crédito',
            onReschedule: () {},
            onCancel: () {},
          ),
          
          // Sessões adicionais para permitir rolagem
          SessionCardWidget(
            date: 'Segunda, 3 mar 2025',
            doctorName: 'Dr. Roberto Almeida',
            sessionType: 'Terapia Cognitivo-Comportamental',
            timeRange: '09:00 - 10:00',
            status: SessionStatus.scheduled,
            paymentInfo: 'Pago via PIX',
            onReschedule: () {},
            onCancel: () {},
          ),
          
          SessionCardWidget(
            date: 'Quarta, 5 mar 2025',
            doctorName: 'Dra. Fernanda Costa',
            sessionType: 'Terapia Individual',
            timeRange: '16:30 - 17:30',
            status: SessionStatus.pending,
            onReschedule: () {},
            onCancel: () {},
          ),
          
          SessionCardWidget(
            date: 'Sexta, 7 mar 2025',
            doctorName: 'Dr. Paulo Mendes',
            sessionType: 'Aconselhamento Familiar',
            timeRange: '14:00 - 15:30',
            status: SessionStatus.scheduled,
            paymentInfo: 'Pago via Convênio',
            onReschedule: () {},
            onCancel: () {},
          ),
          
          SessionCardWidget(
            date: 'Terça, 11 mar 2025',
            doctorName: 'Dra. Juliana Santos',
            sessionType: 'Terapia Infantil',
            timeRange: '13:00 - 14:00',
            status: SessionStatus.scheduled,
            paymentInfo: 'Pago via Boleto',
            onReschedule: () {},
            onCancel: () {},
          ),
        ];
        
      case 1: // Concluídas
        return [
          SessionCardWidget(
            date: 'Segunda, 17 fev 2025',
            doctorName: 'Dra. Ana Martins',
            sessionType: 'Terapia Individual',
            timeRange: '14:00 - 15:00',
            status: SessionStatus.completed,
            paymentInfo: 'Pago via Cartão de Crédito',
            onReschedule: null,
            onCancel: null,
          ),
          
          SessionCardWidget(
            date: 'Quarta, 12 fev 2025',
            doctorName: 'Dr. Carlos Silva',
            sessionType: 'Avaliação Psicológica',
            timeRange: '10:30 - 12:00',
            status: SessionStatus.completed,
            paymentInfo: 'Pago via PIX',
            onReschedule: null,
            onCancel: null,
          ),
          
          SessionCardWidget(
            date: 'Sexta, 7 fev 2025',
            doctorName: 'Dra. Fernanda Costa',
            sessionType: 'Terapia Individual',
            timeRange: '16:30 - 17:30',
            status: SessionStatus.completed,
            paymentInfo: 'Pago via Convênio',
            onReschedule: null,
            onCancel: null,
          )
        ];

      default:
        return [];
    }
  }
}
