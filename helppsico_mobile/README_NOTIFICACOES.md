Criado por IA (apenas para referencia 
)
# Implementação de Notificações Locais no HelpPsico Mobile

Este documento descreve a implementação do sistema de notificações locais para as sessões de psicólogos no aplicativo HelpPsico Mobile, utilizando o padrão Cubit para gerenciamento de estado.

## Visão Geral

O sistema de notificações locais foi implementado para agendar três notificações para cada sessão não finalizada:
1. Um lembrete 5 minutos antes do início da sessão
2. Uma notificação no exato horário de início da sessão
3. Uma notificação no término da sessão (calculada com base no valor da sessão)

Cada notificação contém o nome do psicólogo no título e uma mensagem contextual no corpo, além de carregar o ID da sessão como payload.

## Arquivos Implementados

### 1. SessionNotificationCubit

O arquivo `lib/presentation/viewmodels/cubit/session_notification_cubit.dart` contém a lógica principal para gerenciar as notificações locais:

- **Inicialização**: Configura o plugin de notificações, solicita permissões e cria canais de notificação.
- **Agendamento**: Agenda as três notificações para cada sessão não finalizada.
- **Cancelamento**: Permite cancelar notificações de uma sessão específica ou todas as notificações.
- **Preferências**: Gerencia as preferências do usuário para ativar/desativar notificações por sessão.
- **Cálculo de Duração**: Calcula a duração da sessão com base no valor (R$).

### 2. SessionNotificationSwitch

O arquivo `lib/presentation/widgets/sessions/session_notification_switch.dart` implementa o widget de switch para ativar/desativar notificações para cada sessão:

- Exibe um switch discreto em cada card de sessão.
- Carrega e salva a preferência do usuário usando SharedPreferences.
- Agenda ou cancela notificações quando o switch é alterado.

### 3. Integração na SessionsWrapper

O arquivo `lib/presentation/views/sessions_wrapper.dart` foi modificado para:

- Inicializar o SessionNotificationCubit.
- Atualizar automaticamente as notificações quando novas sessões são carregadas da API.
- Fornecer o cubit para os widgets filhos através do BlocProvider.

### 4. Modificação no SessionCardWidget

O arquivo `lib/presentation/widgets/sessions/session_card_widget.dart` foi modificado para:

- Adicionar o switch de notificações em cada card de sessão.
- Manter o design original, adicionando apenas o switch de forma discreta.

## Configurações Nativas

### Android (AndroidManifest.xml)

Adicione as seguintes permissões e configurações ao seu AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<!-- Dentro da tag <application> -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>
```

### iOS (AppDelegate.swift)

Modifique o AppDelegate.swift para incluir o seguinte código:

```swift
import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    UNUserNotificationCenter.current().delegate = self
    
    
    let sessoesCategoryIdentifier = "sessoes"
    let sessaoCategory = UNNotificationCategory(
      identifier: sessoesCategoryIdentifier,
      actions: [],
      intentIdentifiers: [],
      options: [.customDismissAction]
    )
    
    UNUserNotificationCenter.current().setNotificationCategories([sessaoCategory])
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .badge, .sound])
  }
}
```

## Dependências Adicionadas

As seguintes dependências foram adicionadas ao projeto:

```yaml
flutter_local_notifications: ^latest_version
shared_preferences: ^latest_version
timezone: ^latest_version
```

## Funcionamento

1. Quando o aplicativo é iniciado, o sistema de notificações é inicializado e solicita permissões.
2. Quando a lista de sessões é carregada da API, todas as notificações antigas são canceladas e novas são agendadas para as sessões não finalizadas.
3. O usuário pode ativar/desativar notificações para cada sessão individualmente usando o switch no card da sessão.
4. As preferências do usuário são salvas usando SharedPreferences e persistem entre as execuções do aplicativo.
5. As notificações são exibidas mesmo quando o aplicativo está fechado, graças às configurações nativas.

## Cálculo da Duração da Sessão

A duração da sessão é calculada com base no valor da sessão, seguindo a lógica:
- Cada R$ 3,00 equivale a 1 minuto de sessão
- Duração mínima de 50 minutos (valor padrão)

Esta lógica pode ser ajustada conforme necessário no método `_calculateSessionDuration` do SessionNotificationCubit.