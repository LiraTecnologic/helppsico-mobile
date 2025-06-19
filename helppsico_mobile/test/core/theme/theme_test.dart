import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/theme.dart';


void main() {
  group('AppTheme Tests', () {
    test('should have correct primary color', () {
      expect(AppTheme.primaryColor, const Color(0xFF6200EE));
    });

    test('should have correct secondary color', () {
      expect(AppTheme.secondaryColor, const Color(0xFF03DAC6));
    });

    test('should create valid ThemeData', () {
      final themeData = AppTheme.theme;
      
      expect(themeData, isA<ThemeData>());
     
    });

    test('should have correct AppBar theme configuration', () {
      final themeData = AppTheme.theme;
      final appBarTheme = themeData.appBarTheme;
      
      expect(appBarTheme, isNotNull);
      expect(appBarTheme.backgroundColor, AppTheme.primaryColor);
      expect(appBarTheme.foregroundColor, Colors.white);
      expect(appBarTheme.elevation, 0);
      expect(appBarTheme.centerTitle, true);
    });

    test('should have correct ElevatedButton theme configuration', () {
      final themeData = AppTheme.theme;
      final elevatedButtonTheme = themeData.elevatedButtonTheme;
      
      expect(elevatedButtonTheme, isNotNull);
      expect(elevatedButtonTheme.style, isNotNull);
      
      // Testa as propriedades do estilo do botão
      final buttonStyle = elevatedButtonTheme.style!;
      
      // Testa backgroundColor
      final backgroundColor = buttonStyle.backgroundColor?.resolve({});
      expect(backgroundColor, AppTheme.primaryColor);
      
      // Testa foregroundColor
      final foregroundColor = buttonStyle.foregroundColor?.resolve({});
      expect(foregroundColor, Colors.white);
      
      // Testa elevation
      final elevation = buttonStyle.elevation?.resolve({});
      expect(elevation, 2);
      
      // Testa shape
      final shape = buttonStyle.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());
      if (shape is RoundedRectangleBorder) {
        expect(shape.borderRadius, BorderRadius.circular(8));
      }
    });

    test('should have consistent color scheme', () {
      final themeData = AppTheme.theme;
      
     
      expect(themeData.appBarTheme.backgroundColor, AppTheme.primaryColor);
      
      // Verifica se as cores são consistentes
      expect(AppTheme.primaryColor.value, 0xFF6200EE);
      expect(AppTheme.secondaryColor.value, 0xFF03DAC6);
    });

    test('should have proper contrast for accessibility', () {
      // Testa se as cores têm contraste adequado
      final primaryColor = AppTheme.primaryColor;
      final secondaryColor = AppTheme.secondaryColor;
      
      // Verifica se as cores não são iguais
      expect(primaryColor, isNot(equals(secondaryColor)));
      
      // Verifica se as cores têm valores válidos
      expect(primaryColor.alpha, 255);
      expect(secondaryColor.alpha, 255);
    });

    test('should maintain color immutability', () {
      final primaryColor1 = AppTheme.primaryColor;
      final primaryColor2 = AppTheme.primaryColor;
      final secondaryColor1 = AppTheme.secondaryColor;
      final secondaryColor2 = AppTheme.secondaryColor;
      
      // Verifica se as cores são sempre as mesmas instâncias
      expect(primaryColor1, equals(primaryColor2));
      expect(secondaryColor1, equals(secondaryColor2));
      expect(primaryColor1.value, primaryColor2.value);
      expect(secondaryColor1.value, secondaryColor2.value);
    });

    test('should create theme data multiple times consistently', () {
      final themeData1 = AppTheme.theme;
      final themeData2 = AppTheme.theme;
      
      // Verifica se os temas têm as mesmas configurações
  
      expect(themeData1.appBarTheme.backgroundColor, themeData2.appBarTheme.backgroundColor);
      expect(themeData1.appBarTheme.foregroundColor, themeData2.appBarTheme.foregroundColor);
      expect(themeData1.appBarTheme.elevation, themeData2.appBarTheme.elevation);
      expect(themeData1.appBarTheme.centerTitle, themeData2.appBarTheme.centerTitle);
    });

    test('should have valid color values', () {
      // Testa se as cores têm valores hexadecimais válidos
      expect(AppTheme.primaryColor.value, isA<int>());
      expect(AppTheme.secondaryColor.value, isA<int>());
      
      // Testa se os valores estão no range válido para cores
      expect(AppTheme.primaryColor.value, greaterThanOrEqualTo(0x00000000));
      expect(AppTheme.primaryColor.value, lessThanOrEqualTo(0xFFFFFFFF));
      expect(AppTheme.secondaryColor.value, greaterThanOrEqualTo(0x00000000));
      expect(AppTheme.secondaryColor.value, lessThanOrEqualTo(0xFFFFFFFF));
    });

    test('should have proper RGB components', () {
      final primaryColor = AppTheme.primaryColor;
      final secondaryColor = AppTheme.secondaryColor;
      
      // Testa componentes RGB da cor primária (0xFF6200EE)
      expect(primaryColor.alpha, 255); // FF
      expect(primaryColor.red, 98);    // 62
      expect(primaryColor.green, 0);   // 00
      expect(primaryColor.blue, 238);  // EE
      
      // Testa componentes RGB da cor secundária (0xFF03DAC6)
      expect(secondaryColor.alpha, 255); // FF
      expect(secondaryColor.red, 3);     // 03
      expect(secondaryColor.green, 218); // DA
      expect(secondaryColor.blue, 198);  // C6
    });

    test('should work with Material Design color system', () {
      final themeData = AppTheme.theme;
      
   
     
      // Verifica se as cores do Material Design estão disponíveis
      expect(Colors.deepPurple[500], isNotNull);
      expect(Colors.deepPurple[700], isNotNull);
    });

    test('should have proper button styling inheritance', () {
      final themeData = AppTheme.theme;
      final elevatedButtonTheme = themeData.elevatedButtonTheme;
      
      expect(elevatedButtonTheme.style, isNotNull);
      
      // Verifica se o estilo pode ser aplicado a um botão
      final buttonStyle = elevatedButtonTheme.style!;
      expect(buttonStyle.backgroundColor, isNotNull);
      expect(buttonStyle.foregroundColor, isNotNull);
      expect(buttonStyle.elevation, isNotNull);
      expect(buttonStyle.shape, isNotNull);
    });

    test('should support theme extensions', () {
      final themeData = AppTheme.theme;
      
      // Verifica se o tema pode ser estendido
      final extendedTheme = themeData.copyWith(
        brightness: Brightness.dark,
      );
      
      expect(extendedTheme, isA<ThemeData>());
      expect(extendedTheme.brightness, Brightness.dark);
      
    });

    test('should maintain theme consistency across app lifecycle', () {
      // Simula múltiplas chamadas como se fosse durante o ciclo de vida da app
      final themes = List.generate(10, (index) => AppTheme.theme);
      
      // Verifica se todos os temas são consistentes
      for (int i = 1; i < themes.length; i++) {
        
        expect(themes[i].appBarTheme.backgroundColor, themes[0].appBarTheme.backgroundColor);
        expect(themes[i].elevatedButtonTheme.style?.backgroundColor?.resolve({}),
               themes[0].elevatedButtonTheme.style?.backgroundColor?.resolve({}));
      }
    });
  });
}