import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('uk')
  ];

  /// No description provided for @common_appName.
  ///
  /// In es, this message translates to:
  /// **'vezuway.'**
  String get common_appName;

  /// No description provided for @common_appTagline.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus envios'**
  String get common_appTagline;

  /// No description provided for @common_retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get common_retry;

  /// No description provided for @common_cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get common_save;

  /// No description provided for @common_loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In es, this message translates to:
  /// **'Exito'**
  String get common_success;

  /// No description provided for @common_viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get common_viewAll;

  /// No description provided for @common_user.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get common_user;

  /// No description provided for @common_close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get common_close;

  /// No description provided for @common_confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get common_confirm;

  /// No description provided for @common_delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get common_edit;

  /// No description provided for @common_search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get common_search;

  /// No description provided for @common_noResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get common_noResults;

  /// No description provided for @common_kg.
  ///
  /// In es, this message translates to:
  /// **'kg'**
  String get common_kg;

  /// No description provided for @common_eur.
  ///
  /// In es, this message translates to:
  /// **'EUR'**
  String get common_eur;

  /// No description provided for @common_pcs.
  ///
  /// In es, this message translates to:
  /// **'uds'**
  String get common_pcs;

  /// No description provided for @common_today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get common_today;

  /// No description provided for @common_yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get common_yesterday;

  /// No description provided for @common_deleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar eliminación'**
  String get common_deleteConfirmTitle;

  /// No description provided for @common_deleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar este {itemType}?'**
  String common_deleteConfirmMessage(String itemType);

  /// No description provided for @auth_loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesion'**
  String get auth_loginTitle;

  /// No description provided for @auth_loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesion'**
  String get auth_loginButton;

  /// No description provided for @auth_emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electronico'**
  String get auth_emailLabel;

  /// No description provided for @auth_emailHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electronico'**
  String get auth_emailHint;

  /// No description provided for @auth_passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contrasena'**
  String get auth_passwordLabel;

  /// No description provided for @auth_passwordHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contrasena'**
  String get auth_passwordHint;

  /// No description provided for @auth_emailRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electronico'**
  String get auth_emailRequired;

  /// No description provided for @auth_emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo valido'**
  String get auth_emailInvalid;

  /// No description provided for @auth_passwordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contrasena'**
  String get auth_passwordRequired;

  /// No description provided for @auth_loginError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesion'**
  String get auth_loginError;

  /// No description provided for @auth_registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get auth_registerTitle;

  /// No description provided for @auth_registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus datos para registrarte'**
  String get auth_registerSubtitle;

  /// No description provided for @auth_nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get auth_nameLabel;

  /// No description provided for @auth_nameHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get auth_nameHint;

  /// No description provided for @auth_nameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get auth_nameRequired;

  /// No description provided for @auth_phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Telefono (opcional)'**
  String get auth_phoneLabel;

  /// No description provided for @auth_phoneHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu telefono'**
  String get auth_phoneHint;

  /// No description provided for @auth_confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contrasena'**
  String get auth_confirmPasswordLabel;

  /// No description provided for @auth_confirmPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contrasena'**
  String get auth_confirmPasswordHint;

  /// No description provided for @auth_confirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contrasena'**
  String get auth_confirmPasswordRequired;

  /// No description provided for @auth_passwordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contrasenas no coinciden'**
  String get auth_passwordMismatch;

  /// No description provided for @auth_passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contrasena debe tener al menos 8 caracteres'**
  String get auth_passwordMinLength;

  /// No description provided for @auth_registerButton.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get auth_registerButton;

  /// No description provided for @auth_registerError.
  ///
  /// In es, this message translates to:
  /// **'Error al registrar'**
  String get auth_registerError;

  /// No description provided for @auth_noAccount.
  ///
  /// In es, this message translates to:
  /// **'No tienes cuenta?'**
  String get auth_noAccount;

  /// No description provided for @auth_hasAccount.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes cuenta?'**
  String get auth_hasAccount;

  /// No description provided for @auth_signUp.
  ///
  /// In es, this message translates to:
  /// **'Registrate'**
  String get auth_signUp;

  /// No description provided for @auth_signIn.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesion'**
  String get auth_signIn;

  /// No description provided for @auth_continueWith.
  ///
  /// In es, this message translates to:
  /// **'o continua con'**
  String get auth_continueWith;

  /// No description provided for @auth_continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get auth_continueWithGoogle;

  /// No description provided for @auth_logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesion'**
  String get auth_logout;

  /// No description provided for @home_greeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {userName}'**
  String home_greeting(String userName);

  /// No description provided for @home_upcomingRoutes.
  ///
  /// In es, this message translates to:
  /// **'Proximas rutas'**
  String get home_upcomingRoutes;

  /// No description provided for @home_activeTrip.
  ///
  /// In es, this message translates to:
  /// **'Viaje activo'**
  String get home_activeTrip;

  /// No description provided for @home_nextTrip.
  ///
  /// In es, this message translates to:
  /// **'Proximo viaje'**
  String get home_nextTrip;

  /// No description provided for @home_noScheduledRoutes.
  ///
  /// In es, this message translates to:
  /// **'Sin rutas programadas'**
  String get home_noScheduledRoutes;

  /// No description provided for @home_createRoutePrompt.
  ///
  /// In es, this message translates to:
  /// **'Planifica tu proxima ruta'**
  String get home_createRoutePrompt;

  /// No description provided for @stats_packages.
  ///
  /// In es, this message translates to:
  /// **'Paquetes'**
  String get stats_packages;

  /// No description provided for @stats_totalWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso total'**
  String get stats_totalWeight;

  /// No description provided for @stats_declaredValue.
  ///
  /// In es, this message translates to:
  /// **'Valor'**
  String get stats_declaredValue;

  /// No description provided for @packages_title.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get packages_title;

  /// No description provided for @packages_searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar por codigo, remitente o destinatario...'**
  String get packages_searchPlaceholder;

  /// No description provided for @packages_filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get packages_filterAll;

  /// No description provided for @packages_emptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin paquetes'**
  String get packages_emptyTitle;

  /// No description provided for @packages_emptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Usa el boton + para registrar un nuevo paquete'**
  String get packages_emptyMessage;

  /// No description provided for @packages_emptyFilterTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get packages_emptyFilterTitle;

  /// No description provided for @packages_emptyFilterMessage.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron paquetes con los filtros aplicados'**
  String get packages_emptyFilterMessage;

  /// No description provided for @packages_changeStatus.
  ///
  /// In es, this message translates to:
  /// **'Cambiar estado'**
  String get packages_changeStatus;

  /// No description provided for @packages_selectNewStatus.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el nuevo estado del paquete'**
  String get packages_selectNewStatus;

  /// No description provided for @packages_detailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del Paquete'**
  String get packages_detailTitle;

  /// No description provided for @packages_trackingCode.
  ///
  /// In es, this message translates to:
  /// **'Codigo de Seguimiento'**
  String get packages_trackingCode;

  /// No description provided for @packages_codeCopied.
  ///
  /// In es, this message translates to:
  /// **'Codigo copiado'**
  String get packages_codeCopied;

  /// No description provided for @packages_weight.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get packages_weight;

  /// No description provided for @packages_dimensions.
  ///
  /// In es, this message translates to:
  /// **'Dimensiones'**
  String get packages_dimensions;

  /// No description provided for @packages_declaredValue.
  ///
  /// In es, this message translates to:
  /// **'Valor Declarado'**
  String get packages_declaredValue;

  /// No description provided for @packages_notSpecified.
  ///
  /// In es, this message translates to:
  /// **'No especificado'**
  String get packages_notSpecified;

  /// No description provided for @packages_senderReceiver.
  ///
  /// In es, this message translates to:
  /// **'Remitente y Destinatario'**
  String get packages_senderReceiver;

  /// No description provided for @packages_sender.
  ///
  /// In es, this message translates to:
  /// **'Remitente'**
  String get packages_sender;

  /// No description provided for @packages_receiver.
  ///
  /// In es, this message translates to:
  /// **'Destinatario'**
  String get packages_receiver;

  /// No description provided for @packages_details.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get packages_details;

  /// No description provided for @packages_description.
  ///
  /// In es, this message translates to:
  /// **'Descripcion'**
  String get packages_description;

  /// No description provided for @packages_notes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get packages_notes;

  /// No description provided for @packages_statusHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de Estados'**
  String get packages_statusHistory;

  /// No description provided for @packages_noHistory.
  ///
  /// In es, this message translates to:
  /// **'Sin historial'**
  String get packages_noHistory;

  /// No description provided for @packages_historyError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar historial'**
  String get packages_historyError;

  /// No description provided for @packages_historyUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Historial no disponible'**
  String get packages_historyUnavailable;

  /// No description provided for @packages_loadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el paquete'**
  String get packages_loadError;

  /// No description provided for @packages_count.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin paquetes} =1{1 paquete} other{{count} paquetes}}'**
  String packages_count(int count);

  /// No description provided for @packages_createTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Paquete'**
  String get packages_createTitle;

  /// No description provided for @packages_createNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo envío'**
  String get packages_createNew;

  /// No description provided for @packages_createSuccess.
  ///
  /// In es, this message translates to:
  /// **'Paquete creado correctamente'**
  String get packages_createSuccess;

  /// No description provided for @packages_createError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el paquete'**
  String get packages_createError;

  /// No description provided for @packages_assignRoute.
  ///
  /// In es, this message translates to:
  /// **'Asignar a ruta'**
  String get packages_assignRoute;

  /// No description provided for @packages_senderSection.
  ///
  /// In es, this message translates to:
  /// **'Remitente'**
  String get packages_senderSection;

  /// No description provided for @packages_senderNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get packages_senderNameLabel;

  /// No description provided for @packages_senderNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del remitente'**
  String get packages_senderNameHint;

  /// No description provided for @packages_nameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es requerido'**
  String get packages_nameRequired;

  /// No description provided for @packages_phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Telefono'**
  String get packages_phoneLabel;

  /// No description provided for @packages_phoneHintSpain.
  ///
  /// In es, this message translates to:
  /// **'+34 600 000 000'**
  String get packages_phoneHintSpain;

  /// No description provided for @packages_phoneHintUkraine.
  ///
  /// In es, this message translates to:
  /// **'+380 00 000 0000'**
  String get packages_phoneHintUkraine;

  /// No description provided for @packages_addressLabel.
  ///
  /// In es, this message translates to:
  /// **'Direccion'**
  String get packages_addressLabel;

  /// No description provided for @packages_pickupAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Direccion de recogida'**
  String get packages_pickupAddressHint;

  /// No description provided for @packages_receiverSection.
  ///
  /// In es, this message translates to:
  /// **'Destinatario'**
  String get packages_receiverSection;

  /// No description provided for @packages_receiverNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del destinatario'**
  String get packages_receiverNameHint;

  /// No description provided for @packages_deliveryAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Direccion de entrega'**
  String get packages_deliveryAddressHint;

  /// No description provided for @packages_detailsSection.
  ///
  /// In es, this message translates to:
  /// **'Detalles del paquete'**
  String get packages_detailsSection;

  /// No description provided for @packages_contentHint.
  ///
  /// In es, this message translates to:
  /// **'Contenido del paquete'**
  String get packages_contentHint;

  /// No description provided for @packages_weightLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get packages_weightLabel;

  /// No description provided for @packages_declaredValueLabel.
  ///
  /// In es, this message translates to:
  /// **'Valor declarado (EUR)'**
  String get packages_declaredValueLabel;

  /// No description provided for @packages_notesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get packages_notesLabel;

  /// No description provided for @packages_additionalNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Notas adicionales...'**
  String get packages_additionalNotesHint;

  /// No description provided for @packages_unassigned.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get packages_unassigned;

  /// No description provided for @packages_tabSender.
  ///
  /// In es, this message translates to:
  /// **'Remitente'**
  String get packages_tabSender;

  /// No description provided for @packages_tabReceiver.
  ///
  /// In es, this message translates to:
  /// **'Destinatario'**
  String get packages_tabReceiver;

  /// No description provided for @packages_widthLabel.
  ///
  /// In es, this message translates to:
  /// **'Ancho'**
  String get packages_widthLabel;

  /// No description provided for @packages_heightLabel.
  ///
  /// In es, this message translates to:
  /// **'Alto'**
  String get packages_heightLabel;

  /// No description provided for @packages_lengthLabel.
  ///
  /// In es, this message translates to:
  /// **'Largo'**
  String get packages_lengthLabel;

  /// No description provided for @packages_quantityLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get packages_quantityLabel;

  /// No description provided for @packages_tariffLabel.
  ///
  /// In es, this message translates to:
  /// **'TARIFA'**
  String get packages_tariffLabel;

  /// No description provided for @packages_totalPrice.
  ///
  /// In es, this message translates to:
  /// **'TOTAL'**
  String get packages_totalPrice;

  /// No description provided for @packages_noRoutesTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin rutas disponibles'**
  String get packages_noRoutesTitle;

  /// No description provided for @packages_noRoutesMessage.
  ///
  /// In es, this message translates to:
  /// **'Crea una ruta primero para poder registrar paquetes'**
  String get packages_noRoutesMessage;

  /// No description provided for @packages_createRouteButton.
  ///
  /// In es, this message translates to:
  /// **'Crear ruta'**
  String get packages_createRouteButton;

  /// No description provided for @packages_submitPackage.
  ///
  /// In es, this message translates to:
  /// **'Crear paquete'**
  String get packages_submitPackage;

  /// No description provided for @packages_addressRequired.
  ///
  /// In es, this message translates to:
  /// **'La direccion es requerida'**
  String get packages_addressRequired;

  /// No description provided for @packages_routeRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una ruta'**
  String get packages_routeRequired;

  /// No description provided for @packages_selectRoute.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar ruta'**
  String get packages_selectRoute;

  /// No description provided for @packages_volumetricWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso volumetrico'**
  String get packages_volumetricWeight;

  /// No description provided for @packages_toEurope.
  ///
  /// In es, this message translates to:
  /// **'A EUROPA'**
  String get packages_toEurope;

  /// No description provided for @packages_cityLabel.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get packages_cityLabel;

  /// No description provided for @packages_addressButton.
  ///
  /// In es, this message translates to:
  /// **'Direccion'**
  String get packages_addressButton;

  /// No description provided for @packages_deliverySection.
  ///
  /// In es, this message translates to:
  /// **'ENTREGA'**
  String get packages_deliverySection;

  /// No description provided for @packages_hide.
  ///
  /// In es, this message translates to:
  /// **'Ocultar'**
  String get packages_hide;

  /// No description provided for @packages_exactAddress.
  ///
  /// In es, this message translates to:
  /// **'Direccion exacta'**
  String get packages_exactAddress;

  /// No description provided for @packages_googleMapsLink.
  ///
  /// In es, this message translates to:
  /// **'Google Maps'**
  String get packages_googleMapsLink;

  /// No description provided for @packages_weightKg.
  ///
  /// In es, this message translates to:
  /// **'PESO (KG)'**
  String get packages_weightKg;

  /// No description provided for @packages_quantityPcs.
  ///
  /// In es, this message translates to:
  /// **'CANTIDAD (UDS)'**
  String get packages_quantityPcs;

  /// No description provided for @packages_dimensionsCm.
  ///
  /// In es, this message translates to:
  /// **'DIMENSIONES (CM)'**
  String get packages_dimensionsCm;

  /// No description provided for @packages_nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get packages_nameLabel;

  /// No description provided for @packages_cityRequired.
  ///
  /// In es, this message translates to:
  /// **'La ciudad es requerida'**
  String get packages_cityRequired;

  /// No description provided for @packages_mapsPrefix.
  ///
  /// In es, this message translates to:
  /// **'Maps'**
  String get packages_mapsPrefix;

  /// No description provided for @packages_billingWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso facturable'**
  String get packages_billingWeight;

  /// No description provided for @packages_route.
  ///
  /// In es, this message translates to:
  /// **'Ruta'**
  String get packages_route;

  /// No description provided for @packages_origin.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get packages_origin;

  /// No description provided for @packages_destination.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get packages_destination;

  /// No description provided for @packages_departureDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de salida'**
  String get packages_departureDate;

  /// No description provided for @packageDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripcion'**
  String get packageDescription;

  /// No description provided for @packages_imagesSection.
  ///
  /// In es, this message translates to:
  /// **'Imagenes del paquete'**
  String get packages_imagesSection;

  /// No description provided for @packages_addImage.
  ///
  /// In es, this message translates to:
  /// **'Anadir imagen'**
  String get packages_addImage;

  /// No description provided for @packages_noImages.
  ///
  /// In es, this message translates to:
  /// **'Sin imagenes'**
  String get packages_noImages;

  /// No description provided for @packages_imageAdded.
  ///
  /// In es, this message translates to:
  /// **'Imagen anadida correctamente'**
  String get packages_imageAdded;

  /// No description provided for @packages_imageDeleted.
  ///
  /// In es, this message translates to:
  /// **'Imagen eliminada correctamente'**
  String get packages_imageDeleted;

  /// No description provided for @packages_imageError.
  ///
  /// In es, this message translates to:
  /// **'Error al procesar la imagen'**
  String get packages_imageError;

  /// No description provided for @packages_deleteImageTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar imagen'**
  String get packages_deleteImageTitle;

  /// No description provided for @packages_deleteImageConfirm.
  ///
  /// In es, this message translates to:
  /// **'Estas seguro de eliminar esta imagen?'**
  String get packages_deleteImageConfirm;

  /// No description provided for @packages_editPrice.
  ///
  /// In es, this message translates to:
  /// **'Editar precio'**
  String get packages_editPrice;

  /// No description provided for @packages_priceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio (€)'**
  String get packages_priceLabel;

  /// No description provided for @packages_priceHint.
  ///
  /// In es, this message translates to:
  /// **'Introduce el precio o deja vacio para calculo automatico'**
  String get packages_priceHint;

  /// No description provided for @packages_selectAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get packages_selectAll;

  /// No description provided for @packages_selectedCount.
  ///
  /// In es, this message translates to:
  /// **'{count} seleccionados'**
  String packages_selectedCount(int count);

  /// No description provided for @packages_advanceStatus.
  ///
  /// In es, this message translates to:
  /// **'Avanzar'**
  String get packages_advanceStatus;

  /// No description provided for @packages_bulkUpdateSuccess.
  ///
  /// In es, this message translates to:
  /// **'{count} paquetes actualizados'**
  String packages_bulkUpdateSuccess(int count);

  /// No description provided for @packages_filterStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get packages_filterStatus;

  /// No description provided for @packages_filterTrip.
  ///
  /// In es, this message translates to:
  /// **'Viaje'**
  String get packages_filterTrip;

  /// No description provided for @packages_filterCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get packages_filterCity;

  /// No description provided for @packages_filterAllTrips.
  ///
  /// In es, this message translates to:
  /// **'Todos los viajes'**
  String get packages_filterAllTrips;

  /// No description provided for @packages_filterSearchCity.
  ///
  /// In es, this message translates to:
  /// **'Buscar ciudad...'**
  String get packages_filterSearchCity;

  /// No description provided for @packages_filterClearCities.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get packages_filterClearCities;

  /// No description provided for @packages_filterActiveTrips.
  ///
  /// In es, this message translates to:
  /// **'ACTIVOS'**
  String get packages_filterActiveTrips;

  /// No description provided for @packages_filterUpcomingTrips.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMOS'**
  String get packages_filterUpcomingTrips;

  /// No description provided for @packages_filterPastTrips.
  ///
  /// In es, this message translates to:
  /// **'PASADOS'**
  String get packages_filterPastTrips;

  /// No description provided for @packages_countShort.
  ///
  /// In es, this message translates to:
  /// **'{count} paq.'**
  String packages_countShort(int count);

  /// No description provided for @packages_novaPostNumber.
  ///
  /// In es, this message translates to:
  /// **'Nova Post'**
  String get packages_novaPostNumber;

  /// No description provided for @routes_title.
  ///
  /// In es, this message translates to:
  /// **'Rutas'**
  String get routes_title;

  /// No description provided for @routes_activeTab.
  ///
  /// In es, this message translates to:
  /// **'Activas ({count})'**
  String routes_activeTab(int count);

  /// No description provided for @routes_upcomingTab.
  ///
  /// In es, this message translates to:
  /// **'Proximas ({count})'**
  String routes_upcomingTab(int count);

  /// No description provided for @routes_historyTab.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get routes_historyTab;

  /// No description provided for @routes_emptyActive.
  ///
  /// In es, this message translates to:
  /// **'No hay rutas activas'**
  String get routes_emptyActive;

  /// No description provided for @routes_emptyActiveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las rutas en progreso apareceran aqui'**
  String get routes_emptyActiveSubtitle;

  /// No description provided for @routes_emptyPlanned.
  ///
  /// In es, this message translates to:
  /// **'No hay rutas programadas'**
  String get routes_emptyPlanned;

  /// No description provided for @routes_emptyPlannedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea una nueva ruta para empezar'**
  String get routes_emptyPlannedSubtitle;

  /// No description provided for @routes_emptyHistory.
  ///
  /// In es, this message translates to:
  /// **'Sin historial'**
  String get routes_emptyHistory;

  /// No description provided for @routes_emptyHistorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las rutas completadas apareceran aqui'**
  String get routes_emptyHistorySubtitle;

  /// No description provided for @routes_createTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva Ruta'**
  String get routes_createTitle;

  /// No description provided for @routes_originDestination.
  ///
  /// In es, this message translates to:
  /// **'Origen y Destino'**
  String get routes_originDestination;

  /// No description provided for @routes_originCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad de origen'**
  String get routes_originCity;

  /// No description provided for @routes_destinationCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad de destino'**
  String get routes_destinationCity;

  /// No description provided for @routes_originRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la ciudad de origen'**
  String get routes_originRequired;

  /// No description provided for @routes_destinationRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la ciudad de destino'**
  String get routes_destinationRequired;

  /// No description provided for @routes_departureDates.
  ///
  /// In es, this message translates to:
  /// **'Fechas de salida'**
  String get routes_departureDates;

  /// No description provided for @routes_departureDatesHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una o mas fechas en el calendario'**
  String get routes_departureDatesHint;

  /// No description provided for @routes_atLeastOneDate.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos una fecha de salida'**
  String get routes_atLeastOneDate;

  /// No description provided for @routes_tripDuration.
  ///
  /// In es, this message translates to:
  /// **'Duracion del viaje (opcional)'**
  String get routes_tripDuration;

  /// No description provided for @routes_tripDurationHint.
  ///
  /// In es, this message translates to:
  /// **'Numero de horas'**
  String get routes_tripDurationHint;

  /// No description provided for @routes_tripDurationDescription.
  ///
  /// In es, this message translates to:
  /// **'Tiempo estimado de viaje en horas'**
  String get routes_tripDurationDescription;

  /// No description provided for @routes_notesOptional.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get routes_notesOptional;

  /// No description provided for @routes_notesHint.
  ///
  /// In es, this message translates to:
  /// **'Observaciones adicionales...'**
  String get routes_notesHint;

  /// No description provided for @routes_createButton.
  ///
  /// In es, this message translates to:
  /// **'Crear Ruta'**
  String get routes_createButton;

  /// No description provided for @routes_createButtonWithDates.
  ///
  /// In es, this message translates to:
  /// **'Crear Ruta ({count} {count, plural, =1{fecha} other{fechas}})'**
  String routes_createButtonWithDates(int count);

  /// No description provided for @routes_createSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ruta creada correctamente'**
  String get routes_createSuccess;

  /// No description provided for @routes_createError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear la ruta'**
  String get routes_createError;

  /// No description provided for @routes_editTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Ruta'**
  String get routes_editTitle;

  /// No description provided for @routes_updateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ruta actualizada correctamente'**
  String get routes_updateSuccess;

  /// No description provided for @routes_updateError.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar la ruta'**
  String get routes_updateError;

  /// No description provided for @routes_selectDatesPrompt.
  ///
  /// In es, this message translates to:
  /// **'Toca los dias en el calendario para seleccionar'**
  String get routes_selectDatesPrompt;

  /// No description provided for @routes_selectedDatesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{fecha seleccionada} other{fechas seleccionadas}}'**
  String routes_selectedDatesCount(int count);

  /// No description provided for @routes_month.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get routes_month;

  /// No description provided for @routes_searchCity.
  ///
  /// In es, this message translates to:
  /// **'Buscar ciudad...'**
  String get routes_searchCity;

  /// No description provided for @routes_stopsOptional.
  ///
  /// In es, this message translates to:
  /// **'Paradas intermedias (opcional)'**
  String get routes_stopsOptional;

  /// No description provided for @routes_pricing.
  ///
  /// In es, this message translates to:
  /// **'Tarifas'**
  String get routes_pricing;

  /// No description provided for @routes_pricePerKg.
  ///
  /// In es, this message translates to:
  /// **'Precio/kg'**
  String get routes_pricePerKg;

  /// No description provided for @routes_minimumPrice.
  ///
  /// In es, this message translates to:
  /// **'Minimo'**
  String get routes_minimumPrice;

  /// No description provided for @routes_multiplier.
  ///
  /// In es, this message translates to:
  /// **'Multiplicador'**
  String get routes_multiplier;

  /// No description provided for @routes_multiplierHint.
  ///
  /// In es, this message translates to:
  /// **'Ajuste estacional (1.0 = precio base)'**
  String get routes_multiplierHint;

  /// No description provided for @routes_deleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar ruta'**
  String get routes_deleteConfirmTitle;

  /// No description provided for @routes_deleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estas seguro de eliminar esta ruta? Esta accion no se puede deshacer.'**
  String get routes_deleteConfirmMessage;

  /// No description provided for @routes_deleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ruta eliminada'**
  String get routes_deleteSuccess;

  /// No description provided for @routes_deleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar la ruta'**
  String get routes_deleteError;

  /// No description provided for @routes_routeDetails.
  ///
  /// In es, this message translates to:
  /// **'DETALLES DE RUTA'**
  String get routes_routeDetails;

  /// No description provided for @routes_addCountry.
  ///
  /// In es, this message translates to:
  /// **'+ Agregar Pais'**
  String get routes_addCountry;

  /// No description provided for @routes_originPoint.
  ///
  /// In es, this message translates to:
  /// **'Punto de Origen'**
  String get routes_originPoint;

  /// No description provided for @routes_stopN.
  ///
  /// In es, this message translates to:
  /// **'Parada {n}'**
  String routes_stopN(int n);

  /// No description provided for @routes_finalDestination.
  ///
  /// In es, this message translates to:
  /// **'Destino Final'**
  String get routes_finalDestination;

  /// No description provided for @routes_addCity.
  ///
  /// In es, this message translates to:
  /// **'Agregar Ciudad'**
  String get routes_addCity;

  /// No description provided for @routes_addStop.
  ///
  /// In es, this message translates to:
  /// **'Agregar parada'**
  String get routes_addStop;

  /// No description provided for @routes_noIntermediateStops.
  ///
  /// In es, this message translates to:
  /// **'Sin paradas intermedias'**
  String get routes_noIntermediateStops;

  /// No description provided for @routes_deleteStop.
  ///
  /// In es, this message translates to:
  /// **'eliminar'**
  String get routes_deleteStop;

  /// No description provided for @routes_pricingSection.
  ///
  /// In es, this message translates to:
  /// **'PRECIOS'**
  String get routes_pricingSection;

  /// No description provided for @routes_amount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get routes_amount;

  /// No description provided for @routes_currency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get routes_currency;

  /// No description provided for @routes_publishRoute.
  ///
  /// In es, this message translates to:
  /// **'Publicar Ruta'**
  String get routes_publishRoute;

  /// No description provided for @routes_selectCountry.
  ///
  /// In es, this message translates to:
  /// **'Selecciona pais'**
  String get routes_selectCountry;

  /// No description provided for @routes_selectCity.
  ///
  /// In es, this message translates to:
  /// **'Selecciona ciudad'**
  String get routes_selectCity;

  /// No description provided for @routes_atLeastOneCity.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos una ciudad'**
  String get routes_atLeastOneCity;

  /// No description provided for @country_germany.
  ///
  /// In es, this message translates to:
  /// **'Alemania'**
  String get country_germany;

  /// No description provided for @country_poland.
  ///
  /// In es, this message translates to:
  /// **'Polonia'**
  String get country_poland;

  /// No description provided for @nav_home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get nav_home;

  /// No description provided for @nav_packages.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get nav_packages;

  /// No description provided for @nav_routes.
  ///
  /// In es, this message translates to:
  /// **'Rutas'**
  String get nav_routes;

  /// No description provided for @nav_contacts.
  ///
  /// In es, this message translates to:
  /// **'Contactos'**
  String get nav_contacts;

  /// No description provided for @contacts_title.
  ///
  /// In es, this message translates to:
  /// **'Contactos'**
  String get contacts_title;

  /// No description provided for @contacts_search.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre, email o teléfono...'**
  String get contacts_search;

  /// No description provided for @contacts_all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get contacts_all;

  /// No description provided for @contacts_verified.
  ///
  /// In es, this message translates to:
  /// **'Verificados'**
  String get contacts_verified;

  /// No description provided for @contacts_newContact.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Contacto'**
  String get contacts_newContact;

  /// No description provided for @contacts_noContacts.
  ///
  /// In es, this message translates to:
  /// **'No hay contactos'**
  String get contacts_noContacts;

  /// No description provided for @contacts_noContactsDesc.
  ///
  /// In es, this message translates to:
  /// **'Los contactos se crearán automáticamente al crear paquetes'**
  String get contacts_noContactsDesc;

  /// No description provided for @contacts_nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get contacts_nameLabel;

  /// No description provided for @contacts_nameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get contacts_nameRequired;

  /// No description provided for @contacts_emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get contacts_emailLabel;

  /// No description provided for @contacts_emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Email inválido'**
  String get contacts_emailInvalid;

  /// No description provided for @contacts_phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get contacts_phoneLabel;

  /// No description provided for @contacts_notesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get contacts_notesLabel;

  /// No description provided for @contacts_create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get contacts_create;

  /// No description provided for @contacts_created.
  ///
  /// In es, this message translates to:
  /// **'Contacto creado'**
  String get contacts_created;

  /// No description provided for @contacts_createError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear contacto'**
  String get contacts_createError;

  /// No description provided for @contacts_detail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Contacto'**
  String get contacts_detail;

  /// No description provided for @contacts_edit.
  ///
  /// In es, this message translates to:
  /// **'Editar Contacto'**
  String get contacts_edit;

  /// No description provided for @contacts_updated.
  ///
  /// In es, this message translates to:
  /// **'Contacto actualizado'**
  String get contacts_updated;

  /// No description provided for @contacts_deleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Contacto'**
  String get contacts_deleteTitle;

  /// No description provided for @contacts_deleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar este contacto?'**
  String get contacts_deleteConfirm;

  /// No description provided for @contacts_deleted.
  ///
  /// In es, this message translates to:
  /// **'Contacto eliminado'**
  String get contacts_deleted;

  /// No description provided for @contacts_errorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar contactos'**
  String get contacts_errorLoading;

  /// No description provided for @contacts_errorLoadingPackages.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar paquetes'**
  String get contacts_errorLoadingPackages;

  /// No description provided for @contacts_tabHistory.
  ///
  /// In es, this message translates to:
  /// **'Histórico'**
  String get contacts_tabHistory;

  /// No description provided for @contacts_tabDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get contacts_tabDetails;

  /// No description provided for @contacts_noPackages.
  ///
  /// In es, this message translates to:
  /// **'Sin paquetes'**
  String get contacts_noPackages;

  /// No description provided for @contacts_noPackagesDesc.
  ///
  /// In es, this message translates to:
  /// **'Este contacto no tiene paquetes asociados'**
  String get contacts_noPackagesDesc;

  /// No description provided for @contacts_statsSent.
  ///
  /// In es, this message translates to:
  /// **'Enviados'**
  String get contacts_statsSent;

  /// No description provided for @contacts_statsReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibidos'**
  String get contacts_statsReceived;

  /// No description provided for @contacts_statsTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get contacts_statsTotal;

  /// No description provided for @contacts_systemInfo.
  ///
  /// In es, this message translates to:
  /// **'Información del Sistema'**
  String get contacts_systemInfo;

  /// No description provided for @contacts_fieldId.
  ///
  /// In es, this message translates to:
  /// **'ID'**
  String get contacts_fieldId;

  /// No description provided for @contacts_fieldCreatedBy.
  ///
  /// In es, this message translates to:
  /// **'Creado por'**
  String get contacts_fieldCreatedBy;

  /// No description provided for @contacts_fieldCreatedAt.
  ///
  /// In es, this message translates to:
  /// **'Fecha de creación'**
  String get contacts_fieldCreatedAt;

  /// No description provided for @contacts_fieldUpdatedAt.
  ///
  /// In es, this message translates to:
  /// **'Última actualización'**
  String get contacts_fieldUpdatedAt;

  /// No description provided for @contacts_lastActivity.
  ///
  /// In es, this message translates to:
  /// **'Última actividad'**
  String get contacts_lastActivity;

  /// No description provided for @contacts_notes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get contacts_notes;

  /// No description provided for @contacts_linkedUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario vinculado'**
  String get contacts_linkedUser;

  /// No description provided for @quickAction_title.
  ///
  /// In es, this message translates to:
  /// **'Crear nuevo'**
  String get quickAction_title;

  /// No description provided for @quickAction_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona que quieres registrar'**
  String get quickAction_subtitle;

  /// No description provided for @quickAction_newRoute.
  ///
  /// In es, this message translates to:
  /// **'Nueva ruta'**
  String get quickAction_newRoute;

  /// No description provided for @quickAction_newRouteSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Espana-Ucrania'**
  String get quickAction_newRouteSubtitle;

  /// No description provided for @quickAction_newPackage.
  ///
  /// In es, this message translates to:
  /// **'Nuevo paquete'**
  String get quickAction_newPackage;

  /// No description provided for @quickAction_newPackageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get quickAction_newPackageSubtitle;

  /// No description provided for @quickAction_scan.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get quickAction_scan;

  /// No description provided for @quickAction_scanSubtitle.
  ///
  /// In es, this message translates to:
  /// **'OCR'**
  String get quickAction_scanSubtitle;

  /// No description provided for @quickAction_import.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get quickAction_import;

  /// No description provided for @quickAction_importSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Excel'**
  String get quickAction_importSubtitle;

  /// No description provided for @userMenu_profile.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get userMenu_profile;

  /// No description provided for @userMenu_settings.
  ///
  /// In es, this message translates to:
  /// **'Configuracion'**
  String get userMenu_settings;

  /// No description provided for @userMenu_help.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get userMenu_help;

  /// No description provided for @userMenu_language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get userMenu_language;

  /// No description provided for @userMenu_theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get userMenu_theme;

  /// No description provided for @profile_title.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get profile_title;

  /// No description provided for @profile_name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profile_name;

  /// No description provided for @profile_nameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre completo'**
  String get profile_nameHint;

  /// No description provided for @profile_nameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es requerido'**
  String get profile_nameRequired;

  /// No description provided for @profile_saveName.
  ///
  /// In es, this message translates to:
  /// **'Guardar nombre'**
  String get profile_saveName;

  /// No description provided for @profile_nameUpdated.
  ///
  /// In es, this message translates to:
  /// **'Nombre actualizado correctamente'**
  String get profile_nameUpdated;

  /// No description provided for @profile_nameError.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar el nombre'**
  String get profile_nameError;

  /// No description provided for @profile_changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contrasena'**
  String get profile_changePassword;

  /// No description provided for @profile_currentPassword.
  ///
  /// In es, this message translates to:
  /// **'Contrasena actual'**
  String get profile_currentPassword;

  /// No description provided for @profile_newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contrasena'**
  String get profile_newPassword;

  /// No description provided for @profile_confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contrasena'**
  String get profile_confirmPassword;

  /// No description provided for @profile_passwordRequired.
  ///
  /// In es, this message translates to:
  /// **'La contrasena es requerida'**
  String get profile_passwordRequired;

  /// No description provided for @profile_passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contrasena debe tener al menos 8 caracteres'**
  String get profile_passwordMinLength;

  /// No description provided for @profile_passwordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contrasenas no coinciden'**
  String get profile_passwordMismatch;

  /// No description provided for @profile_updatePassword.
  ///
  /// In es, this message translates to:
  /// **'Actualizar contrasena'**
  String get profile_updatePassword;

  /// No description provided for @profile_passwordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contrasena actualizada correctamente'**
  String get profile_passwordUpdated;

  /// No description provided for @profile_passwordError.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar la contrasena'**
  String get profile_passwordError;

  /// No description provided for @profile_changePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get profile_changePhoto;

  /// No description provided for @profile_avatarUpdated.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil actualizada'**
  String get profile_avatarUpdated;

  /// No description provided for @profile_avatarError.
  ///
  /// In es, this message translates to:
  /// **'Error al subir la imagen'**
  String get profile_avatarError;

  /// No description provided for @status_package_registered.
  ///
  /// In es, this message translates to:
  /// **'Registrado'**
  String get status_package_registered;

  /// No description provided for @status_package_registered_desc.
  ///
  /// In es, this message translates to:
  /// **'Paquete registrado en el sistema'**
  String get status_package_registered_desc;

  /// No description provided for @status_package_inTransit.
  ///
  /// In es, this message translates to:
  /// **'En camino'**
  String get status_package_inTransit;

  /// No description provided for @status_package_inTransit_desc.
  ///
  /// In es, this message translates to:
  /// **'Enviar en ruta'**
  String get status_package_inTransit_desc;

  /// No description provided for @status_package_delivered.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get status_package_delivered;

  /// No description provided for @status_package_delivered_desc.
  ///
  /// In es, this message translates to:
  /// **'Entregar al cliente'**
  String get status_package_delivered_desc;

  /// No description provided for @status_package_delayed.
  ///
  /// In es, this message translates to:
  /// **'Retrasado'**
  String get status_package_delayed;

  /// No description provided for @status_package_delayed_desc.
  ///
  /// In es, this message translates to:
  /// **'Surgieron problemas con el envio'**
  String get status_package_delayed_desc;

  /// No description provided for @status_route_planned.
  ///
  /// In es, this message translates to:
  /// **'Planificada'**
  String get status_route_planned;

  /// No description provided for @status_route_inProgress.
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get status_route_inProgress;

  /// No description provided for @status_route_completed.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get status_route_completed;

  /// No description provided for @status_route_cancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get status_route_cancelled;

  /// No description provided for @statusChip_inTransit.
  ///
  /// In es, this message translates to:
  /// **'EN TRANSITO'**
  String get statusChip_inTransit;

  /// No description provided for @statusChip_delivered.
  ///
  /// In es, this message translates to:
  /// **'ENTREGADO'**
  String get statusChip_delivered;

  /// No description provided for @statusChip_pending.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTE'**
  String get statusChip_pending;

  /// No description provided for @statusChip_planned.
  ///
  /// In es, this message translates to:
  /// **'PLANIFICADA'**
  String get statusChip_planned;

  /// No description provided for @tripCard_driver.
  ///
  /// In es, this message translates to:
  /// **'Conductor'**
  String get tripCard_driver;

  /// No description provided for @tripCard_vehicle.
  ///
  /// In es, this message translates to:
  /// **'Mercedes Sprinter'**
  String get tripCard_vehicle;

  /// No description provided for @tripCard_spain.
  ///
  /// In es, this message translates to:
  /// **'Espana'**
  String get tripCard_spain;

  /// No description provided for @tripCard_ukraine.
  ///
  /// In es, this message translates to:
  /// **'Ucrania'**
  String get tripCard_ukraine;

  /// No description provided for @tripCard_capacity.
  ///
  /// In es, this message translates to:
  /// **'Capacidad'**
  String get tripCard_capacity;

  /// No description provided for @tripCard_perKg.
  ///
  /// In es, this message translates to:
  /// **'/kg'**
  String get tripCard_perKg;

  /// No description provided for @tripCard_deliveryCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 envio} other{{count} envios}}'**
  String tripCard_deliveryCount(int count);

  /// No description provided for @tripCard_call.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get tripCard_call;

  /// No description provided for @tripCard_message.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get tripCard_message;

  /// No description provided for @tripCard_rating.
  ///
  /// In es, this message translates to:
  /// **'Rating'**
  String get tripCard_rating;

  /// No description provided for @tripCard_deliveries.
  ///
  /// In es, this message translates to:
  /// **'Envios'**
  String get tripCard_deliveries;

  /// No description provided for @country_spain.
  ///
  /// In es, this message translates to:
  /// **'Espana'**
  String get country_spain;

  /// No description provided for @country_ukraine.
  ///
  /// In es, this message translates to:
  /// **'Ucrania'**
  String get country_ukraine;

  /// No description provided for @action_changeStatusTo.
  ///
  /// In es, this message translates to:
  /// **'Cambiar a \"{status}\"'**
  String action_changeStatusTo(String status);

  /// No description provided for @action_openMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get action_openMap;

  /// No description provided for @action_viewOnMap.
  ///
  /// In es, this message translates to:
  /// **'Ver en mapa'**
  String get action_viewOnMap;

  /// No description provided for @action_call.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get action_call;

  /// No description provided for @action_whatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get action_whatsapp;

  /// No description provided for @action_telegram.
  ///
  /// In es, this message translates to:
  /// **'Telegram'**
  String get action_telegram;

  /// No description provided for @action_viber.
  ///
  /// In es, this message translates to:
  /// **'Viber'**
  String get action_viber;

  /// No description provided for @ocr_scanButton.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get ocr_scanButton;

  /// No description provided for @ocr_selectSource.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar origen'**
  String get ocr_selectSource;

  /// No description provided for @ocr_camera.
  ///
  /// In es, this message translates to:
  /// **'Camara'**
  String get ocr_camera;

  /// No description provided for @ocr_gallery.
  ///
  /// In es, this message translates to:
  /// **'Galeria'**
  String get ocr_gallery;

  /// No description provided for @ocr_resultsTitle.
  ///
  /// In es, this message translates to:
  /// **'Resultados del escaneo'**
  String get ocr_resultsTitle;

  /// No description provided for @ocr_resultsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa y edita los datos detectados'**
  String get ocr_resultsSubtitle;

  /// No description provided for @ocr_apply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar datos'**
  String get ocr_apply;

  /// No description provided for @ocr_error.
  ///
  /// In es, this message translates to:
  /// **'Error al procesar la imagen'**
  String get ocr_error;

  /// No description provided for @ocr_noDataFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron datos en la imagen. Intenta con otra foto mas clara.'**
  String get ocr_noDataFound;

  /// No description provided for @notifications_enableTitle.
  ///
  /// In es, this message translates to:
  /// **'Activa las notificaciones'**
  String get notifications_enableTitle;

  /// No description provided for @notifications_enableDescription.
  ///
  /// In es, this message translates to:
  /// **'Recibe alertas sobre tus envios y rutas'**
  String get notifications_enableDescription;

  /// No description provided for @notifications_enable.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get notifications_enable;

  /// No description provided for @notifications_notNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get notifications_notNow;

  /// No description provided for @tripsRoutes_title.
  ///
  /// In es, this message translates to:
  /// **'Viajes y Rutas'**
  String get tripsRoutes_title;

  /// No description provided for @tripsRoutes_trips.
  ///
  /// In es, this message translates to:
  /// **'Viajes'**
  String get tripsRoutes_trips;

  /// No description provided for @tripsRoutes_routes.
  ///
  /// In es, this message translates to:
  /// **'Rutas'**
  String get tripsRoutes_routes;

  /// No description provided for @tripsRoutes_noTrips.
  ///
  /// In es, this message translates to:
  /// **'No hay viajes'**
  String get tripsRoutes_noTrips;

  /// No description provided for @tripsRoutes_noTripsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer viaje'**
  String get tripsRoutes_noTripsSubtitle;

  /// No description provided for @tripsRoutes_createTrip.
  ///
  /// In es, this message translates to:
  /// **'Crear viaje'**
  String get tripsRoutes_createTrip;

  /// No description provided for @tripsRoutes_noRouteTemplates.
  ///
  /// In es, this message translates to:
  /// **'No hay plantillas de rutas'**
  String get tripsRoutes_noRouteTemplates;

  /// No description provided for @tripsRoutes_noRouteTemplatesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea una plantilla para crear viajes rápidamente'**
  String get tripsRoutes_noRouteTemplatesSubtitle;

  /// No description provided for @trips_sectionActive.
  ///
  /// In es, this message translates to:
  /// **'ACTIVOS'**
  String get trips_sectionActive;

  /// No description provided for @trips_sectionUpcoming.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMOS'**
  String get trips_sectionUpcoming;

  /// No description provided for @trips_sectionHistory.
  ///
  /// In es, this message translates to:
  /// **'HISTORIAL'**
  String get trips_sectionHistory;

  /// No description provided for @trips_packagesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} paquetes'**
  String trips_packagesCount(int count);

  /// No description provided for @trips_changeStatus.
  ///
  /// In es, this message translates to:
  /// **'Cambiar estado'**
  String get trips_changeStatus;

  /// No description provided for @trips_retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get trips_retry;

  /// No description provided for @trips_clearFilter.
  ///
  /// In es, this message translates to:
  /// **'Borrar filtro'**
  String get trips_clearFilter;

  /// No description provided for @trips_routeTemplate.
  ///
  /// In es, this message translates to:
  /// **'PLANTILLA DE RUTA'**
  String get trips_routeTemplate;

  /// No description provided for @trips_originPoint.
  ///
  /// In es, this message translates to:
  /// **'PUNTO DE ORIGEN'**
  String get trips_originPoint;

  /// No description provided for @trips_destinationPoint.
  ///
  /// In es, this message translates to:
  /// **'PUNTO DE DESTINO'**
  String get trips_destinationPoint;

  /// No description provided for @trips_departureDates.
  ///
  /// In es, this message translates to:
  /// **'FECHAS DE SALIDA'**
  String get trips_departureDates;

  /// No description provided for @trips_departureDate.
  ///
  /// In es, this message translates to:
  /// **'FECHA DE SALIDA'**
  String get trips_departureDate;

  /// No description provided for @trips_departureTimeOptional.
  ///
  /// In es, this message translates to:
  /// **'HORA DE SALIDA (opcional)'**
  String get trips_departureTimeOptional;

  /// No description provided for @trips_notesOptional.
  ///
  /// In es, this message translates to:
  /// **'NOTAS (opcional)'**
  String get trips_notesOptional;

  /// No description provided for @trips_additionalInfo.
  ///
  /// In es, this message translates to:
  /// **'Información adicional...'**
  String get trips_additionalInfo;

  /// No description provided for @trips_selectDates.
  ///
  /// In es, this message translates to:
  /// **'Selecciona fechas'**
  String get trips_selectDates;

  /// No description provided for @trips_createTripCount.
  ///
  /// In es, this message translates to:
  /// **'Crear {count} viajes'**
  String trips_createTripCount(int count);

  /// No description provided for @trips_selectAtLeastOneDate.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos una fecha'**
  String get trips_selectAtLeastOneDate;

  /// No description provided for @trips_selectTemplateOrCities.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una plantilla o indica las ciudades'**
  String get trips_selectTemplateOrCities;

  /// No description provided for @trips_tripCreated.
  ///
  /// In es, this message translates to:
  /// **'¡Viaje creado!'**
  String get trips_tripCreated;

  /// No description provided for @trips_tripsCreated.
  ///
  /// In es, this message translates to:
  /// **'¡{count} viajes creados!'**
  String trips_tripsCreated(int count);

  /// No description provided for @trips_tripsPartiallyCreated.
  ///
  /// In es, this message translates to:
  /// **'Creados {success} de {total} viajes'**
  String trips_tripsPartiallyCreated(int success, int total);

  /// No description provided for @trips_errorCreating.
  ///
  /// In es, this message translates to:
  /// **'Error al crear viajes'**
  String get trips_errorCreating;

  /// No description provided for @trips_resetSelection.
  ///
  /// In es, this message translates to:
  /// **'Resetear selección'**
  String get trips_resetSelection;

  /// No description provided for @trips_notSpecified.
  ///
  /// In es, this message translates to:
  /// **'No especificado'**
  String get trips_notSpecified;

  /// No description provided for @trips_selectTemplate.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una plantilla'**
  String get trips_selectTemplate;

  /// No description provided for @trips_noTemplate.
  ///
  /// In es, this message translates to:
  /// **'Sin plantilla (introducir manualmente)'**
  String get trips_noTemplate;

  /// No description provided for @trips_errorLoadingTemplate.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar la plantilla'**
  String get trips_errorLoadingTemplate;

  /// No description provided for @trips_cityHint.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get trips_cityHint;

  /// No description provided for @trips_weekdayMon.
  ///
  /// In es, this message translates to:
  /// **'Lu'**
  String get trips_weekdayMon;

  /// No description provided for @trips_weekdayTue.
  ///
  /// In es, this message translates to:
  /// **'Ma'**
  String get trips_weekdayTue;

  /// No description provided for @trips_weekdayWed.
  ///
  /// In es, this message translates to:
  /// **'Mi'**
  String get trips_weekdayWed;

  /// No description provided for @trips_weekdayThu.
  ///
  /// In es, this message translates to:
  /// **'Ju'**
  String get trips_weekdayThu;

  /// No description provided for @trips_weekdayFri.
  ///
  /// In es, this message translates to:
  /// **'Vi'**
  String get trips_weekdayFri;

  /// No description provided for @trips_weekdaySat.
  ///
  /// In es, this message translates to:
  /// **'Sá'**
  String get trips_weekdaySat;

  /// No description provided for @trips_weekdaySun.
  ///
  /// In es, this message translates to:
  /// **'Do'**
  String get trips_weekdaySun;

  /// No description provided for @trips_editTrip.
  ///
  /// In es, this message translates to:
  /// **'Editar viaje'**
  String get trips_editTrip;

  /// No description provided for @trips_editTripSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Modificar detalles del viaje'**
  String get trips_editTripSubtitle;

  /// No description provided for @trips_deleteTripSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar este viaje'**
  String get trips_deleteTripSubtitle;

  /// No description provided for @trips_tripUpdated.
  ///
  /// In es, this message translates to:
  /// **'Viaje actualizado'**
  String get trips_tripUpdated;

  /// No description provided for @trips_cannotDeletePast.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar un viaje con fecha pasada'**
  String get trips_cannotDeletePast;

  /// No description provided for @trips_cannotDeleteWithPackages.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar un viaje con paquetes asignados'**
  String get trips_cannotDeleteWithPackages;

  /// No description provided for @trips_itemTypeTrip.
  ///
  /// In es, this message translates to:
  /// **'viaje'**
  String get trips_itemTypeTrip;

  /// No description provided for @trips_itemTypeRouteTemplate.
  ///
  /// In es, this message translates to:
  /// **'plantilla de ruta'**
  String get trips_itemTypeRouteTemplate;

  /// No description provided for @trips_tripDeleted.
  ///
  /// In es, this message translates to:
  /// **'Viaje eliminado'**
  String get trips_tripDeleted;

  /// No description provided for @trips_tripDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar viaje'**
  String get trips_tripDeleteError;

  /// No description provided for @trips_routeTemplateDeleted.
  ///
  /// In es, this message translates to:
  /// **'Plantilla eliminada'**
  String get trips_routeTemplateDeleted;

  /// No description provided for @trips_routeTemplateDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar plantilla'**
  String get trips_routeTemplateDeleteError;

  /// No description provided for @myOrders_title.
  ///
  /// In es, this message translates to:
  /// **'Mis Pedidos'**
  String get myOrders_title;

  /// No description provided for @myOrders_filterByStatus.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por estado'**
  String get myOrders_filterByStatus;

  /// No description provided for @myOrders_filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get myOrders_filterAll;

  /// No description provided for @myOrders_filterPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get myOrders_filterPending;

  /// No description provided for @myOrders_filterInTransit.
  ///
  /// In es, this message translates to:
  /// **'En tránsito'**
  String get myOrders_filterInTransit;

  /// No description provided for @myOrders_filterDelivered.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get myOrders_filterDelivered;

  /// No description provided for @myOrders_filterDelayed.
  ///
  /// In es, this message translates to:
  /// **'Retrasado'**
  String get myOrders_filterDelayed;

  /// No description provided for @myOrders_noOrdersFiltered.
  ///
  /// In es, this message translates to:
  /// **'No hay pedidos con este estado'**
  String get myOrders_noOrdersFiltered;

  /// No description provided for @myOrders_noOrders.
  ///
  /// In es, this message translates to:
  /// **'No tienes pedidos'**
  String get myOrders_noOrders;

  /// No description provided for @myOrders_noOrdersDesc.
  ///
  /// In es, this message translates to:
  /// **'Cuando envíes o recibas paquetes,\naparecerán aquí'**
  String get myOrders_noOrdersDesc;

  /// No description provided for @myOrders_errorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar pedidos'**
  String get myOrders_errorLoading;

  /// No description provided for @myOrders_retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get myOrders_retry;

  /// No description provided for @myOrders_senderAndReceiver.
  ///
  /// In es, this message translates to:
  /// **'Remitente y Destinatario'**
  String get myOrders_senderAndReceiver;

  /// No description provided for @myOrders_youAreSender.
  ///
  /// In es, this message translates to:
  /// **'Eres el Remitente'**
  String get myOrders_youAreSender;

  /// No description provided for @myOrders_youAreReceiver.
  ///
  /// In es, this message translates to:
  /// **'Eres el Destinatario'**
  String get myOrders_youAreReceiver;

  /// No description provided for @driverPending_title.
  ///
  /// In es, this message translates to:
  /// **'Solicitud en revisión'**
  String get driverPending_title;

  /// No description provided for @driverPending_message.
  ///
  /// In es, this message translates to:
  /// **'Tu solicitud como conductor está siendo revisada por nuestro equipo.'**
  String get driverPending_message;

  /// No description provided for @driverPending_emailNotice.
  ///
  /// In es, this message translates to:
  /// **'Te notificaremos por email cuando sea aprobada.'**
  String get driverPending_emailNotice;

  /// No description provided for @driverPending_verifying.
  ///
  /// In es, this message translates to:
  /// **'Verificando...'**
  String get driverPending_verifying;

  /// No description provided for @driverPending_refreshStatus.
  ///
  /// In es, this message translates to:
  /// **'Actualizar estado'**
  String get driverPending_refreshStatus;

  /// No description provided for @driverPending_logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get driverPending_logout;

  /// No description provided for @clientDashboard_title.
  ///
  /// In es, this message translates to:
  /// **'Mis Envios'**
  String get clientDashboard_title;

  /// No description provided for @clientDashboard_myShipments.
  ///
  /// In es, this message translates to:
  /// **'Mis envios'**
  String get clientDashboard_myShipments;

  /// No description provided for @clientDashboard_noShipments.
  ///
  /// In es, this message translates to:
  /// **'No tienes envios registrados'**
  String get clientDashboard_noShipments;

  /// No description provided for @clientDashboard_createFirst.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer envio'**
  String get clientDashboard_createFirst;

  /// No description provided for @clientDashboard_totalShipments.
  ///
  /// In es, this message translates to:
  /// **'Total enviados'**
  String get clientDashboard_totalShipments;

  /// No description provided for @clientDashboard_inTransit.
  ///
  /// In es, this message translates to:
  /// **'En transito'**
  String get clientDashboard_inTransit;

  /// No description provided for @clientDashboard_delivered.
  ///
  /// In es, this message translates to:
  /// **'Entregados'**
  String get clientDashboard_delivered;

  /// No description provided for @clientDashboard_viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get clientDashboard_viewAll;

  /// No description provided for @admin_panelTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel de Admin'**
  String get admin_panelTitle;

  /// No description provided for @admin_userManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Usuarios'**
  String get admin_userManagement;

  /// No description provided for @admin_users.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get admin_users;

  /// No description provided for @admin_requests.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get admin_requests;

  /// No description provided for @admin_allUsers.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get admin_allUsers;

  /// No description provided for @admin_clients.
  ///
  /// In es, this message translates to:
  /// **'Clientes'**
  String get admin_clients;

  /// No description provided for @admin_drivers.
  ///
  /// In es, this message translates to:
  /// **'Transportistas'**
  String get admin_drivers;

  /// No description provided for @admin_client.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get admin_client;

  /// No description provided for @admin_driver.
  ///
  /// In es, this message translates to:
  /// **'Transportista'**
  String get admin_driver;

  /// No description provided for @admin_noUsers.
  ///
  /// In es, this message translates to:
  /// **'No hay usuarios'**
  String get admin_noUsers;

  /// No description provided for @admin_loadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar datos'**
  String get admin_loadError;

  /// No description provided for @admin_registered.
  ///
  /// In es, this message translates to:
  /// **'Registrado'**
  String get admin_registered;

  /// No description provided for @admin_userSingular.
  ///
  /// In es, this message translates to:
  /// **'usuario'**
  String get admin_userSingular;

  /// No description provided for @admin_userPlural.
  ///
  /// In es, this message translates to:
  /// **'usuarios'**
  String get admin_userPlural;

  /// No description provided for @admin_clientSingular.
  ///
  /// In es, this message translates to:
  /// **'cliente'**
  String get admin_clientSingular;

  /// No description provided for @admin_clientPlural.
  ///
  /// In es, this message translates to:
  /// **'clientes'**
  String get admin_clientPlural;

  /// No description provided for @admin_driverSingular.
  ///
  /// In es, this message translates to:
  /// **'transportista'**
  String get admin_driverSingular;

  /// No description provided for @admin_driverPlural.
  ///
  /// In es, this message translates to:
  /// **'transportistas'**
  String get admin_driverPlural;

  /// No description provided for @admin_statusApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get admin_statusApproved;

  /// No description provided for @admin_statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get admin_statusPending;

  /// No description provided for @admin_statusRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get admin_statusRejected;

  /// No description provided for @admin_noPendingDrivers.
  ///
  /// In es, this message translates to:
  /// **'No hay conductores pendientes'**
  String get admin_noPendingDrivers;

  /// No description provided for @admin_allDriversReviewed.
  ///
  /// In es, this message translates to:
  /// **'Todos los conductores han sido revisados'**
  String get admin_allDriversReviewed;

  /// No description provided for @admin_pendingDriverSingular.
  ///
  /// In es, this message translates to:
  /// **'Conductor pendiente'**
  String get admin_pendingDriverSingular;

  /// No description provided for @admin_pendingDriverPlural.
  ///
  /// In es, this message translates to:
  /// **'Conductores pendientes'**
  String get admin_pendingDriverPlural;

  /// No description provided for @admin_approve.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get admin_approve;

  /// No description provided for @admin_reject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get admin_reject;

  /// No description provided for @admin_approveDriver.
  ///
  /// In es, this message translates to:
  /// **'Aprobar conductor'**
  String get admin_approveDriver;

  /// No description provided for @admin_rejectDriver.
  ///
  /// In es, this message translates to:
  /// **'Rechazar conductor'**
  String get admin_rejectDriver;

  /// No description provided for @admin_approveConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro que deseas aprobar a {name} como conductor? Recibirá un email de confirmación y podrá acceder a todas las funciones de la app.'**
  String admin_approveConfirm(String name);

  /// No description provided for @admin_rejectConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro que deseas rechazar a {name} como conductor? Recibirá un email notificándole del rechazo.'**
  String admin_rejectConfirm(String name);

  /// No description provided for @admin_driverApproved.
  ///
  /// In es, this message translates to:
  /// **'{name} ha sido aprobado'**
  String admin_driverApproved(String name);

  /// No description provided for @admin_driverRejected.
  ///
  /// In es, this message translates to:
  /// **'{name} ha sido rechazado'**
  String admin_driverRejected(String name);

  /// No description provided for @admin_rejectReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo (opcional)'**
  String get admin_rejectReasonLabel;

  /// No description provided for @admin_rejectReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Documentación incompleta'**
  String get admin_rejectReasonHint;

  /// No description provided for @admin_registeredAgo.
  ///
  /// In es, this message translates to:
  /// **'Registrado {time}'**
  String admin_registeredAgo(String time);

  /// No description provided for @admin_reapplication.
  ///
  /// In es, this message translates to:
  /// **'Re-solicitud'**
  String get admin_reapplication;

  /// No description provided for @admin_previousRejectionReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo del rechazo anterior:'**
  String get admin_previousRejectionReason;

  /// No description provided for @admin_driverAppeal.
  ///
  /// In es, this message translates to:
  /// **'Apelación del conductor:'**
  String get admin_driverAppeal;

  /// No description provided for @admin_planRequests.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get admin_planRequests;

  /// No description provided for @admin_noPlanRequests.
  ///
  /// In es, this message translates to:
  /// **'Sin solicitudes de plan'**
  String get admin_noPlanRequests;

  /// No description provided for @admin_noPlanRequestsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cuando los conductores soliciten un plan, aparecerán aquí'**
  String get admin_noPlanRequestsSubtitle;

  /// No description provided for @admin_approvePlan.
  ///
  /// In es, this message translates to:
  /// **'Aprobar plan'**
  String get admin_approvePlan;

  /// No description provided for @admin_rejectPlan.
  ///
  /// In es, this message translates to:
  /// **'Rechazar plan'**
  String get admin_rejectPlan;

  /// No description provided for @admin_approvePlanConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Aprobar el plan {plan} para {name}?'**
  String admin_approvePlanConfirm(String plan, String name);

  /// No description provided for @admin_rejectPlanConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Rechazar el plan {plan} para {name}?'**
  String admin_rejectPlanConfirm(String plan, String name);

  /// No description provided for @admin_planApproved.
  ///
  /// In es, this message translates to:
  /// **'Plan aprobado para {name}'**
  String admin_planApproved(String name);

  /// No description provided for @admin_planRejected.
  ///
  /// In es, this message translates to:
  /// **'Plan rechazado para {name}'**
  String admin_planRejected(String name);

  /// No description provided for @driverRejected_title.
  ///
  /// In es, this message translates to:
  /// **'Solicitud rechazada'**
  String get driverRejected_title;

  /// No description provided for @driverRejected_message.
  ///
  /// In es, this message translates to:
  /// **'Tu solicitud como conductor ha sido rechazada.'**
  String get driverRejected_message;

  /// No description provided for @driverRejected_reasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo del rechazo:'**
  String get driverRejected_reasonLabel;

  /// No description provided for @driverRejected_noReasonProvided.
  ///
  /// In es, this message translates to:
  /// **'No se proporcionó un motivo específico.'**
  String get driverRejected_noReasonProvided;

  /// No description provided for @driverRejected_appealHint.
  ///
  /// In es, this message translates to:
  /// **'Explica por qué crees que tu solicitud debería ser reconsiderada (mínimo 20 caracteres)...'**
  String get driverRejected_appealHint;

  /// No description provided for @driverRejected_submitAppeal.
  ///
  /// In es, this message translates to:
  /// **'Enviar apelación'**
  String get driverRejected_submitAppeal;

  /// No description provided for @driverRejected_submitting.
  ///
  /// In es, this message translates to:
  /// **'Enviando...'**
  String get driverRejected_submitting;

  /// No description provided for @driverRejected_appealRequired.
  ///
  /// In es, this message translates to:
  /// **'La apelación es requerida'**
  String get driverRejected_appealRequired;

  /// No description provided for @driverRejected_appealMinLength.
  ///
  /// In es, this message translates to:
  /// **'La apelación debe tener al menos 20 caracteres'**
  String get driverRejected_appealMinLength;

  /// No description provided for @driverRejected_appealSent.
  ///
  /// In es, this message translates to:
  /// **'Apelación enviada correctamente. Tu solicitud está siendo revisada nuevamente.'**
  String get driverRejected_appealSent;

  /// No description provided for @driverRejected_appealError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar la apelación. Inténtalo de nuevo.'**
  String get driverRejected_appealError;

  /// No description provided for @driverRejected_appealAlreadySent.
  ///
  /// In es, this message translates to:
  /// **'Ya has enviado una apelación. Tu solicitud está siendo revisada nuevamente.'**
  String get driverRejected_appealAlreadySent;

  /// No description provided for @driverRejected_logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get driverRejected_logout;

  /// No description provided for @plans_menuTitle.
  ///
  /// In es, this message translates to:
  /// **'Planes y precios'**
  String get plans_menuTitle;

  /// No description provided for @plans_title.
  ///
  /// In es, this message translates to:
  /// **'Elige tu plan ideal'**
  String get plans_title;

  /// No description provided for @plans_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Herramientas premium para tu negocio'**
  String get plans_subtitle;

  /// No description provided for @plans_basic.
  ///
  /// In es, this message translates to:
  /// **'Básico'**
  String get plans_basic;

  /// No description provided for @plans_pro.
  ///
  /// In es, this message translates to:
  /// **'Pro'**
  String get plans_pro;

  /// No description provided for @plans_premium.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get plans_premium;

  /// No description provided for @plans_perMonth.
  ///
  /// In es, this message translates to:
  /// **'/mes'**
  String get plans_perMonth;

  /// No description provided for @plans_priceLabel.
  ///
  /// In es, this message translates to:
  /// **'{name} — {price}€/mes'**
  String plans_priceLabel(String name, int price);

  /// No description provided for @plans_scanner.
  ///
  /// In es, this message translates to:
  /// **'Escáner'**
  String get plans_scanner;

  /// No description provided for @plans_sms.
  ///
  /// In es, this message translates to:
  /// **'SMS'**
  String get plans_sms;

  /// No description provided for @plans_shipmentHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de envíos'**
  String get plans_shipmentHistory;

  /// No description provided for @plans_contactBook.
  ///
  /// In es, this message translates to:
  /// **'Libro de contactos'**
  String get plans_contactBook;

  /// No description provided for @plans_contactList.
  ///
  /// In es, this message translates to:
  /// **'Lista de contactos'**
  String get plans_contactList;

  /// No description provided for @plans_selectPlan.
  ///
  /// In es, this message translates to:
  /// **'Solicitar plan'**
  String plans_selectPlan(String plan);

  /// No description provided for @plans_popular.
  ///
  /// In es, this message translates to:
  /// **'Popular'**
  String get plans_popular;

  /// No description provided for @plans_featureScanner.
  ///
  /// In es, this message translates to:
  /// **'Escáner'**
  String get plans_featureScanner;

  /// No description provided for @plans_featureSms.
  ///
  /// In es, this message translates to:
  /// **'Mensajes SMS'**
  String get plans_featureSms;

  /// No description provided for @plans_featureHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get plans_featureHistory;

  /// No description provided for @plans_requestSuccess.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada correctamente'**
  String get plans_requestSuccess;

  /// No description provided for @plans_requestError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar la solicitud'**
  String get plans_requestError;

  /// No description provided for @plans_currentPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan actual'**
  String get plans_currentPlan;

  /// No description provided for @plans_requested.
  ///
  /// In es, this message translates to:
  /// **'Solicitado'**
  String get plans_requested;

  /// No description provided for @marketing_trackingTitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar seguimiento'**
  String get marketing_trackingTitle;

  /// No description provided for @marketing_trackingDesc.
  ///
  /// In es, this message translates to:
  /// **'Informa al cliente del estado de su paquete. Genera confianza y profesionalidad'**
  String get marketing_trackingDesc;

  /// No description provided for @marketing_trackingMessage.
  ///
  /// In es, this message translates to:
  /// **'Hola {name}, tu paquete {tracking} está registrado y será recogido pronto. ¡Te mantendremos informado!'**
  String marketing_trackingMessage(String name, String tracking);

  /// No description provided for @marketing_loyaltyTitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar fidelización'**
  String get marketing_loyaltyTitle;

  /// No description provided for @marketing_loyaltyDesc.
  ///
  /// In es, this message translates to:
  /// **'Ofrece un descuento y fideliza al cliente. Los clientes recurrentes son los más rentables'**
  String get marketing_loyaltyDesc;

  /// No description provided for @marketing_loyaltyMessage.
  ///
  /// In es, this message translates to:
  /// **'Hola {name}, gracias por confiar en nosotros. En tu próximo envío tienes un 10% de descuento. ¡Contáctanos cuando lo necesites!'**
  String marketing_loyaltyMessage(String name);

  /// No description provided for @marketing_tripTitle.
  ///
  /// In es, this message translates to:
  /// **'Avisar próximo viaje'**
  String get marketing_tripTitle;

  /// No description provided for @marketing_tripDesc.
  ///
  /// In es, this message translates to:
  /// **'Notifica tu próximo viaje y capta envíos. Cada mensaje puede ser un nuevo paquete'**
  String get marketing_tripDesc;

  /// No description provided for @marketing_tripMessage.
  ///
  /// In es, this message translates to:
  /// **'Hola {name}, tengo viaje {origin} → {destination} el {date}. ¿Tienes algo para enviar? ¡Contáctame!'**
  String marketing_tripMessage(
      String name, String origin, String destination, String date);

  /// No description provided for @marketing_upgradeCta.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear con Plan Pro'**
  String get marketing_upgradeCta;

  /// No description provided for @marketing_premiumFeature.
  ///
  /// In es, this message translates to:
  /// **'Función Premium'**
  String get marketing_premiumFeature;

  /// No description provided for @marketing_noPhone.
  ///
  /// In es, this message translates to:
  /// **'Sin teléfono'**
  String get marketing_noPhone;

  /// No description provided for @marketing_noPackage.
  ///
  /// In es, this message translates to:
  /// **'Sin paquetes pendientes'**
  String get marketing_noPackage;

  /// No description provided for @marketing_noTrip.
  ///
  /// In es, this message translates to:
  /// **'Sin viajes programados'**
  String get marketing_noTrip;

  /// No description provided for @admin_userDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de usuario'**
  String get admin_userDetail;

  /// No description provided for @admin_personalInfo.
  ///
  /// In es, this message translates to:
  /// **'Información personal'**
  String get admin_personalInfo;

  /// No description provided for @admin_userPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan activo'**
  String get admin_userPlan;

  /// No description provided for @admin_userNoPlan.
  ///
  /// In es, this message translates to:
  /// **'Sin plan'**
  String get admin_userNoPlan;

  /// No description provided for @admin_dates.
  ///
  /// In es, this message translates to:
  /// **'Fechas'**
  String get admin_dates;

  /// No description provided for @admin_lastUpdate.
  ///
  /// In es, this message translates to:
  /// **'Última actualización'**
  String get admin_lastUpdate;

  /// No description provided for @admin_userLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get admin_userLanguage;

  /// No description provided for @admin_userTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get admin_userTheme;

  /// No description provided for @admin_superAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get admin_superAdmin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
