
import 'package:flutter/material.dart';

enum NotificationType {
  appointment,
  reminder,
}

class NotificationCard extends StatelessWidget {
  final NotificationType type;
  final String date;
  final String title;
  final String description;
  final String actionText;
  final VoidCallback onActionPressed;
  
  const NotificationCard({
    Key? key,
    required this.type,
    required this.date,
    required this.title,
    required this.description,
    required this.actionText,
    required this.onActionPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTypeTag(),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeTag() {
    Color backgroundColor;
    String text;
    
    switch (type) {
      case NotificationType.appointment:
        backgroundColor = const Color(0xFF3B82F6); 
        text = 'Consulta';
        break;
      case NotificationType.reminder:
        backgroundColor = const Color(0xFFF59E0B); 
        text = 'Lembrete';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onActionPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFE6F0FF), 
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          actionText,
          style: const TextStyle(
            color: Color(0xFF3B82F6), 
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}