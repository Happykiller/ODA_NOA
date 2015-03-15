/*
* Import les données Automate du REC au TAB.
*
* @param {text} p_date :  (ex : 2013-08-01)
* @return {int} : Si pas d'erreur sortie par defaut (ex : 1)
* @example : select charger_data_automate('');
*/
DROP PROCEDURE IF EXISTS `charger_data_automate`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `charger_data_automate`( p_date TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN                                                                                   
	/*Alimentation tab_automate_ticket_details*/
	REPLACE INTO `tab_automate_ticket_details`
	SELECT null,b.*, NOW()
	FROM  (
		SELECT DISTINCT a.*
		FROM `rec_automate_ticket_details` a
		WHERE 1=1
	) b
	;

	/*Alimentation tab_automate_ticket_docs*/
	REPLACE INTO `tab_automate_ticket_docs`
	SELECT null,b.*, NOW()
	FROM  (
		SELECT DISTINCT a.*
		FROM `rec_automate_ticket_docs` a
		WHERE 1=1
	) b
	;

	/*Alimentation tab_automate_ticket_liens*/
	REPLACE INTO `tab_automate_ticket_liens`
	SELECT null,b.*, NOW()
	FROM  (
		SELECT DISTINCT a.*
		FROM `rec_automate_ticket_liens` a
		WHERE 1=1
	) b
	;

	/*Alimentation tab_automate_ticket_msgs*/
	REPLACE INTO `tab_automate_ticket_msgs`
	SELECT null,b.*, NOW()
	FROM  (
		SELECT DISTINCT a.*
		FROM `rec_automate_ticket_msgs` a
		WHERE 1=1
	) b
	;

	/*Alimentation tab_automate_ticket_statuts*/
	REPLACE INTO `tab_automate_ticket_statuts`
	SELECT null,b.*, NOW()
	FROM  (
		SELECT DISTINCT a.*
		FROM `rec_automate_ticket_statuts` a
		WHERE 1=1
	) b
	;
 
	RETURN 1; 
END$$