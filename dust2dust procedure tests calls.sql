USE dust2dust;
/*_____         _     ____                         _                     
 |_   _|__  ___| |_  |  _ \ _ __ ___   ___ ___  __| |_   _ _ __ ___  ___ 
   | |/ _ \/ __| __| | |_) | '__/ _ \ / __/ _ \/ _` | | | | '__/ _ \/ __|
   | |  __/\__ \ |_  |  __/| | | (_) | (_|  __/ (_| | |_| | | |  __/\__ \
   |_|\___||___/\__| |_|   |_|  \___/ \___\___|\__,_|\__,_|_|  \___||___/
*/                                                                         



-- TEST SUCCESSFUL LOGIN PROCEDURE
-- Set account status to offline to allow login
UPDATE `user_account`
	SET `status` = 'Logged out'
    WHERE `username` = 'KbyzFTW';
    
-- Set login attempts to default    
UPDATE `user_account`
	SET `attempts` = 0
    WHERE `username` = 'KbyzFTW';

-- Check user account
SELECT * FROM `user_account`
WHERE `username` = 'KbyzFTW';
    
-- Call successful login
CALL login ('KbyzFTW', 'CoolioJulio');

-- TEST FAILED LOGIN PROCEDURE AND LOCKOUT
-- Log character out
UPDATE `user_account`
	SET `status` = 'Logged out'
    WHERE `username` = 'KbyzFTW';
    
-- Set login attempts to default    
UPDATE `user_account`
	SET `attempts` = 0
    WHERE `username` = 'KbyzFTW';
    
-- Call invalid login credentials x3
CALL login ('KbyzFTW', 'akdandk');

-- Check user account
SELECT * FROM `user_account`
WHERE `username` = 'KbyzFTW';

-- TEST LOGOUT PROCEDURE

-- Login a user
CALL login ('test', 'test');

-- Check user status
SELECT * FROM `user_account` WHERE `username` = 'test';

-- Logout user
CALL logout ('test');

-- TEST REGISTER ACCOUNT PROCEDURE
CALL signup ('xXBlack_BloodzXx', 'whitefang@email.co.uk', 'fangz', 'Kyle');

-- Check user account table for new account
SELECT * FROM `user_account`;

-- Test error handling of registering with existing username
CALL signup ('xXBlack_BloodzXx', 'somethingdifferent@email.co.uk', 'fangz', 'Kyle');

-- Test error handling of registering with existing email
CALL signup ('somethingdifferent', 'whitefang@email.co.uk', 'fangz', 'Kyle');

-- TEST EDIT ACCOUNT PROCEDURE

SELECT * FROM `user_account` WHERE `username` = 'KyrVorga';

-- Select existing username, provide new credentials (username, email, password, and first name)
CALL edit_account ('KyrVorga', 'TyrMorgen', 'onehand@email.com', 'Justice', 'Tyr');

-- See updated accounts
SELECT * FROM `user_account`;

-- Test error handling with editing with exsiting username
CALL edit_account ('TyrMorgen', 'KbyzFTW', 'onehand@email.com', 'Justice', 'Tyr');

-- Test error handling with editing with exsiting email
CALL edit_account ('TyrMorgen', 'something different', 'onehand@email.com', 'Justice', 'Tyr');

-- TEST BAN ACCOUNT PROCEDURE
-- Set status to an unbanned state
CALL logout ('test');

 -- Call procedure to set an account to a locked state (banned) an account by username
CALL ban_account ('test');
 
 -- View updated account status
SELECT `username`, `status`
FROM `user_account`
WHERE `username` = 'test';

-- TEST UNBAN ACCOUNT PROCEDURE
-- Bann an account
CALL ban_account ('test');

-- View update
SELECT * FROM `user_account` WHERE `username` = 'test';

-- Unban the account
CALL unban_account ('test');

-- Test error handler with unbanned account
CALL unban_account ('dfadffasf');

-- TEST DELETE ACCOUNT PROCEDURE
-- Create a new account
CALL signup ('Paquod', 'whaleoil@email.com', 'MobyDick', 'Ahab');

-- Delete the account
CALL delete_account ('Paquod');

-- Check user account list
SELECT * FROM `user_account`;

-- TEST GAMEBOARD PROCEDURE
CALL draw_gameboard (9,9);
SELECT * FROM `game`;

-- TEST ENTER CHARACTER CALL
CALL draw_gameboard(9,9);


-- Select a mapID to join
SELECT * FROM `map`;
-- Enter the map

CALL enter_character ('Verga', 1);
CALL enter_character ('Fulmini', 1);
CALL enter_character ('test', 1);
CALL enter_character ('KbyzFTW', 2);

-- See where the character is
SELECT * FROM `tile` WHERE `username` = 'Verga';

-- See update to the character table
SELECT * FROM `character` WHERE `username` = 'Verga';

-- Test error handler when attempting to enter a game when a character is already active
CALL enter_character ('Verga', 2);

-- TEST PLAYER MOVEMENT PROCEDURE
-- Select the tile where a username exists. Take note of the tileID they are on.
SELECT * FROM `tile` WHERE `username` = 'Verga';

-- Call the movement procedure, make sure the mapID is correct
CALL player_movement ('Verga', 'up', 2);

-- TEST SCORE POINTS PROCEDURE
CALL score_points ('Verga');

SELECT * FROM `character` WHERE `username` = 'Verga';

-- Test error handler for non-existing player
CALL score_points ('someplayer');

-- TEST REMOVE PLAYER FROM GAME PROCEDURE
-- Reutrn an active game and list of active players
CALL get_games_and_players;

-- Remove an active player
CALL remove_player ('Verga');

-- Test error handler when attempting to remove an in-active player
CALL remove_player('Fulmini');

-- TEST KILL GAME PROCEDURE

-- Create a game
CALL draw_gameboard(9,9);

-- Insert a character
CALL enter_character ('Fulmini', 4);

-- Kill the game with the new gameID 
SELECT * FROM `map`;
CALL kill_game (5);

-- See updates to the game
CALL get_games_and_players;

-- See updates to the character
SELECT * FROM `character` WHERE `username` = 'Fulmini';