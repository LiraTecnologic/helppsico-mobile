import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/presentation/views/documents_screen.dart';
import 'package:helppsico_mobile/presentation/views/sessions_wrapper.dart';
import '../../core/theme.dart';
import '../widgets/common/document_card.dart';
import '../../domain/entities/document_model.dart';
import '../widgets/drawer/custom_drawer.dart';
import 'package:helppsico_mobile/presentation/widgets/common/custom_app_bar.dart';
import '../viewmodels/cubit/dashboard_cubit.dart';
import '../viewmodels/state/dashboard_state.dart';
import '../widgets/dashboard/dashboard_session_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DashboardCubit();
    _cubit.loadData();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.ATESTADO:
        return Icons.medical_services;
      case DocumentType.DECLARACAO:
        return Icons.description;
      case DocumentType.RELATORIO_PSICOLOGICO:
        return Icons.psychology;
      case DocumentType.RELATORIO_MULTIPROFISSIONAL:
        return Icons.group;
      case DocumentType.LAUDO_PSICOLOGICO:
        return Icons.assessment;
      case DocumentType.PARECER_PSICOLOGICO:
        return Icons.send;
      default:
        return Icons.insert_drive_file;
    }
  }



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardError) {
              return Center(child: Text(state.message));
            } else if (state is DashboardLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Próxima sessão",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (state.nextSession != null)
                        DashboardSessionCardWidget(
                          session: state.nextSession!,
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SessionsWrapper()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Ver mais"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Último documento",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (state.lastDocument != null)
                        DocumentCard(
                          title: state.lastDocument!.title,
                          date: "${state.lastDocument!.date.day}/${state.lastDocument!.date.month}",
                          icon: _getDocumentIcon(state.lastDocument!.type),
                          onTap: null,
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DocumentsScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Ver mais"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
