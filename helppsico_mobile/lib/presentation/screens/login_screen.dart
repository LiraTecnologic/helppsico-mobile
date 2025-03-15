
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  
                  
                  CustomButton(
                    text: 'Logar-se',
                    onPressed: () {
                    
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
                        'N o tem uma conta? ',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                      ),
                      TextLink(
                        text: 'Cadastre-se',
                        onTap: () {
                        
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
