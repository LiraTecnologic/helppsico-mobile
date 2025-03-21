import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/text_divider.dart';
import '../widgets/text_link.dart';

export 'login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // widgets, com um padding superior para liberar espaço para o logo
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 170),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                      'Tenha a melhor interaçãoo com seu psicólogo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    const CustomTextField(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const CustomTextField(
                      hintText: 'Senha',
                      obscureText: true,
                    ),
                    const SizedBox(height: 16.0),
                    CustomButton(
                      text: 'Logar-se',
                      onPressed: () {
                        // lógica de login
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const TextDivider(text: 'ou'),
                    const SizedBox(height: 16.0),
                    Center(
                      child: TextLink(
                        text: 'Esqueceu a senha?',
                        onTap: () {
                          print('Forgot password');
                        },
                      ),
                    ),
                    const SizedBox(height: 48.0),
                    Row(
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
                          onTap: () {
                            // lógica de cadastro
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Logo posicionada de forma absoluta na parte superior
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
  }
}
