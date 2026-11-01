-- Создание администратора.
-- Хеш пароля сгенерируйте локально и вставьте вместо PASTE_HASH_HERE:
--   php -r 'echo password_hash("ваш_пароль", PASSWORD_DEFAULT), PHP_EOL;'
USE vinyl_catalog;

INSERT INTO users (username, password_hash)
VALUES ('admin', 'PASTE_HASH_HERE');
