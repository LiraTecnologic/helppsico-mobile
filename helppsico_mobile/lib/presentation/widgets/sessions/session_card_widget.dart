// lib/widgets/session_card_widget.dart
import 'package:flutter/material.dart';

enum SessionStatus {
  pending,
  scheduled,
  completed,
  canceled
}

class SessionCardWidget extends StatelessWidget {
  final String date;
  final String doctorName;
  final String sessionType;
  final String timeRange;
  final SessionStatus status;
  final String? paymentInfo;
  final Function()? onReschedule;
  final Function()? onCancel;

  const SessionCardWidget({
    super.key,
    required this.date,
    required this.doctorName,
    required this.sessionType,
    required this.timeRange,
    required this.status,
    this.paymentInfo,
    this.onReschedule,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),
            
            // Doctor Info Row
            Row(
              children: [
                // Profile Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sessionType,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeRange,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            
            if (paymentInfo != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.payment,
                    size: 16,
                    color: Color(0xFF666666),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    paymentInfo!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            
            // Action Buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Reschedule Button
                TextButton(
                  onPressed: onReschedule,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1042CB),
                  ),
                  child: const Text('Reagendar'),
                ),
                const SizedBox(width: 8),
                
                // Cancel Button
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    String text;

    switch (status) {
      case SessionStatus.pending:
        backgroundColor = const Color(0xFFFFAA00);
        text = 'A pagar';
        break;
      case SessionStatus.scheduled:
        backgroundColor = const Color(0xFF1E88E5);
        text = 'Agendada';
        break;
      case SessionStatus.completed:
        backgroundColor = const Color(0xFF43A047);
        text = 'Concluída';
        break;
      case SessionStatus.canceled:
        backgroundColor = const Color(0xFFE53935);
        text = 'Cancelada';
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
}