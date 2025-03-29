// lib/widgets/session_tab_bar.dart
import 'package:flutter/material.dart';

class SessionTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const SessionTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTab('Próximas', 0),
          _buildTab('Concluídas', 1),
          _buildTab('Todas', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final bool isSelected = selectedIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected 
                  ? const Color(0xFF1042CB) 
                  : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected 
                  ? const Color(0xFF1042CB) 
                  : Colors.grey,
                fontWeight: isSelected 
                  ? FontWeight.bold 
                  : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}