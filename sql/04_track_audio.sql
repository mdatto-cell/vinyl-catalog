-- Оцифровки треков. Только добавление колонок: старый код продолжает работать.
-- Повторный запуск безопасен (IF NOT EXISTS, MariaDB 10.0.2+).

ALTER TABLE records
    ADD COLUMN IF NOT EXISTS music_dir VARCHAR(255) NULL DEFAULT NULL
        COMMENT 'Имя папки в public/uploads/music';

ALTER TABLE records
    ADD UNIQUE INDEX IF NOT EXISTS uq_records_music_dir (music_dir);

ALTER TABLE record_tracks
    ADD COLUMN IF NOT EXISTS audio_path VARCHAR(500) NULL DEFAULT NULL
        COMMENT 'Ссылка на файл: /uploads/music/<папка>/<файл>',
    ADD COLUMN IF NOT EXISTS audio_format VARCHAR(8) NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS audio_size BIGINT UNSIGNED NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS audio_uploaded_at DATETIME NULL DEFAULT NULL;
