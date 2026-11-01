-- Полная схема каталога (снята с рабочей БД, без данных).
-- Новая установка: mysql vinyl_catalog < sql/02_schema.sql
-- Колонки оцифровок уже включены; 04_track_audio.sql нужна только для обновления старых БД.
USE vinyl_catalog;

CREATE TABLE IF NOT EXISTS `records` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `artist` varchar(255) NOT NULL,
  `album_title` varchar(255) NOT NULL,
  `tracklist_text` mediumtext DEFAULT NULL,
  `release_year` smallint(5) unsigned DEFAULT NULL,
  `album_year` smallint(5) unsigned DEFAULT NULL,
  `catalog_number` varchar(255) DEFAULT NULL,
  `barcode` varchar(255) DEFAULT NULL,
  `pressing_plant` varchar(255) DEFAULT NULL,
  `label_name` varchar(255) DEFAULT NULL,
  `genre_name` varchar(255) DEFAULT NULL,
  `style_name` varchar(255) DEFAULT NULL,
  `acquired_at` datetime DEFAULT NULL,
  `purchase_price` decimal(10,2) DEFAULT NULL,
  `purchase_price_usd` decimal(10,2) DEFAULT NULL,
  `sale_price` decimal(10,2) DEFAULT NULL,
  `storage_status` enum('in_stock','expected','lent_out') NOT NULL DEFAULT 'in_stock',
  `notes` text DEFAULT NULL,
  `discogs_release_id` int(10) unsigned DEFAULT NULL,
  `media_condition` varchar(64) DEFAULT NULL,
  `sleeve_condition` varchar(64) DEFAULT NULL,
  `discogs_image_url` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `music_dir` varchar(255) DEFAULT NULL COMMENT 'Имя папки в public/uploads/music',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_records_music_dir` (`music_dir`),
  KEY `idx_artist` (`artist`),
  KEY `idx_album_title` (`album_title`),
  KEY `idx_catalog_number` (`catalog_number`),
  KEY `idx_barcode` (`barcode`),
  KEY `idx_storage_status` (`storage_status`),
  KEY `idx_discogs_release_id` (`discogs_release_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `record_photos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `record_id` int(10) unsigned NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_record_photos_record_id` (`record_id`),
  CONSTRAINT `fk_photos_record` FOREIGN KEY (`record_id`) REFERENCES `records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `record_tracks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `record_id` int(10) unsigned NOT NULL,
  `position` varchar(32) DEFAULT NULL,
  `track_title` varchar(255) NOT NULL,
  `duration` varchar(32) DEFAULT NULL,
  `sort_order` int(10) unsigned NOT NULL DEFAULT 0,
  `audio_path` varchar(500) DEFAULT NULL COMMENT 'Ссылка на файл: /uploads/music/<папка>/<файл>',
  `audio_format` varchar(8) DEFAULT NULL,
  `audio_size` bigint(20) unsigned DEFAULT NULL,
  `audio_uploaded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_record_tracks_record_id` (`record_id`),
  CONSTRAINT `fk_tracks_record` FOREIGN KEY (`record_id`) REFERENCES `records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

