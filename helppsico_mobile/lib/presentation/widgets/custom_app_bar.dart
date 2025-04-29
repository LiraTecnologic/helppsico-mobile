import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      title: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/menu');
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            'assets/icons/logo.png',
            height: 65,
            width: 65,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}