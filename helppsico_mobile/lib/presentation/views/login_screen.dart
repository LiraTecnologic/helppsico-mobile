import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/auth_cubit.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/auth_state.dart';
import 'package:helppsico_mobile/presentation/views/dashboard_screen.dart';

import 'package:helppsico_mobile/presentation/widgets/common/custom_button.dart';
import 'package:helppsico_mobile/presentation/widgets/common/custom_text_field.dart';
import 'package:helppsico_mobile/presentation/widgets/common/text_divider.dart';
import 'package:helppsico_mobile/presentation/widgets/common/text_link.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthFailure(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bem-vindo, ${state.userName}!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          } else if (state is AuthFailure) {
            _handleAuthFailure(context, state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 170),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Iniciar sessão',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Tenha a melhor interação com seu psicólogo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 32.0),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$')
                                    .hasMatch(value)) {
                                  return 'Por favor, insira um email válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'Senha',
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira sua senha';
                                }
                                if (value.length < 6) {
                                  return 'A senha deve ter pelo menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            state is AuthLoading
                                ? const CircularProgressIndicator()
                                : CustomButton(
                                    text: 'Logar-se',
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        context.read<AuthCubit>().login(
                                              _emailController.text,
                                              _passwordController.text,
                                            );
                                      }
                                    },
                                  ),
                            const SizedBox(height: 16.0),
                            const TextDivider(text: 'ou'),
                            const SizedBox(height: 48.0),
                            Center(
                              child:   Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Não tem uma conta? ',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextLink(
                                  text: 'Cadastre-se',
                                  onTap: () {},
                                ),
                              ],
                            ),
                            ),
                            const SizedBox(height: 48.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/images/logoAzul.png',
                        height: 150,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }
}