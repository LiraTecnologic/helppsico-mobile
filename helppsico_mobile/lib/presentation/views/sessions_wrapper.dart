import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasources/sessions_datasource.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/sessions_cubit.dart';
import 'package:helppsico_mobile/presentation/views/sessions_screen.dart';

class SessionsWrapper extends StatelessWidget {
  const SessionsWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionsCubit(
        SessionRepository(
          SessionsDataSource(GenericHttp()),
        ),
      ),
      child: const SessionsPage(),
    );
  }
}