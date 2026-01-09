// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get common_appName => 'vezuway.';

  @override
  String get common_appTagline => 'Керуй доставками';

  @override
  String get common_retry => 'Повторити';

  @override
  String get common_cancel => 'Скасувати';

  @override
  String get common_save => 'Зберегти';

  @override
  String get common_loading => 'Завантаження...';

  @override
  String get common_error => 'Помилка';

  @override
  String get common_success => 'Успiх';

  @override
  String get common_viewAll => 'Переглянути всi';

  @override
  String get common_user => 'Користувач';

  @override
  String get common_close => 'Закрити';

  @override
  String get common_confirm => 'Пiдтвердити';

  @override
  String get common_delete => 'Видалити';

  @override
  String get common_edit => 'Редагувати';

  @override
  String get common_search => 'Шукати';

  @override
  String get common_noResults => 'Немає результатiв';

  @override
  String get common_kg => 'кг';

  @override
  String get common_eur => 'EUR';

  @override
  String get auth_loginTitle => 'Увiйти';

  @override
  String get auth_loginButton => 'Увiйти';

  @override
  String get auth_emailLabel => 'Електронна пошта';

  @override
  String get auth_emailHint => 'Введiть електронну пошту';

  @override
  String get auth_passwordLabel => 'Пароль';

  @override
  String get auth_passwordHint => 'Введiть пароль';

  @override
  String get auth_emailRequired => 'Введiть електронну пошту';

  @override
  String get auth_emailInvalid => 'Введiть дiйсну електронну пошту';

  @override
  String get auth_passwordRequired => 'Введiть пароль';

  @override
  String get auth_loginError => 'Помилка входу';

  @override
  String get auth_registerTitle => 'Створити акаунт';

  @override
  String get auth_registerSubtitle => 'Введiть вашi данi для реєстрацiї';

  @override
  String get auth_nameLabel => 'Повне iм\'я';

  @override
  String get auth_nameHint => 'Введiть ваше iм\'я';

  @override
  String get auth_nameRequired => 'Введiть ваше iм\'я';

  @override
  String get auth_phoneLabel => 'Телефон (необов\'язково)';

  @override
  String get auth_phoneHint => 'Введiть телефон';

  @override
  String get auth_confirmPasswordLabel => 'Пiдтвердити пароль';

  @override
  String get auth_confirmPasswordHint => 'Пiдтвердiть пароль';

  @override
  String get auth_confirmPasswordRequired => 'Пiдтвердiть пароль';

  @override
  String get auth_passwordMismatch => 'Паролi не спiвпадають';

  @override
  String get auth_passwordMinLength =>
      'Пароль повинен мiстити не менше 8 символiв';

  @override
  String get auth_registerButton => 'Створити акаунт';

  @override
  String get auth_registerError => 'Помилка реєстрацiї';

  @override
  String get auth_noAccount => 'Немає акаунту?';

  @override
  String get auth_hasAccount => 'Вже є акаунт?';

  @override
  String get auth_signUp => 'Зареєструватися';

  @override
  String get auth_signIn => 'Увiйти';

  @override
  String get auth_continueWith => 'або продовжити через';

  @override
  String get auth_continueWithGoogle => 'Продовжити через Google';

  @override
  String get auth_logout => 'Вийти';

  @override
  String home_greeting(String userName) {
    return 'Привiт, $userName';
  }

  @override
  String get home_upcomingRoutes => 'Найближчi маршрути';

  @override
  String get home_activeTrip => 'Активна поїздка';

  @override
  String get home_nextTrip => 'Наступна поїздка';

  @override
  String get home_noScheduledRoutes => 'Немає рейсiв';

  @override
  String get home_createRoutePrompt => 'Сплануй наступний рейс';

  @override
  String get stats_packages => 'Посилки';

  @override
  String get stats_totalWeight => 'Загальна вага';

  @override
  String get stats_declaredValue => 'Вартiсть';

  @override
  String get packages_title => 'Замовлення';

  @override
  String get packages_searchPlaceholder =>
      'Шукати за кодом, вiдправником або отримувачем...';

  @override
  String get packages_filterAll => 'Всi';

  @override
  String get packages_emptyTitle => 'Немає посилок';

  @override
  String get packages_emptyMessage =>
      'Використовуйте кнопку + щоб зареєструвати нову посилку';

  @override
  String get packages_emptyFilterTitle => 'Немає результатiв';

  @override
  String get packages_emptyFilterMessage =>
      'Не знайдено посилок за обраними фiльтрами';

  @override
  String get packages_changeStatus => 'Змiнити статус';

  @override
  String get packages_selectNewStatus => 'Оберiть новий статус посилки';

  @override
  String get packages_detailTitle => 'Деталi посилки';

  @override
  String get packages_trackingCode => 'Код вiдстеження';

  @override
  String get packages_weight => 'Вага';

  @override
  String get packages_declaredValue => 'Оголошена вартiсть';

  @override
  String get packages_notSpecified => 'Не вказано';

  @override
  String get packages_senderReceiver => 'Вiдправник та Отримувач';

  @override
  String get packages_sender => 'Вiдправник';

  @override
  String get packages_receiver => 'Отримувач';

  @override
  String get packages_details => 'Деталi';

  @override
  String get packages_description => 'Опис';

  @override
  String get packages_notes => 'Примiтки';

  @override
  String get packages_statusHistory => 'Iсторiя статусiв';

  @override
  String get packages_noHistory => 'Немає iсторiї';

  @override
  String get packages_historyError => 'Помилка завантаження iсторiї';

  @override
  String get packages_loadError => 'Помилка завантаження посилки';

  @override
  String packages_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count посилок',
      few: '$count посилки',
      one: '1 посилка',
      zero: 'Немає посилок',
    );
    return '$_temp0';
  }

  @override
  String get packages_createTitle => 'Нова посилка';

  @override
  String get packages_createSuccess => 'Посилку успiшно створено';

  @override
  String get packages_createError => 'Помилка створення посилки';

  @override
  String get packages_assignRoute => 'Призначити на маршрут';

  @override
  String get packages_senderSection => 'Вiдправник';

  @override
  String get packages_senderNameLabel => 'Iм\'я *';

  @override
  String get packages_senderNameHint => 'Iм\'я вiдправника';

  @override
  String get packages_nameRequired => 'Iм\'я обов\'язкове';

  @override
  String get packages_phoneLabel => 'Телефон';

  @override
  String get packages_phoneHintSpain => '+34 600 000 000';

  @override
  String get packages_phoneHintUkraine => '+380 00 000 0000';

  @override
  String get packages_addressLabel => 'Адреса';

  @override
  String get packages_pickupAddressHint => 'Адреса забору';

  @override
  String get packages_receiverSection => 'Отримувач';

  @override
  String get packages_receiverNameHint => 'Iм\'я отримувача';

  @override
  String get packages_deliveryAddressHint => 'Адреса доставки';

  @override
  String get packages_detailsSection => 'Деталi посилки';

  @override
  String get packages_contentHint => 'Вмiст посилки';

  @override
  String get packages_weightLabel => 'Вага (кг)';

  @override
  String get packages_declaredValueLabel => 'Оголошена вартiсть (EUR)';

  @override
  String get packages_notesLabel => 'Примiтки';

  @override
  String get packages_additionalNotesHint => 'Додатковi примiтки...';

  @override
  String get packages_unassigned => 'Не призначено';

  @override
  String get packages_tabSender => 'Вiдправник';

  @override
  String get packages_tabReceiver => 'Отримувач';

  @override
  String get packages_widthLabel => 'Ш';

  @override
  String get packages_heightLabel => 'В';

  @override
  String get packages_lengthLabel => 'Д';

  @override
  String get packages_quantityLabel => 'Кiлькiсть';

  @override
  String get packages_tariffLabel => 'ТАРИФ';

  @override
  String get packages_totalPrice => 'ВСЬОГО';

  @override
  String get packages_noRoutesTitle => 'Немає доступних маршрутiв';

  @override
  String get packages_noRoutesMessage =>
      'Спочатку створiть маршрут, щоб реєструвати посилки';

  @override
  String get packages_createRouteButton => 'Створити маршрут';

  @override
  String get packages_submitPackage => 'Оформити посилку';

  @override
  String get packages_addressRequired => 'Адреса обов\'язкова';

  @override
  String get packages_routeRequired => 'Оберiть маршрут';

  @override
  String get packages_selectRoute => 'Оберiть маршрут';

  @override
  String get packages_volumetricWeight => 'Об\'ємна вага';

  @override
  String get packages_toEurope => 'В ЄВРОПУ';

  @override
  String get packages_cityLabel => 'Місто';

  @override
  String get packages_addressButton => 'Адреса';

  @override
  String get packages_deliverySection => 'ДОСТАВКА';

  @override
  String get packages_hide => 'Приховати';

  @override
  String get packages_exactAddress => 'Точна адреса';

  @override
  String get packages_googleMapsLink => 'Посилання на Google Maps';

  @override
  String get packages_weightKg => 'ВАГА (КГ)';

  @override
  String get packages_quantityPcs => 'КІЛЬКІСТЬ (ШТ)';

  @override
  String get packages_dimensionsCm => 'ГАБАРИТИ (СМ)';

  @override
  String get packages_nameLabel => 'Ім\'я';

  @override
  String get packages_cityRequired => 'Місто обов\'язкове';

  @override
  String get packages_mapsPrefix => 'Карти';

  @override
  String get packages_billingWeight => 'Розрахункова вага';

  @override
  String get routes_title => 'Маршрути';

  @override
  String routes_activeTab(int count) {
    return 'Активнi ($count)';
  }

  @override
  String routes_upcomingTab(int count) {
    return 'Найближчi ($count)';
  }

  @override
  String get routes_historyTab => 'Iсторiя';

  @override
  String get routes_emptyActive => 'Немає активних маршрутiв';

  @override
  String get routes_emptyActiveSubtitle => 'Маршрути в процесi з\'являться тут';

  @override
  String get routes_emptyPlanned => 'Немає запланованих маршрутiв';

  @override
  String get routes_emptyPlannedSubtitle =>
      'Створiть новий маршрут, щоб почати';

  @override
  String get routes_emptyHistory => 'Немає iсторiї';

  @override
  String get routes_emptyHistorySubtitle =>
      'Завершенi маршрути з\'являться тут';

  @override
  String get routes_createTitle => 'Новий маршрут';

  @override
  String get routes_originDestination => 'Вiдправлення та Призначення';

  @override
  String get routes_originCity => 'Мiсто вiдправлення';

  @override
  String get routes_destinationCity => 'Мiсто призначення';

  @override
  String get routes_originRequired => 'Введiть мiсто вiдправлення';

  @override
  String get routes_destinationRequired => 'Введiть мiсто призначення';

  @override
  String get routes_departureDates => 'Дати вiдправлення';

  @override
  String get routes_departureDatesHint =>
      'Оберiть одну або декiлька дат у календарi';

  @override
  String get routes_atLeastOneDate =>
      'Оберiть щонайменше одну дату вiдправлення';

  @override
  String get routes_tripDuration => 'Тривалiсть поїздки (необов\'язково)';

  @override
  String get routes_tripDurationHint => 'Кiлькiсть годин';

  @override
  String get routes_tripDurationDescription =>
      'Приблизний час поїздки в годинах';

  @override
  String get routes_notesOptional => 'Примiтки (необов\'язково)';

  @override
  String get routes_notesHint => 'Додатковi спостереження...';

  @override
  String get routes_createButton => 'Створити маршрут';

  @override
  String routes_createButtonWithDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дат',
      few: 'дати',
      one: 'дата',
    );
    return 'Створити маршрут ($count $_temp0)';
  }

  @override
  String get routes_createSuccess => 'Маршрут успiшно створено';

  @override
  String get routes_createError => 'Помилка створення маршруту';

  @override
  String get routes_selectDatesPrompt =>
      'Торкнiться днiв у календарi для вибору';

  @override
  String routes_selectedDatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'обраних дат',
      few: 'обранi дати',
      one: 'обрана дата',
    );
    return '$_temp0';
  }

  @override
  String get routes_month => 'Мiсяць';

  @override
  String get routes_searchCity => 'Пошук мiста...';

  @override
  String get routes_stopsOptional => 'Промiжнi зупинки (необовязково)';

  @override
  String get routes_pricing => 'Тарифи';

  @override
  String get routes_pricePerKg => 'Цiна/кг';

  @override
  String get routes_minimumPrice => 'Мiнiмум';

  @override
  String get routes_multiplier => 'Множник';

  @override
  String get routes_multiplierHint => 'Сезонне коригування (1.0 = базова цiна)';

  @override
  String get routes_deleteConfirmTitle => 'Видалити маршрут';

  @override
  String get routes_deleteConfirmMessage =>
      'Ви впевненi, що хочете видалити цей маршрут? Цю дiю не можна скасувати.';

  @override
  String get routes_deleteSuccess => 'Маршрут видалено';

  @override
  String get routes_deleteError => 'Помилка видалення маршруту';

  @override
  String get nav_home => 'Головна';

  @override
  String get nav_packages => 'Посилки';

  @override
  String get nav_routes => 'Рейси';

  @override
  String get quickAction_title => 'Створити нове';

  @override
  String get quickAction_subtitle => 'Оберiть, що хочете зареєструвати';

  @override
  String get quickAction_newRoute => 'Новий маршрут';

  @override
  String get quickAction_newRouteSubtitle => 'Iспанiя-Україна';

  @override
  String get quickAction_newPackage => 'Нова посилка';

  @override
  String get quickAction_newPackageSubtitle => 'Вручну';

  @override
  String get quickAction_scan => 'Сканувати';

  @override
  String get quickAction_scanSubtitle => 'OCR';

  @override
  String get quickAction_import => 'Iмпортувати';

  @override
  String get quickAction_importSubtitle => 'Excel';

  @override
  String get userMenu_profile => 'Мiй профiль';

  @override
  String get userMenu_settings => 'Налаштування';

  @override
  String get userMenu_help => 'Допомога';

  @override
  String get userMenu_language => 'Мова';

  @override
  String get userMenu_theme => 'Тема';

  @override
  String get status_package_pending => 'Очiкує';

  @override
  String get status_package_pickedUp => 'Забрано';

  @override
  String get status_package_inTransit => 'В дорозi';

  @override
  String get status_package_inWarehouse => 'На складi';

  @override
  String get status_package_outForDelivery => 'Доставляється';

  @override
  String get status_package_delivered => 'Доставлено';

  @override
  String get status_package_cancelled => 'Скасовано';

  @override
  String get status_package_returned => 'Повернено';

  @override
  String get status_route_planned => 'Заплановано';

  @override
  String get status_route_inProgress => 'В процесi';

  @override
  String get status_route_completed => 'Завершено';

  @override
  String get status_route_cancelled => 'Скасовано';

  @override
  String get statusChip_inTransit => 'В ДОРОЗI';

  @override
  String get statusChip_delivered => 'ДОСТАВЛЕНО';

  @override
  String get statusChip_pending => 'ОЧIКУЄ';

  @override
  String get statusChip_planned => 'ЗАПЛАНОВАНО';

  @override
  String get tripCard_driver => 'Водiй';

  @override
  String get tripCard_vehicle => 'Mercedes Sprinter';

  @override
  String get tripCard_spain => 'Iспанiя';

  @override
  String get tripCard_ukraine => 'Україна';

  @override
  String get tripCard_capacity => 'Мiсткiсть';

  @override
  String get tripCard_perKg => '/кг';

  @override
  String tripCard_deliveryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count доставок',
      few: '$count доставки',
      one: '1 доставка',
    );
    return '$_temp0';
  }

  @override
  String get tripCard_call => 'Зателефонувати';

  @override
  String get tripCard_message => 'Повiдомлення';

  @override
  String get tripCard_rating => 'Рейтинг';

  @override
  String get tripCard_deliveries => 'Доставки';

  @override
  String get country_spain => 'Iспанiя';

  @override
  String get country_ukraine => 'Україна';
}
