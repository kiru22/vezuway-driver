<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Name Fields for City Matching
    |--------------------------------------------------------------------------
    |
    | Fields used to match city names across different languages.
    |
    */

    'name_fields' => ['name', 'nameEs', 'nameUk'],

    /*
    |--------------------------------------------------------------------------
    | Cities for OCR Text Parsing
    |--------------------------------------------------------------------------
    |
    | List of cities used by the OCR text parser to detect city names
    | in scanned images. Each city has canonical name, Spanish name,
    | Ukrainian name, and country code.
    |
    */

    'cities' => [
        // Spanish cities
        ['name' => 'Madrid', 'nameEs' => 'Madrid', 'nameUk' => 'Мадрид', 'country' => 'ES'],
        ['name' => 'Barcelona', 'nameEs' => 'Barcelona', 'nameUk' => 'Барселона', 'country' => 'ES'],
        ['name' => 'Valencia', 'nameEs' => 'Valencia', 'nameUk' => 'Валенсія', 'country' => 'ES'],
        ['name' => 'Sevilla', 'nameEs' => 'Sevilla', 'nameUk' => 'Севілья', 'country' => 'ES'],
        ['name' => 'Zaragoza', 'nameEs' => 'Zaragoza', 'nameUk' => 'Сарагоса', 'country' => 'ES'],
        ['name' => 'Malaga', 'nameEs' => 'Malaga', 'nameUk' => 'Малага', 'country' => 'ES'],
        ['name' => 'Murcia', 'nameEs' => 'Murcia', 'nameUk' => 'Мурсія', 'country' => 'ES'],
        ['name' => 'Palma de Mallorca', 'nameEs' => 'Palma de Mallorca', 'nameUk' => 'Пальма-де-Майорка', 'country' => 'ES'],
        ['name' => 'Bilbao', 'nameEs' => 'Bilbao', 'nameUk' => 'Більбао', 'country' => 'ES'],
        ['name' => 'Alicante', 'nameEs' => 'Alicante', 'nameUk' => 'Аліканте', 'country' => 'ES'],
        ['name' => 'Cordoba', 'nameEs' => 'Cordoba', 'nameUk' => 'Кордова', 'country' => 'ES'],
        ['name' => 'Valladolid', 'nameEs' => 'Valladolid', 'nameUk' => 'Вальядолід', 'country' => 'ES'],
        ['name' => 'Vigo', 'nameEs' => 'Vigo', 'nameUk' => 'Віго', 'country' => 'ES'],
        ['name' => 'Gijon', 'nameEs' => 'Gijon', 'nameUk' => 'Хіхон', 'country' => 'ES'],
        ['name' => 'Granada', 'nameEs' => 'Granada', 'nameUk' => 'Гранада', 'country' => 'ES'],
        ['name' => 'Elche', 'nameEs' => 'Elche', 'nameUk' => 'Ельче', 'country' => 'ES'],
        ['name' => 'Oviedo', 'nameEs' => 'Oviedo', 'nameUk' => 'Овʼєдо', 'country' => 'ES'],
        ['name' => 'Cartagena', 'nameEs' => 'Cartagena', 'nameUk' => 'Картахена', 'country' => 'ES'],
        ['name' => 'Jerez de la Frontera', 'nameEs' => 'Jerez de la Frontera', 'nameUk' => 'Херес-де-ла-Фронтера', 'country' => 'ES'],
        ['name' => 'Pamplona', 'nameEs' => 'Pamplona', 'nameUk' => 'Памплона', 'country' => 'ES'],
        ['name' => 'Santander', 'nameEs' => 'Santander', 'nameUk' => 'Сантандер', 'country' => 'ES'],
        ['name' => 'San Sebastian', 'nameEs' => 'San Sebastian', 'nameUk' => 'Сан-Себастьян', 'country' => 'ES'],
        ['name' => 'Burgos', 'nameEs' => 'Burgos', 'nameUk' => 'Бургос', 'country' => 'ES'],
        ['name' => 'Salamanca', 'nameEs' => 'Salamanca', 'nameUk' => 'Саламанка', 'country' => 'ES'],
        ['name' => 'Tarragona', 'nameEs' => 'Tarragona', 'nameUk' => 'Таррагона', 'country' => 'ES'],

        // Ukrainian cities
        ['name' => 'Kyiv', 'nameEs' => 'Kiev', 'nameUk' => 'Київ', 'country' => 'UA'],
        ['name' => 'Kharkiv', 'nameEs' => 'Jarkov', 'nameUk' => 'Харків', 'country' => 'UA'],
        ['name' => 'Odesa', 'nameEs' => 'Odesa', 'nameUk' => 'Одеса', 'country' => 'UA'],
        ['name' => 'Dnipro', 'nameEs' => 'Dnipro', 'nameUk' => 'Дніпро', 'country' => 'UA'],
        ['name' => 'Lviv', 'nameEs' => 'Leópolis', 'nameUk' => 'Львів', 'country' => 'UA'],
        ['name' => 'Zaporizhzhia', 'nameEs' => 'Zaporiyia', 'nameUk' => 'Запоріжжя', 'country' => 'UA'],
        ['name' => 'Vinnytsia', 'nameEs' => 'Vinnytsia', 'nameUk' => 'Вінниця', 'country' => 'UA'],
        ['name' => 'Poltava', 'nameEs' => 'Poltava', 'nameUk' => 'Полтава', 'country' => 'UA'],
        ['name' => 'Chernihiv', 'nameEs' => 'Chernihiv', 'nameUk' => 'Чернігів', 'country' => 'UA'],
        ['name' => 'Cherkasy', 'nameEs' => 'Cherkasy', 'nameUk' => 'Черкаси', 'country' => 'UA'],
        ['name' => 'Zhytomyr', 'nameEs' => 'Zhytomyr', 'nameUk' => 'Житомир', 'country' => 'UA'],
        ['name' => 'Sumy', 'nameEs' => 'Sumy', 'nameUk' => 'Суми', 'country' => 'UA'],
        ['name' => 'Rivne', 'nameEs' => 'Rivne', 'nameUk' => 'Рівне', 'country' => 'UA'],
        ['name' => 'Ternopil', 'nameEs' => 'Ternopil', 'nameUk' => 'Тернопіль', 'country' => 'UA'],
        ['name' => 'Lutsk', 'nameEs' => 'Lutsk', 'nameUk' => 'Луцьк', 'country' => 'UA'],
        ['name' => 'Ivano-Frankivsk', 'nameEs' => 'Ivano-Frankivsk', 'nameUk' => 'Івано-Франківськ', 'country' => 'UA'],
        ['name' => 'Khmelnytskyi', 'nameEs' => 'Jmelnytsky', 'nameUk' => 'Хмельницький', 'country' => 'UA'],
        ['name' => 'Uzhhorod', 'nameEs' => 'Úzhhorod', 'nameUk' => 'Ужгород', 'country' => 'UA'],
        ['name' => 'Chernivtsi', 'nameEs' => 'Chernivtsi', 'nameUk' => 'Чернівці', 'country' => 'UA'],
        ['name' => 'Kropyvnytskyi', 'nameEs' => 'Kropyvnytsky', 'nameUk' => 'Кропивницький', 'country' => 'UA'],
        ['name' => 'Mykolaiv', 'nameEs' => 'Mykolaiv', 'nameUk' => 'Миколаїв', 'country' => 'UA'],
        ['name' => 'Kherson', 'nameEs' => 'Jerson', 'nameUk' => 'Херсон', 'country' => 'UA'],
        ['name' => 'Bila Tserkva', 'nameEs' => 'Bila Tserkva', 'nameUk' => 'Біла Церква', 'country' => 'UA'],
        ['name' => 'Kremenchuk', 'nameEs' => 'Kremenchuk', 'nameUk' => 'Кременчук', 'country' => 'UA'],
        ['name' => 'Kamianske', 'nameEs' => 'Kamianske', 'nameUk' => 'Камʼянське', 'country' => 'UA'],

        // Polish cities (transit)
        ['name' => 'Warsaw', 'nameEs' => 'Varsovia', 'nameUk' => 'Варшава', 'country' => 'PL'],
        ['name' => 'Krakow', 'nameEs' => 'Cracovia', 'nameUk' => 'Краків', 'country' => 'PL'],
        ['name' => 'Lodz', 'nameEs' => 'Lodz', 'nameUk' => 'Лодзь', 'country' => 'PL'],
        ['name' => 'Wroclaw', 'nameEs' => 'Breslavia', 'nameUk' => 'Вроцлав', 'country' => 'PL'],
        ['name' => 'Poznan', 'nameEs' => 'Poznan', 'nameUk' => 'Познань', 'country' => 'PL'],
        ['name' => 'Gdansk', 'nameEs' => 'Gdansk', 'nameUk' => 'Гданськ', 'country' => 'PL'],
        ['name' => 'Lublin', 'nameEs' => 'Lublin', 'nameUk' => 'Люблін', 'country' => 'PL'],
        ['name' => 'Katowice', 'nameEs' => 'Katowice', 'nameUk' => 'Катовіце', 'country' => 'PL'],
        ['name' => 'Bialystok', 'nameEs' => 'Bialystok', 'nameUk' => 'Білосток', 'country' => 'PL'],
        ['name' => 'Rzeszow', 'nameEs' => 'Rzeszow', 'nameUk' => 'Жешув', 'country' => 'PL'],
        ['name' => 'Przemysl', 'nameEs' => 'Przemysl', 'nameUk' => 'Перемишль', 'country' => 'PL'],
        ['name' => 'Zamosc', 'nameEs' => 'Zamosc', 'nameUk' => 'Замость', 'country' => 'PL'],
        ['name' => 'Chelm', 'nameEs' => 'Chelm', 'nameUk' => 'Холм', 'country' => 'PL'],
        ['name' => 'Hrubieszow', 'nameEs' => 'Hrubieszow', 'nameUk' => 'Грубешів', 'country' => 'PL'],
        ['name' => 'Medyka', 'nameEs' => 'Medyka', 'nameUk' => 'Медика', 'country' => 'PL'],
    ],

];
