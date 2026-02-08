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
  String get common_today => 'Hoy';

  @override
  String get common_yesterday => 'Ayer';

  @override
  String get common_deleteConfirmTitle => 'Confirmar eliminación';

  @override
  String common_deleteConfirmMessage(String itemType) {
    return '¿Estás seguro de que deseas eliminar este $itemType?';
  }

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
  String get stats_contacts => 'Contactos';

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
  String get packages_codeCopied => 'Codigo copiado';

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
  String get packages_createNew => 'Nuevo envío';

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
  String get packages_widthLabel => 'Ancho';

  @override
  String get packages_heightLabel => 'Alto';

  @override
  String get packages_lengthLabel => 'Largo';

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
  String get packages_googleMapsLink => 'Google Maps';

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
  String get packageDescription => 'Descripcion';

  @override
  String get packages_imagesSection => 'Imagenes del paquete';

  @override
  String get packages_addImage => 'Anadir imagen';

  @override
  String get packages_noImages => 'Sin imagenes';

  @override
  String get packages_imageAdded => 'Imagen anadida correctamente';

  @override
  String get packages_imageDeleted => 'Imagen eliminada correctamente';

  @override
  String get packages_imageError => 'Error al procesar la imagen';

  @override
  String get packages_deleteImageTitle => 'Eliminar imagen';

  @override
  String get packages_deleteImageConfirm =>
      'Estas seguro de eliminar esta imagen?';

  @override
  String get packages_editPrice => 'Editar precio';

  @override
  String get packages_priceLabel => 'Precio (€)';

  @override
  String get packages_priceHint =>
      'Introduce el precio o deja vacio para calculo automatico';

  @override
  String get packages_selectAll => 'Todos';

  @override
  String packages_selectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get packages_advanceStatus => 'Avanzar';

  @override
  String packages_bulkUpdateSuccess(int count) {
    return '$count paquetes actualizados';
  }

  @override
  String get packages_filterStatus => 'Estado';

  @override
  String get packages_filterTrip => 'Viaje';

  @override
  String get packages_filterCity => 'Ciudad';

  @override
  String get packages_filterAllTrips => 'Todos los viajes';

  @override
  String get packages_filterSearchCity => 'Buscar ciudad...';

  @override
  String get packages_filterClearCities => 'Limpiar';

  @override
  String get packages_filterActiveTrips => 'ACTIVOS';

  @override
  String get packages_filterUpcomingTrips => 'PRÓXIMOS';

  @override
  String get packages_filterPastTrips => 'PASADOS';

  @override
  String packages_countShort(int count) {
    return '$count paq.';
  }

  @override
  String get packages_novaPostNumber => 'Nova Post';

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
  String get routes_editTitle => 'Editar Ruta';

  @override
  String get routes_updateSuccess => 'Ruta actualizada correctamente';

  @override
  String get routes_updateError => 'Error al actualizar la ruta';

  @override
  String get routes_editSubtitle => 'Modificar ciudades y precios';

  @override
  String get routes_deleteSubtitle => 'Eliminar esta ruta';

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
  String get routes_routeDetails => 'DETALLES DE RUTA';

  @override
  String get routes_addCountry => '+ Agregar Pais';

  @override
  String get routes_originPoint => 'Punto de Origen';

  @override
  String routes_stopN(int n) {
    return 'Parada $n';
  }

  @override
  String get routes_finalDestination => 'Destino Final';

  @override
  String get routes_addCity => 'Agregar Ciudad';

  @override
  String get routes_addStop => 'Agregar parada';

  @override
  String get routes_noIntermediateStops => 'Sin paradas intermedias';

  @override
  String get routes_deleteStop => 'eliminar';

  @override
  String get routes_pricingSection => 'PRECIOS';

  @override
  String get routes_amount => 'Monto';

  @override
  String get routes_currency => 'Moneda';

  @override
  String get routes_publishRoute => 'Publicar Ruta';

  @override
  String get routes_selectCountry => 'Selecciona pais';

  @override
  String get routes_selectCity => 'Selecciona ciudad';

  @override
  String get routes_atLeastOneCity => 'Agrega al menos una ciudad';

  @override
  String get country_germany => 'Alemania';

  @override
  String get country_poland => 'Polonia';

  @override
  String get nav_home => 'Inicio';

  @override
  String get nav_packages => 'Pedidos';

  @override
  String get nav_routes => 'Rutas';

  @override
  String get nav_contacts => 'Contactos';

  @override
  String get contacts_title => 'Contactos';

  @override
  String get contacts_search => 'Buscar por nombre, email o teléfono...';

  @override
  String get contacts_all => 'Todos';

  @override
  String get contacts_verified => 'Verificados';

  @override
  String get contacts_newContact => 'Nuevo Contacto';

  @override
  String get contacts_noContacts => 'No hay contactos';

  @override
  String get contacts_noContactsDesc =>
      'Los contactos se crearán automáticamente al crear paquetes';

  @override
  String get contacts_nameLabel => 'Nombre *';

  @override
  String get contacts_nameRequired => 'El nombre es obligatorio';

  @override
  String get contacts_emailLabel => 'Email';

  @override
  String get contacts_emailInvalid => 'Email inválido';

  @override
  String get contacts_phoneLabel => 'Teléfono';

  @override
  String get contacts_notesLabel => 'Notas';

  @override
  String get contacts_create => 'Crear';

  @override
  String get contacts_created => 'Contacto creado';

  @override
  String get contacts_createError => 'Error al crear contacto';

  @override
  String get contacts_detail => 'Detalle de Contacto';

  @override
  String get contacts_edit => 'Editar Contacto';

  @override
  String get contacts_editSubtitle => 'Modificar datos del contacto';

  @override
  String get contacts_deleteSubtitle => 'Eliminar este contacto';

  @override
  String get contacts_updated => 'Contacto actualizado';

  @override
  String get contacts_deleteTitle => 'Eliminar Contacto';

  @override
  String get contacts_deleteConfirm =>
      '¿Estás seguro de eliminar este contacto?';

  @override
  String get contacts_deleted => 'Contacto eliminado';

  @override
  String get contacts_errorLoading => 'Error al cargar contactos';

  @override
  String get contacts_errorLoadingPackages => 'Error al cargar paquetes';

  @override
  String get contacts_tabHistory => 'Histórico';

  @override
  String get contacts_tabDetails => 'Detalles';

  @override
  String get contacts_noPackages => 'Sin paquetes';

  @override
  String get contacts_noPackagesDesc =>
      'Este contacto no tiene paquetes asociados';

  @override
  String get contacts_statsSent => 'Enviados';

  @override
  String get contacts_statsReceived => 'Recibidos';

  @override
  String get contacts_statsTotal => 'Total';

  @override
  String get contacts_systemInfo => 'Información del Sistema';

  @override
  String get contacts_fieldId => 'ID';

  @override
  String get contacts_fieldCreatedBy => 'Creado por';

  @override
  String get contacts_fieldCreatedAt => 'Fecha de creación';

  @override
  String get contacts_fieldUpdatedAt => 'Última actualización';

  @override
  String get contacts_lastActivity => 'Última actividad';

  @override
  String get contacts_notes => 'Notas';

  @override
  String get contacts_linkedUser => 'Usuario vinculado';

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
  String get profile_title => 'Mi perfil';

  @override
  String get profile_name => 'Nombre';

  @override
  String get profile_nameHint => 'Tu nombre completo';

  @override
  String get profile_nameRequired => 'El nombre es requerido';

  @override
  String get profile_saveName => 'Guardar nombre';

  @override
  String get profile_nameUpdated => 'Nombre actualizado correctamente';

  @override
  String get profile_nameError => 'Error al actualizar el nombre';

  @override
  String get profile_changePassword => 'Cambiar contrasena';

  @override
  String get profile_currentPassword => 'Contrasena actual';

  @override
  String get profile_newPassword => 'Nueva contrasena';

  @override
  String get profile_confirmPassword => 'Confirmar contrasena';

  @override
  String get profile_passwordRequired => 'La contrasena es requerida';

  @override
  String get profile_passwordMinLength =>
      'La contrasena debe tener al menos 8 caracteres';

  @override
  String get profile_passwordMismatch => 'Las contrasenas no coinciden';

  @override
  String get profile_updatePassword => 'Actualizar contrasena';

  @override
  String get profile_passwordUpdated => 'Contrasena actualizada correctamente';

  @override
  String get profile_passwordError => 'Error al actualizar la contrasena';

  @override
  String get profile_changePhoto => 'Cambiar foto';

  @override
  String get profile_avatarUpdated => 'Foto de perfil actualizada';

  @override
  String get profile_avatarError => 'Error al subir la imagen';

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

  @override
  String get ocr_scanButton => 'Escanear';

  @override
  String get ocr_selectSource => 'Seleccionar origen';

  @override
  String get ocr_camera => 'Camara';

  @override
  String get ocr_gallery => 'Galeria';

  @override
  String get ocr_resultsTitle => 'Resultados del escaneo';

  @override
  String get ocr_resultsSubtitle => 'Revisa y edita los datos detectados';

  @override
  String get ocr_apply => 'Aplicar datos';

  @override
  String get ocr_error => 'Error al procesar la imagen';

  @override
  String get ocr_noDataFound =>
      'No se encontraron datos en la imagen. Intenta con otra foto mas clara.';

  @override
  String get notifications_enableTitle => 'Activa las notificaciones';

  @override
  String get notifications_enableDescription =>
      'Recibe alertas sobre tus envios y rutas';

  @override
  String get notifications_enable => 'Activar';

  @override
  String get notifications_notNow => 'Ahora no';

  @override
  String get tripsRoutes_title => 'Viajes y Rutas';

  @override
  String get tripsRoutes_trips => 'Viajes';

  @override
  String get tripsRoutes_routes => 'Rutas';

  @override
  String get tripsRoutes_noTrips => 'No hay viajes';

  @override
  String get tripsRoutes_noTripsSubtitle => 'Crea tu primer viaje';

  @override
  String get tripsRoutes_createTrip => 'Crear viaje';

  @override
  String get tripsRoutes_noRouteTemplates => 'No hay plantillas de rutas';

  @override
  String get tripsRoutes_noRouteTemplatesSubtitle =>
      'Crea una plantilla para crear viajes rápidamente';

  @override
  String get trips_sectionActive => 'ACTIVOS';

  @override
  String get trips_sectionUpcoming => 'PRÓXIMOS';

  @override
  String get trips_sectionHistory => 'HISTORIAL';

  @override
  String trips_packagesCount(int count) {
    return '$count paquetes';
  }

  @override
  String get trips_changeStatus => 'Cambiar estado';

  @override
  String get trips_retry => 'Reintentar';

  @override
  String get trips_clearFilter => 'Borrar filtro';

  @override
  String get trips_routeTemplate => 'PLANTILLA DE RUTA';

  @override
  String get trips_originPoint => 'PUNTO DE ORIGEN';

  @override
  String get trips_destinationPoint => 'PUNTO DE DESTINO';

  @override
  String get trips_departureDates => 'FECHAS DE SALIDA';

  @override
  String get trips_departureDate => 'FECHA DE SALIDA';

  @override
  String get trips_departureTimeOptional => 'HORA DE SALIDA (opcional)';

  @override
  String get trips_notesOptional => 'NOTAS (opcional)';

  @override
  String get trips_additionalInfo => 'Información adicional...';

  @override
  String get trips_selectDates => 'Selecciona fechas';

  @override
  String trips_createTripCount(int count) {
    return 'Crear $count viajes';
  }

  @override
  String get trips_selectAtLeastOneDate => 'Selecciona al menos una fecha';

  @override
  String get trips_selectTemplateOrCities =>
      'Selecciona una plantilla o indica las ciudades';

  @override
  String get trips_tripCreated => '¡Viaje creado!';

  @override
  String trips_tripsCreated(int count) {
    return '¡$count viajes creados!';
  }

  @override
  String trips_tripsPartiallyCreated(int success, int total) {
    return 'Creados $success de $total viajes';
  }

  @override
  String get trips_errorCreating => 'Error al crear viajes';

  @override
  String get trips_resetSelection => 'Resetear selección';

  @override
  String get trips_notSpecified => 'No especificado';

  @override
  String get trips_selectTemplate => 'Selecciona una plantilla';

  @override
  String get trips_noTemplate => 'Sin plantilla (introducir manualmente)';

  @override
  String get trips_errorLoadingTemplate => 'Error al cargar la plantilla';

  @override
  String get trips_cityHint => 'Ciudad';

  @override
  String get trips_weekdayMon => 'Lu';

  @override
  String get trips_weekdayTue => 'Ma';

  @override
  String get trips_weekdayWed => 'Mi';

  @override
  String get trips_weekdayThu => 'Ju';

  @override
  String get trips_weekdayFri => 'Vi';

  @override
  String get trips_weekdaySat => 'Sá';

  @override
  String get trips_weekdaySun => 'Do';

  @override
  String get trips_editTrip => 'Editar viaje';

  @override
  String get trips_editTripSubtitle => 'Modificar detalles del viaje';

  @override
  String get trips_deleteTripSubtitle => 'Eliminar este viaje';

  @override
  String get trips_tripUpdated => 'Viaje actualizado';

  @override
  String get trips_cannotDeletePast =>
      'No se puede eliminar un viaje con fecha pasada';

  @override
  String get trips_cannotDeleteWithPackages =>
      'No se puede eliminar un viaje con paquetes asignados';

  @override
  String get trips_itemTypeTrip => 'viaje';

  @override
  String get trips_itemTypeRouteTemplate => 'plantilla de ruta';

  @override
  String get trips_tripDeleted => 'Viaje eliminado';

  @override
  String get trips_tripDeleteError => 'Error al eliminar viaje';

  @override
  String get trips_routeTemplateDeleted => 'Plantilla eliminada';

  @override
  String get trips_routeTemplateDeleteError => 'Error al eliminar plantilla';

  @override
  String get myOrders_title => 'Mis Pedidos';

  @override
  String get myOrders_filterByStatus => 'Filtrar por estado';

  @override
  String get myOrders_filterAll => 'Todos';

  @override
  String get myOrders_filterPending => 'Pendiente';

  @override
  String get myOrders_filterInTransit => 'En tránsito';

  @override
  String get myOrders_filterDelivered => 'Entregado';

  @override
  String get myOrders_filterDelayed => 'Retrasado';

  @override
  String get myOrders_noOrdersFiltered => 'No hay pedidos con este estado';

  @override
  String get myOrders_noOrders => 'No tienes pedidos';

  @override
  String get myOrders_noOrdersDesc =>
      'Cuando envíes o recibas paquetes,\naparecerán aquí';

  @override
  String get myOrders_errorLoading => 'Error al cargar pedidos';

  @override
  String get myOrders_retry => 'Reintentar';

  @override
  String get myOrders_senderAndReceiver => 'Remitente y Destinatario';

  @override
  String get myOrders_youAreSender => 'Eres el Remitente';

  @override
  String get myOrders_youAreReceiver => 'Eres el Destinatario';

  @override
  String get driverPending_title => 'Solicitud en revisión';

  @override
  String get driverPending_message =>
      'Tu solicitud como conductor está siendo revisada por nuestro equipo.';

  @override
  String get driverPending_emailNotice =>
      'Te notificaremos por email cuando sea aprobada.';

  @override
  String get driverPending_verifying => 'Verificando...';

  @override
  String get driverPending_refreshStatus => 'Actualizar estado';

  @override
  String get driverPending_logout => 'Cerrar sesión';

  @override
  String get clientDashboard_title => 'Mis Envios';

  @override
  String get clientDashboard_myShipments => 'Mis envios';

  @override
  String get clientDashboard_noShipments => 'No tienes envios registrados';

  @override
  String get clientDashboard_createFirst => 'Crea tu primer envio';

  @override
  String get clientDashboard_totalShipments => 'Total enviados';

  @override
  String get clientDashboard_inTransit => 'En transito';

  @override
  String get clientDashboard_delivered => 'Entregados';

  @override
  String get clientDashboard_viewAll => 'Ver todos';

  @override
  String get admin_panelTitle => 'Panel de Admin';

  @override
  String get admin_userManagement => 'Gestión de Usuarios';

  @override
  String get admin_users => 'Usuarios';

  @override
  String get admin_requests => 'Solicitudes';

  @override
  String get admin_allUsers => 'Todos';

  @override
  String get admin_clients => 'Clientes';

  @override
  String get admin_drivers => 'Transportistas';

  @override
  String get admin_client => 'Cliente';

  @override
  String get admin_driver => 'Transportista';

  @override
  String get admin_noUsers => 'No hay usuarios';

  @override
  String get admin_loadError => 'Error al cargar datos';

  @override
  String get admin_registered => 'Registrado';

  @override
  String get admin_userSingular => 'usuario';

  @override
  String get admin_userPlural => 'usuarios';

  @override
  String get admin_clientSingular => 'cliente';

  @override
  String get admin_clientPlural => 'clientes';

  @override
  String get admin_driverSingular => 'transportista';

  @override
  String get admin_driverPlural => 'transportistas';

  @override
  String get admin_statusApproved => 'Aprobado';

  @override
  String get admin_statusPending => 'Pendiente';

  @override
  String get admin_statusRejected => 'Rechazado';

  @override
  String get admin_noPendingDrivers => 'No hay conductores pendientes';

  @override
  String get admin_allDriversReviewed =>
      'Todos los conductores han sido revisados';

  @override
  String get admin_pendingDriverSingular => 'Conductor pendiente';

  @override
  String get admin_pendingDriverPlural => 'Conductores pendientes';

  @override
  String get admin_approve => 'Aprobar';

  @override
  String get admin_reject => 'Rechazar';

  @override
  String get admin_approveDriver => 'Aprobar conductor';

  @override
  String get admin_rejectDriver => 'Rechazar conductor';

  @override
  String admin_approveConfirm(String name) {
    return '¿Estás seguro que deseas aprobar a $name como conductor? Recibirá un email de confirmación y podrá acceder a todas las funciones de la app.';
  }

  @override
  String admin_rejectConfirm(String name) {
    return '¿Estás seguro que deseas rechazar a $name como conductor? Recibirá un email notificándole del rechazo.';
  }

  @override
  String admin_driverApproved(String name) {
    return '$name ha sido aprobado';
  }

  @override
  String admin_driverRejected(String name) {
    return '$name ha sido rechazado';
  }

  @override
  String get admin_rejectReasonLabel => 'Motivo (opcional)';

  @override
  String get admin_rejectReasonHint => 'Ej: Documentación incompleta';

  @override
  String admin_registeredAgo(String time) {
    return 'Registrado $time';
  }

  @override
  String get admin_reapplication => 'Re-solicitud';

  @override
  String get admin_previousRejectionReason => 'Motivo del rechazo anterior:';

  @override
  String get admin_driverAppeal => 'Apelación del conductor:';

  @override
  String get admin_planRequests => 'Planes';

  @override
  String get admin_noPlanRequests => 'Sin solicitudes de plan';

  @override
  String get admin_noPlanRequestsSubtitle =>
      'Cuando los conductores soliciten un plan, aparecerán aquí';

  @override
  String get admin_approvePlan => 'Aprobar plan';

  @override
  String get admin_rejectPlan => 'Rechazar plan';

  @override
  String admin_approvePlanConfirm(String plan, String name) {
    return '¿Aprobar el plan $plan para $name?';
  }

  @override
  String admin_rejectPlanConfirm(String plan, String name) {
    return '¿Rechazar el plan $plan para $name?';
  }

  @override
  String admin_planApproved(String name) {
    return 'Plan aprobado para $name';
  }

  @override
  String admin_planRejected(String name) {
    return 'Plan rechazado para $name';
  }

  @override
  String get driverRejected_title => 'Solicitud rechazada';

  @override
  String get driverRejected_message =>
      'Tu solicitud como conductor ha sido rechazada.';

  @override
  String get driverRejected_reasonLabel => 'Motivo del rechazo:';

  @override
  String get driverRejected_noReasonProvided =>
      'No se proporcionó un motivo específico.';

  @override
  String get driverRejected_appealHint =>
      'Explica por qué crees que tu solicitud debería ser reconsiderada (mínimo 20 caracteres)...';

  @override
  String get driverRejected_submitAppeal => 'Enviar apelación';

  @override
  String get driverRejected_submitting => 'Enviando...';

  @override
  String get driverRejected_appealRequired => 'La apelación es requerida';

  @override
  String get driverRejected_appealMinLength =>
      'La apelación debe tener al menos 20 caracteres';

  @override
  String get driverRejected_appealSent =>
      'Apelación enviada correctamente. Tu solicitud está siendo revisada nuevamente.';

  @override
  String get driverRejected_appealError =>
      'Error al enviar la apelación. Inténtalo de nuevo.';

  @override
  String get driverRejected_appealAlreadySent =>
      'Ya has enviado una apelación. Tu solicitud está siendo revisada nuevamente.';

  @override
  String get driverRejected_logout => 'Cerrar sesión';

  @override
  String get plans_menuTitle => 'Planes y precios';

  @override
  String get plans_title => 'Elige tu plan ideal';

  @override
  String get plans_subtitle => 'Herramientas premium para tu negocio';

  @override
  String get plans_basic => 'Básico';

  @override
  String get plans_pro => 'Pro';

  @override
  String get plans_premium => 'Premium';

  @override
  String get plans_perMonth => '/mes';

  @override
  String plans_priceLabel(String name, int price) {
    return '$name — $price€/mes';
  }

  @override
  String get plans_scanner => 'Escáner';

  @override
  String get plans_sms => 'SMS';

  @override
  String get plans_shipmentHistory => 'Historial de envíos';

  @override
  String get plans_contactBook => 'Libro de contactos';

  @override
  String get plans_contactList => 'Lista de contactos';

  @override
  String plans_selectPlan(String plan) {
    return 'Solicitar plan';
  }

  @override
  String get plans_popular => 'Popular';

  @override
  String get plans_featureScanner => 'Escáner';

  @override
  String get plans_featureSms => 'Mensajes SMS';

  @override
  String get plans_featureHistory => 'Historial';

  @override
  String get plans_requestSuccess => 'Solicitud enviada correctamente';

  @override
  String get plans_requestError => 'Error al enviar la solicitud';

  @override
  String get plans_currentPlan => 'Plan actual';

  @override
  String get plans_requested => 'Solicitado';

  @override
  String get marketing_trackingTitle => 'Enviar seguimiento';

  @override
  String get marketing_trackingDesc =>
      'Informa al cliente del estado de su paquete. Genera confianza y profesionalidad';

  @override
  String marketing_trackingMessage(String name, String tracking) {
    return 'Hola $name, tu paquete $tracking está registrado y será recogido pronto. ¡Te mantendremos informado!';
  }

  @override
  String get marketing_loyaltyTitle => 'Enviar fidelización';

  @override
  String get marketing_loyaltyDesc =>
      'Ofrece un descuento y fideliza al cliente. Los clientes recurrentes son los más rentables';

  @override
  String marketing_loyaltyMessage(String name) {
    return 'Hola $name, gracias por confiar en nosotros. En tu próximo envío tienes un 10% de descuento. ¡Contáctanos cuando lo necesites!';
  }

  @override
  String get marketing_tripTitle => 'Avisar próximo viaje';

  @override
  String get marketing_tripDesc =>
      'Notifica tu próximo viaje y capta envíos. Cada mensaje puede ser un nuevo paquete';

  @override
  String marketing_tripMessage(
      String name, String origin, String destination, String date) {
    return 'Hola $name, tengo viaje $origin → $destination el $date. ¿Tienes algo para enviar? ¡Contáctame!';
  }

  @override
  String get marketing_upgradeCta => 'Desbloquear con Plan Pro';

  @override
  String get marketing_premiumFeature => 'Función Premium';

  @override
  String get marketing_noPhone => 'Sin teléfono';

  @override
  String get marketing_noPackage => 'Sin paquetes pendientes';

  @override
  String get marketing_noTrip => 'Sin viajes programados';

  @override
  String get admin_userDetail => 'Detalle de usuario';

  @override
  String get admin_personalInfo => 'Información personal';

  @override
  String get admin_userPlan => 'Plan activo';

  @override
  String get admin_userNoPlan => 'Sin plan';

  @override
  String get admin_dates => 'Fechas';

  @override
  String get admin_lastUpdate => 'Última actualización';

  @override
  String get admin_userLanguage => 'Idioma';

  @override
  String get admin_userTheme => 'Tema';

  @override
  String get admin_superAdmin => 'Administrador';
}
