# Каталог виниловых пластинок

Каталог домашней коллекции винила на PHP и MariaDB/MySQL: витрина с обложками для гостей, админка для добавления и редактирования пластинок, импорт из Discogs, загрузка оцифровок треков с мини-плеером.

Рабочая установка: [catalog.beebzzz.ru](https://catalog.beebzzz.ru/).

## Возможности

**Каталог**
- Сетка обложек и список, тёмная и светлая темы. Тема хранится в cookie и в адрес не попадает.
- Поиск по исполнителю, альбому, номеру и баркоду. Фильтры по жанру, статусу и первой букве, сортировка по исполнителю, году и дате добавления.
- Карточка пластинки: фотографии с просмотром крупно, трек-лист, лейбл, годы альбома и издания.
- Значок «Слушать» на обложках альбомов, у которых есть оцифровки.

**Админка**
- Добавление и редактирование пластинок, до 10 фото на пластинку.
- Импорт релиза из Discogs: трек-лист, обложка, лейбл, годы.
- Трек-лист с отдельными полями позиции, названия и времени. Строки можно переставлять, добавлять и удалять, а также вставлять текстом (`A1 - Название - 4:32` или через TAB).
- Цена покупки и статус учёта видны только администратору. На плитках выводится цена, рядом со счётчиком — сумма по текущему фильтру.
- CSRF-защита всех POST-форм.

**Оцифровки** ([docs/audio.md](docs/audio.md))
- Загрузка FLAC, WAV и MP3 к каждому треку. Формат проверяется по сигнатуре файла, загрузка идёт с индикатором прогресса.
- Папка альбома `Исполнитель_-_[год]_-_Альбом`, файлы вида `01_Название_трека.flac`.
- Удаление файла отдельного трека или всей папки альбома. Ссылки на файлы хранятся в БД, диск не сканируется.
- Для гостей: кнопка «скачать» и мини-плеер с перемоткой и автопереходом к следующему треку.
- Необязательно: раздача через отдельный кеширующий хост ([docs/cdn.md](docs/cdn.md)) или через `X-Accel-Redirect`.

## Требования

- PHP 8.0+ с расширениями `pdo_mysql`, `mbstring`, `curl`, `fileinfo`. Расширение `intl` необязательно: оно транслитерирует имена файлов для старых браузеров.
- MariaDB 10.3+ (на ней проект работает и проверен). На MySQL 8.0 не проверялось; при обновлении старой БД на MySQL уберите `IF NOT EXISTS` из `sql/04_track_audio.sql`.
- Apache 2.4 (с `AllowOverride`) или Nginx + PHP-FPM.
- Сборка фронтенда не нужна: чистые CSS и JS. Шрифт Golos Text подключается из Google Fonts.

## Установка

```bash
git clone https://github.com/<you>/vinyl-catalog.git /var/www/vinyl-catalog
cd /var/www/vinyl-catalog

# 1. Конфиг
cp app/config.example.php app/config.php
nano app/config.php            # БД, токен Discogs, при желании AUDIO_BASE_URL

# 2. БД (в 01_create_database.sql замените пароль пользователя)
mysql -u root -p < sql/01_create_database.sql
mysql -u root -p vinyl_catalog < sql/02_schema.sql
# sql/04_track_audio.sql — только при обновлении старой БД

# 3. Администратор: сгенерируйте хеш и вставьте его в sql/03_create_admin.sql
php -r 'echo password_hash("ваш_пароль", PASSWORD_DEFAULT), PHP_EOL;'
mysql -u root -p vinyl_catalog < sql/03_create_admin.sql

# 4. Права на загрузки
chown -R www-data:www-data public/uploads
chmod 640 app/config.php && chown root:www-data app/config.php
```

Корень сайта должен указывать на `public/`. Папки `app/`, `sql/`, `tests/` и `docs/` не должны отдаваться веб-сервером.

**Apache**

```apache
<VirtualHost *:443>
    ServerName catalog.example.com
    DocumentRoot /var/www/vinyl-catalog/public
    <Directory /var/www/vinyl-catalog/public>
        AllowOverride All
        Require all granted
    </Directory>
    LimitRequestBody 2147483648
</VirtualHost>
```

**Nginx**

```nginx
server {
    server_name catalog.example.com;
    root /var/www/vinyl-catalog/public;
    index index.php;
    client_max_body_size 2g;

    location ^~ /uploads/ {
        location ~ \.php$ { return 403; }
        try_files $uri =404;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_read_timeout 900s;
    }
}
```

**PHP** (для больших FLAC): `upload_max_filesize = 2G`, `post_max_size = 2G`, `max_execution_time = 900`. Подробности в [docs/audio.md](docs/audio.md).

## Обновление существующей установки

1. Сделайте резервную копию файлов и БД.
2. `git pull`, или скопируйте `app/`, `public/`, `sql/` и `tests/` поверх текущих файлов. `app/config.php` и `public/uploads/` не трогайте.
3. Примените новые миграции из `sql/`. Они идемпотентны, повторный запуск безопасен.
4. Если OPcache настроен без проверки изменений файлов, перезапустите PHP-FPM.

Старые ссылки с `?theme=light` по-прежнему работают: тема запоминается в cookie, параметр убирается из адресной строки.

## Структура

```
app/            ядро: БД, авторизация, шаблон, треки, Discogs, аудио, конфиг
public/         корень сайта: страницы, админка, ассеты, uploads/
  admin/        добавление, редактирование, Discogs, API загрузки аудио
  assets/       style.css, gallery.css, site.js
  uploads/      фото пластинок (records/) и оцифровки (music/), не в git
sql/            схема и миграции
tests/          консольные тесты
docs/           оцифровки и раздача через CDN
```

## Тесты

```bash
php tests/tracks_test.php          # разбор трек-листов, валидация, Discogs на фикстурах
php tests/tracks_test.php --db     # то же плюс запись в БД внутри транзакции (только на тестовой БД)
php tests/audio_test.php [dir]     # имена папок и файлов, защита путей; dir — папка с t.flac/t.wav/t.mp3
```

Для тестов нужен `app/config.php`.

## Безопасность

- `app/config.php`, дампы БД и загруженные файлы в репозиторий не попадают (см. `.gitignore`).
- В `public/uploads/` выполнение PHP запрещено через `.htaccess`. Для Nginx есть правило в примере выше.
- Цены, статусы и админские действия доступны только после входа. API загрузки аудио проверяет сессию и CSRF-токен.
- HTML-страницы отдаются с `Cache-Control: private, no-store`. Не кешируйте их на CDN.
