CREATE DATABASE IF NOT EXISTS vinyl_catalog
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'vinyl_user'@'localhost' IDENTIFIED BY 'CHANGE_ME_strong_password';
GRANT ALL PRIVILEGES ON vinyl_catalog.* TO 'vinyl_user'@'localhost';
FLUSH PRIVILEGES;
