/*
* Récupère le statut noa pour un statut automate.
*
* @param {text} p_type : le type de mapping choisi
* @param {text} p_statut_automate : le statut sous automate
* @return {int} : retourne l'id du tag du statut, sinon 0.
* @example : select get_mapping_statut_automate("ADV","RECEPTION");
* @test : SELECT get_mapping_statut_automate('ADV',a.`statut`) FROM `tab_automate_ticket_details` a WHERE 1=1 AND `dateTime_record` > NOW() - INTERVAL 1 DAY;
*/
DROP FUNCTION IF EXISTS `get_mapping_statut_automate`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_mapping_statut_automate`( p_type TEXT, p_statut_automate TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE varRetour INT DEFAULT 0;
	
	DECLARE debug BOOLEAN DEFAULT FALSE;
	DECLARE trace BOOLEAN DEFAULT FALSE;
	
	CASE p_type
		WHEN 'ADV' THEN 
			BEGIN
				CASE p_statut_automate
					WHEN 'RECEPTION' THEN SET varRetour = 1 /*Nouveau*/;
					WHEN 'PRISE_EN_MAIN' THEN SET varRetour := 2/*Pris en main*/;
					WHEN 'ANALYSE' THEN SET varRetour := 3/*En analyse*/;
					WHEN 'SUPPORT/SOUTIEN' THEN SET varRetour := 5 /*Fermé*/;
					WHEN 'CORRECTION' THEN SET varRetour := 5 /*Fermé*/;
					WHEN 'ENREGISTREE' THEN SET varRetour := 5 /*Fermé*/;
					WHEN 'FERMEE' THEN SET varRetour := 5 /*Fermé*/;
					ELSE SET varRetour := 0;
				END CASE;
			END;
			
		WHEN 'SN3DISE' THEN 
			BEGIN
				CASE p_statut_automate
					WHEN 'RECEPTION' THEN SET varRetour := 1 /*Nouveau*/;
					WHEN 'PRISE_EN_MAIN' THEN SET varRetour := 2/*Pris en main*/;
					WHEN 'ANALYSE' THEN SET varRetour := 3/*En analyse*/;
					WHEN 'SUPPORT/SOUTIEN' THEN SET varRetour := 4 /*En attente*/;
					WHEN 'CORRECTION' THEN SET varRetour := 5 /*Fermé*/;
					WHEN 'ENREGISTREE' THEN SET varRetour := 5 /*Fermé*/;
					WHEN 'FERMEE' THEN SET varRetour := 5 /*Fermé*/;
					ELSE SET varRetour := 0;
				END CASE;
			END;
			
	END CASE;
		
	RETURN varRetour; 
END$$