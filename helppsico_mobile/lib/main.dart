import 'package:flutter/material.dart';
import 'core/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpPsico',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
    );
  }
} 