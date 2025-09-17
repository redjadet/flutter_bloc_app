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
  String get openChartsTooltip => 'Abrir gráficos';

  @override
  String get openSettingsTooltip => 'Abrir configuración';

  @override
  String get settingsPageTitle => 'Configuración';

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
}
