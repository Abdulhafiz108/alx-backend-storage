-- An SQL script that creates a stored procedure ComputeAverageWeightedScoreForUsers that computes and store the average weighted score for all students.

DELIMITER $$

CREATE PROCEDURE ComputeAverageWeightedScoreForUsers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE user_id INT;
    DECLARE total_score FLOAT;
    DECLARE total_weight FLOAT;
    
    -- Declare cursor for selecting all user IDs
    DECLARE user_cursor CURSOR FOR
        SELECT id FROM users;
    
    -- Declare continue handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Open the cursor
    OPEN user_cursor;
    
    -- Loop through all users
    user_loop: LOOP
        -- Fetch user ID from cursor
        FETCH user_cursor INTO user_id;
        
        -- Check if cursor is done
        IF done THEN
            LEAVE user_loop;
        END IF;
        
        -- Reset total score and total weight for each user
        SET total_score = 0;
	SET total_weight = 0;
        
        -- Calculate total weighted score for the current user
        SELECT SUM(c.score * p.weight)
        INTO total_score
        FROM corrections c
        JOIN projects p ON c.project_id = p.id
        WHERE c.user_id = user_id;
        
        -- Calculate total weight for the current user
        SELECT SUM(p.weight)
        INTO total_weight
        FROM corrections c
        JOIN projects p ON c.project_id = p.id
        WHERE c.user_id = user_id;
        
        -- Compute average weighted score
        IF total_weight > 0 THEN
            UPDATE users
            SET average_score = total_score / total_weight
            WHERE id = user_id;
        ELSE
            UPDATE users
            SET average_score = 0
            WHERE id = user_id;
        END IF;
    END LOOP;
    
    -- Close the cursor
    CLOSE user_cursor;
END $$

DELIMITER ;
