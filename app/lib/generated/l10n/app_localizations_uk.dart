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
  String get common_pcs => 'шт';

  @override
  String get common_today => 'Сьогодні';

  @override
  String get common_yesterday => 'Вчора';

  @override
  String get common_deleteConfirmTitle => 'Підтвердити видалення';

  @override
  String common_deleteConfirmMessage(String itemType) {
    return 'Ви впевнені, що хочете видалити цей $itemType?';
  }

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
  String get stats_totalWeight => 'Заг. вага';

  @override
  String get stats_declaredValue => 'Вартiсть';

  @override
  String get stats_contacts => 'Контакти';

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
  String get packages_codeCopied => 'Код скопійовано';

  @override
  String get packages_weight => 'Вага';

  @override
  String get packages_dimensions => 'Габарити';

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
  String get packages_historyUnavailable => 'Iсторiя недоступна';

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
  String get packages_createNew => 'Нове відправлення';

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
  String get packages_widthLabel => 'Шир.';

  @override
  String get packages_heightLabel => 'Вис.';

  @override
  String get packages_lengthLabel => 'Довж.';

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
  String get packages_googleMapsLink => 'Google Maps';

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
  String get packages_route => 'Маршрут';

  @override
  String get packages_origin => 'Вiдправлення';

  @override
  String get packages_destination => 'Призначення';

  @override
  String get packages_departureDate => 'Дата вiдправлення';

  @override
  String get packageDescription => 'Опис';

  @override
  String get packages_imagesSection => 'Фото посилки';

  @override
  String get packages_addImage => 'Додати фото';

  @override
  String get packages_noImages => 'Немає фото';

  @override
  String get packages_imageAdded => 'Фото успiшно додано';

  @override
  String get packages_imageDeleted => 'Фото успiшно видалено';

  @override
  String get packages_imageError => 'Помилка обробки зображення';

  @override
  String get packages_deleteImageTitle => 'Видалити фото';

  @override
  String get packages_deleteImageConfirm =>
      'Ви впевненi, що хочете видалити це фото?';

  @override
  String get packages_editPrice => 'Редагувати цiну';

  @override
  String get packages_priceLabel => 'Цiна (€)';

  @override
  String get packages_priceHint =>
      'Введiть цiну або залиште порожнiм для автоматичного розрахунку';

  @override
  String get packages_selectAll => 'Усi';

  @override
  String packages_selectedCount(int count) {
    return '$count обрано';
  }

  @override
  String get packages_advanceStatus => 'Далi';

  @override
  String packages_bulkUpdateSuccess(int count) {
    return '$count посилок оновлено';
  }

  @override
  String get packages_filterStatus => 'Статус';

  @override
  String get packages_filterTrip => 'Рейс';

  @override
  String get packages_filterCity => 'Місто';

  @override
  String get packages_filterAllTrips => 'Усі рейси';

  @override
  String get packages_filterSearchCity => 'Шукати місто...';

  @override
  String get packages_filterClearCities => 'Очистити';

  @override
  String get packages_filterActiveTrips => 'АКТИВНІ';

  @override
  String get packages_filterUpcomingTrips => 'НАСТУПНІ';

  @override
  String get packages_filterPastTrips => 'МИНУЛІ';

  @override
  String packages_countShort(int count) {
    return '$count пос.';
  }

  @override
  String get packages_novaPostNumber => 'Нова Пошта';

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
  String get routes_editTitle => 'Редагувати маршрут';

  @override
  String get routes_updateSuccess => 'Маршрут успiшно оновлено';

  @override
  String get routes_updateError => 'Помилка оновлення маршруту';

  @override
  String get routes_editSubtitle => 'Змінити міста та ціни';

  @override
  String get routes_deleteSubtitle => 'Видалити цей маршрут';

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
  String get routes_routeDetails => 'ДЕТАЛI МАРШРУТУ';

  @override
  String get routes_addCountry => '+ Додати Країну';

  @override
  String get routes_originPoint => 'Точка Вiдправлення';

  @override
  String routes_stopN(int n) {
    return 'Зупинка $n';
  }

  @override
  String get routes_finalDestination => 'Кiнцеве Призначення';

  @override
  String get routes_addCity => 'Додати Мiсто';

  @override
  String get routes_addStop => 'Додати зупинку';

  @override
  String get routes_noIntermediateStops => 'Без промiжних зупинок';

  @override
  String get routes_deleteStop => 'видалити';

  @override
  String get routes_pricingSection => 'ЦIНОУТВОРЕННЯ';

  @override
  String get routes_amount => 'Сума';

  @override
  String get routes_currency => 'Валюта';

  @override
  String get routes_publishRoute => 'Опублiкувати Маршрут';

  @override
  String get routes_selectCountry => 'Оберiть країну';

  @override
  String get routes_selectCity => 'Оберiть мiсто';

  @override
  String get routes_atLeastOneCity => 'Додайте щонайменше одне мiсто';

  @override
  String get country_germany => 'Нiмеччина';

  @override
  String get country_poland => 'Польща';

  @override
  String get nav_home => 'Головна';

  @override
  String get nav_packages => 'Посилки';

  @override
  String get nav_routes => 'Рейси';

  @override
  String get nav_contacts => 'Контакти';

  @override
  String get contacts_title => 'Контакти';

  @override
  String get contacts_search => 'Шукати за іменем, email або телефоном...';

  @override
  String get contacts_all => 'Всі';

  @override
  String get contacts_verified => 'Верифіковані';

  @override
  String get contacts_newContact => 'Новий Контакт';

  @override
  String get contacts_noContacts => 'Немає контактів';

  @override
  String get contacts_noContactsDesc =>
      'Контакти створюватимуться автоматично при створенні посилок';

  @override
  String get contacts_nameLabel => 'Ім\'я *';

  @override
  String get contacts_nameRequired => 'Імя обовязкове';

  @override
  String get contacts_emailLabel => 'Email';

  @override
  String get contacts_emailInvalid => 'Невірний email';

  @override
  String get contacts_phoneLabel => 'Телефон';

  @override
  String get contacts_notesLabel => 'Нотатки';

  @override
  String get contacts_create => 'Створити';

  @override
  String get contacts_created => 'Контакт створено';

  @override
  String get contacts_createError => 'Помилка створення контакту';

  @override
  String get contacts_detail => 'Деталі Контакту';

  @override
  String get contacts_edit => 'Редагувати Контакт';

  @override
  String get contacts_editSubtitle => 'Змінити дані контакту';

  @override
  String get contacts_deleteSubtitle => 'Видалити контакт назавжди';

  @override
  String get contacts_updated => 'Контакт оновлено';

  @override
  String get contacts_deleteTitle => 'Видалити Контакт';

  @override
  String get contacts_deleteConfirm =>
      'Ви впевнені, що хочете видалити цей контакт?';

  @override
  String get contacts_deleted => 'Контакт видалено';

  @override
  String get contacts_errorLoading => 'Помилка завантаження контактів';

  @override
  String get contacts_errorLoadingPackages => 'Помилка завантаження посилок';

  @override
  String get contacts_tabHistory => 'Історія';

  @override
  String get contacts_tabDetails => 'Деталі';

  @override
  String get contacts_noPackages => 'Немає посилок';

  @override
  String get contacts_noPackagesDesc => 'Цей контакт не має посилок';

  @override
  String get contacts_statsSent => 'Відправлено';

  @override
  String get contacts_statsReceived => 'Отримано';

  @override
  String get contacts_statsTotal => 'Всього';

  @override
  String get contacts_systemInfo => 'Системна Інформація';

  @override
  String get contacts_fieldId => 'ID';

  @override
  String get contacts_fieldCreatedBy => 'Створено';

  @override
  String get contacts_fieldCreatedAt => 'Дата створення';

  @override
  String get contacts_fieldUpdatedAt => 'Останнє оновлення';

  @override
  String get contacts_lastActivity => 'Остання активність';

  @override
  String get contacts_notes => 'Нотатки';

  @override
  String get contacts_linkedUser => 'Пов\'язаний користувач';

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
  String get profile_title => 'Мiй профiль';

  @override
  String get profile_name => 'Iм\'я';

  @override
  String get profile_nameHint => 'Ваше повне iм\'я';

  @override
  String get profile_nameRequired => 'Iм\'я обов\'язкове';

  @override
  String get profile_saveName => 'Зберегти iм\'я';

  @override
  String get profile_nameUpdated => 'Iм\'я успiшно оновлено';

  @override
  String get profile_nameError => 'Помилка оновлення iменi';

  @override
  String get profile_changePassword => 'Змiнити пароль';

  @override
  String get profile_currentPassword => 'Поточний пароль';

  @override
  String get profile_newPassword => 'Новий пароль';

  @override
  String get profile_confirmPassword => 'Пiдтвердити пароль';

  @override
  String get profile_passwordRequired => 'Пароль обов\'язковий';

  @override
  String get profile_passwordMinLength =>
      'Пароль має мiстити щонайменше 8 символiв';

  @override
  String get profile_passwordMismatch => 'Паролi не збiгаються';

  @override
  String get profile_updatePassword => 'Оновити пароль';

  @override
  String get profile_passwordUpdated => 'Пароль успiшно оновлено';

  @override
  String get profile_passwordError => 'Помилка оновлення паролю';

  @override
  String get profile_changePhoto => 'Змiнити фото';

  @override
  String get profile_avatarUpdated => 'Фото профiлю оновлено';

  @override
  String get profile_avatarError => 'Помилка завантаження зображення';

  @override
  String get status_package_registered => 'Оформлено';

  @override
  String get status_package_registered_desc =>
      'Посилка зареєстрована в системi';

  @override
  String get status_package_inTransit => 'В дорозi';

  @override
  String get status_package_inTransit_desc => 'Вiдправити посилку в рейс';

  @override
  String get status_package_delivered => 'Видано';

  @override
  String get status_package_delivered_desc => 'Вручити посилку клiєнту';

  @override
  String get status_package_delayed => 'Затримується';

  @override
  String get status_package_delayed_desc => 'Виникли проблеми з посилкою';

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

  @override
  String action_changeStatusTo(String status) {
    return 'Змiнити на \"$status\"';
  }

  @override
  String get action_openMap => 'Карта';

  @override
  String get action_viewOnMap => 'Переглянути на карті';

  @override
  String get action_call => 'Зателефонувати';

  @override
  String get action_whatsapp => 'WhatsApp';

  @override
  String get action_telegram => 'Telegram';

  @override
  String get action_viber => 'Viber';

  @override
  String get ocr_scanButton => 'Сканувати';

  @override
  String get ocr_selectSource => 'Оберiть джерело';

  @override
  String get ocr_camera => 'Камера';

  @override
  String get ocr_gallery => 'Галерея';

  @override
  String get ocr_resultsTitle => 'Результати сканування';

  @override
  String get ocr_resultsSubtitle => 'Перевiрте та вiдредагуйте знайденi данi';

  @override
  String get ocr_apply => 'Застосувати';

  @override
  String get ocr_error => 'Помилка обробки зображення';

  @override
  String get ocr_noDataFound =>
      'Не знайдено даних на зображеннi. Спробуйте iнше фото з чiткiшим текстом.';

  @override
  String get notifications_enableTitle => 'Увiмкнiть сповiщення';

  @override
  String get notifications_enableDescription =>
      'Отримуйте сповiщення про вашi вiдправлення та маршрути';

  @override
  String get notifications_enable => 'Увiмкнути';

  @override
  String get notifications_notNow => 'Не зараз';

  @override
  String get tripsRoutes_title => 'Рейси і Маршрути';

  @override
  String get tripsRoutes_trips => 'Рейси';

  @override
  String get tripsRoutes_routes => 'Маршрути';

  @override
  String get tripsRoutes_noTrips => 'Немає рейсів';

  @override
  String get tripsRoutes_noTripsSubtitle => 'Створіть перший рейс';

  @override
  String get tripsRoutes_createTrip => 'Створити рейс';

  @override
  String get tripsRoutes_noRouteTemplates => 'Немає шаблонів маршрутів';

  @override
  String get tripsRoutes_noRouteTemplatesSubtitle =>
      'Створіть шаблон для швидкого створення рейсів';

  @override
  String get trips_sectionActive => 'АКТИВНІ';

  @override
  String get trips_sectionUpcoming => 'НАСТУПНІ';

  @override
  String get trips_sectionHistory => 'ІСТОРІЯ';

  @override
  String trips_packagesCount(int count) {
    return '$count посилок';
  }

  @override
  String get trips_changeStatus => 'Змінити статус';

  @override
  String get trips_retry => 'Повторити';

  @override
  String get trips_clearFilter => 'Скинути фільтр';

  @override
  String get trips_routeTemplate => 'ШАБЛОН МАРШРУТУ';

  @override
  String get trips_originPoint => 'ПУНКТ ВІДПРАВЛЕННЯ';

  @override
  String get trips_destinationPoint => 'ПУНКТ ПРИЗНАЧЕННЯ';

  @override
  String get trips_departureDates => 'ДАТИ ВИЇЗДУ';

  @override
  String get trips_departureDate => 'ДАТА ВИЇЗДУ';

  @override
  String get trips_departureTimeOptional => 'ЧАС ВИЇЗДУ (необов\'язково)';

  @override
  String get trips_notesOptional => 'НОТАТКИ (необов\'язково)';

  @override
  String get trips_additionalInfo => 'Додаткова інформація...';

  @override
  String get trips_selectDates => 'Виберіть дати';

  @override
  String trips_createTripCount(int count) {
    return 'Створити $count рейсів';
  }

  @override
  String get trips_selectAtLeastOneDate => 'Виберіть хоча б одну дату';

  @override
  String get trips_selectTemplateOrCities =>
      'Виберіть шаблон або вкажіть міста';

  @override
  String get trips_tripCreated => 'Рейс створено!';

  @override
  String trips_tripsCreated(int count) {
    return 'Створено $count рейсів!';
  }

  @override
  String trips_tripsPartiallyCreated(int success, int total) {
    return 'Створено $success з $total рейсів';
  }

  @override
  String get trips_errorCreating => 'Помилка при створенні рейсів';

  @override
  String get trips_resetSelection => 'Скинути вибір';

  @override
  String get trips_notSpecified => 'Не вказано';

  @override
  String get trips_selectTemplate => 'Виберіть шаблон';

  @override
  String get trips_noTemplate => 'Без шаблону (ввести вручну)';

  @override
  String get trips_errorLoadingTemplate => 'Помилка завантаження шаблону';

  @override
  String get trips_cityHint => 'Місто';

  @override
  String get trips_weekdayMon => 'Пн';

  @override
  String get trips_weekdayTue => 'Вт';

  @override
  String get trips_weekdayWed => 'Ср';

  @override
  String get trips_weekdayThu => 'Чт';

  @override
  String get trips_weekdayFri => 'Пт';

  @override
  String get trips_weekdaySat => 'Сб';

  @override
  String get trips_weekdaySun => 'Нд';

  @override
  String get trips_editTrip => 'Редагувати поїздку';

  @override
  String get trips_editTripSubtitle => 'Змінити деталі поїздки';

  @override
  String get trips_deleteTripSubtitle => 'Видалити цю поїздку';

  @override
  String get trips_tripUpdated => 'Поїздку оновлено';

  @override
  String get trips_cannotDeletePast => 'Не можна видалити рейс з минулою датою';

  @override
  String get trips_cannotDeleteWithPackages =>
      'Не можна видалити рейс з призначеними посилками';

  @override
  String get trips_itemTypeTrip => 'рейс';

  @override
  String get trips_itemTypeRouteTemplate => 'шаблон маршруту';

  @override
  String get trips_tripDeleted => 'Рейс видалено';

  @override
  String get trips_tripDeleteError => 'Помилка видалення рейсу';

  @override
  String get trips_routeTemplateDeleted => 'Шаблон видалено';

  @override
  String get trips_routeTemplateDeleteError => 'Помилка видалення шаблону';

  @override
  String get myOrders_title => 'Мої Замовлення';

  @override
  String get myOrders_filterByStatus => 'Фільтр за статусом';

  @override
  String get myOrders_filterAll => 'Всі';

  @override
  String get myOrders_filterPending => 'Очікує';

  @override
  String get myOrders_filterInTransit => 'В дорозі';

  @override
  String get myOrders_filterDelivered => 'Доставлено';

  @override
  String get myOrders_filterDelayed => 'Затримано';

  @override
  String get myOrders_noOrdersFiltered => 'Немає замовлень з таким статусом';

  @override
  String get myOrders_noOrders => 'У вас немає замовлень';

  @override
  String get myOrders_noOrdersDesc =>
      'Коли ви відправите або отримаєте посилки,\nвони з\'являться тут';

  @override
  String get myOrders_errorLoading => 'Помилка завантаження замовлень';

  @override
  String get myOrders_retry => 'Повторити';

  @override
  String get myOrders_senderAndReceiver => 'Відправник і Отримувач';

  @override
  String get myOrders_youAreSender => 'Ви Відправник';

  @override
  String get myOrders_youAreReceiver => 'Ви Отримувач';

  @override
  String get driverPending_title => 'Заявка на розгляді';

  @override
  String get driverPending_message =>
      'Ваша заявка як водія перевіряється нашою командою.';

  @override
  String get driverPending_emailNotice =>
      'Ми повідомимо вас електронною поштою, коли її схвалять.';

  @override
  String get driverPending_verifying => 'Перевірка...';

  @override
  String get driverPending_refreshStatus => 'Оновити статус';

  @override
  String get driverPending_logout => 'Вийти';

  @override
  String get clientDashboard_title => 'Мої Відправлення';

  @override
  String get clientDashboard_myShipments => 'Мої відправлення';

  @override
  String get clientDashboard_noShipments =>
      'У вас немає зареєстрованих відправлень';

  @override
  String get clientDashboard_createFirst => 'Створіть ваше перше відправлення';

  @override
  String get clientDashboard_totalShipments => 'Всього відправлено';

  @override
  String get clientDashboard_inTransit => 'У дорозі';

  @override
  String get clientDashboard_delivered => 'Доставлено';

  @override
  String get clientDashboard_viewAll => 'Переглянути всі';

  @override
  String get admin_panelTitle => 'Панель Адміна';

  @override
  String get admin_userManagement => 'Керування Користувачами';

  @override
  String get admin_users => 'Користувачі';

  @override
  String get admin_requests => 'Заявки';

  @override
  String get admin_allUsers => 'Всі';

  @override
  String get admin_clients => 'Клієнти';

  @override
  String get admin_drivers => 'Перевізники';

  @override
  String get admin_client => 'Клієнт';

  @override
  String get admin_driver => 'Перевізник';

  @override
  String get admin_noUsers => 'Немає користувачів';

  @override
  String get admin_loadError => 'Помилка завантаження даних';

  @override
  String get admin_registered => 'Зареєстрований';

  @override
  String get admin_userSingular => 'користувач';

  @override
  String get admin_userPlural => 'користувачів';

  @override
  String get admin_clientSingular => 'клієнт';

  @override
  String get admin_clientPlural => 'клієнтів';

  @override
  String get admin_driverSingular => 'перевізник';

  @override
  String get admin_driverPlural => 'перевізників';

  @override
  String get admin_statusApproved => 'Схвалено';

  @override
  String get admin_statusPending => 'Очікує';

  @override
  String get admin_statusRejected => 'Відхилено';

  @override
  String get admin_noPendingDrivers => 'Немає водіїв на розгляді';

  @override
  String get admin_allDriversReviewed => 'Всі водії перевірені';

  @override
  String get admin_pendingDriverSingular => 'Водій на розгляді';

  @override
  String get admin_pendingDriverPlural => 'Водіїв на розгляді';

  @override
  String get admin_approve => 'Схвалити';

  @override
  String get admin_reject => 'Відхилити';

  @override
  String get admin_approveDriver => 'Схвалити водія';

  @override
  String get admin_rejectDriver => 'Відхилити водія';

  @override
  String admin_approveConfirm(String name) {
    return 'Ви впевнені, що хочете схвалити $name як водія? Він отримає email з підтвердженням і зможе користуватися всіма функціями додатку.';
  }

  @override
  String admin_rejectConfirm(String name) {
    return 'Ви впевнені, що хочете відхилити $name як водія? Він отримає email з повідомленням про відхилення.';
  }

  @override
  String admin_driverApproved(String name) {
    return '$name був схвалений';
  }

  @override
  String admin_driverRejected(String name) {
    return '$name був відхилений';
  }

  @override
  String get admin_rejectReasonLabel => 'Причина (необов\'язково)';

  @override
  String get admin_rejectReasonHint => 'Напр: Неповна документація';

  @override
  String admin_registeredAgo(String time) {
    return 'Зареєстрований $time';
  }

  @override
  String get admin_reapplication => 'Повторна заявка';

  @override
  String get admin_previousRejectionReason => 'Причина попередньої відмови:';

  @override
  String get admin_driverAppeal => 'Апеляція водія:';

  @override
  String get admin_planRequests => 'Плани';

  @override
  String get admin_noPlanRequests => 'Немає запитів на план';

  @override
  String get admin_noPlanRequestsSubtitle =>
      'Коли водії запитають план, вони з\'являться тут';

  @override
  String get admin_approvePlan => 'Схвалити план';

  @override
  String get admin_rejectPlan => 'Відхилити план';

  @override
  String admin_approvePlanConfirm(String plan, String name) {
    return 'Схвалити план $plan для $name?';
  }

  @override
  String admin_rejectPlanConfirm(String plan, String name) {
    return 'Відхилити план $plan для $name?';
  }

  @override
  String admin_planApproved(String name) {
    return 'План схвалено для $name';
  }

  @override
  String admin_planRejected(String name) {
    return 'План відхилено для $name';
  }

  @override
  String get driverRejected_title => 'Заявку відхилено';

  @override
  String get driverRejected_message =>
      'Вашу заявку на роль водія було відхилено.';

  @override
  String get driverRejected_reasonLabel => 'Причина відмови:';

  @override
  String get driverRejected_noReasonProvided => 'Конкретна причина не вказана.';

  @override
  String get driverRejected_appealHint =>
      'Поясніть, чому вважаєте, що вашу заявку слід переглянути (мінімум 20 символів)...';

  @override
  String get driverRejected_submitAppeal => 'Надіслати апеляцію';

  @override
  String get driverRejected_submitting => 'Надсилання...';

  @override
  String get driverRejected_appealRequired => 'Апеляція є обов\'язковою';

  @override
  String get driverRejected_appealMinLength =>
      'Апеляція повинна містити щонайменше 20 символів';

  @override
  String get driverRejected_appealSent =>
      'Апеляцію успішно надіслано. Вашу заявку переглядають повторно.';

  @override
  String get driverRejected_appealError =>
      'Помилка надсилання апеляції. Спробуйте ще раз.';

  @override
  String get driverRejected_appealAlreadySent =>
      'Ви вже надіслали апеляцію. Вашу заявку переглядають повторно.';

  @override
  String get driverRejected_logout => 'Вийти';

  @override
  String get plans_menuTitle => 'Плани та ціни';

  @override
  String get plans_title => 'Обери свій ідеальний план';

  @override
  String get plans_subtitle => 'Преміум інструменти для твого бізнесу';

  @override
  String get plans_basic => 'Базовий';

  @override
  String get plans_pro => 'Pro';

  @override
  String get plans_premium => 'Преміум';

  @override
  String get plans_perMonth => '/міс';

  @override
  String plans_priceLabel(String name, int price) {
    return '$name — $price€/міс';
  }

  @override
  String get plans_scanner => 'Сканер';

  @override
  String get plans_sms => 'SMS';

  @override
  String get plans_shipmentHistory => 'Історія відправлень';

  @override
  String get plans_contactBook => 'Книга контактів';

  @override
  String get plans_contactList => 'Список контактів';

  @override
  String plans_selectPlan(String plan) {
    return 'Замовити план';
  }

  @override
  String get plans_popular => 'Популярний';

  @override
  String get plans_featureScanner => 'Сканер';

  @override
  String get plans_featureSms => 'SMS повідомлення';

  @override
  String get plans_featureHistory => 'Історія';

  @override
  String get plans_requestSuccess => 'Запит успішно надіслано';

  @override
  String get plans_requestError => 'Помилка при відправці запиту';

  @override
  String get plans_currentPlan => 'Поточний план';

  @override
  String get plans_requested => 'Запитано';

  @override
  String get marketing_trackingTitle => 'Надіслати відстеження';

  @override
  String get marketing_trackingDesc =>
      'Повідом клієнту про стан його посилки. Формує довіру та професійність';

  @override
  String marketing_trackingMessage(String name, String tracking) {
    return 'Привіт $name, твоя посилка $tracking зареєстрована і скоро буде забрана. Будемо тримати в курсі!';
  }

  @override
  String get marketing_loyaltyTitle => 'Надіслати лояльність';

  @override
  String get marketing_loyaltyDesc =>
      'Запропонуй знижку і зроби клієнта постійним. Постійні клієнти — найприбутковіші';

  @override
  String marketing_loyaltyMessage(String name) {
    return 'Привіт $name, дякуємо за довіру. На наступне відправлення маєш знижку 10%. Пиши, коли потрібно!';
  }

  @override
  String get marketing_tripTitle => 'Повідомити про рейс';

  @override
  String get marketing_tripDesc =>
      'Повідом про наступний рейс і збери посилки. Кожне повідомлення — це потенційна посилка';

  @override
  String marketing_tripMessage(
      String name, String origin, String destination, String date) {
    return 'Привіт $name, маю рейс $origin → $destination $date. Маєш щось для відправки? Пиши!';
  }

  @override
  String get marketing_upgradeCta => 'Розблокувати з Планом Pro';

  @override
  String get marketing_premiumFeature => 'Преміум функція';

  @override
  String get marketing_noPhone => 'Без телефону';

  @override
  String get marketing_noPackage => 'Немає очікуючих посилок';

  @override
  String get marketing_noTrip => 'Немає запланованих рейсів';

  @override
  String get admin_userDetail => 'Деталі користувача';

  @override
  String get admin_personalInfo => 'Особиста інформація';

  @override
  String get admin_userPlan => 'Активний план';

  @override
  String get admin_userNoPlan => 'Без плану';

  @override
  String get admin_dates => 'Дати';

  @override
  String get admin_lastUpdate => 'Останнє оновлення';

  @override
  String get admin_userLanguage => 'Мова';

  @override
  String get admin_userTheme => 'Тема';

  @override
  String get admin_superAdmin => 'Адміністратор';
}
