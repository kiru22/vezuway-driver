// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get common_appName => 'vezuway.';

  @override
  String get common_appTagline => 'Gestiona tus envios';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_loading => 'Cargando...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Exito';

  @override
  String get common_viewAll => 'Ver todas';

  @override
  String get common_user => 'Usuario';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_noResults => 'Sin resultados';

  @override
  String get common_kg => 'kg';

  @override
  String get common_eur => 'EUR';

  @override
  String get common_pcs => 'uds';

  @override
  String get auth_loginTitle => 'Iniciar sesion';

  @override
  String get auth_loginButton => 'Iniciar sesion';

  @override
  String get auth_emailLabel => 'Correo electronico';

  @override
  String get auth_emailHint => 'Ingresa tu correo electronico';

  @override
  String get auth_passwordLabel => 'Contrasena';

  @override
  String get auth_passwordHint => 'Ingresa tu contrasena';

  @override
  String get auth_emailRequired => 'Ingresa tu correo electronico';

  @override
  String get auth_emailInvalid => 'Ingresa un correo valido';

  @override
  String get auth_passwordRequired => 'Ingresa tu contrasena';

  @override
  String get auth_loginError => 'Error al iniciar sesion';

  @override
  String get auth_registerTitle => 'Crear cuenta';

  @override
  String get auth_registerSubtitle => 'Ingresa tus datos para registrarte';

  @override
  String get auth_nameLabel => 'Nombre completo';

  @override
  String get auth_nameHint => 'Ingresa tu nombre';

  @override
  String get auth_nameRequired => 'Ingresa tu nombre';

  @override
  String get auth_phoneLabel => 'Telefono (opcional)';

  @override
  String get auth_phoneHint => 'Ingresa tu telefono';

  @override
  String get auth_confirmPasswordLabel => 'Confirmar contrasena';

  @override
  String get auth_confirmPasswordHint => 'Confirma tu contrasena';

  @override
  String get auth_confirmPasswordRequired => 'Confirma tu contrasena';

  @override
  String get auth_passwordMismatch => 'Las contrasenas no coinciden';

  @override
  String get auth_passwordMinLength =>
      'La contrasena debe tener al menos 8 caracteres';

  @override
  String get auth_registerButton => 'Crear cuenta';

  @override
  String get auth_registerError => 'Error al registrar';

  @override
  String get auth_noAccount => 'No tienes cuenta?';

  @override
  String get auth_hasAccount => 'Ya tienes cuenta?';

  @override
  String get auth_signUp => 'Registrate';

  @override
  String get auth_signIn => 'Inicia sesion';

  @override
  String get auth_continueWith => 'o continua con';

  @override
  String get auth_continueWithGoogle => 'Continuar con Google';

  @override
  String get auth_logout => 'Cerrar sesion';

  @override
  String home_greeting(String userName) {
    return 'Hola, $userName';
  }

  @override
  String get home_upcomingRoutes => 'Proximas rutas';

  @override
  String get home_activeTrip => 'Viaje activo';

  @override
  String get home_nextTrip => 'Proximo viaje';

  @override
  String get home_noScheduledRoutes => 'Sin rutas programadas';

  @override
  String get home_createRoutePrompt => 'Planifica tu proxima ruta';

  @override
  String get stats_packages => 'Paquetes';

  @override
  String get stats_totalWeight => 'Peso total';

  @override
  String get stats_declaredValue => 'Valor';

  @override
  String get packages_title => 'Pedidos';

  @override
  String get packages_searchPlaceholder =>
      'Buscar por codigo, remitente o destinatario...';

  @override
  String get packages_filterAll => 'Todos';

  @override
  String get packages_emptyTitle => 'Sin paquetes';

  @override
  String get packages_emptyMessage =>
      'Usa el boton + para registrar un nuevo paquete';

  @override
  String get packages_emptyFilterTitle => 'Sin resultados';

  @override
  String get packages_emptyFilterMessage =>
      'No se encontraron paquetes con los filtros aplicados';

  @override
  String get packages_changeStatus => 'Cambiar estado';

  @override
  String get packages_selectNewStatus =>
      'Selecciona el nuevo estado del paquete';

  @override
  String get packages_detailTitle => 'Detalle del Paquete';

  @override
  String get packages_trackingCode => 'Codigo de Seguimiento';

  @override
  String get packages_weight => 'Peso';

  @override
  String get packages_dimensions => 'Dimensiones';

  @override
  String get packages_declaredValue => 'Valor Declarado';

  @override
  String get packages_notSpecified => 'No especificado';

  @override
  String get packages_senderReceiver => 'Remitente y Destinatario';

  @override
  String get packages_sender => 'Remitente';

  @override
  String get packages_receiver => 'Destinatario';

  @override
  String get packages_details => 'Detalles';

  @override
  String get packages_description => 'Descripcion';

  @override
  String get packages_notes => 'Notas';

  @override
  String get packages_statusHistory => 'Historial de Estados';

  @override
  String get packages_noHistory => 'Sin historial';

  @override
  String get packages_historyError => 'Error al cargar historial';

  @override
  String get packages_historyUnavailable => 'Historial no disponible';

  @override
  String get packages_loadError => 'Error al cargar el paquete';

  @override
  String packages_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paquetes',
      one: '1 paquete',
      zero: 'Sin paquetes',
    );
    return '$_temp0';
  }

  @override
  String get packages_createTitle => 'Nuevo Paquete';

  @override
  String get packages_createSuccess => 'Paquete creado correctamente';

  @override
  String get packages_createError => 'Error al crear el paquete';

  @override
  String get packages_assignRoute => 'Asignar a ruta';

  @override
  String get packages_senderSection => 'Remitente';

  @override
  String get packages_senderNameLabel => 'Nombre *';

  @override
  String get packages_senderNameHint => 'Nombre del remitente';

  @override
  String get packages_nameRequired => 'El nombre es requerido';

  @override
  String get packages_phoneLabel => 'Telefono';

  @override
  String get packages_phoneHintSpain => '+34 600 000 000';

  @override
  String get packages_phoneHintUkraine => '+380 00 000 0000';

  @override
  String get packages_addressLabel => 'Direccion';

  @override
  String get packages_pickupAddressHint => 'Direccion de recogida';

  @override
  String get packages_receiverSection => 'Destinatario';

  @override
  String get packages_receiverNameHint => 'Nombre del destinatario';

  @override
  String get packages_deliveryAddressHint => 'Direccion de entrega';

  @override
  String get packages_detailsSection => 'Detalles del paquete';

  @override
  String get packages_contentHint => 'Contenido del paquete';

  @override
  String get packages_weightLabel => 'Peso (kg)';

  @override
  String get packages_declaredValueLabel => 'Valor declarado (EUR)';

  @override
  String get packages_notesLabel => 'Notas';

  @override
  String get packages_additionalNotesHint => 'Notas adicionales...';

  @override
  String get packages_unassigned => 'Sin asignar';

  @override
  String get packages_tabSender => 'Remitente';

  @override
  String get packages_tabReceiver => 'Destinatario';

  @override
  String get packages_widthLabel => 'An';

  @override
  String get packages_heightLabel => 'Al';

  @override
  String get packages_lengthLabel => 'La';

  @override
  String get packages_quantityLabel => 'Cantidad';

  @override
  String get packages_tariffLabel => 'TARIFA';

  @override
  String get packages_totalPrice => 'TOTAL';

  @override
  String get packages_noRoutesTitle => 'Sin rutas disponibles';

  @override
  String get packages_noRoutesMessage =>
      'Crea una ruta primero para poder registrar paquetes';

  @override
  String get packages_createRouteButton => 'Crear ruta';

  @override
  String get packages_submitPackage => 'Crear paquete';

  @override
  String get packages_addressRequired => 'La direccion es requerida';

  @override
  String get packages_routeRequired => 'Selecciona una ruta';

  @override
  String get packages_selectRoute => 'Seleccionar ruta';

  @override
  String get packages_volumetricWeight => 'Peso volumetrico';

  @override
  String get packages_toEurope => 'A EUROPA';

  @override
  String get packages_cityLabel => 'Ciudad';

  @override
  String get packages_addressButton => 'Direccion';

  @override
  String get packages_deliverySection => 'ENTREGA';

  @override
  String get packages_hide => 'Ocultar';

  @override
  String get packages_exactAddress => 'Direccion exacta';

  @override
  String get packages_googleMapsLink => 'Enlace a Google Maps';

  @override
  String get packages_weightKg => 'PESO (KG)';

  @override
  String get packages_quantityPcs => 'CANTIDAD (UDS)';

  @override
  String get packages_dimensionsCm => 'DIMENSIONES (CM)';

  @override
  String get packages_nameLabel => 'Nombre';

  @override
  String get packages_cityRequired => 'La ciudad es requerida';

  @override
  String get packages_mapsPrefix => 'Maps';

  @override
  String get packages_billingWeight => 'Peso facturable';

  @override
  String get packages_route => 'Ruta';

  @override
  String get packages_origin => 'Origen';

  @override
  String get packages_destination => 'Destino';

  @override
  String get packages_departureDate => 'Fecha de salida';

  @override
  String get routes_title => 'Rutas';

  @override
  String routes_activeTab(int count) {
    return 'Activas ($count)';
  }

  @override
  String routes_upcomingTab(int count) {
    return 'Proximas ($count)';
  }

  @override
  String get routes_historyTab => 'Historial';

  @override
  String get routes_emptyActive => 'No hay rutas activas';

  @override
  String get routes_emptyActiveSubtitle =>
      'Las rutas en progreso apareceran aqui';

  @override
  String get routes_emptyPlanned => 'No hay rutas programadas';

  @override
  String get routes_emptyPlannedSubtitle => 'Crea una nueva ruta para empezar';

  @override
  String get routes_emptyHistory => 'Sin historial';

  @override
  String get routes_emptyHistorySubtitle =>
      'Las rutas completadas apareceran aqui';

  @override
  String get routes_createTitle => 'Nueva Ruta';

  @override
  String get routes_originDestination => 'Origen y Destino';

  @override
  String get routes_originCity => 'Ciudad de origen';

  @override
  String get routes_destinationCity => 'Ciudad de destino';

  @override
  String get routes_originRequired => 'Ingresa la ciudad de origen';

  @override
  String get routes_destinationRequired => 'Ingresa la ciudad de destino';

  @override
  String get routes_departureDates => 'Fechas de salida';

  @override
  String get routes_departureDatesHint =>
      'Selecciona una o mas fechas en el calendario';

  @override
  String get routes_atLeastOneDate => 'Selecciona al menos una fecha de salida';

  @override
  String get routes_tripDuration => 'Duracion del viaje (opcional)';

  @override
  String get routes_tripDurationHint => 'Numero de horas';

  @override
  String get routes_tripDurationDescription =>
      'Tiempo estimado de viaje en horas';

  @override
  String get routes_notesOptional => 'Notas (opcional)';

  @override
  String get routes_notesHint => 'Observaciones adicionales...';

  @override
  String get routes_createButton => 'Crear Ruta';

  @override
  String routes_createButtonWithDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fechas',
      one: 'fecha',
    );
    return 'Crear Ruta ($count $_temp0)';
  }

  @override
  String get routes_createSuccess => 'Ruta creada correctamente';

  @override
  String get routes_createError => 'Error al crear la ruta';

  @override
  String get routes_selectDatesPrompt =>
      'Toca los dias en el calendario para seleccionar';

  @override
  String routes_selectedDatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fechas seleccionadas',
      one: 'fecha seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get routes_month => 'Mes';

  @override
  String get routes_searchCity => 'Buscar ciudad...';

  @override
  String get routes_stopsOptional => 'Paradas intermedias (opcional)';

  @override
  String get routes_pricing => 'Tarifas';

  @override
  String get routes_pricePerKg => 'Precio/kg';

  @override
  String get routes_minimumPrice => 'Minimo';

  @override
  String get routes_multiplier => 'Multiplicador';

  @override
  String get routes_multiplierHint => 'Ajuste estacional (1.0 = precio base)';

  @override
  String get routes_deleteConfirmTitle => 'Eliminar ruta';

  @override
  String get routes_deleteConfirmMessage =>
      '¿Estas seguro de eliminar esta ruta? Esta accion no se puede deshacer.';

  @override
  String get routes_deleteSuccess => 'Ruta eliminada';

  @override
  String get routes_deleteError => 'Error al eliminar la ruta';

  @override
  String get nav_home => 'Inicio';

  @override
  String get nav_packages => 'Pedidos';

  @override
  String get nav_routes => 'Rutas';

  @override
  String get quickAction_title => 'Crear nuevo';

  @override
  String get quickAction_subtitle => 'Selecciona que quieres registrar';

  @override
  String get quickAction_newRoute => 'Nueva ruta';

  @override
  String get quickAction_newRouteSubtitle => 'Espana-Ucrania';

  @override
  String get quickAction_newPackage => 'Nuevo paquete';

  @override
  String get quickAction_newPackageSubtitle => 'Manual';

  @override
  String get quickAction_scan => 'Escanear';

  @override
  String get quickAction_scanSubtitle => 'OCR';

  @override
  String get quickAction_import => 'Importar';

  @override
  String get quickAction_importSubtitle => 'Excel';

  @override
  String get userMenu_profile => 'Mi perfil';

  @override
  String get userMenu_settings => 'Configuracion';

  @override
  String get userMenu_help => 'Ayuda';

  @override
  String get userMenu_language => 'Idioma';

  @override
  String get userMenu_theme => 'Tema';

  @override
  String get status_package_registered => 'Registrado';

  @override
  String get status_package_registered_desc =>
      'Paquete registrado en el sistema';

  @override
  String get status_package_inTransit => 'En camino';

  @override
  String get status_package_inTransit_desc => 'Enviar en ruta';

  @override
  String get status_package_delivered => 'Entregado';

  @override
  String get status_package_delivered_desc => 'Entregar al cliente';

  @override
  String get status_package_delayed => 'Retrasado';

  @override
  String get status_package_delayed_desc => 'Surgieron problemas con el envio';

  @override
  String get status_route_planned => 'Planificada';

  @override
  String get status_route_inProgress => 'En progreso';

  @override
  String get status_route_completed => 'Completada';

  @override
  String get status_route_cancelled => 'Cancelada';

  @override
  String get statusChip_inTransit => 'EN TRANSITO';

  @override
  String get statusChip_delivered => 'ENTREGADO';

  @override
  String get statusChip_pending => 'PENDIENTE';

  @override
  String get statusChip_planned => 'PLANIFICADA';

  @override
  String get tripCard_driver => 'Conductor';

  @override
  String get tripCard_vehicle => 'Mercedes Sprinter';

  @override
  String get tripCard_spain => 'Espana';

  @override
  String get tripCard_ukraine => 'Ucrania';

  @override
  String get tripCard_capacity => 'Capacidad';

  @override
  String get tripCard_perKg => '/kg';

  @override
  String tripCard_deliveryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count envios',
      one: '1 envio',
    );
    return '$_temp0';
  }

  @override
  String get tripCard_call => 'Llamar';

  @override
  String get tripCard_message => 'Mensaje';

  @override
  String get tripCard_rating => 'Rating';

  @override
  String get tripCard_deliveries => 'Envios';

  @override
  String get country_spain => 'Espana';

  @override
  String get country_ukraine => 'Ucrania';

  @override
  String action_changeStatusTo(String status) {
    return 'Cambiar a \"$status\"';
  }

  @override
  String get action_openMap => 'Mapa';

  @override
  String get action_viewOnMap => 'Ver en mapa';

  @override
  String get action_call => 'Llamar';

  @override
  String get action_whatsapp => 'WhatsApp';

  @override
  String get action_telegram => 'Telegram';

  @override
  String get action_viber => 'Viber';
}
