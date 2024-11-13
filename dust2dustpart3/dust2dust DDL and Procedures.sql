DROP SCHEMA IF EXISTS dust2dust;
CREATE SCHEMA dust2dust;
USE dust2dust;

/*
   ____                _         ____        _        _                    
  / ___|_ __ ___  __ _| |_ ___  |  _ \  __ _| |_ __ _| |__   __ _ ___  ___ 
 | |   | '__/ _ \/ _` | __/ _ \ | | | |/ _` | __/ _` | '_ \ / _` / __|/ _ \
 | |___| | |  __/ (_| | ||  __/ | |_| | (_| | || (_| | |_) | (_| \__ \  __/
  \____|_|  \___|\__,_|\__\___| |____/ \__,_|\__\__,_|_.__/ \__,_|___/\___|
                                                                           
*/
DROP PROCEDURE IF EXISTS create_database;

DELIMITER $$

CREATE PROCEDURE create_database()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SELECT 'Database error occured!' AS MESSAGE_TEXT;
	END;

	START TRANSACTION;
	DROP SCHEMA IF EXISTS dust2dust;
	CREATE SCHEMA dust2dust;
	/* DROP TABLE IF EXISTS `tile`;
	DROP TABLE IF EXISTS `inventory`;
	DROP TABLE IF EXISTS `item`;
	DROP TABLE IF EXISTS `npc`;
	DROP TABLE IF EXISTS `grid`;
	DROP TABLE IF EXISTS `map`;
	DROP TABLE IF EXISTS `game`;
	DROP TABLE IF EXISTS `character`;
	DROP TABLE IF EXISTS `user_account`; */

/*
 GAME, MAP, GRID
 A game of Dust2Dust comes into existance when at least one player enters a game. 
 From that point the game will be active and any other players will join the game on that ID. A single game can handle up to 10 players at once. 
 When a character attempts to join a game excessive of 10 players, a new game will be generated for that player to enter. 

 */

	CREATE TABLE `game`(
		`gameID` INT AUTO_INCREMENT PRIMARY KEY,
		`runtime` TIME DEFAULT 0,
		`status` VARCHAR(10) NOT NULL DEFAULT 'Active'
	);

	CREATE TABLE `map`(
		`mapID` INT AUTO_INCREMENT PRIMARY KEY,
		`gameID` INT,
		`maxRow` INT DEFAULT 10,
		`maxCol` INT DEFAULT 10,
		FOREIGN KEY (`gameID`) REFERENCES `game` (`gameID`)	
        ON DELETE CASCADE
	);

	/*
	 USER_ACCOUNT TABLE DROP AND CREATION
	 The purpose of the user_account table is to create and store accounts for player and admin-level users of the game. 
	 Each account is identified by a unique username (PK) and requires a unique email. 
	 The email, though a candidate key, cannot be used as the username will be public to other players and would be a breach of privacy. 
	 Only the user's first name is nessessary.
	 The account type distingusihes standard player from administrator level abilities in the system
	 
	 */

	CREATE TABLE `user_account`(
		`username` VARCHAR(50) PRIMARY KEY UNIQUE,
		`email` VARCHAR(255) UNIQUE,
		`password` VARCHAR(100),
		`firstName` VARCHAR(100),
		`accountType` VARCHAR(25) DEFAULT 'Player',
		`status` VARCHAR(25) DEFAULT 'Logged Out',
		`attempts` INT (3) DEFAULT 0
	);

	/*
	 CHARACTER TABLE DROP AND CREATION
	 The purpose of the character table is to store both static and dynamic data on a player character including
	 the character name (unique, PK), the player's username (FK), their base/current health during an active game, 
	 score during an active game, highest score earned, the status of the character (active or inactive), the id of the game they are active in,
	 the time of their last attack, application of an attack cooldown, 
	 a timer for their last movement, and an AFK check which will log them out of the game from the server side if inactive for too long

	 */

	CREATE TABLE `character`(
		`username` VARCHAR(50) PRIMARY KEY, 
		`gameID` INT NULL,
		`status` VARCHAR (10) DEFAULT 'Offline',
		`health` INT(4) DEFAULT 10,
		`currentScore` INT(10) DEFAULT 0,
		`highScore` INT(10) DEFAULT 0,
		`lastAttack` TIME DEFAULT 0,
		`attackCooldown` VARCHAR (10) DEFAULT 'OFF',
		`invincibility` VARCHAR (10) DEFAULT 'OFF',
		`lastMove` TIME DEFAULT 0,
		`afk` VARCHAR (10) DEFAULT 'OFF',
		FOREIGN KEY (`username`) REFERENCES `user_account` (`username`)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
		FOREIGN KEY (`gameID`) REFERENCES `game` (`gameID`)
		ON DELETE CASCADE
	);


	/* ITEM CREATE TABLE */

	CREATE TABLE `item`(
		`itemID` INT PRIMARY KEY,
		`itemName` VARCHAR(25),
		`description` TEXT,
		`damagePoints` INT(2) NULL,
		`healthPoints` INT(2) NULL
	);

	/* NPC CREATE TABLE */
	CREATE TABLE `npc`(
		`npcID` INT PRIMARY KEY, 
		`npcName` VARCHAR(100),
		`dialogue` TEXT,
		`itemID` INT NULL
	);

	/* TILE CREATE TABKE */

	CREATE TABLE `tile`(
		`tileID` INT AUTO_INCREMENT,
		`mapID` INT,
		`row` INT NOT NULL,
		`col` INT NOT NULL,
		`tileType` INT NOT NULL DEFAULT 0,
		`npcID` INT NULL,
		`itemID` INT NULL, 
		`username` VARCHAR(50) NULL,
		`movementTimer` TIME,
		PRIMARY KEY (`tileID`, `mapID`),
		FOREIGN KEY (`mapID`) REFERENCES `map` (`mapID`)
		ON DELETE CASCADE,
		FOREIGN KEY (`npcID`) REFERENCES `npc` (`npcID`),
		FOREIGN KEY (`itemID`) REFERENCES `item` (`itemID`),
		FOREIGN KEY (`username`) REFERENCES `character` (`username`)
		ON DELETE CASCADE
		ON UPDATE CASCADE
	);

	/* INVENTORY CREATE TABLE */

	CREATE TABLE `inventory`( 
		`username` VARCHAR(50),
		`itemID` INT, 
		`quantity` INT NULL,
		PRIMARY KEY (`username`, `itemID`),
		FOREIGN KEY (`username`) REFERENCES `character` (`username`)
		ON DELETE CASCADE,
		FOREIGN KEY (`itemID`) REFERENCES `item` (`itemID`)
	);
	COMMIT;
END $$

DELIMITER ;

-- CALL CREATE DATABASE PROCEDURE 
CALL create_database;

/*
  ___                     _     _____         _     ____        _        
 |_ _|_ __  ___  ___ _ __| |_  |_   _|__  ___| |_  |  _ \  __ _| |_ __ _ 
  | || '_ \/ __|/ _ \ '__| __|   | |/ _ \/ __| __| | | | |/ _` | __/ _` |
  | || | | \__ \  __/ |  | |_    | |  __/\__ \ |_  | |_| | (_| | || (_| |
 |___|_| |_|___/\___|_|   \__|   |_|\___||___/\__| |____/ \__,_|\__\__,_|
                                                                         
*/
USE dust2dust;

DROP PROCEDURE IF EXISTS insert_test_data;

DELIMITER $$

CREATE PROCEDURE insert_test_data()
COMMENT 'Inserting test data for dust2dust application testing'
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SELECT 'Database error occured!' AS MESSAGE_TEXT;
	END;
	START TRANSACTION;
	INSERT INTO user_account (`username`, `email`,`password`, `firstName`, `accountType`, `status`) VALUES ('test', 'test@email.com', 'test', 'test', 'Admin', 'Active');
    INSERT INTO user_account (`username`, `email`,`password`, `firstName`, `accountType`, `status`) VALUES ('KbyzFTW', 'kbyz@email.co.nz', 'CoolioJulio', 'Kira', 'Player', 'In-game');
	INSERT INTO user_account (`username`, `email`,`password`, `firstName`, `accountType`, `status`) VALUES ('DielgaChu', 'jbabs@email.co.nz', 'SwampStench', 'Julia', 'Player', 'Logged-out');
	INSERT INTO user_account (`username`, `email`,`password`, `firstName`, `accountType`, `status`) VALUES ('Fulmini', 'rossia@email.co.au', 'FKAGoth', 'Alex', 'Player', 'Logged-out');
	INSERT INTO user_account (`username`, `email`,`password`, `firstName`, `accountType`, `status`) VALUES ('Verga', 'generalmarx@email.com', 'CoconutTree', 'Mark', 'Player', 'Logged-out');
	INSERT INTO user_account (`username`, `email`,`password`, `firstName`, `accountType`, `status`) VALUES ('VintageSistah', 'jnel@email.co.nz', 'savblanc2019', 'Junel', 'Player', 'Logged-out');
	INSERT INTO user_account (`username`, `email`,`password`, `firstName`, `accountType`, `status`) VALUES ('KyrVorga', 'rhydawg@email.co.nz', 'somethingHard1', 'Rhylei', 'Player', 'Logged-out');

	/* INSERT GAME */
	INSERT INTO `game` (gameID, runtime, status) VALUES (1, '00:00:00', 'Active');

	/*INSERT NPC DATA*/
	INSERT INTO `npc` (`npcID`, `npcName`, `dialogue`, `itemID`) VALUES (1, 'Clyde Barrow', 'Hey partner! Im on the run and these bullets are weighing me down! Here, take some!', 1);
	INSERT INTO `npc` (`npcID`, `npcName`, `dialogue`) VALUES (2, 'Wyatt Earp', 'I got my eye on you, cowpoke.');

	/* INSERT ITEM DATA*/
	INSERT INTO `item` (`itemID`, `itemName`, `description`, `damagePoints`) VALUES (1, 'Bullet', 'Put this in your revolver, point, and shoot.', 1);
	INSERT INTO `item` (`itemID`, `itemName`, `description`, `healthPoints`) VALUES (2, 'Whiskey', 'Drink this for your vitality.', 2);


	/* INSERT PLAYER CHARACTER DATA
	 Displays two player characters at different states, offline with only relevant data, and online with current in-game data.
	  */
	INSERT INTO `character` (`username`, `gameID`) VALUES ('test', 1);


	/*INSERT INVENTORY DATA*/
	INSERT INTO `inventory` (`username`, `itemID`, `quantity`) VALUES ('test', 1, 3);
	INSERT INTO `inventory` (`username`, `itemID`, `quantity`) VALUES ('test', 2, 0);
	
	COMMIT;
    
END $$
DELIMITER ;

-- CALL INSERT TEST DATA PROCEDURE
CALL insert_test_data;

/*
  _                _          ___     _               _               _   
 | |    ___   __ _(_)_ __    ( _ )   | |    ___   ___| | _____  _   _| |_ 
 | |   / _ \ / _` | | '_ \   / _ \/\ | |   / _ \ / __| |/ / _ \| | | | __|
 | |__| (_) | (_| | | | | | | (_>  < | |__| (_) | (__|   < (_) | |_| | |_ 
 |_____\___/ \__, |_|_| |_|  \___/\/ |_____\___/ \___|_|\_\___/ \__,_|\__|
             |___/                                                        
*/

DROP PROCEDURE IF EXISTS login;

DELIMITER $$

CREATE PROCEDURE login(IN `username_para` VARCHAR(50), IN `password_para` VARCHAR(100))
COMMENT 'Check login parameters'
BEGIN
DECLARE `status` VARCHAR(10) DEFAULT 'Logged out';
DECLARE `attempts` INT DEFAULT 0;
START TRANSACTION;
    
    SELECT ua.`status`, ua.`attempts`
    INTO `status`, `attempts`
    FROM `user_account` ua
    WHERE ua.`username` = `username_para`;

    IF `status` = 'Locked' THEN
        SELECT 'Account Locked' AS MESSAGE;
    ELSEIF EXISTS (
        SELECT 1
        FROM `user_account` ua
        WHERE ua.`username` = `username_para`
        AND ua.`password` = `password_para`
    ) THEN
        UPDATE `user_account` ua
        SET ua.`status` = 'Online',
            ua.`attempts` = 0
        WHERE ua.`username` = `username_para`;
        SELECT 'Logged In' AS MESSAGE;
    ELSE
        UPDATE `user_account` ua
        SET ua.`attempts` = ua.`attempts` + 1
        WHERE ua.`username` = `username_para`;

        SELECT ua.`attempts`
        INTO `attempts`
        FROM `user_account` ua
        WHERE ua.`username` = `username_para`;
	-- Prepare account locked message for excess of login attemps
        IF `attempts` >= 3 THEN
            UPDATE `user_account` ua
            SET ua.`status` = 'Locked'
            WHERE ua.`username` = `username_para`;
            SELECT 'Invalid Login: Account Locked' AS MESSAGE;
		-- If attempts are less than 3, handle invalid login attempt
        ELSE
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Invalid login details!';
        END IF;
    END IF;
COMMIT;

END $$

DELIMITER ;

/*
  _                            _   
 | |    ___   __ _  ___  _   _| |_ 
 | |   / _ \ / _` |/ _ \| | | | __|
 | |__| (_) | (_| | (_) | |_| | |_ 
 |_____\___/ \__, |\___/ \__,_|\__|
             |___/                 
*/
DROP PROCEDURE IF EXISTS logout;

DELIMITER $$
CREATE PROCEDURE logout(IN `username_para` VARCHAR (50))
BEGIN
	DECLARE `status` VARCHAR (10);
    
    -- Update the new status
	SELECT ua.`status`
    INTO `status`
    FROM `user_account` ua
    WHERE ua.`username` = `username_para`;
    
    -- Rollback update if attempting to logout a user that is already logged out
    SELECT ua.`status` FROM `user_account` ua
    WHERE ua.`username` = `username_para`;
	IF `status` = 'Logged out' THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT  = "Error: That account is already logged out.";
	END IF;
    
    -- Update the status field to display the correct data
	UPDATE `user_account` ua
	SET ua.`status` = 'Logged out'
	WHERE ua.`username` = `username_para`;
    SELECT 'Logged Out' AS MESSAGE;
    
COMMIT;
END $$

DELIMITER ;


/*
  ____            _     _                 _                             _   
 |  _ \ ___  __ _(_)___| |_ ___ _ __     / \   ___ ___ ___  _   _ _ __ | |_ 
 | |_) / _ \/ _` | / __| __/ _ \ '__|   / _ \ / __/ __/ _ \| | | | '_ \| __|
 |  _ <  __/ (_| | \__ \ ||  __/ |     / ___ \ (_| (_| (_) | |_| | | | | |_ 
 |_| \_\___|\__, |_|___/\__\___|_|    /_/   \_\___\___\___/ \__,_|_| |_|\__|
            |___/                                                           
*/
DROP PROCEDURE IF EXISTS signup;

DELIMITER $$

CREATE PROCEDURE signup (IN `username_para` VARCHAR(50), IN `email_para` VARCHAR(255), IN `password_para` VARCHAR(100), IN `firstName_para` VARCHAR (100))
BEGIN
	DECLARE var_exists INT;
    
    START TRANSACTION; 
    
-- Check existing usernames in user account table
	SELECT COUNT(*) INTO var_exists
	FROM user_account
	WHERE `username` = `username_para`;
	IF var_exists > 0 THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'That username is taken! Try something different.';
	END IF;
-- Check existing email in user account table
	SELECT COUNT(*) INTO var_exists
	FROM user_account
	WHERE `email` = `email_para`;
	IF var_exists > 0 THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'That email address is already in use! Try something different.';
	END IF;
-- Reject null criteria
	IF (`username_para` IS NULL OR `username_para` = '') 
		OR (`email_para` IS NULL OR `email_para` = '') 
		OR (`password_para` IS NULL OR `password_para` = '')  
        OR (`firstName_para` IS NULL OR `firstName_para` = '') THEN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Some fields are null!';
	END IF;

-- Insert new user if critera is acceptable 
	INSERT INTO user_account (`username`, `email`, `password`, `firstName`) VALUES (`username_para`, `email_para`, `password_para`, `firstName_para`);
	SELECT 'Account created!' AS MESSAGE;
    
COMMIT;

END $$

DELIMITER ;


/*
  _____    _ _ _        _                             _   
 | ____|__| (_) |_     / \   ___ ___ ___  _   _ _ __ | |_ 
 |  _| / _` | | __|   / _ \ / __/ __/ _ \| | | | '_ \| __|
 | |__| (_| | | |_   / ___ \ (_| (_| (_) | |_| | | | | |_ 
 |_____\__,_|_|\__| /_/   \_\___\___\___/ \__,_|_| |_|\__|
                                                          
*/

DROP PROCEDURE IF EXISTS edit_account;

DELIMITER $$

CREATE PROCEDURE edit_account (IN `username_para` VARCHAR(50), IN `new_username_para` VARCHAR (50), IN `new_email_para` VARCHAR(255), IN `new_password_para` VARCHAR(100), IN `new_firstName_para` VARCHAR (100))
BEGIN
	DECLARE var_exists INT;
    
    START TRANSACTION;
-- Check existing usernames in user account table
	SELECT COUNT(*) INTO var_exists
	FROM user_account
	WHERE `username` = `new_username_para`;
	IF var_exists > 0 THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That username is taken! Try something different.';
	END IF;
-- Check existing email in user account table
	SELECT COUNT(*) INTO var_exists
	FROM user_account
	WHERE `email` = `new_email_para`;
	IF var_exists > 0 THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That email address is already in use! Try something different.';
	END IF;
-- Reject null criteria
	IF (`username_para` IS NULL OR `username_para` = '') 
		OR (`new_username_para` IS NULL OR `new_username_para` = '') 
        OR (`new_email_para` IS NULL OR `new_email_para` = '') 
        OR (`new_password_para` IS NULL OR `new_password_para` = '')  
        OR (`new_firstName_para` IS NULL OR `new_firstName_para` = '') THEN
        ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Some fields are null!';
	END IF;

-- Insert new user if critera is acceptable 
	UPDATE `user_account` 
		SET 
			`username` = `new_username_para`,
			`email` = `new_email_para`,
			`password` = `new_password_para`,
			`firstName` = `new_firstName_para`
		WHERE `username` = `username_para`;
		SELECT 'Account updated!' AS MESSAGE;
	COMMIT;

END $$

DELIMITER ;

/*
  ____                 _    _ _      _                             _       
 / ___|  ___  ___     / \  | | |    / \   ___ ___ ___  _   _ _ __ | |_ ___ 
 \___ \ / _ \/ _ \   / _ \ | | |   / _ \ / __/ __/ _ \| | | | '_ \| __/ __|
  ___) |  __/  __/  / ___ \| | |  / ___ \ (_| (_| (_) | |_| | | | | |_\__ \
 |____/ \___|\___| /_/   \_\_|_| /_/   \_\___\___\___/ \__,_|_| |_|\__|___/
                                                                           
*/
DROP PROCEDURE IF EXISTS all_accounts;

DELIMITER $$

CREATE PROCEDURE all_accounts()
BEGIN
-- Delare an error handler 
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
	ROLLBACK;
	SELECT 'Database error occured!' AS MESSAGE_TEXT;
END;
START TRANSACTION;
	-- Select all from the user_account table
	SELECT * 
    FROM user_account;
    
COMMIT;

END $$

DELIMITER ;

-- TEST SEE ALL ACCOUNTS PROCEDURE
CALL all_accounts;

/*
  ____                   _                             _   
 | __ )  __ _ _ __      / \   ___ ___ ___  _   _ _ __ | |_ 
 |  _ \ / _` | '_ \    / _ \ / __/ __/ _ \| | | | '_ \| __|
 | |_) | (_| | | | |  / ___ \ (_| (_| (_) | |_| | | | | |_ 
 |____/ \__,_|_| |_| /_/   \_\___\___\___/ \__,_|_| |_|\__|
                                                           
*/

DROP PROCEDURE IF EXISTS ban_account;

DELIMITER $$

CREATE PROCEDURE ban_account (IN `username_para` VARCHAR(50))
COMMENT 'Lock player account, preventing login attempts until unlocked.'
BEGIN
	DECLARE `new_status` VARCHAR (50);
    DECLARE `var_exists` INT;
	
    START TRANSACTION;
    
    -- Update the status field with the new status delcaration
    SELECT `status`
		INTO `new_status`
		FROM `user_account`
		WHERE `username` = `username_para` FOR UPDATE;
        
	-- Check for existing usernames
	SELECT COUNT(*) INTO `var_exists`
		FROM `user_account`
		WHERE `username` = `username_para`;
		IF `var_exists` <= 0 THEN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That username does not exist!.';
	END IF;
    -- Throw rollback error if username parammeter is null
    IF `username_para` IS NULL OR `username_para` = ' ' THEN
		ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Username field was null!';
	END IF;
    
	-- Update the status of the username with the matching parameter input if the account is not already banned
    IF `new_status` != 'Locked' THEN
		UPDATE `user_account`
		SET `status` = 'Locked'
		WHERE `username` = `username_para`;
        
		SELECT 'Account banned!' AS MESSAGE_TEXT;
	ELSE
		ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That account has already been banned!';
	END IF;
    
COMMIT;

END $$

DELIMITER ;

/*
  _   _       _                      _                             _   
 | | | |_ __ | |__   __ _ _ __      / \   ___ ___ ___  _   _ _ __ | |_ 
 | | | | '_ \| '_ \ / _` | '_ \    / _ \ / __/ __/ _ \| | | | '_ \| __|
 | |_| | | | | |_) | (_| | | | |  / ___ \ (_| (_| (_) | |_| | | | | |_ 
  \___/|_| |_|_.__/ \__,_|_| |_| /_/   \_\___\___\___/ \__,_|_| |_|\__|
                                                                       
*/
DROP PROCEDURE IF EXISTS unban_account;

DELIMITER $$

CREATE PROCEDURE unban_account (IN `username_para` VARCHAR(50))
COMMENT 'Unlock player account, allowing login attempts.'
BEGIN
	DECLARE `new_status` VARCHAR (50);
    DECLARE `var_exists` INT;
    
    START TRANSACTION;
    
    -- Update the status field with the new status delcaration
    SELECT `status`
		INTO `new_status`
		FROM `user_account`
		WHERE `username` = `username_para` FOR UPDATE;
        
	-- Check for existing usernames
	SELECT COUNT(*) INTO `var_exists`
		FROM `user_account`
		WHERE `username` = `username_para`;
		IF `var_exists` <= 0 THEN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That username does not exist!.';
	END IF;
    -- Throw rollback error if username parammeter is null
    IF `username_para` IS NULL OR `username_para` = '' THEN
		ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Username field was null!';
	END IF;
    
	-- Update the status of the username with the matching parameter input if the account is not already banned
    IF `new_status` = 'Locked' THEN
		UPDATE `user_account` 
		SET `status` = 'Logged out'
		WHERE `username` = `username_para`;
        
		SELECT 'Account unbanned!' AS MESSAGE_TEXT;
	ELSE
		ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That account has already unlocked!';
	END IF;
    
COMMIT;

END $$

DELIMITER ;

/*
  ____       _      _            _                             _   
 |  _ \  ___| | ___| |_ ___     / \   ___ ___ ___  _   _ _ __ | |_ 
 | | | |/ _ \ |/ _ \ __/ _ \   / _ \ / __/ __/ _ \| | | | '_ \| __|
 | |_| |  __/ |  __/ ||  __/  / ___ \ (_| (_| (_) | |_| | | | | |_ 
 |____/ \___|_|\___|\__\___| /_/   \_\___\___\___/ \__,_|_| |_|\__|
                                                                   
*/
DROP PROCEDURE IF EXISTS delete_account;

DELIMITER $$

CREATE PROCEDURE delete_account(IN `username_para` VARCHAR(50))
COMMENT 'Delete user account.'
BEGIN
	DECLARE var_exists INT;
    
	START TRANSACTION;
    SELECT COUNT(*) INTO var_exists
	FROM `user_account`
	WHERE `username` = `username_para`;
	IF var_exists <= 0 THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That username does not exist!.';
	END IF;
    -- Throw rollback error if username parammeter is null
    IF `username_para` IS NULL OR `username_para` = ' ' THEN
		ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Username field was null!';
	ELSE
		DELETE
		FROM user_account ua 
		WHERE ua.username = `username_para`;
    
	END IF;
    
SELECT 'Account deleted!' AS MESSAGE_TEXT;

COMMIT;

END $$

DELIMITER ; 

/*
  ____                 _                 _            _____ _ _        _____                      
 |  _ \ __ _ _ __   __| | ___  _ __ ___ (_)___  ___  |_   _(_) | ___  |_   _|   _ _ __   ___  ___ 
 | |_) / _` | '_ \ / _` |/ _ \| '_ ` _ \| / __|/ _ \   | | | | |/ _ \   | || | | | '_ \ / _ \/ __|
 |  _ < (_| | | | | (_| | (_) | | | | | | \__ \  __/   | | | | |  __/   | || |_| | |_) |  __/\__ \
 |_| \_\__,_|_| |_|\__,_|\___/|_| |_| |_|_|___/\___|   |_| |_|_|\___|   |_| \__, | .__/ \___||___/
                                                                            |___/|_|              
*/
DROP FUNCTION IF EXISTS get_tile_type;

DELIMITER $$

CREATE FUNCTION get_tile_type() RETURNS INT
COMMENT 'Function to generate different tile types when called in the draw_gameboard procedure'
DETERMINISTIC 
BEGIN
	-- Create tileType 1 to represent an item on a tile
	IF ROUND(RAND() * 3) = 2 THEN
		RETURN 1;
	-- Create tileType 2 to represent an NPC on a tile
	ELSEIF ROUND(RAND() * 2) = 1 THEN
		RETURN 2;
	ELSE
    -- Create tileType 0 to represent an empty tile
		RETURN 0;
	END IF;	
END $$

DELIMITER ;


/*
   ____                _         _   _                  ____                      
  / ___|_ __ ___  __ _| |_ ___  | \ | | _____      __  / ___| __ _ _ __ ___   ___ 
 | |   | '__/ _ \/ _` | __/ _ \ |  \| |/ _ \ \ /\ / / | |  _ / _` | '_ ` _ \ / _ \
 | |___| | |  __/ (_| | ||  __/ | |\  |  __/\ V  V /  | |_| | (_| | | | | | |  __/
  \____|_|  \___|\__,_|\__\___| |_| \_|\___| \_/\_/    \____|\__,_|_| |_| |_|\___|
                                                                                  
*/

DROP PROCEDURE IF EXISTS draw_gameboard;

DELIMITER $$

CREATE PROCEDURE draw_gameboard(IN `maxRow_para` INT, IN `maxCol_para` INT)
BEGIN
	DECLARE new_game_id INT;
	DECLARE new_map_id INT;
	DECLARE current_row INT DEFAULT 0;
	DECLARE current_col INT DEFAULT 0;
	DECLARE tile_type INT DEFAULT 0;
    /*
    EXIT HANDLER CAUSING ISSUES
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SELECT 'Database error occured!' AS MESSAGE_TEXT;
    END;
	*/
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION;

-- Create a new gameID based on the next numerical order from the last insterted gameID
	INSERT INTO `game` (`status`) VALUES ('Active');
	SET new_game_id = LAST_INSERT_ID();

	-- Create a new mapID based on the next numerical order from the last insterted mapID and related to the last inserted gameID (above)
	INSERT INTO `map` (`gameID`) VALUES (new_game_id);
	SET new_map_id = LAST_INSERT_ID();
	-- Create maxium rows and columns that end at a given border, set the tile type with the tile type function to place an item (1) or npc (2) at random
		WHILE current_row < `maxRow_para` DO
			WHILE current_col < `maxCol_para` DO
				SET tile_type = get_tile_type();
			
				 -- Insert an id for each row and column which will identify the tile one by one until the parameter is reached
					INSERT INTO `tile` (`mapID`, `row`, `col`, `tileType`)
					VALUES (new_map_id, current_row, current_col, tile_type)
                    ON DUPLICATE KEY UPDATE `tileType` = VALUES(`tileType`);
				
				SET current_col = current_col + 1;
			END WHILE;
			
			SET current_col = 0;
			SET current_row = current_row + 1;
			
		END WHILE;
        
	SELECT 'New gameboard created!' AS MESSAGE;
    
COMMIT;

END $$

DELIMITER ;

/*
  ____  _                      ____                      _                         _ 
 / ___|| |__   _____      __  / ___| __ _ _ __ ___   ___| |__   ___   __ _ _ __ __| |
 \___ \| '_ \ / _ \ \ /\ / / | |  _ / _` | '_ ` _ \ / _ \ '_ \ / _ \ / _` | '__/ _` |
  ___) | | | | (_) \ V  V /  | |_| | (_| | | | | | |  __/ |_) | (_) | (_| | | | (_| |
 |____/|_| |_|\___/ \_/\_/    \____|\__,_|_| |_| |_|\___|_.__/ \___/ \__,_|_|  \__,_|
                                                                                     
*/

DROP PROCEDURE IF EXISTS show_gameboard;

DELIMITER $$

CREATE PROCEDURE show_gameboard(IN `gameID_para` INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SELECT 'Database error occured!' AS MESSAGE_TEXT;
    END;
    
	START TRANSACTION;
    SELECT 
		t.`tileID`, 
		t.`mapID`,
        t. `row`,
        t.`col`,
        t.`tileType`,
        t.`npcID`,
        t.`itemID`,
        t.`username`
        FROM `tile` t
    JOIN `map` m ON m.`mapID` = t.`mapID`
    JOIN `game` g ON m.`gameID` = g.`gameID`
    WHERE g.`gameID` = `gameID_para`;
    
COMMIT;

END $$

DELIMITER ;

-- TEST SHOW GAMEBOARD PROCEDURE
CALL show_gameboard (3);


/*
  _____       _                 _       ____                      
 | ____|_ __ | |_ ___ _ __     / \     / ___| __ _ _ __ ___   ___ 
 |  _| | '_ \| __/ _ \ '__|   / _ \   | |  _ / _` | '_ ` _ \ / _ \
 | |___| | | | ||  __/ |     / ___ \  | |_| | (_| | | | | | |  __/
 |_____|_| |_|\__\___|_|    /_/   \_\  \____|\__,_|_| |_| |_|\___|
                                                                  
*/
DROP PROCEDURE IF EXISTS enter_character;

DELIMITER $$

CREATE PROCEDURE enter_character (IN `username_para` VARCHAR(50), `mapID_para` INT)
BEGIN
	DECLARE home_tile INT;
    DECLARE character_exists INT;
    DECLARE current_gameID INT;
	DECLARE new_gameID INT;
    
    START TRANSACTION;
    
    -- Call the associated gameID to the mapID
    SET new_gameID = (
    SELECT `gameID`
    FROM `map`
    WHERE `mapID` = `mapID_para`);
    
	-- Select an unoccupied tile as the hometile
    SELECT `tileID`
		INTO home_tile
	FROM `tile`
		WHERE `tileType` = 0
        AND `mapID` = `mapID_para`
        AND `username` IS NULL
        ORDER BY RAND()
        LIMIT 1;
	
-- Check to see if the player already has a character in the database
    SELECT COUNT(*) INTO character_exists
    FROM `character` 
    WHERE `username` = `username_para`;
    
    -- If the character exists, update stat columns to defaults
	IF character_exists > 0 THEN
		SELECT `gameID` INTO current_gameID FROM `character` WHERE `username` = `username_para`;
		IF current_gameID IS NULL THEN
			UPDATE `character` 
			SET  `gameID` = new_gameID,
				`status` = 'Active',
				`health` = 10,
				`currentScore` = 0,
				`attackCooldown` = 'Off',
				`invincibility` = 'Off',
				`lastMove` = NOW()
			WHERE `username` = `username_para`;
		 ELSE
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That character is already in a game!';
		END IF;
	ELSE 
	-- Insert new character details with the given username parameter, setting all stat columns to defaults
		INSERT INTO `character` (`username`, `gameID`, `status`, `health`, `currentScore`, `attackCooldown`, `invincibility`, `lastMove`)
		VALUES (`username_para`, new_gameID, 'Active', 10, 0, 'Off', 'Off', NOW());
	END IF;

    
	SET autocommit = OFF;
	START TRANSACTION;
    IF EXISTS (
		SELECT  ua.`username` 
		FROM `user_account` ua
		WHERE ua.`username` = `username_para`
        )
	THEN
		UPDATE `tile` 
        SET `username` = `username_para`
        WHERE `tileID` = home_tile;
        
		UPDATE `user_account` ua
		SET ua.`status` = 'Active'
		WHERE ua.`username` = `username_para`;
        
		COMMIT;
	ELSE 
		ROLLBACK;
	END IF;
    
COMMIT;

END $$

DELIMITER ;

/*
  _   _           _       _         _           _                              
 | | | |_ __   __| | __ _| |_ ___  | | __ _ ___| |_   _ __ ___   _____   _____ 
 | | | | '_ \ / _` |/ _` | __/ _ \ | |/ _` / __| __| | '_ ` _ \ / _ \ \ / / _ \
 | |_| | |_) | (_| | (_| | ||  __/ | | (_| \__ \ |_  | | | | | | (_) \ V /  __/
  \___/| .__/ \__,_|\__,_|\__\___| |_|\__,_|___/\__| |_| |_| |_|\___/ \_/ \___|
       |_|                                                                     
*/
DROP PROCEDURE IF EXISTS update_lastMove;

DELIMITER $$

CREATE PROCEDURE update_lastMove (IN `username_para` VARCHAR(50))
COMMENT 'Updates the players lastMove column when an action is made. To be called recursively in movement-based procedures'
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SELECT 'Database error occured!' AS MESSAGE_TEXT;
    END;
    
START TRANSACTION;
 
	UPDATE `character`
		SET `lastMove` = NOW()
		WHERE `username` = `username_para`;
COMMIT;

END $$

DELIMITER ;

/*
  ____  _                         __  __                                     _   
 |  _ \| | __ _ _   _  ___ _ __  |  \/  | _____   _____ _ __ ___   ___ _ __ | |_ 
 | |_) | |/ _` | | | |/ _ \ '__| | |\/| |/ _ \ \ / / _ \ '_ ` _ \ / _ \ '_ \| __|
 |  __/| | (_| | |_| |  __/ |    | |  | | (_) \ V /  __/ | | | | |  __/ | | | |_ 
 |_|   |_|\__,_|\__, |\___|_|    |_|  |_|\___/ \_/ \___|_| |_| |_|\___|_| |_|\__|
                |___/                                                            
*/
DROP PROCEDURE IF EXISTS player_movement;

DELIMITER $$

CREATE PROCEDURE player_movement(IN `username_para` VARCHAR(50), IN `direction` VARCHAR(10), IN `mapID_para` INT)
BEGIN
    DECLARE current_row INT;
    DECLARE current_col INT;
    DECLARE new_row INT;
    DECLARE new_col INT;
	
    START TRANSACTION;
    -- Find the player's current tile
    SELECT `row`, `col` INTO current_row, current_col
    FROM `tile`
    WHERE `username` = `username_para`
    AND `mapID` = `mapID_para`;

    -- Determine the new row and column based on the direction
    CASE `direction`
        WHEN 'up' THEN
            SET new_row = current_row - 1;
            SET new_col = current_col;
        WHEN 'down' THEN
            SET new_row = current_row + 1;
            SET new_col = current_col;
        WHEN 'left' THEN
            SET new_row = current_row;
            SET new_col = current_col - 1;
        WHEN 'right' THEN
            SET new_row = current_row;
            SET new_col = current_col + 1;
        ELSE
			ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Cant move that way!';
    END CASE;

    -- Check if the target tile is no occupied by another player
    IF EXISTS (SELECT 1 FROM `tile` WHERE `row` = new_row AND `col` = new_col AND `username` IS NOT NULL AND `username` != `username_para`) THEN
		ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That tile is occupied!';
    END IF;
    
    
    -- Update the player's current tile and the target tile
    UPDATE `tile`
    SET `username` = NULL, `tileType` = 0
    WHERE `row` = current_row 
    AND `col` = current_col 
    AND `username` = `username_para`
    AND `mapID` = `mapID_para`;
    
	-- Update the username of the occupied tile to the current player
    UPDATE `tile`
    SET `username` = `username_para`
    WHERE `row` = new_row AND `col` = new_col
    AND `mapID` = `mapID_para`;
    
    CALL update_lastMove (`username_para`);
    
    SELECT * FROM `tile` WHERE `username` = `username_para`;
    
COMMIT;

END $$

DELIMITER ;


/*
  _   _ ____   ____   __  __                                     _   
 | \ | |  _ \ / ___| |  \/  | _____   _____ _ __ ___   ___ _ __ | |_ 
 |  \| | |_) | |     | |\/| |/ _ \ \ / / _ \ '_ ` _ \ / _ \ '_ \| __|
 | |\  |  __/| |___  | |  | | (_) \ V /  __/ | | | | |  __/ | | | |_ 
 |_| \_|_|    \____| |_|  |_|\___/ \_/ \___|_| |_| |_|\___|_| |_|\__|
                                                                     
*/
-- INCOMPLETE 
/*
  ____  _                  _ _                                     _   _ _           
 |  _ \| | __ _  ___ ___  (_) |_ ___ _ __ ___  ___    ___  _ __   | |_(_) | ___  ___ 
 | |_) | |/ _` |/ __/ _ \ | | __/ _ \ '_ ` _ \/ __|  / _ \| '_ \  | __| | |/ _ \/ __|
 |  __/| | (_| | (_|  __/ | | ||  __/ | | | | \__ \ | (_) | | | | | |_| | |  __/\__ \
 |_|   |_|\__,_|\___\___| |_|\__\___|_| |_| |_|___/  \___/|_| |_|  \__|_|_|\___||___/
                                                                                     
-- INCOMPLETE 

DROP FUNCTION IF EXISTS place_item;

DELIMITER $$

CREATE PROCEDURE place_items()
BEGIN
DECLARE occupied_tile;
START TRANSACTION;

SELECT COUNT(*) `itemID`, `npcID`, `username`
INTO occupied_tile;
IF
	occupied_tile > 0 THEN
		ROLLBACK;
        SELECT MESSAGE_TEXT = `That tile is taken!" 
ELSE
    UPDATE `tile` t
    JOIN `item` i ON t.`itemID` = i.`itemID`
    SET t.`itemID` = i.`itemID`
    WHERE t.`tileType` = 1;
END IF;

COMMIT;

END $$

DELIMITER ;

*/
/*
  ____                       ____       _       _       
 / ___|  ___ ___  _ __ ___  |  _ \ ___ (_)_ __ | |_ ___ 
 \___ \ / __/ _ \| '__/ _ \ | |_) / _ \| | '_ \| __/ __|
  ___) | (_| (_) | | |  __/ |  __/ (_) | | | | | |_\__ \
 |____/ \___\___/|_|  \___| |_|   \___/|_|_| |_|\__|___/
                                                        
*/
DROP PROCEDURE IF EXISTS score_points;

DELIMITER $$

CREATE PROCEDURE score_points (IN `username_para` VARCHAR(50))
COMMENT 'Add 100 to the integer of the currentScore field in the character table'
BEGIN
	DECLARE current_score INT;
    DECLARE var_exists INT;
    
    START TRANSACTION;
    
    SELECT COUNT(*) `username` INTO var_exists
    FROM `character`
    WHERE `username` = `username_para`;
    IF var_exists <= 0  THEN
		ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: That player does not exist!';
	ELSE
    SELECT `currentScore` INTO current_score 
		FROM `character`
		WHERE `username` = `username_para` FOR UPDATE;
    
		IF current_score IS NOT NULL THEN
			UPDATE `character`
			SET `currentScore` = current_score + 100
			WHERE `username` = `username_para`;
			COMMIT;
		ELSE
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error: Username cannot be found!";
		END IF;
	END IF;
COMMIT;
END $$

DELIMITER ;


/*
  ____                 _    _ _      _        _   _              ____                           
 / ___|  ___  ___     / \  | | |    / \   ___| |_(_)_   _____   / ___| __ _ _ __ ___   ___  ___ 
 \___ \ / _ \/ _ \   / _ \ | | |   / _ \ / __| __| \ \ / / _ \ | |  _ / _` | '_ ` _ \ / _ \/ __|
  ___) |  __/  __/  / ___ \| | |  / ___ \ (__| |_| |\ V /  __/ | |_| | (_| | | | | | |  __/\__ \
 |____/ \___|\___| /_/   \_\_|_| /_/   \_\___|\__|_| \_/ \___|  \____|\__,_|_| |_| |_|\___||___/
                                                                                                
*/
DROP PROCEDURE IF EXISTS get_games_and_players;

DELIMITER $$

CREATE PROCEDURE get_games_and_players()
COMMENT 'Return all active games with associated active players.'
BEGIN
-- Decalre an error handler to catch any possible errors
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
	ROLLBACK;
    SELECT 'Database error occured!' AS MESSAGE_TEXT;
END;

START TRANSACTION;
	SELECT g.gameID, c.username
	FROM game g
		INNER JOIN `character` c 
		ON g.gameID = c.gameID
		AND c.gameID IS NOT NULL
		AND g.status = 'Active';
COMMIT;

END $$

DELIMITER ;

-- TEST GAMES AND PLAYERS CALL
CALL get_games_and_players;


/*
  ____                                 ____  _                         _____                       ____                      
 |  _ \ ___ _ __ ___   _____   _____  |  _ \| | __ _ _   _  ___ _ __  |  ___| __ ___  _ __ ___    / ___| __ _ _ __ ___   ___ 
 | |_) / _ \ '_ ` _ \ / _ \ \ / / _ \ | |_) | |/ _` | | | |/ _ \ '__| | |_ | '__/ _ \| '_ ` _ \  | |  _ / _` | '_ ` _ \ / _ \
 |  _ <  __/ | | | | | (_) \ V /  __/ |  __/| | (_| | |_| |  __/ |    |  _|| | | (_) | | | | | | | |_| | (_| | | | | | |  __/
 |_| \_\___|_| |_| |_|\___/ \_/ \___| |_|   |_|\__,_|\__, |\___|_|    |_|  |_|  \___/|_| |_| |_|  \____|\__,_|_| |_| |_|\___|
                                                     |___/                                                                   
*/
DROP PROCEDURE IF EXISTS remove_player;

DELIMITER $$

CREATE PROCEDURE remove_player(IN `username_para` VARCHAR (50))
COMMENT 'Removes an active player from an active game at an admin level'
BEGIN
DECLARE `status` VARCHAR (10);
-- Decalre an error handlers to catch null fields

START TRANSACTION;
	-- Handle error if admin tried to delete a null field
	IF
    (`username_para` = NULL OR `username_para` = '') THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Fields were null!';
	END IF;
       -- Update the new status
	SELECT ua.`status`
    INTO `status`
    FROM `user_account` ua
    WHERE ua.`username` = `username_para`;
    
    -- Rollback update if attempting to remove an inactive player
    SELECT `status` FROM `user_account` ua
    WHERE ua.`username` = `username_para`;
	IF `status` = 'Logged-in' OR 'Offline' THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT  = "Error: That player is not in a game!.";
	END IF;
    -- Unoccupy the last tile the player was on
    UPDATE `tile`
    SET `username` = NULL
    WHERE `username` = `username_para`;
    
    -- Update the character table to reflect their in-game status
	UPDATE `character`
    SET `gameID` = NULL, `status` = 'Offline'
    WHERE `gameID` IS NOT NULL
    AND `username` = `username_para`;
    
    -- Update the user account table to reflect their new status
    UPDATE `user_account`
    SET `status` = 'Logged-in'
    WHERE `username` = `username_para`;
	
    SELECT 'Player removed!' AS MESSAGE;
COMMIT;

END $$

DELIMITER ;


/*
  _  ___ _ _    ____                      
 | |/ (_) | |  / ___| __ _ _ __ ___   ___ 
 | ' /| | | | | |  _ / _` | '_ ` _ \ / _ \
 | . \| | | | | |_| | (_| | | | | | |  __/
 |_|\_\_|_|_|  \____|\__,_|_| |_| |_|\___|
                                          
*/
DROP PROCEDURE IF EXISTS kill_game;

DELIMITER $$

CREATE PROCEDURE kill_game (IN `gameID_para` INT)
BEGIN

START TRANSACTION;
	IF
    (`gameID_para` = NULL OR `gameID_para` = '') THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Fields were null!';
	ELSE
	-- Deleting the gameID from the associated mapID
	DELETE FROM `map`
	WHERE `gameID` = `gameID_para`;
	
    -- Update the status of the game to 'offline' to prevent any active players from joining
    UPDATE `game`
    SET `status` = 'Offline'
    WHERE `gameID` = `gameID_para`;
    
    -- Update all associated characters in that game to disassociate them with the gameID and set their status to 'Logged in'
    UPDATE `character` c
    JOIN `game` g
		ON c.`gameID` = g.`gameID`
    SET c.`status` = 'Logged in', c.`gameID` = NULL
    WHERE g.`status` = 'Offline'
    AND g.`gameID` = `gameID_para`;

	SELECT 'Game killed!' AS MESSAGE_TEXT;
	END IF;
COMMIT;

END $$

DELIMITER ;








