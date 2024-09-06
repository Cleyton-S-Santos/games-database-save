use railway

CREATE TABLE TB_GAMES_CATEGORY (
    game_category_id INT AUTO_INCREMENT PRIMARY KEY,
    game_category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE TB_GAMES (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    game_name VARCHAR(100) NOT NULL,
    game_image VARCHAR(400),
    game_main_category INT NOT NULL,
    game_secondary_category INT,
    UNIQUE (game_id, game_main_category, game_secondary_category),
    FOREIGN KEY (game_main_category) REFERENCES TB_GAMES_CATEGORY(game_category_id),
    FOREIGN KEY (game_secondary_category) REFERENCES TB_GAMES_CATEGORY(game_category_id)
);

CREATE TABLE TB_USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    user_email VARCHAR(100) NOT NULL,
    user_password_hash VARCHAR(100) NOT NULL,
    user_verified_account BOOLEAN
);

ALTER TABLE TB_USERS
ADD CONSTRAINT unique_user_email UNIQUE (user_email);

CREATE TABLE TB_GAMES_FEEDBACKS (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    score INT CHECK (score >= 0 AND score <= 50),
    user_origin INT NOT NULL,
    game_id INT NOT NULL,
    feedback VARCHAR(1000),
    FOREIGN KEY (user_origin) REFERENCES TB_USERS(user_id),
    FOREIGN KEY (game_id) REFERENCES TB_GAMES(game_id)
);

ALTER TABLE TB_GAMES
ADD COLUMN game_rating DOUBLE;


CREATE DEFINER=`root`@`%` TRIGGER `update_game_avg` AFTER INSERT ON `TB_GAMES_FEEDBACKS` FOR EACH ROW BEGIN
    -- Declare a variable to hold the average score
    DECLARE avg_score int;

    -- Calculate the average score for the game
    SELECT AVG(railway.TB_GAMES_FEEDBACKS.score)
    INTO avg_score
    FROM railway.TB_GAMES_FEEDBACKS
    WHERE game_id = NEW.game_id;

    -- Update the game rating in the TB_GAMES table
    UPDATE railway.TB_GAMES
    SET game_rating = avg_score
    WHERE game_id = NEW.game_id;
END

CREATE DEFINER=`root`@`%` TRIGGER `update_game_avg_on_update_feedback` AFTER UPDATE ON `TB_GAMES_FEEDBACKS` FOR EACH ROW BEGIN
    -- Declare a variable to hold the average score
    DECLARE avg_score int;

    -- Calculate the average score for the game
    SELECT AVG(railway.TB_GAMES_FEEDBACKS.score)
    INTO avg_score
    FROM railway.TB_GAMES_FEEDBACKS
    WHERE game_id = NEW.game_id;

    -- Update the game rating in the TB_GAMES table
    UPDATE railway.TB_GAMES
    SET game_rating = avg_score
    WHERE game_id = NEW.game_id;
END

CREATE DEFINER=`root`@`%` TRIGGER `update_game_avg_on_delete_feedback` AFTER DELETE ON `TB_GAMES_FEEDBACKS` FOR EACH ROW BEGIN
    -- Declare a variable to hold the average score
    DECLARE avg_score int;

    -- Calculate the average score for the game
    SELECT AVG(railway.TB_GAMES_FEEDBACKS.score)
    INTO avg_score
    FROM railway.TB_GAMES_FEEDBACKS
    WHERE game_id = OLD.game_id;

    -- Update the game rating in the TB_GAMES table
    UPDATE railway.TB_GAMES
    SET game_rating = avg_score
    WHERE game_id = OLD.game_id;
END
