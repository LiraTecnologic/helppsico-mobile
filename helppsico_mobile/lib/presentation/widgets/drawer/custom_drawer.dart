import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:helppsico_mobile/presentation/views/dashboard_screen.dart';
import 'package:helppsico_mobile/presentation/views/documents_screen.dart';
import 'package:helppsico_mobile/presentation/views/login_screen.dart';
import 'package:helppsico_mobile/presentation/views/notifications_screen.dart';

import 'package:helppsico_mobile/presentation/views/review_screen.dart';
import 'package:helppsico_mobile/presentation/views/sessions_wrapper.dart';
import '../../../core/theme.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/auth_cubit.dart';
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Drawer(
        child: Container(
          color: AppTheme.primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Menu",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 25),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home,
                    title: "Meu Painel",
                    onTap: () {
                      Navigator.pop(context);
                      if (ModalRoute.of(context)?.settings.name != '/dashboard') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.calendar_today,
                    title: "Sessões",
                    onTap: () {
                      Navigator.pop(context);
                      if (ModalRoute.of(context)?.settings.name != '/sessions') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SessionsWrapper()),
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.description,
                    title: "Documentos",
                    onTap: () {
                      Navigator.pop(context);
                      if (ModalRoute.of(context)?.settings.name != '/documents') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DocumentsScreen()),
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.notifications,
                    title: "Notificações",
                    onTap: () {
                      Navigator.pop(context);
                      if (ModalRoute.of(context)?.settings.name != '/notifications') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.star,
                    title: "Avaliar psicólogo",
                    onTap: () {
                      Navigator.pop(context);
                      if (ModalRoute.of(context)?.settings.name != '/avaliar-psicologo') {
                        Navigator.of(context).pushReplacementNamed('/avaliar-psicologo');
                      }
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildDrawerItem(
                  context: context,
                  icon: Icons.logout,
                  title: "Sair",
                  onTap: () {
                    final authCubit = context.read<AuthCubit>();
                    authCubit.logout();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}