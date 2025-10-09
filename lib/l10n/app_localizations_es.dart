// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get autoLabel => 'Automático';

  @override
  String get pausedLabel => 'Pausado';

  @override
  String nextAutoDecrementIn(int s) {
    return 'Próxima disminución automática en: ${s}s';
  }

  @override
  String get autoDecrementPaused => 'Disminución automática en pausa';

  @override
  String get lastChangedLabel => 'Último cambio:';

  @override
  String get appTitle => 'Demostración de Flutter';

  @override
  String get homeTitle => 'Página principal de la demostración';

  @override
  String get pushCountLabel => 'Has pulsado el botón tantas veces:';

  @override
  String get incrementTooltip => 'Incrementar';

  @override
  String get decrementTooltip => 'Disminuir';

  @override
  String get loadErrorMessage => 'No se pudo cargar el contador guardado';

  @override
  String get startAutoHint => 'Si el contador es 0, toca + para iniciar auto';

  @override
  String get cannotGoBelowZero => 'El contador no puede ser inferior a 0';

  @override
  String get openExampleTooltip => 'Abrir página de ejemplo';

  @override
  String get examplePageTitle => 'Página de ejemplo';

  @override
  String get examplePageDescription =>
      'Esta página demuestra el enrutamiento con GoRouter.';

  @override
  String get exampleBackButtonLabel => 'Volver al contador';

  @override
  String get exampleNativeInfoButton => 'Obtener info nativa';

  @override
  String get exampleNativeInfoTitle => 'Información de la plataforma';

  @override
  String get exampleNativeInfoError =>
      'No se pudieron obtener los datos nativos de la plataforma.';

  @override
  String get exampleRunIsolatesButton => 'Ejecutar ejemplos con aislados';

  @override
  String get exampleIsolateParallelPending => 'Ejecutando tareas paralelas...';

  @override
  String exampleIsolateFibonacciLabel(int input, int value) {
    return 'Fibonacci($input) = $value';
  }

  @override
  String exampleIsolateParallelComplete(String values, int milliseconds) {
    return 'Valores duplicados en paralelo: $values (terminado en $milliseconds ms)';
  }

  @override
  String get settingsBiometricPrompt =>
      'Autentícate para abrir la configuración';

  @override
  String get settingsBiometricFailed => 'No se pudo verificar tu identidad.';

  @override
  String get openChartsTooltip => 'Abrir gráficos';

  @override
  String get openGraphqlTooltip => 'Explorar demo GraphQL';

  @override
  String get openSettingsTooltip => 'Abrir configuración';

  @override
  String get settingsPageTitle => 'Configuración';

  @override
  String get accountSectionTitle => 'Cuenta';

  @override
  String accountSignedInAs(String name) {
    return 'Has iniciado sesión como $name';
  }

  @override
  String get accountSignedOutLabel => 'No has iniciado sesión.';

  @override
  String get accountSignInButton => 'Iniciar sesión';

  @override
  String get accountManageButton => 'Administrar cuenta';

  @override
  String get accountGuestLabel => 'Cuenta de invitado en uso';

  @override
  String get accountGuestDescription =>
      'Has iniciado sesión de forma anónima. Crea una cuenta para sincronizar tus datos entre dispositivos.';

  @override
  String get accountUpgradeButton => 'Crear o vincular cuenta';

  @override
  String get themeSectionTitle => 'Apariencia';

  @override
  String get themeModeSystem => 'Predeterminado del sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get languageSectionTitle => 'Idioma';

  @override
  String get languageSystemDefault => 'Usar idioma del dispositivo';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageTurkish => 'Turco';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get openChatTooltip => 'Chatear con IA';

  @override
  String get chatPageTitle => 'Chat con IA';

  @override
  String get chatInputHint => 'Pregunta lo que quieras al asistente...';

  @override
  String get chatSendButton => 'Enviar mensaje';

  @override
  String get chatEmptyState => 'Comienza la conversación enviando un mensaje.';

  @override
  String get chatModelLabel => 'Modelo';

  @override
  String get chatModelGptOss20b => 'GPT-OSS-20B';

  @override
  String get chatModelGptOss120b => 'GPT-OSS-120B';

  @override
  String get chatHistoryShowTooltip => 'Mostrar historial';

  @override
  String get chatHistoryHideTooltip => 'Ocultar historial';

  @override
  String get chatHistoryPanelTitle => 'Historial de conversaciones';

  @override
  String get chatHistoryStartNew => 'Iniciar nueva conversación';

  @override
  String get chatHistoryClearAll => 'Eliminar historial';

  @override
  String get chatHistoryDeleteConversation => 'Eliminar conversación';

  @override
  String get chatHistoryClearAllWarning =>
      'Esto eliminará permanentemente todas las conversaciones guardadas.';

  @override
  String get profilePageTitle => 'Perfil';

  @override
  String get anonymousSignInButton => 'Continuar como invitado';

  @override
  String get anonymousSignInDescription =>
      'Puedes probar la app sin crear una cuenta. Más tarde podrás mejorar desde Configuración.';

  @override
  String get anonymousSignInFailed =>
      'No se pudo iniciar la sesión de invitado. Inténtalo de nuevo.';

  @override
  String get anonymousUpgradeHint =>
      'Actualmente usas una sesión de invitado. Inicia sesión para conservar tus datos para el futuro.';

  @override
  String get authErrorInvalidEmail => 'La dirección de correo parece inválida.';

  @override
  String get authErrorUserDisabled =>
      'Esta cuenta está deshabilitada. Ponte en contacto con el soporte.';

  @override
  String get authErrorUserNotFound =>
      'No encontramos una cuenta con esos datos.';

  @override
  String get authErrorWrongPassword =>
      'La contraseña es incorrecta. Verifícala e inténtalo de nuevo.';

  @override
  String get authErrorEmailInUse =>
      'Ese correo ya está vinculado a otra cuenta.';

  @override
  String get authErrorOperationNotAllowed =>
      'Este método de inicio de sesión está deshabilitado. Prueba otra opción.';

  @override
  String get authErrorWeakPassword =>
      'Elige una contraseña más segura antes de continuar.';

  @override
  String get authErrorRequiresRecentLogin =>
      'Vuelve a iniciar sesión para completar esta acción.';

  @override
  String get authErrorCredentialInUse =>
      'Esas credenciales ya están asociadas a otra cuenta.';

  @override
  String get authErrorInvalidCredential =>
      'Las credenciales proporcionadas son inválidas o han expirado.';

  @override
  String get authErrorGeneric =>
      'No pudimos completar la solicitud. Inténtalo de nuevo.';

  @override
  String chatHistoryDeleteConversationWarning(String title) {
    return '¿Eliminar \"$title\"?';
  }

  @override
  String get cancelButtonLabel => 'Cancelar';

  @override
  String get deleteButtonLabel => 'Eliminar';

  @override
  String get chatHistoryEmpty => 'Todavía no hay conversaciones guardadas.';

  @override
  String chatHistoryConversationTitle(int index) {
    return 'Conversación $index';
  }

  @override
  String chatHistoryUpdatedAt(String timestamp) {
    return 'Actualizado $timestamp';
  }

  @override
  String get chartPageTitle => 'Precio de Bitcoin (USD)';

  @override
  String get chartPageDescription =>
      'Precio de cierre de los últimos 7 días (fuente: CoinGecko)';

  @override
  String get chartPageError => 'No se pudieron cargar los datos del gráfico.';

  @override
  String get chartPageEmpty => 'Aún no hay datos del gráfico.';

  @override
  String get chartZoomToggleLabel => 'Activar zoom con gestos';

  @override
  String get graphqlSampleTitle => 'Países GraphQL';

  @override
  String get graphqlSampleFilterLabel => 'Filtrar por continente';

  @override
  String get graphqlSampleAllContinents => 'Todos los continentes';

  @override
  String get graphqlSampleErrorTitle => 'Algo salió mal';

  @override
  String get graphqlSampleGenericError =>
      'No pudimos cargar los países en este momento.';

  @override
  String get graphqlSampleRetryButton => 'Intentar de nuevo';

  @override
  String get graphqlSampleEmpty =>
      'Ningún país coincide con los filtros seleccionados.';

  @override
  String get graphqlSampleCapitalLabel => 'Capital';

  @override
  String get graphqlSampleCurrencyLabel => 'Moneda';

  @override
  String get graphqlSampleNetworkError =>
      'Error de red. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get graphqlSampleInvalidRequestError =>
      'La solicitud fue rechazada. Prueba con otro filtro.';

  @override
  String get graphqlSampleServerError =>
      'El servicio no está disponible. Vuelve a intentarlo más tarde.';

  @override
  String get graphqlSampleDataError =>
      'Se recibió una respuesta inesperada. Intenta de nuevo.';

  @override
  String get exampleWebsocketButton => 'Abrir demostración de WebSocket';

  @override
  String exampleNativeBatteryLabel(int percent) {
    return 'Nivel de batería: $percent% ';
  }

  @override
  String get websocketDemoTitle => 'Demostración WebSocket';

  @override
  String get websocketDemoWebUnsupported =>
      'La demo de WebSocket aún no está disponible en compilaciones web.';

  @override
  String get websocketReconnectTooltip => 'Reconectar';

  @override
  String get websocketEmptyState =>
      'Aún no hay mensajes. Envía un mensaje para comenzar.';

  @override
  String get websocketMessageHint => 'Escribe un mensaje';

  @override
  String get websocketSendButton => 'Enviar';

  @override
  String websocketStatusConnected(String endpoint) {
    return 'Conectado a $endpoint';
  }

  @override
  String websocketStatusConnecting(String endpoint) {
    return 'Conectando a $endpoint...';
  }

  @override
  String websocketErrorLabel(String error) {
    return 'Error de WebSocket: $error';
  }
}
