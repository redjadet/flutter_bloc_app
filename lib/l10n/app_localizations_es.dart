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
  String get openGoogleMapsTooltip => 'Abrir demo de Google Maps';

  @override
  String get openWhiteboardTooltip => 'Abrir Whiteboard';

  @override
  String get openMarkdownEditorTooltip => 'Abrir Editor de Markdown';

  @override
  String get openTodoTooltip => 'Abrir Lista de Tareas';

  @override
  String get chatPageTitle => 'Chat con IA';

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
}
