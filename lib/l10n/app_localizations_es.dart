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
  String get saveErrorMessage => 'No se pudo guardar el contador';

  @override
  String get startAutoHint => 'Si el contador es 0, toca + para iniciar auto';

  @override
  String get cannotGoBelowZero => 'El contador no puede ser inferior a 0';

  @override
  String get openExampleTooltip => 'Abrir página de ejemplo';

  @override
  String get openCaseStudyDemoTooltip => 'Abrir demo de caso clínico dental';

  @override
  String get openCalculatorTooltip => 'Abrir calculadora de pagos';

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
  String get exampleNativeInfoDialogTitle => 'Detalles de la plataforma';

  @override
  String get exampleNativeInfoDialogPlatformLabel => 'Plataforma';

  @override
  String get exampleNativeInfoDialogVersionLabel => 'Versión';

  @override
  String get exampleNativeInfoDialogManufacturerLabel => 'Fabricante';

  @override
  String get exampleNativeInfoDialogModelLabel => 'Modelo';

  @override
  String get exampleNativeInfoDialogBatteryLabel => 'Nivel de batería';

  @override
  String get exampleDialogCloseButton => 'Cerrar';

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
  String get calculatorTitle => 'Calculadora de pagos';

  @override
  String get calculatorSummaryHeader => 'Resumen de pago';

  @override
  String get calculatorResultLabel => 'Resultado';

  @override
  String get calculatorSubtotalLabel => 'Subtotal';

  @override
  String calculatorTaxLabel(String rate) {
    return 'Impuesto ($rate)';
  }

  @override
  String calculatorTipLabel(String rate) {
    return 'Propina ($rate)';
  }

  @override
  String get calculatorTotalLabel => 'Monto a cobrar';

  @override
  String get calculatorTaxPresetsLabel => 'Impuestos rápidos';

  @override
  String get calculatorCustomTaxLabel => 'Impuesto personalizado';

  @override
  String get calculatorCustomTaxDialogTitle => 'Impuesto personalizado';

  @override
  String get calculatorCustomTaxFieldLabel => 'Porcentaje de impuesto';

  @override
  String get calculatorResetTax => 'Restablecer impuesto';

  @override
  String get calculatorTipRateLabel => 'Propinas rápidas';

  @override
  String get calculatorCustomTipLabel => 'Propina personalizada';

  @override
  String get calculatorResetTip => 'Borrar propina';

  @override
  String get calculatorCustomTipDialogTitle => 'Propina personalizada';

  @override
  String get calculatorCustomTipFieldLabel => 'Porcentaje de propina';

  @override
  String get calculatorCancel => 'Cancelar';

  @override
  String get calculatorApply => 'Aplicar';

  @override
  String get calculatorKeypadHeader => 'Teclado';

  @override
  String get calculatorClearLabel => 'Limpiar';

  @override
  String get calculatorBackspace => 'Retroceso';

  @override
  String get calculatorPercentCommand => 'Porcentaje';

  @override
  String get calculatorToggleSign => 'Cambiar signo';

  @override
  String get calculatorDecimalPointLabel => 'Punto decimal';

  @override
  String get calculatorErrorTitle => 'Error';

  @override
  String get calculatorErrorDivisionByZero => 'No se puede dividir entre cero';

  @override
  String get calculatorErrorInvalidResult =>
      'El resultado no es un número válido';

  @override
  String get calculatorErrorNonPositiveTotal =>
      'El total debe ser mayor que cero';

  @override
  String get calculatorEquals => 'Calcular total';

  @override
  String get calculatorPaymentTitle => 'Resumen de pago';

  @override
  String get calculatorNewCalculation => 'Nueva operación';

  @override
  String get settingsBiometricPrompt =>
      'Autentícate para abrir la configuración';

  @override
  String get settingsBiometricFailed => 'No se pudo verificar tu identidad.';

  @override
  String get settingsBiometricUnavailable =>
      'La autenticación biométrica no está disponible en la web. Se abrirá la configuración igualmente.';

  @override
  String get openChartsTooltip => 'Abrir gráficos';

  @override
  String get openGraphqlTooltip => 'Explorar demo GraphQL';

  @override
  String get openSettingsTooltip => 'Abrir configuración';

  @override
  String get settingsPageTitle => 'Configuración';

  @override
  String get settingsThrowTestException => 'Lanzar excepción de prueba';

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
  String get languageArabic => 'Árabe';

  @override
  String get appInfoSectionTitle => 'Información de la app';

  @override
  String get settingsRemoteConfigSectionTitle => 'Configuración remota';

  @override
  String get settingsRemoteConfigStatusIdle =>
      'Esperando la primera actualización';

  @override
  String get settingsRemoteConfigStatusLoading =>
      'Cargando los valores más recientes...';

  @override
  String get settingsRemoteConfigStatusLoaded => 'Últimos valores cargados';

  @override
  String get settingsRemoteConfigStatusError =>
      'No se pudo cargar la configuración remota';

  @override
  String get settingsRemoteConfigErrorLabel => 'Último error';

  @override
  String get remoteConfigAwesomeFeatureEnabled =>
      'La función Awesome está activada';

  @override
  String get settingsRemoteConfigFlagLabel => 'Indicador de la función Awesome';

  @override
  String get settingsRemoteConfigFlagEnabled => 'Activado';

  @override
  String get settingsRemoteConfigFlagDisabled => 'Desactivado';

  @override
  String get settingsRemoteConfigTestValueLabel => 'Valor de prueba';

  @override
  String get settingsRemoteConfigTestValueEmpty => 'Sin definir';

  @override
  String get settingsRemoteConfigRetryButton => 'Reintentar carga';

  @override
  String get settingsRemoteConfigClearCacheButton => 'Borrar caché de config';

  @override
  String get settingsSyncDiagnosticsTitle => 'Diagnósticos de sincronización';

  @override
  String get settingsSyncDiagnosticsEmpty =>
      'Aún no hay ejecuciones de sincronización.';

  @override
  String settingsSyncLastRunLabel(String timestamp) {
    return 'Última ejecución: $timestamp';
  }

  @override
  String settingsSyncOperationsLabel(int processed, int failed) {
    return 'Ops: $processed procesadas, $failed fallidas';
  }

  @override
  String settingsSyncPendingLabel(int count) {
    return 'Pendientes al inicio: $count';
  }

  @override
  String settingsSyncPrunedLabel(int count) {
    return 'Depurados: $count';
  }

  @override
  String settingsSyncDurationLabel(int ms) {
    return 'Duración: ${ms}ms';
  }

  @override
  String get settingsSyncHistoryTitle => 'Ejecuciones recientes de sync';

  @override
  String get settingsGraphqlCacheSectionTitle => 'Caché de GraphQL';

  @override
  String get settingsGraphqlCacheDescription =>
      'Borra los países/continentes en caché usados por la demo GraphQL. Los datos se renovarán en la siguiente carga.';

  @override
  String get settingsGraphqlCacheClearButton => 'Limpiar caché de GraphQL';

  @override
  String get settingsGraphqlCacheClearedMessage => 'Caché de GraphQL limpiada';

  @override
  String get settingsGraphqlCacheErrorMessage =>
      'No se pudo limpiar la caché de GraphQL';

  @override
  String get settingsProfileCacheSectionTitle => 'Caché de perfil';

  @override
  String get settingsProfileCacheDescription =>
      'Borra la instantánea de perfil guardada localmente que permite mostrar la pantalla de perfil sin conexión.';

  @override
  String get settingsProfileCacheClearButton => 'Borrar caché de perfil';

  @override
  String get settingsProfileCacheClearedMessage =>
      'Se borró el caché de perfil';

  @override
  String get settingsProfileCacheErrorMessage =>
      'No se pudo borrar el caché de perfil';

  @override
  String settingsDiagnosticsLastSyncedAt(
    String formattedDate,
    String formattedTime,
  ) {
    return 'Última sincronización: $formattedDate $formattedTime';
  }

  @override
  String settingsDiagnosticsCacheSizeKb(int kilobytes) {
    return 'Tamaño de caché: $kilobytes KB';
  }

  @override
  String settingsDiagnosticsDataSource(String name) {
    return 'Origen: $name';
  }

  @override
  String get networkRetryingSnackBarMessage => 'Reintentando…';

  @override
  String get appInfoVersionLabel => 'Versión';

  @override
  String get appInfoBuildNumberLabel => 'Número de compilación';

  @override
  String get appInfoLoadingLabel => 'Cargando información de la app...';

  @override
  String get appInfoLoadErrorLabel =>
      'No se pudo cargar la información de la app.';

  @override
  String get appInfoRetryButtonLabel => 'Reintentar';

  @override
  String get openChatTooltip => 'Chatear con IA';

  @override
  String get openGenuiDemoTooltip => 'Demo GenUI';

  @override
  String get openGoogleMapsTooltip => 'Abrir demo de Google Maps';

  @override
  String get openWhiteboardTooltip => 'Abrir Whiteboard';

  @override
  String get openMarkdownEditorTooltip => 'Abrir Editor de Markdown';

  @override
  String get openTodoTooltip => 'Abrir Lista de Tareas';

  @override
  String get openWalletconnectAuthTooltip => 'Conectar billetera';

  @override
  String get chatPageTitle => 'Chat con IA';

  @override
  String get chatTransportSupabase => 'Supabase';

  @override
  String get chatTransportDirect => 'Directo';

  @override
  String get chatTransportSupabaseSemanticsLabel =>
      'Supabase. Las respuestas usan el proxy de Supabase Edge; Hugging Face se ejecuta en el servidor.';

  @override
  String get chatTransportDirectSemanticsLabel =>
      'Directo. La aplicación llama a Hugging Face directamente.';

  @override
  String get chatTransportRenderOrchestration => 'Orquestación';

  @override
  String get chatTransportRenderOrchestrationSemanticsLabel =>
      'Orquestación. Las respuestas usan tu servicio de FastAPI Cloud, que enruta a Hugging Face.';

  @override
  String get chatFastApiCloudBadgeLabel => 'FastAPI Cloud';

  @override
  String get chatFastApiCloudBadgeSemanticsLabel =>
      'FastAPI Cloud. La orquestación se ejecuta en FastAPI Cloud.';

  @override
  String get chatModelAuto => 'Auto';

  @override
  String get chatRenderStrictMode =>
      'Demo de FastAPI Cloud en modo estricto; sin alternativa de respaldo.';

  @override
  String get chatAuthRefreshRequired =>
      'Vuelve a iniciar sesión para seguir usando la demo de chat en FastAPI Cloud.';

  @override
  String get chatSessionEnded =>
      'Tu sesión terminó. Inicia un chat nuevo tras iniciar sesión.';

  @override
  String get chatSwitchAccount =>
      'Cambia de cuenta para actualizar las credenciales de la demo de FastAPI Cloud.';

  @override
  String get chatTokenMissing =>
      'Falta el token de Hugging Face. Comprueba la conexión e inténtalo de nuevo.';

  @override
  String get chatOrchestrationTooltip =>
      'Enrutado en el servidor entre modelos cuando se elige Auto.';

  @override
  String get chatOfflineBadgeLabel => 'Sin conexión';

  @override
  String get chatOfflineBadgeSemanticsLabel =>
      'Sin conexión. Los mensajes se sincronizarán cuando vuelvas a estar en línea.';

  @override
  String get chatInputHint => 'Pregunta lo que quieras al asistente...';

  @override
  String get searchHint => 'Buscar...';

  @override
  String get retryButtonLabel => 'REINTENTAR';

  @override
  String get featureLoadError =>
      'No se pudo cargar esta función. Inténtalo de nuevo.';

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
  String get chatMessageStatusPending => 'Sincronización pendiente';

  @override
  String get chatMessageStatusSyncing => 'Sincronizando…';

  @override
  String get chatMessageStatusOffline =>
      'Sin conexión: se enviará al conectarse';

  @override
  String get registerTitle => 'Registrarse';

  @override
  String get registerFullNameLabel => 'Nombre completo';

  @override
  String get registerFullNameHint => 'María Pérez';

  @override
  String get registerEmailLabel => 'Correo electrónico';

  @override
  String get registerEmailHint => 'maria.perez@example.com';

  @override
  String get registerPhoneLabel => 'Número de teléfono';

  @override
  String get registerPhoneHint => '5551234567';

  @override
  String get registerCountryPickerTitle => 'Elige tu código de país';

  @override
  String get registerPasswordLabel => 'Contraseña';

  @override
  String get registerPasswordHint => 'Crear contraseña';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get registerConfirmPasswordHint => 'Vuelve a escribir la contraseña';

  @override
  String get registerSubmitButton => 'Siguiente';

  @override
  String get registerDialogTitle => 'Registro completado';

  @override
  String registerDialogMessage(String name) {
    return '¡Bienvenido a bordo, $name!';
  }

  @override
  String get registerDialogOk => 'Aceptar';

  @override
  String get registerFullNameEmptyError => 'Ingresa tu nombre completo';

  @override
  String get registerFullNameTooShortError =>
      'El nombre debe tener al menos 2 caracteres';

  @override
  String get registerEmailEmptyError => 'Ingresa tu correo electrónico';

  @override
  String get registerEmailInvalidError =>
      'Ingresa un correo electrónico válido';

  @override
  String get registerPasswordEmptyError => 'Ingresa tu contraseña';

  @override
  String get registerPasswordTooShortError =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get registerPasswordLettersAndNumbersError => 'Usa letras y números';

  @override
  String get registerPasswordWhitespaceError =>
      'La contraseña no puede contener espacios';

  @override
  String get registerTermsCheckboxPrefix => 'He leído y acepto los ';

  @override
  String get registerTermsCheckboxSuffix => '.';

  @override
  String get registerTermsLinkLabel => 'Términos y Condiciones';

  @override
  String get registerTermsError => 'Debes aceptar los términos para continuar';

  @override
  String get registerTermsDialogTitle => 'Términos y Condiciones';

  @override
  String get registerTermsDialogBody =>
      'Al crear una cuenta te comprometes a usar la aplicación de forma responsable, respetar a otros usuarios y cumplir con todas las leyes aplicables. Aceptas nuestra política de privacidad, reconoces que la disponibilidad del servicio puede cambiar y aceptas que tu cuenta puede suspenderse en caso de uso indebido o violaciones de estos términos.';

  @override
  String get registerTermsAcceptButton => 'Aceptar';

  @override
  String get registerTermsRejectButton => 'Cancelar';

  @override
  String get registerTermsPrompt =>
      'Revisa y acepta los términos antes de continuar.';

  @override
  String get registerTermsButtonLabel => 'Leer términos y condiciones';

  @override
  String get registerTermsSheetTitle => 'Términos y condiciones';

  @override
  String get registerTermsSheetBody =>
      'Esta aplicación de demostración debe usarse de forma responsable. Al registrarte aceptas proteger tus credenciales, cumplir con las leyes aplicables y entender que el contenido es meramente ilustrativo y puede cambiar sin previo aviso. Si no estás de acuerdo, interrumpe el proceso de registro.';

  @override
  String get registerTermsDialogAcknowledge => 'He leído los términos';

  @override
  String get registerTermsCheckboxLabel => 'Acepto los términos y condiciones';

  @override
  String get registerTermsCheckboxDisabledHint =>
      'Lee los términos antes de aceptarlos.';

  @override
  String get registerTermsNotAcceptedError =>
      'Debes aceptar los términos para continuar.';

  @override
  String get registerConfirmPasswordEmptyError => 'Confirma tu contraseña';

  @override
  String get registerConfirmPasswordMismatchError =>
      'Las contraseñas no coinciden';

  @override
  String get registerPhoneEmptyError => 'Ingresa tu número de teléfono';

  @override
  String get registerPhoneInvalidError => 'Introduce entre 6 y 15 dígitos';

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
  String get authErrorNetworkRequestFailed =>
      'Compruebe su conexión e inténtelo de nuevo.';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos. Espere antes de intentarlo de nuevo.';

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
  String get chartDataSourceCache => 'Caché';

  @override
  String get chartDataSourceSupabaseEdge => 'Supabase (Edge)';

  @override
  String get chartDataSourceSupabaseTables => 'Supabase (Tablas)';

  @override
  String get chartDataSourceFirebaseCloud => 'Firebase (Cloud)';

  @override
  String get chartDataSourceFirebaseFirestore => 'Firebase (Firestore)';

  @override
  String get chartDataSourceRemote => 'Remoto';

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
  String get graphqlSampleDataSourceCache => 'Caché';

  @override
  String get graphqlSampleDataSourceSupabaseEdge => 'Supabase (Edge)';

  @override
  String get graphqlSampleDataSourceSupabaseTables => 'Supabase (Tablas)';

  @override
  String get graphqlSampleDataSourceRemote => 'Remoto';

  @override
  String get exampleWebsocketButton => 'Abrir demostración de WebSocket';

  @override
  String get exampleGoogleMapsButton => 'Abrir demo de Google Maps';

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

  @override
  String get googleMapsPageTitle => 'Demostración de Google Maps';

  @override
  String get googleMapsPageGenericError =>
      'No pudimos cargar los datos del mapa.';

  @override
  String get googleMapsPageControlsHeading => 'Controles del mapa';

  @override
  String get googleMapsPageMapTypeNormal => 'Mostrar mapa estándar';

  @override
  String get googleMapsPageMapTypeHybrid => 'Mostrar mapa híbrido';

  @override
  String get googleMapsPageTrafficToggle => 'Mostrar tráfico en tiempo real';

  @override
  String get googleMapsPageApiKeyHelp =>
      'Añade las claves de API de Google Maps a los proyectos nativos para ver mosaicos en vivo.';

  @override
  String get googleMapsPageEmptyLocations =>
      'Sin ubicaciones disponibles todavía.';

  @override
  String get googleMapsPageLocationsHeading => 'Lugares destacados';

  @override
  String get googleMapsPageFocusButton => 'Centrar';

  @override
  String get googleMapsPageSelectedBadge => 'Seleccionado';

  @override
  String get googleMapsPageMissingKeyTitle =>
      'Añade una clave de API de Google Maps';

  @override
  String get googleMapsPageMissingKeyDescription =>
      'Configura claves válidas de Google Maps en los proyectos nativos para usar esta demostración.';

  @override
  String get googleMapsPageUnsupportedDescription =>
      'La demo de Google Maps solo está disponible en compilaciones de Android y iOS.';

  @override
  String get syncStatusOfflineTitle => 'Sin conexión';

  @override
  String syncStatusOfflineMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# cambios',
      one: '# cambio',
      zero: 'tus cambios',
    );
    return 'Sincronizaremos $_temp0 cuando vuelvas a estar en línea.';
  }

  @override
  String get syncStatusSyncingTitle => 'Sincronizando cambios';

  @override
  String syncStatusSyncingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: 'Sincronizando # cambios…',
      one: 'Sincronizando # cambio…',
      zero: 'Terminando tus últimas actualizaciones.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusPendingTitle => 'Cambios en cola';

  @override
  String syncStatusPendingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# cambios esperando sincronización.',
      one: '# cambio esperando sincronización.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusDegradedTitle =>
      'Se detectaron problemas de sincronización';

  @override
  String get syncStatusDegradedMessage =>
      'Es posible que algunos datos no estén sincronizados. Toca Reintentar para volver a iniciar la sincronización.';

  @override
  String get syncStatusSyncNowButton => 'Sincronizar ahora';

  @override
  String counterLastSynced(Object timestamp) {
    return 'Última sincronización: $timestamp';
  }

  @override
  String counterChangeId(Object changeId) {
    return 'ID de cambio: $changeId';
  }

  @override
  String get syncQueueInspectorButton => 'Ver cola de sincronización';

  @override
  String get syncQueueInspectorEmpty => 'No hay operaciones pendientes.';

  @override
  String get syncQueueInspectorTitle => 'Operaciones pendientes';

  @override
  String syncQueueInspectorOperation(String entity, int attempts) {
    return 'Entidad: $entity, intentos: $attempts';
  }

  @override
  String get exampleTodoListButton => 'Todo List Demo';

  @override
  String get exampleChatListButton => 'Chat List Demo';

  @override
  String get exampleSearchDemoButton => 'Search Demo';

  @override
  String get exampleProfileButton => 'Profile Demo';

  @override
  String get exampleRegisterButton => 'Register Demo';

  @override
  String get exampleLoggedOutButton => 'Logged Out Demo';

  @override
  String get exampleLibraryDemoButton => 'Library Demo';

  @override
  String get libraryDemoPageTitle => 'Library Demo';

  @override
  String get libraryDemoBrandName => 'Epoch';

  @override
  String get libraryDemoPanelTitle => 'Library';

  @override
  String get libraryDemoSearchHint => 'Search your library';

  @override
  String get libraryDemoCategoryScapes => 'Scapes';

  @override
  String get libraryDemoCategoryPacks => 'Packs';

  @override
  String get libraryDemoAssetsTitle => 'All Assets';

  @override
  String get libraryDemoAssetName => 'Asset Name';

  @override
  String get libraryDemoAssetTypeObject => 'Object';

  @override
  String get libraryDemoAssetTypeImage => 'Image';

  @override
  String get libraryDemoAssetTypeSound => 'Sound';

  @override
  String get libraryDemoAssetTypeFootage => 'Footage';

  @override
  String get libraryDemoAssetDuration => '00:00';

  @override
  String get libraryDemoFormatObj => 'OBJ';

  @override
  String get libraryDemoFormatJpg => 'JPG';

  @override
  String get libraryDemoFormatMp4 => 'MP4';

  @override
  String get libraryDemoFormatMp3 => 'MP3';

  @override
  String get libraryDemoBackButtonLabel => 'Back';

  @override
  String get libraryDemoFilterButtonLabel => 'Filter';

  @override
  String get todoListTitle => 'Todo List';

  @override
  String get todoListLoadError => 'Unable to load todos';

  @override
  String get todoListAddAction => 'Add todo';

  @override
  String get todoListSaveAction => 'Save';

  @override
  String get todoListCancelAction => 'Cancel';

  @override
  String get todoListDeleteAction => 'Delete';

  @override
  String get todoListEditAction => 'Editar';

  @override
  String get todoListCompleteAction => 'Completar';

  @override
  String get todoListUndoAction => 'Marcar como activa';

  @override
  String get todoListDeleteDialogTitle => 'Delete todo?';

  @override
  String todoListDeleteDialogMessage(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get todoListSearchHint => 'Buscar tareas...';

  @override
  String get todoListDeleteUndone => 'Tarea eliminada';

  @override
  String get todoListSortAction => 'Ordenar';

  @override
  String get todoListSortDateDesc => 'Fecha (más reciente primero)';

  @override
  String get todoListSortDateAsc => 'Fecha (más antigua primero)';

  @override
  String get todoListSortTitleAsc => 'Título (A a Z)';

  @override
  String get todoListSortTitleDesc => 'Título (Z a A)';

  @override
  String get todoListSortManual => 'Manual (arrastrar para reordenar)';

  @override
  String get todoListSortPriorityDesc => 'Prioridad (alta a baja)';

  @override
  String get todoListSortPriorityAsc => 'Prioridad (baja a alta)';

  @override
  String get todoListSortDueDateAsc =>
      'Fecha de vencimiento (más próxima primero)';

  @override
  String get todoListSortDueDateDesc =>
      'Fecha de vencimiento (más lejana primero)';

  @override
  String get todoListPriorityNone => 'None';

  @override
  String get todoListPriorityLow => 'Low';

  @override
  String get todoListPriorityMedium => 'Medium';

  @override
  String get todoListPriorityHigh => 'High';

  @override
  String get todoListDueDateLabel => 'Due date';

  @override
  String get todoListNoDueDate => 'Sin fecha de vencimiento';

  @override
  String get todoListClearDueDate => 'Quitar fecha de vencimiento';

  @override
  String get todoListPriorityLabel => 'Priority';

  @override
  String get todoListSelectAll => 'Select all';

  @override
  String get todoListClearSelection => 'Clear selection';

  @override
  String get todoListBatchDelete => 'Delete selected';

  @override
  String get todoListBatchDeleteDialogTitle => 'Delete selected todos?';

  @override
  String todoListBatchDeleteDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count todos',
      one: '1 todo',
    );
    return 'Delete $_temp0? This cannot be undone.';
  }

  @override
  String get todoListBatchComplete => 'Complete selected';

  @override
  String get todoListBatchUncomplete => 'Uncomplete selected';

  @override
  String todoListItemsSelected(int count) {
    return '$count selected';
  }

  @override
  String get todoListAddDialogTitle => 'New todo';

  @override
  String get todoListEditDialogTitle => 'Edit todo';

  @override
  String get todoListTitlePlaceholder => 'Title';

  @override
  String get todoListDescriptionPlaceholder => 'Description (optional)';

  @override
  String get todoListEmptyTitle => 'No todos yet';

  @override
  String get todoListEmptyMessage => 'Add your first task to get started.';

  @override
  String get todoListFilterAll => 'All';

  @override
  String get todoListFilterActive => 'Active';

  @override
  String get todoListFilterCompleted => 'Completed';

  @override
  String get todoListClearCompletedAction => 'Clear completed';

  @override
  String get todoListClearCompletedDialogTitle => 'Clear completed todos?';

  @override
  String todoListClearCompletedDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed todos',
      one: '1 completed todo',
    );
    return 'Delete $_temp0? This cannot be undone.';
  }

  @override
  String get exampleScapesButton => 'Scapes Demo';

  @override
  String get exampleWalletconnectAuthButton => 'WalletConnect Auth (Demo)';

  @override
  String get exampleCameraGalleryButton => 'Demo Cámara y galería';

  @override
  String get cameraGalleryPageTitle => 'Cámara y galería';

  @override
  String get cameraGalleryTakePhoto => 'Tomar foto';

  @override
  String get cameraGalleryPickFromGallery => 'Elegir de la galería';

  @override
  String get cameraGalleryNoImage => 'Ninguna imagen seleccionada';

  @override
  String get cameraGalleryPermissionDenied =>
      'Se denegó el acceso a la cámara o la galería.';

  @override
  String get cameraGalleryCancelled => 'Se canceló la selección.';

  @override
  String get cameraGalleryGenericError =>
      'Algo salió mal. Por favor, inténtelo de nuevo.';

  @override
  String get cameraGalleryCameraUnavailable =>
      'La cámara no está disponible. Use un dispositivo real o elija de la galería.';

  @override
  String get scapesPageTitle => 'Library / Scapes';

  @override
  String get scapeNameLabel => 'Scape Name';

  @override
  String scapeMetadataFormat(String duration, int assetCount) {
    String _temp0 = intl.Intl.pluralLogic(
      assetCount,
      locale: localeName,
      other: '$assetCount ASSETS',
      one: '1 ASSET',
    );
    return '$duration • $_temp0';
  }

  @override
  String get scapeFavoriteAddTooltip => 'Add favorite';

  @override
  String get scapeFavoriteRemoveTooltip => 'Remove favorite';

  @override
  String get scapeMoreOptionsTooltip => 'More options';

  @override
  String get scapesGridViewTooltip => 'Grid view';

  @override
  String get scapesListViewTooltip => 'List view';

  @override
  String get noWalletConnected =>
      'No wallet connected. Please connect a wallet first.';

  @override
  String get noWalletLinked => 'No wallet linked. Connect and link first.';

  @override
  String get couldNotPlayAudio => 'Could not play audio';

  @override
  String get scapesErrorOccurred => 'An error occurred';

  @override
  String get noScapesAvailable => 'No scapes available';

  @override
  String get genuiDemoPageTitle => 'Demo GenUI';

  @override
  String get genuiDemoHintText => 'Ingrese un mensaje para generar UI...';

  @override
  String get genuiDemoSendButton => 'Enviar';

  @override
  String get genuiDemoErrorTitle => 'Error';

  @override
  String get genuiDemoNoApiKey =>
      'GEMINI_API_KEY no configurado. Por favor, agréguelo a secrets.json o use --dart-define=GEMINI_API_KEY=...';

  @override
  String get walletconnectAuthTitle => 'Conectar billetera';

  @override
  String get connectWalletButton => 'Conectar billetera';

  @override
  String get walletAddress => 'Dirección de billetera';

  @override
  String get linkToFirebase => 'Vincular a cuenta';

  @override
  String get relinkToAccount => 'Volver a vincular a cuenta';

  @override
  String get disconnectWallet => 'Desconectar';

  @override
  String get walletConnected => 'Billetera conectada';

  @override
  String get walletLinked => 'Billetera vinculada a cuenta';

  @override
  String get walletConnectError => 'Error al conectar billetera';

  @override
  String get walletLinkError => 'Error al vincular billetera a cuenta';

  @override
  String get walletProfileSection => 'Perfil';

  @override
  String get balanceOffChain => 'Saldo (fuera de cadena)';

  @override
  String get balanceOnChain => 'Saldo (en cadena)';

  @override
  String get rewards => 'Recompensas';

  @override
  String get lastClaim => 'Última reclamación';

  @override
  String get lastClaimNever => 'Nunca';

  @override
  String get nfts => 'NFTs';

  @override
  String nftsCount(int count) {
    return '$count NFT(s)';
  }

  @override
  String get playlearnTitle => 'Playlearn';

  @override
  String get playlearnTopicAnimals => 'Animales';

  @override
  String get playlearnListen => 'Escuchar';

  @override
  String get playlearnTapToListen => 'Toca para escuchar';

  @override
  String get playlearnBack => 'Atrás';

  @override
  String get openPlaylearnTooltip => 'Abrir Playlearn';

  @override
  String get openIgamingDemoTooltip => 'Demo iGaming';

  @override
  String get whiteboardChoosePenColor => 'Elegir color del lápiz';

  @override
  String get whiteboardPickColor => 'Elegir un color';

  @override
  String get whiteboardUndo => 'Deshacer';

  @override
  String get whiteboardUndoLastStroke => 'Deshacer último trazo';

  @override
  String get whiteboardRedo => 'Rehacer';

  @override
  String get whiteboardRedoLastStroke => 'Rehacer último trazo deshecho';

  @override
  String get whiteboardClear => 'Borrar';

  @override
  String get whiteboardClearAllStrokes => 'Borrar todos los trazos';

  @override
  String get whiteboardPenColor => 'Color del lápiz';

  @override
  String get whiteboardStrokeWidth => 'Grosor del trazo';

  @override
  String get whiteboardStrokeWidthThin => 'Fino';

  @override
  String get whiteboardStrokeWidthMedium => 'Medio';

  @override
  String get whiteboardStrokeWidthThick => 'Grueso';

  @override
  String get whiteboardStrokeWidthExtra => 'Extra';

  @override
  String get errorUnknown => 'Ha ocurrido un error desconocido';

  @override
  String get errorNetwork =>
      'Error de conexión de red. Compruebe su conexión a internet.';

  @override
  String get errorTimeout =>
      'La solicitud ha tardado demasiado. Inténtelo de nuevo.';

  @override
  String get errorUnauthorized =>
      'Se requiere autenticación. Inicie sesión de nuevo.';

  @override
  String get errorForbidden =>
      'Acceso denegado. No tiene permiso para esta acción.';

  @override
  String get errorNotFound => 'No se encontró el recurso solicitado.';

  @override
  String get errorServer => 'Error del servidor. Inténtelo más tarde.';

  @override
  String get errorGeneric => 'Algo ha ido mal. Inténtelo de nuevo.';

  @override
  String get errorClient =>
      'Error del cliente. Compruebe su solicitud e inténtelo de nuevo.';

  @override
  String get errorTooManyRequests =>
      'Demasiadas solicitudes. Espere antes de intentarlo de nuevo.';

  @override
  String get errorServiceUnavailable =>
      'Servicio no disponible temporalmente. Inténtelo de nuevo en un minuto.';

  @override
  String get igamingDemoLobbyTitle => 'Demo iGaming';

  @override
  String get igamingDemoBalanceLabel => 'Saldo virtual';

  @override
  String get igamingDemoPlayGame => 'Jugar Lucky Spin';

  @override
  String get igamingDemoGameTitle => 'Lucky Spin';

  @override
  String get igamingDemoStakeLabel => 'Apuesta';

  @override
  String get igamingDemoPlayButton => 'Girar';

  @override
  String get igamingDemoResultWin => '¡Has ganado!';

  @override
  String get igamingDemoResultLoss => 'Esta vez no ha habido suerte.';

  @override
  String get igamingDemoPlayAgain => 'Jugar de nuevo';

  @override
  String get igamingDemoBackToLobby => 'Volver al lobby';

  @override
  String get igamingDemoErrorInsufficientBalance => 'Saldo insuficiente';

  @override
  String get igamingDemoErrorLoadBalance => 'No se pudo cargar el saldo';

  @override
  String get igamingDemoSymbolLegendTitle => 'Símbolos';

  @override
  String get igamingDemoSymbolWinHint =>
      'Tres símbolos iguales = Ganas. Símbolos distintos = No ganas.';

  @override
  String get igamingDemoSymbol7 => 'Siete';

  @override
  String get igamingDemoSymbolStar => 'Estrella';

  @override
  String get igamingDemoSymbolDiamond => 'Diamante';

  @override
  String get igamingDemoSymbolCircle => 'Círculo';

  @override
  String get igamingDemoSymbolTriangle => 'Triángulo';

  @override
  String get igamingDemoSymbolGem => 'Gema';

  @override
  String get exampleIgamingDemoButton => 'Demo iGaming';

  @override
  String get exampleFcmDemoButton => 'FCM Demo';

  @override
  String get exampleFirebaseFunctionsButton => 'Probar Firebase Functions';

  @override
  String get firebaseFunctionsTestTitle => 'Firebase Functions';

  @override
  String get firebaseFunctionsCallButton => 'Llamar a helloWorld';

  @override
  String get firebaseFunctionsResultLabel => 'Resultado';

  @override
  String get firebaseUnavailableMessage => 'Firebase no está inicializado.';

  @override
  String get fcmDemoPageTitle => 'FCM Demo';

  @override
  String get fcmDemoPermissionLabel => 'Permission';

  @override
  String get fcmDemoPermissionNotDetermined => 'Not determined';

  @override
  String get fcmDemoPermissionAuthorized => 'Granted';

  @override
  String get fcmDemoPermissionDenied => 'Denied';

  @override
  String get fcmDemoPermissionProvisional => 'Provisional';

  @override
  String get fcmDemoFcmTokenLabel => 'FCM token';

  @override
  String get fcmDemoApnsTokenLabel => 'APNs token';

  @override
  String get fcmDemoTokenNotAvailable => 'Not available';

  @override
  String get fcmDemoCopyToken => 'Copy';

  @override
  String get fcmDemoCopySuccess => 'Copied to clipboard';

  @override
  String get fcmDemoCopyFailure => 'Copy failed';

  @override
  String get fcmDemoLastMessageLabel => 'Last message';

  @override
  String get fcmDemoLastMessageNone => 'None yet';

  @override
  String get fcmDemoLastMessageReceived => 'Message received';

  @override
  String get fcmDemoScopeNoteIos =>
      'On iOS, background/terminated delivery requires APNs key in Firebase Console.';

  @override
  String get fcmDemoScopeNoteSimulator =>
      'On iOS Simulator use the .apns file (drag onto simulator or xcrun simctl push).';

  @override
  String get iotDemoPageTitle => 'Demo IoT';

  @override
  String get iotDemoDeviceListEmpty => 'No se encontraron dispositivos';

  @override
  String get iotDemoConnect => 'Conectar';

  @override
  String get iotDemoDisconnect => 'Desconectar';

  @override
  String get iotDemoToggle => 'Alternar';

  @override
  String get iotDemoSetValue => 'Establecer valor';

  @override
  String get iotDemoSetValueHint => 'Valor';

  @override
  String get iotDemoStatusDisconnected => 'Desconectado';

  @override
  String get iotDemoStatusConnecting => 'Conectando';

  @override
  String get iotDemoStatusConnected => 'Conectado';

  @override
  String get iotDemoDeviceTypeLight => 'Luz';

  @override
  String get iotDemoDeviceTypeThermostat => 'Termostato';

  @override
  String get iotDemoDeviceTypePlug => 'Enchufe';

  @override
  String get iotDemoDeviceTypeSensor => 'Sensor';

  @override
  String get iotDemoDeviceTypeSwitch => 'Interruptor';

  @override
  String get iotDemoErrorLoad => 'Error al cargar dispositivos';

  @override
  String get iotDemoErrorConnect => 'Error al conectar';

  @override
  String get iotDemoErrorDisconnect => 'Error al desconectar';

  @override
  String get iotDemoErrorCommand => 'Error al enviar comando';

  @override
  String get iotDemoStateOn => 'Encendido';

  @override
  String get iotDemoStateOff => 'Apagado';

  @override
  String iotDemoCurrentValue(String value) {
    return 'Valor actual: $value';
  }

  @override
  String iotDemoSetValueOutOfRange(String min, String max) {
    return 'El valor debe estar entre $min y $max';
  }

  @override
  String get iotDemoSetValueInvalidNumber => 'Introduzca un número válido';

  @override
  String get iotDemoAddDevice => 'Añadir dispositivo';

  @override
  String get iotDemoAddDeviceNameHint => 'Nombre del dispositivo';

  @override
  String get iotDemoAddDeviceNameRequired => 'El nombre es obligatorio';

  @override
  String iotDemoAddDeviceNameTooLong(String max) {
    return 'El nombre debe tener como máximo $max caracteres';
  }

  @override
  String get iotDemoAddDeviceTypeHint => 'Tipo de dispositivo';

  @override
  String iotDemoAddDeviceInitialValue(String value) {
    return 'Valor inicial: $value';
  }

  @override
  String get iotDemoAddDeviceTooltip => 'Añadir dispositivo';

  @override
  String get iotDemoErrorAdd => 'Error al añadir el dispositivo';

  @override
  String get iotDemoFilterAll => 'Todos';

  @override
  String get iotDemoFilterOnOnly => 'Solo encendidos';

  @override
  String get iotDemoFilterOffOnly => 'Solo apagados';

  @override
  String get openIotDemoTooltip => 'Abrir demo IoT';

  @override
  String get searchAllResultsSectionTitle => 'TODOS LOS RESULTADOS';

  @override
  String get searchErrorLoadingResults => 'Error al cargar resultados';

  @override
  String get searchNoResultsFound => 'No se encontraron resultados';

  @override
  String get profileSeeMore => 'VER MÁS';

  @override
  String get moreTooltip => 'Más';

  @override
  String get whiteboardPageTitle => 'Pizarra';

  @override
  String get playlearnNoWords => 'Sin palabras';

  @override
  String get playlearnNoTopics => 'Sin temas';

  @override
  String get commonEmptyStateTryAgain => 'Reintentar';

  @override
  String get profileNoCachedProfile => 'Sin perfil en caché';

  @override
  String get profileCachedProfileDetailsUnavailable =>
      'Perfil en caché (detalles no disponibles)';

  @override
  String get loggedOutPhotoLabel => 'foto';

  @override
  String get supabaseAuthTitle => 'Auth de Supabase';

  @override
  String get supabaseAuthSignIn => 'Iniciar sesión';

  @override
  String get supabaseAuthSignUp => 'Registrarse';

  @override
  String get supabaseAuthSignOut => 'Cerrar sesión';

  @override
  String get supabaseAuthEmailLabel => 'Correo';

  @override
  String get supabaseAuthPasswordLabel => 'Contraseña';

  @override
  String get supabaseAuthPasswordMinLength => 'Al menos 6 caracteres';

  @override
  String get supabaseAuthDisplayNameLabel => 'Nombre (opcional)';

  @override
  String get supabaseAuthNotConfigured =>
      'Supabase no está configurado. Añade SUPABASE_URL y SUPABASE_ANON_KEY a secretos o entorno.';

  @override
  String get supabaseAuthErrorInvalidCredentials =>
      'Correo o contraseña inválidos';

  @override
  String get supabaseAuthErrorInvalidEmail =>
      'Introduce una dirección de correo válida.';

  @override
  String get supabaseAuthErrorNetwork => 'Error de red. Comprueba la conexión.';

  @override
  String get supabaseAuthErrorWeakPassword =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get supabaseAuthErrorUserAlreadyExists =>
      'Ya existe una cuenta con este correo. Inicia sesión.';

  @override
  String supabaseAuthSignedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get settingsIntegrationsSection => 'Integraciones';

  @override
  String get settingsSupabaseAuth => 'Auth de Supabase';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get exampleIapDemoButton => 'In-app purchases (IAP) demo';

  @override
  String get iapDemoPageTitle => 'In-App Purchases';

  @override
  String get iapDemoDisclaimer =>
      'Store IAP demo. Real purchases require App Store / Play sandbox testing. For emulator/simulator, use the simulated flow.';

  @override
  String get iapDemoUseFakeRepoLabel => 'Use simulated purchases';

  @override
  String get iapDemoForceOutcomeLabel => 'Force outcome';

  @override
  String get iapDemoEntitlementsTitle => 'Entitlements';

  @override
  String get iapDemoCreditsLabel => 'Credits';

  @override
  String get iapDemoPremiumLabel => 'Premium owned';

  @override
  String get iapDemoSubscriptionLabel => 'Subscription active';

  @override
  String get iapDemoSubscriptionExpiryLabel => 'Subscription expiry';

  @override
  String get iapDemoRestoreButton => 'Restore purchases';

  @override
  String get iapDemoProductsTitle => 'Products';

  @override
  String get iapDemoConsumablesTitle => 'Consumables';

  @override
  String get iapDemoNonConsumablesTitle => 'Non-consumables';

  @override
  String get iapDemoSubscriptionsTitle => 'Subscriptions';

  @override
  String get iapDemoLastResultLabel => 'Last result';

  @override
  String get iapDemoBuyButton => 'Buy';

  @override
  String get iapDemoNoProductsFound => 'No products found.';

  @override
  String get exampleCaseStudyDemoButton => 'Demo de caso clínico (odontología)';

  @override
  String get caseStudyDemoTitle => 'Demo de caso clínico';

  @override
  String get caseStudyDemoNewCase => 'Nuevo caso';

  @override
  String get caseStudyDemoHistory => 'Historial';

  @override
  String get caseStudyDemoSettings => 'Ajustes';

  @override
  String get caseStudyDemoMetadataTitle => 'Datos del caso';

  @override
  String get caseStudyDoctorNameLabel => 'Nombre del odontólogo';

  @override
  String get caseStudyCaseTypeLabel => 'Tipo de caso';

  @override
  String get caseStudyNotesLabel => 'Notas (opcional)';

  @override
  String get caseStudyContinue => 'Continuar';

  @override
  String get caseStudyCaseTypeImplant => 'Implante';

  @override
  String get caseStudyCaseTypeOrtho => 'Ortodoncia';

  @override
  String get caseStudyCaseTypeCosmetic => 'Estética';

  @override
  String get caseStudyCaseTypeGeneral => 'General';

  @override
  String get caseStudyRecordTitle => 'Grabar respuestas';

  @override
  String caseStudyQuestionProgress(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get caseStudyPickVideoCamera => 'Grabar vídeo';

  @override
  String get caseStudyPickVideoGallery => 'Elegir de la galería';

  @override
  String get caseStudyNext => 'Siguiente';

  @override
  String get caseStudyGoToReview => 'Ir a revisión';

  @override
  String get caseStudyBack => 'Atrás';

  @override
  String get caseStudyReviewTitle => 'Revisar y enviar';

  @override
  String get caseStudySubmit => 'Enviar';

  @override
  String get caseStudyAbandon => 'Descartar caso';

  @override
  String get caseStudyAbandonConfirmBody =>
      '¿Descartar este caso y eliminar los vídeos grabados?';

  @override
  String get caseStudyDeleteDialogTitle => '¿Eliminar caso?';

  @override
  String get caseStudyDeleteDialogBody =>
      '¿Eliminar este caso de forma permanente? Esta acción no se puede deshacer.';

  @override
  String get caseStudyUploading => 'Subiendo…';

  @override
  String get caseStudyDataModeLocalOnly => 'Solo local';

  @override
  String get caseStudyDataModeSupabase => 'Supabase';

  @override
  String get caseStudyHistoryTitle => 'Casos enviados';

  @override
  String get caseStudyHistoryEmpty => 'Aún no hay casos enviados.';

  @override
  String get caseStudyHistoryDetailTitle => 'Detalle del caso';

  @override
  String get caseStudySubmittedAt => 'Enviado';

  @override
  String get caseStudyVideoMissing => 'Falta el archivo de vídeo';

  @override
  String get caseStudyErrorGeneric => 'Algo salió mal. Inténtelo de nuevo.';

  @override
  String get caseStudyHistoryDetailNotFound =>
      'No se encontró este caso. Puede haberse eliminado o no tener acceso.';

  @override
  String get caseStudyHistoryDetailUnavailable =>
      'No se pudo cargar este caso. Compruebe la conexión e inténtelo de nuevo.';

  @override
  String get caseStudySubmitLocalHistoryFailed =>
      'El caso se guardó en la nube, pero no se pudo actualizar el historial local en este dispositivo. Use «Reintentar guardar en este dispositivo» abajo o abra Historial para ver los envíos en la nube.';

  @override
  String get caseStudyRetryLocalSave =>
      'Reintentar guardar en este dispositivo';

  @override
  String get caseStudyRefreshDetailTooltip => 'Actualizar';

  @override
  String get caseStudySignedUrlsRefreshHint =>
      'La reproducción usa enlaces temporales (unas 24 horas). Desliza hacia abajo o pulsa actualizar si un vídeo deja de funcionar.';

  @override
  String get caseStudyQuestion1 =>
      'Presente al paciente y el motivo de consulta.';

  @override
  String get caseStudyQuestion2 => 'Describa la historia médica relevante.';

  @override
  String get caseStudyQuestion3 => 'Muestre hallazgos del examen extraoral.';

  @override
  String get caseStudyQuestion4 => 'Muestre hallazgos del examen intraoral.';

  @override
  String get caseStudyQuestion5 => 'Explique los hallazgos radiográficos.';

  @override
  String get caseStudyQuestion6 =>
      'Revise el diagnóstico y la lista de problemas.';

  @override
  String get caseStudyQuestion7 =>
      'Describa las opciones de tratamiento comentadas.';

  @override
  String get caseStudyQuestion8 => 'Detalle el plan de tratamiento elegido.';

  @override
  String get caseStudyQuestion9 =>
      'Muestre el estado postoperatorio inmediato.';

  @override
  String get caseStudyQuestion10 => 'Resuma el seguimiento y el pronóstico.';

  @override
  String staffDemoAdminFlagged(int count) {
    return 'Flagged ($count)';
  }

  @override
  String get staffDemoAdminNoFlagged => 'No flagged entries found.';

  @override
  String staffDemoAdminRecentEntries(int count) {
    return 'Recent time entries ($count)';
  }

  @override
  String get staffDemoAdminSeedingReminder =>
      'Seeding reminders: create staffDemoProfiles (user uid), staffDemoSites (site id), and staffDemoShifts (shift id) documents in Firestore for full demo coverage.';

  @override
  String get staffDemoAdminTitle => 'Admin';

  @override
  String get staffDemoAssignToStaffLabel => 'Assign to staff';

  @override
  String get staffDemoComposeDefaultShiftBody =>
      'Your shift starts at 10:00. Please meet at the warehouse.';

  @override
  String get staffDemoComposeRecipientUserId => 'Recipient userId';

  @override
  String get staffDemoComposeSendShiftAssignment => 'Send shift assignment';

  @override
  String get staffDemoComposeStaffListFailed => 'Failed to load staff list.';

  @override
  String staffDemoComposeStaffListFailedWithDetails(String details) {
    return 'Failed to load staff list.\n$details';
  }

  @override
  String get staffDemoComposeTitle => 'Send shift assignment';

  @override
  String get staffDemoContentCouldNotLoadUrl => 'Could not load file URL.';

  @override
  String get staffDemoContentEmpty => 'No content yet.';

  @override
  String get staffDemoContentFailedToOpenItem => 'Failed to load content.';

  @override
  String get staffDemoContentTitle => 'Content';

  @override
  String staffDemoDashboardHello(String name) {
    return 'Hello, $name';
  }

  @override
  String get staffDemoDashboardInactiveProfile =>
      'This staff demo profile is inactive.';

  @override
  String get staffDemoDashboardIntro =>
      'Use the bottom tabs to navigate the demo. Accounting flow starts with Timeclock.';

  @override
  String get staffDemoDashboardLoading => 'Loading…';

  @override
  String get staffDemoDashboardNoProfile =>
      'No staff demo profile found for this user. Seed a staffDemoProfiles document keyed by this user\'s Firebase Auth uid in Firestore.';

  @override
  String get staffDemoDashboardTitle => 'Staff demo';

  @override
  String get staffDemoFormsErrorSiteRequired => 'Site ID is required.';

  @override
  String get staffDemoFormsManagerReport => 'Manager report';

  @override
  String get staffDemoFormsNotesLabel => 'Notes';

  @override
  String get staffDemoFormsSubmitAvailability => 'Submit availability';

  @override
  String get staffDemoFormsSubmitReport => 'Submit report';

  @override
  String get staffDemoFormsSubmitted => 'Submitted.';

  @override
  String get staffDemoFormsSuccessAvailability => 'Availability submitted';

  @override
  String get staffDemoFormsSuccessManagerReport => 'Manager report submitted';

  @override
  String get staffDemoFormsTitle => 'Forms';

  @override
  String get staffDemoFormsWeeklyAvailability => 'Weekly availability';

  @override
  String get staffDemoMessagesEmpty => 'No messages yet.';

  @override
  String get staffDemoMessagesErrorInboxLoadFailed =>
      'Failed to load inbox updates.';

  @override
  String get staffDemoMessagesTitle => 'Messages';

  @override
  String get staffDemoNavAdmin => 'Admin';

  @override
  String get staffDemoNavContent => 'Content';

  @override
  String get staffDemoNavForms => 'Forms';

  @override
  String get staffDemoNavHome => 'Home';

  @override
  String get staffDemoNavMsgs => 'Msgs';

  @override
  String get staffDemoNavProof => 'Proof';

  @override
  String get staffDemoNavTime => 'Time';

  @override
  String get staffDemoNotSignedIn => 'Not signed in.';

  @override
  String get staffDemoProofFailed => 'Failed.';

  @override
  String get staffDemoProofOfflineQueued =>
      'Offline: queued for sync when online.';

  @override
  String get staffDemoProofPhotos => 'Photos';

  @override
  String get staffDemoProofPickPhoto => 'Pick';

  @override
  String get staffDemoProofShiftIdOptional => 'Shift ID (optional)';

  @override
  String get staffDemoProofSignatureClear => 'Clear';

  @override
  String get staffDemoProofSignatureLabel => 'Signature';

  @override
  String get staffDemoProofSignatureNotSaved => 'Not saved';

  @override
  String get staffDemoProofSignatureSave => 'Save signature';

  @override
  String get staffDemoProofSignatureSaved => 'Saved';

  @override
  String get staffDemoProofSignatureSaveBefore => 'Please sign before saving.';

  @override
  String get staffDemoProofSignatureSaveSuccess => 'Signature saved.';

  @override
  String get staffDemoProofSubmit => 'Submit';

  @override
  String get staffDemoProofSubmitProof => 'Submit proof';

  @override
  String get staffDemoProofSubmittedEmpty => 'Submitted proof';

  @override
  String staffDemoProofSubmittedWithId(String proofId) {
    return 'Submitted proof $proofId';
  }

  @override
  String get staffDemoProofTakePhoto => 'Take photo';

  @override
  String get staffDemoProofTitle => 'Proof';

  @override
  String get staffDemoSitePickerEmpty => 'No sites found in staffDemoSites.';

  @override
  String get staffDemoSitePickerFailed => 'Failed to load sites.';

  @override
  String get staffDemoSitePickerLoading => 'Loading sites...';

  @override
  String get staffDemoSitePickerLabel => 'Site';

  @override
  String get staffDemoSubmitting => 'Submitting…';

  @override
  String get staffDemoTimeclockClockIn => 'Clock in';

  @override
  String get staffDemoTimeclockClockOut => 'Clock out';

  @override
  String staffDemoTimeclockClockedInStatus(String entryId) {
    return 'Status: clocked in ($entryId)';
  }

  @override
  String get staffDemoTimeclockClockedOutStatus => 'Status: clocked out';

  @override
  String staffDemoTimeclockDistanceMeters(String distanceM, String radiusM) {
    return 'Distance: ${distanceM}m (radius ${radiusM}m)';
  }

  @override
  String get staffDemoTimeclockLastResultFlags => 'Last result flags:';

  @override
  String get staffDemoTimeclockTitle => 'Timeclock';

  @override
  String get staffDemoVideoPlayerError => 'Could not load this video.';

  @override
  String get staffDemoActionSend => 'Send';

  @override
  String get staffDemoComposeMessageBodyLabel => 'Message body';

  @override
  String get staffDemoComposeRecipientUserIdHelper =>
      'Enter a Firebase Auth uid.';

  @override
  String get staffDemoInboxMessageFallback => 'Message';

  @override
  String get staffDemoShiftConfirmAction => 'Confirm';

  @override
  String get staffDemoShiftConfirmed => 'Confirmed';
}
