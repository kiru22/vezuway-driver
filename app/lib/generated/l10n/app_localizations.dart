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

  /// No description provided for @packages_weight.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get packages_weight;

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
  /// **'An'**
  String get packages_widthLabel;

  /// No description provided for @packages_heightLabel.
  ///
  /// In es, this message translates to:
  /// **'Al'**
  String get packages_heightLabel;

  /// No description provided for @packages_lengthLabel.
  ///
  /// In es, this message translates to:
  /// **'La'**
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
  /// **'Enlace a Google Maps'**
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

  /// No description provided for @status_package_pending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get status_package_pending;

  /// No description provided for @status_package_pickedUp.
  ///
  /// In es, this message translates to:
  /// **'Recogido'**
  String get status_package_pickedUp;

  /// No description provided for @status_package_inTransit.
  ///
  /// In es, this message translates to:
  /// **'En transito'**
  String get status_package_inTransit;

  /// No description provided for @status_package_inWarehouse.
  ///
  /// In es, this message translates to:
  /// **'En almacen'**
  String get status_package_inWarehouse;

  /// No description provided for @status_package_outForDelivery.
  ///
  /// In es, this message translates to:
  /// **'En reparto'**
  String get status_package_outForDelivery;

  /// No description provided for @status_package_delivered.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get status_package_delivered;

  /// No description provided for @status_package_cancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get status_package_cancelled;

  /// No description provided for @status_package_returned.
  ///
  /// In es, this message translates to:
  /// **'Devuelto'**
  String get status_package_returned;

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
