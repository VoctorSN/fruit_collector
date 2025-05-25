DROP SCHEMA IF EXISTS FRUIT_COLLECTOR;
CREATE SCHEMA FRUIT_COLLECTOR DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE FRUIT_COLLECTOR;

CREATE TABLE `Users` (
                         `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                         `name` VARCHAR(50) NULL,
                         UNIQUE KEY `user_name_unique` (`name`)
);

CREATE TABLE `Games` (
                         `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                         `created_at` DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
                         `last_time_played` DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
                         `space` SMALLINT UNIQUE NOT NULL,
                         `current_level` INT NOT NULL DEFAULT 0,
                         `total_deaths` INT NOT NULL DEFAULT 0,
                         `total_time` BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE `Settings` (
                            `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                            `game_id` BIGINT UNSIGNED NOT NULL,
                            `HUD_size` DOUBLE NOT NULL DEFAULT 0.0,
                            `control_size` DOUBLE NOT NULL DEFAULT 0.0,
                            `is_left_handed` BOOLEAN NOT NULL DEFAULT false,
                            `show_controls` BOOLEAN NOT NULL DEFAULT false,
                            `is_music_active` BOOLEAN NOT NULL DEFAULT true,
                            `is_sound_enabled` BOOLEAN NOT NULL DEFAULT true,
                            `game_volume` DOUBLE NOT NULL DEFAULT 0.0,
                            `music_volume` DOUBLE NOT NULL DEFAULT 0.0,
                            FOREIGN KEY (`game_id`) REFERENCES `Games` (`id`) ON DELETE CASCADE
);

CREATE TABLE `Achievements` (
                                `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                                `title`  VARCHAR(50) NOT NULL,
                                `description`  VARCHAR(300) NOT NULL,
                                `difficulty` SMALLINT NOT NULL,
                                UNIQUE KEY `achievements_title_unique` (`title`)
);

CREATE TABLE `Levels` (
                          `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                          `name`  VARCHAR(50) NOT NULL,
                          `difficulty` SMALLINT NOT NULL
);

CREATE TABLE `GameLevel` (
                             `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                             `level_id` BIGINT UNSIGNED NOT NULL,
                             `game_id` BIGINT UNSIGNED NOT NULL,
                             `completed` BOOLEAN NOT NULL DEFAULT 0,
                             `unlocked` BOOLEAN NOT NULL DEFAULT false,
                             `stars` SMALLINT NOT NULL DEFAULT 0,
                             `date_completed` DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
                             `last_time_completed` DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
                             `time` BIGINT NULL,
                             `deaths` INT NOT NULL DEFAULT 0,
                             FOREIGN KEY (`level_id`) REFERENCES `Levels` (`id`),
                             FOREIGN KEY (`game_id`) REFERENCES `Games` (`id`) ON DELETE CASCADE
);

CREATE TABLE `GameAchievement` (
                                   `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                                   `game_id` BIGINT UNSIGNED NOT NULL,
                                   `achievement_id` BIGINT UNSIGNED NOT NULL,
                                   `date_achieved` DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
                                   `achieved` BOOLEAN NOT NULL DEFAULT false,
                                   FOREIGN KEY (`game_id`) REFERENCES `Games` (`id`) ON DELETE CASCADE,
                                   FOREIGN KEY (`achievement_id`) REFERENCES `Achievements` (`id`)
);


INSERT INTO `Achievements` (`id`, `title`, `description`, `difficulty`) VALUES
                                                                            (1001, 'Completa el nivel 1', 'Has completado el nivel 1', 1),
                                                                            (1002, 'Completa todos los niveles', 'Has completado todos los niveles', 6),
                                                                            (1003, 'Nivel 4 superado', 'Has completado el nivel 4', 2),
                                                                            (1004, 'Speedrunner', 'Acaba el juego en menos de 300 segundos', 9),
                                                                            (1005, 'Sin morir', 'Completa el juego sin morir', 10),
                                                                            (1006, 'Estrellas de nivel 5', 'Encuentra todas las estrellas en el nivel 5', 5),
                                                                            (1007, 'Nivel 2 perfecto', 'Pásate el nivel 2 sin morir', 4),
                                                                            (1008, 'Nivel 6 en 5 seg', 'Completa el nivel 6 en menos de 5 segundos', 7);

INSERT INTO `Levels` (`name`, `difficulty`) VALUES
                                                ('tutorial-01', 1),
                                                ('tutorial-02', 1),
                                                ('tutorial-03', 2),
                                                ('tutorial-04', 2),
                                                ('tutorial-05', 3),
                                                ('level-01', 4),
                                                ('level-02', 4),
                                                ('level-03', 5),
                                                ('level-04', 5),
                                                ('level-05', 6),
                                                ('level-06', 6),
                                                ('level-07', 7),
                                                ('level-08', 8),
                                                ('level-98', 10);
                                                ('level-99', 10);
                                                ('level-100', 10);

DELIMITER $$

DELIMITER $$

-- create_game_at_space
DROP PROCEDURE IF EXISTS `create_game_at_space` $$
CREATE PROCEDURE `create_game_at_space` (
    IN `p_space_value` SMALLINT,
    OUT `p_new_game_id` BIGINT
)
BEGIN
    DECLARE existing_game_id BIGINT;

    -- Check if there is already a game in the given space
    SELECT id INTO existing_game_id
    FROM Games
    WHERE space = p_space_value
    LIMIT 1;

    -- If a game exists, delete it (related rows will be deleted via ON DELETE CASCADE)
    IF existing_game_id IS NOT NULL THEN
        DELETE FROM Games WHERE id = existing_game_id;
    END IF;

    -- Insert a new game in the specified space
    INSERT INTO Games (
        created_at,
        space
    )
    VALUES (
        NOW(),
        p_space_value
    );

    -- Retrieve the ID of the newly inserted game
    SET p_new_game_id = LAST_INSERT_ID();

    -- Insert default settings for the new game
    INSERT INTO Settings (game_id)
    VALUES (p_new_game_id);

    -- Populate GameLevel with all levels for the new game
    INSERT INTO GameLevel (game_id, level_id)
    SELECT p_new_game_id, id FROM Levels;

    -- Populate GameAchievement with all achievements for the new game
    INSERT INTO GameAchievement (game_id, achievement_id)
    SELECT p_new_game_id, id FROM Achievements;
END$$

-- insert_settings_for_game
DROP PROCEDURE IF EXISTS `insert_settings_for_game` $$
CREATE PROCEDURE `insert_settings_for_game` (
    IN `p_game_id` BIGINT UNSIGNED,
    IN `p_HUD_size` DOUBLE,
    IN `p_control_size` DOUBLE,
    IN `p_is_left_handed` BOOLEAN,
    IN `p_show_controls` BOOLEAN,
    IN `p_is_music_active` BOOLEAN,
    IN `p_is_sound_enabled` BOOLEAN,
    IN `p_game_volume` DOUBLE,
    IN `p_music_volume` DOUBLE,
    OUT `p_inserted_id` BIGINT UNSIGNED
)
BEGIN
    INSERT INTO Settings (
        game_id,
        HUD_size,
        control_size,
        is_left_handed,
        show_controls,
        is_music_active,
        is_sound_enabled,
        game_volume,
        music_volume
    )
    VALUES (
        p_game_id,
        p_HUD_size,
        p_control_size,
        p_is_left_handed,
        p_show_controls,
        p_is_music_active,
        p_is_sound_enabled,
        p_game_volume,
        p_music_volume
    );

    -- Return the ID of the newly inserted settings row
    SET p_inserted_id = LAST_INSERT_ID();
END$$

-- get_settings_by_game_id
DROP PROCEDURE IF EXISTS `get_settings_by_game_id` $$
CREATE PROCEDURE `get_settings_by_game_id` (
    IN `p_game_id` BIGINT UNSIGNED,
    OUT `p_id` BIGINT UNSIGNED,
    OUT `p_HUD_size` DOUBLE,
    OUT `p_control_size` DOUBLE,
    OUT `p_is_left_handed` BOOLEAN,
    OUT `p_show_controls` BOOLEAN,
    OUT `p_is_music_active` BOOLEAN,
    OUT `p_is_sound_enabled` BOOLEAN,
    OUT `p_game_volume` DOUBLE,
    OUT `p_music_volume` DOUBLE
)
BEGIN
    SELECT
        id,
        HUD_size,
        control_size,
        is_left_handed,
        show_controls,
        is_music_active,
        is_sound_enabled,
        game_volume,
        music_volume
    INTO
        p_id,
        p_HUD_size,
        p_control_size,
        p_is_left_handed,
        p_show_controls,
        p_is_music_active,
        p_is_sound_enabled,
        p_game_volume,
        p_music_volume
    FROM Settings
    WHERE game_id = p_game_id
    LIMIT 1;
END$$

-- get_game_by_space
DROP PROCEDURE IF EXISTS `get_game_by_space` $$
CREATE PROCEDURE `get_game_by_space` (
    IN `p_space` SMALLINT,
    OUT `p_id` BIGINT UNSIGNED,
    OUT `p_created_at` DATETIME,
    OUT `p_last_time_played` DATETIME,
    OUT `p_space_out` SMALLINT,
    OUT `p_current_level` INT,
    OUT `p_total_deaths` INT,
    OUT `p_total_time` BIGINT
)
BEGIN
    SELECT
        id,
        created_at,
        COALESCE(last_time_played, '1970-01-01 00:00:00'),
        space,
        current_level,
        total_deaths,
        total_time
    INTO
        p_id,
        p_created_at,
        p_last_time_played,
        p_space_out,
        p_current_level,
        p_total_deaths,
        p_total_time
    FROM Games
    WHERE space = p_space
    LIMIT 1;
END$$

-- get_or_create_game_by_space
DROP PROCEDURE IF EXISTS `get_or_create_game_by_space` $$
CREATE PROCEDURE `get_or_create_game_by_space` (
    IN `p_space` SMALLINT,
    OUT `p_id` BIGINT UNSIGNED,
    OUT `p_created_at` DATETIME,
    OUT `p_last_time_played` DATETIME,
    OUT `p_space_out` SMALLINT,
    OUT `p_current_level` INT,
    OUT `p_total_deaths` INT,
    OUT `p_total_time` BIGINT
)
BEGIN
    DECLARE v_game_id BIGINT;

    -- Check if game exists in the specified space
    SELECT id INTO v_game_id
    FROM Games
    WHERE space = p_space
    LIMIT 1;

    -- If no game found, create one
    IF v_game_id IS NULL THEN
        CALL create_game_at_space(p_space, v_game_id);
    END IF;

    -- Return the game (newly created or existing)
    SELECT
        id,
        created_at,
        last_time_played,
        space,
        current_level,
        total_deaths,
        total_time
    INTO
        p_id,
        p_created_at,
        p_last_time_played,
        p_space_out,
        p_current_level,
        p_total_deaths,
        p_total_time
    FROM Games
    WHERE space = p_space
    LIMIT 1;
END$$

-- get_game_levels_by_game_id
-- Since this returns multiple rows, we'll simulate OUT parameters by selecting a single row at a time using a cursor
DROP PROCEDURE IF EXISTS `get_game_levels_by_game_id` $$
CREATE PROCEDURE `get_game_levels_by_game_id` (
    IN `p_game_id` BIGINT UNSIGNED,
    OUT `p_id` BIGINT UNSIGNED,
    OUT `p_level_id` BIGINT UNSIGNED,
    OUT `p_level_name` VARCHAR(50),
    OUT `p_level_difficulty` SMALLINT,
    OUT `p_completed` BOOLEAN,
    OUT `p_unlocked` BOOLEAN,
    OUT `p_stars` SMALLINT,
    OUT `p_date_completed` DATETIME,
    OUT `p_last_time_completed` DATETIME,
    OUT `p_time` BIGINT,
    OUT `p_deaths` INT,
    OUT `p_has_next` BOOLEAN
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT
            gl.id,
            gl.level_id,
            l.name,
            l.difficulty,
            gl.completed,
            gl.unlocked,
            gl.stars,
            gl.date_completed,
            gl.last_time_completed,
            gl.time,
            gl.deaths
        FROM GameLevel gl
        INNER JOIN Levels l ON gl.level_id = l.id
        WHERE gl.game_id = p_game_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    FETCH cur INTO
        p_id,
        p_level_id,
        p_level_name,
        p_level_difficulty,
        p_completed,
        p_unlocked,
        p_stars,
        p_date_completed,
        p_last_time_completed,
        p_time,
        p_deaths;

    IF done = 1 THEN
        SET p_has_next = FALSE;
    ELSE
        SET p_has_next = TRUE;
    END IF;

    CLOSE cur;
END$$

-- get_game_achievements_by_game_id
-- Since this returns multiple rows, we'll use a cursor to simulate OUT parameters
DROP PROCEDURE IF EXISTS `get_game_achievements_by_game_id` $$
CREATE PROCEDURE `get_game_achievements_by_game_id` (
    IN `p_game_id` BIGINT UNSIGNED,
    OUT `p_id` BIGINT UNSIGNED,
    OUT `p_achievement_id` BIGINT UNSIGNED,
    OUT `p_achievement_title` VARCHAR(50),
    OUT `p_achievement_description` VARCHAR(300),
    OUT `p_achievement_difficulty` SMALLINT,
    OUT `p_date_achieved` DATETIME,
    OUT `p_achieved` BOOLEAN,
    OUT `p_has_next` BOOLEAN
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT
            ga.id,
            ga.achievement_id,
            a.title,
            a.description,
            a.difficulty,
            ga.date_achieved,
            ga.achieved
        FROM GameAchievement ga
        INNER JOIN Achievements a ON ga.achievement_id = a.id
        WHERE ga.game_id = p_game_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    FETCH cur INTO
        p_id,
        p_achievement_id,
        p_achievement_title,
        p_achievement_description,
        p_achievement_difficulty,
        p_date_achieved,
        p_achieved;

    IF done = 1 THEN
        SET p_has_next = FALSE;
    ELSE
        SET p_has_next = TRUE;
    END IF;

    CLOSE cur;
END$$

-- mark_achievement_as_achieved
DROP PROCEDURE IF EXISTS `mark_achievement_as_achieved` $$
CREATE PROCEDURE `mark_achievement_as_achieved` (
    IN `p_game_id` BIGINT UNSIGNED,
    IN `p_achievement_id` BIGINT UNSIGNED,
    OUT `p_rows_affected` INT
)
BEGIN
    UPDATE GameAchievement
    SET
        achieved = true,
        date_achieved = NOW()
    WHERE
        game_id = p_game_id AND
        achievement_id = p_achievement_id;

    SET p_rows_affected = ROW_COUNT();
END$$

-- update_game_level_by_game_id_and_level_name
DROP PROCEDURE IF EXISTS `update_game_level_by_game_id_and_level_name` $$
CREATE PROCEDURE `update_game_level_by_game_id_and_level_name` (
    IN `p_game_id` BIGINT UNSIGNED,
    IN `p_level_name` TEXT,
    IN `p_completed` BOOLEAN,
    IN `p_unlocked` BOOLEAN,
    IN `p_stars` SMALLINT,
    IN `p_date_completed` DATETIME,
    IN `p_last_time_completed` DATETIME,
    IN `p_time` BIGINT,
    IN `p_deaths` INT,
    OUT `p_rows_affected` INT
)
BEGIN
    UPDATE GameLevel gl
    INNER JOIN Levels l ON gl.level_id = l.id
    SET
        gl.completed = p_completed,
        gl.unlocked = p_unlocked,
        gl.stars = p_stars,
        gl.date_completed = p_date_completed,
        gl.last_time_completed = p_last_time_completed,
        gl.time = p_time,
        gl.deaths = p_deaths
    WHERE
        gl.game_id = p_game_id AND
        l.name = p_level_name;

    SET p_rows_affected = ROW_COUNT();
END$$

-- get_game_achievement_by_title_and_game_id
DROP PROCEDURE IF EXISTS `get_game_achievement_by_title_and_game_id` $$
CREATE PROCEDURE `get_game_achievement_by_title_and_game_id` (
    IN `p_game_id` BIGINT UNSIGNED,
    IN `p_title` TEXT,
    OUT `p_id` BIGINT UNSIGNED,
    OUT `p_achievement_id` BIGINT UNSIGNED,
    OUT `p_achievement_title` VARCHAR(50),
    OUT `p_description` VARCHAR(300),
    OUT `p_difficulty` SMALLINT,
    OUT `p_date_achieved` DATETIME,
    OUT `p_achieved` BOOLEAN
)
BEGIN
    SELECT
        ga.id,
        ga.achievement_id,
        a.title,
        a.description,
        a.difficulty,
        ga.date_achieved,
        ga.achieved
    INTO
        p_id,
        p_achievement_id,
        p_achievement_title,
        p_description,
        p_difficulty,
        p_date_achieved,
        p_achieved
    FROM GameAchievement ga
    INNER JOIN Achievements a ON ga.achievement_id = a.id
    WHERE
        ga.game_id = p_game_id AND
        a.title = p_title
    LIMIT 1;
END$$

-- get_all_games
-- Since this returns multiple rows, we'll use a cursor to simulate OUT parameters
DROP PROCEDURE IF EXISTS `get_all_games` $$
CREATE PROCEDURE `get_all_games` (
    OUT `p_id` BIGINT UNSIGNED,
    OUT `p_created_at` DATETIME,
    OUT `p_last_time_played` DATETIME,
    OUT `p_space` SMALLINT,
    OUT `p_current_level` INT,
    OUT `p_total_deaths` INT,
    OUT `p_total_time` BIGINT,
    OUT `p_has_next` BOOLEAN
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT
            id,
            created_at,
            last_time_played,
            space,
            current_level,
            total_deaths,
            total_time
        FROM Games
        ORDER BY id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    FETCH cur INTO
        p_id,
        p_created_at,
        p_last_time_played,
        p_space,
        p_current_level,
        p_total_deaths,
        p_total_time;

    IF done = 1 THEN
        SET p_has_next = FALSE;
    ELSE
        SET p_has_next = TRUE;
    END IF;

    CLOSE cur;
END$$

DELIMITER ;

DELIMITER ;