

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/session_model.dart';
import 'session_notification_switch.dart';

enum SessionStatus {
  open, 
  completed, 
}





class SessionCardWidget extends StatelessWidget {


  final SessionModel session;

  const SessionCardWidget({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd/MM/yyyy').format(session.data);

    final String timeRange = DateFormat('HH:mm').format(session.data);

    final SessionStatus status =
        session.finalizada ? SessionStatus.completed : SessionStatus.open;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/images/profile.jpeg'),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.psicologoName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatEndereco(session.endereco),
                        style: TextStyle(color: const Color.fromARGB(255, 32, 32, 32), fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeRange,
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'R\$ ${session.valor}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                // Switch para ativar/desativar notificações
                if (!session.finalizada)
                  SessionNotificationSwitch(session: session),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SessionStatus status) {
    Color backgroundColor;
    String text;

    switch (status) {
      case SessionStatus.open:
        backgroundColor = const Color(0xFF43A047);
        text = 'Em Aberto';
        break;
      case SessionStatus.completed:
        backgroundColor = const Color(0xFF666666);
        text = 'Finalizada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatEndereco(String endereco) {
 
  if (!endereco.startsWith('{') || !endereco.endsWith('}')) {
    return endereco;
  }

 
  final content = endereco.substring(1, endereco.length - 1);

  
  final parts = content.split(',');


  final Map<String, String> map = {};
  for (var part in parts) {
    final idx = part.indexOf(':');
    if (idx == -1) continue;
    final key = part.substring(0, idx).trim();
    final value = part.substring(idx + 1).trim();
    map[key] = value;
  }


  final rua    = map['rua']    ?? '';
  final numero = map['numero'] ?? '';
  final cidade = map['cidade'] ?? '';
  final estado = map['estado'] ?? '';
  final cep    = map['cep']    ?? '';

 
  return '$rua, $numero – $cidade, $estado – CEP $cep';
}
}
