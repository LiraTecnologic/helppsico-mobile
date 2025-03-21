// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:helppsico_mobile/presentation/widgets/notifications/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/notifications/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Light gray background
      appBar: CustomAppBar(
        onMenuPressed: () {
          
        },
        onNotificationPressed: () {
         
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notificações',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView(
                  children: [
                    NotificationCard(
                      type: NotificationType.appointment,
                      date: '24 fev 2025',
                      title: 'Dr Ana Martins',
                      description: 'Sua consulta com a doutora Ana foi agendada para amanhã às 14:00, não esqueça de comparecer',
                      actionText: 'Ver Detalhes',
                      onActionPressed: () {
                        //funcionalidades futuras.
                      },
                    ),
                    NotificationCard(
                      type: NotificationType.reminder,
                      date: 'Ontem, 18:45',
                      title: 'Preencha o Questionário',
                      description: 'Por favor, preencha o questionário de acompanhamento antes da sua próxima consulta.',
                      actionText: 'Preencher Agora',
                      onActionPressed: () {
                        
                      },
                    ),
                    NotificationCard(
                      type: NotificationType.appointment,
                      date: '20 fev 2025',
                      title: 'Dr Carlos Silva',
                      description: 'Sua próxima consulta com o Dr. Carlos foi remarcada para o dia 28/02 às 15:30.',
                      actionText: 'Confirmar Mudança',
                      onActionPressed: () {
                       
                      },
                    ),
                    NotificationCard(
                      type: NotificationType.reminder,
                      date: '18 fev 2025',
                      title: 'Renovação de Receita',
                      description: 'Sua receita médica expira em 5 dias. Por favor, entre em contato com seu médico para renovação.',
                      actionText: 'Solicitar Renovação',
                      onActionPressed: () {
                       
                      },
                    ),
                    NotificationCard(
                      type: NotificationType.appointment,
                      date: '15 fev 2025',
                      title: 'Dr Juliana Mendes',
                      description: 'Consulta confirmada para o dia 03/03/2025 às 10:00 com a Dra. Juliana.',
                      actionText: 'Adicionar ao Calendário',
                      onActionPressed: () {
                        
                      },
                    ),
                    NotificationCard(
                      type: NotificationType.reminder,
                      date: '10 fev 2025',
                      title: 'Atualização do App',
                      description: 'Uma nova versão do aplicativo está disponível. Atualize para acessar novos recursos.',
                      actionText: 'Atualizar Agora',
                      onActionPressed: () {
                        
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}