/*
* Alimentation des tables finales Oceanes.
*
* @param {text} p_date (ex : 2013-08-01)
* @return {int} : Si pas d'erreur sortie par defaut (ex : 1)
* @example : select charger_data_oceane('');
*/
DROP FUNCTION IF EXISTS `charger_data_oceane`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `charger_data_oceane`( p_date TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN             
	DECLARE v_eds VARCHAR(100);
	
	/*1) Récupération parametrage*/
	SELECT `param_value`
	INTO v_eds
	FROM `tab_parametres`
	WHERE 1=1
	AND `param_name` = 'eds'
	;
                                                                      
	-- Alimentation tab_oceane_tickets_core
	REPLACE INTO `tab_oceane_tickets_core` (
		`N° ticket`, 
		`Initiateur - Code entité`,
		`Date création ticket (UTC)`, 
		`Date modif. ticket (UTC)`, 
		`EDS de modification`, 
		`Code état`, 
		`Etat`, 
		`Dernier acteur`, 
		`Criticité`, 
		`Criticité - Idt`, 
		`Criticité - poids`,
		`Priorité traitement`,
		`Description`, 
		`Technicien responsable`, 
		`Téléphone`,
		`Date début ticket (UTC)`, 
		`Date clôture ticket (UTC)`, 
		`EDS cloture - Idt`, 
		`EDS cloture - Nom long`,
		`Date rétabliss. ticket (UTC)`, 
		`EDS rétablissement - Idt`, 
		`EDS rétablissement - Nom long`, 
		`Date réparation (UTC)`, 
		`EDS réparation - Nom long`, 
		`EDS réparation - Idt`, 
		`Référence tiers`,
		`Commentaire complet détail`, 
		`Complément interne`, 
		`Détail problème`, 
		`Libellé imputation`, 
		`dateTime_record`
	)
	SELECT `N° ticket`, 
		`Initiateur - Code entité`,
		`Date création ticket (UTC)`, 
		`Date modif. ticket (UTC)`, 
		`EDS de modification`, 
		`Code état`, 
		`Etat`, 
		`Dernier acteur`, 
		`Criticité`, 
		`Criticité - Idt`, 
		`Criticité - poids`,
		`Priorité traitement`,
		`Description`, 
		`Technicien responsable`, 
		`Téléphone`,
		`Date début ticket (UTC)`, 
		`Date clôture ticket (UTC)`, 
		`EDS cloture - Idt`, 
		`EDS cloture - Nom long`,
		`Date rétabliss. ticket (UTC)`, 
		`EDS rétablissement - Idt`, 
		`EDS rétablissement - Nom long`, 
		`Date réparation (UTC)`, 
		`EDS réparation - Nom long`, 
		`EDS réparation - Idt`, 
		`Référence tiers`,
		`Commentaire complet détail`, 
		`Complément interne`, 
		`Détail problème`, 
		`Libellé imputation`, 
		`dateTime_record`
	FROM  `rec_oceane_tickets_core` 
	GROUP BY `N° ticket`, 
		`Date création ticket (UTC)`, 
		`Date modif. ticket (UTC)`, 
		`EDS de modification`, 
		`Code état`, 
		`Etat`, 
		`Dernier acteur`, 
		`Criticité`, 
		`Criticité - Idt`, 
		`Criticité - poids`,
		`Priorité traitement`,
		`Description`, 
		`Technicien responsable`, 
		`Téléphone`,
		`Date début ticket (UTC)`, 
		`Date clôture ticket (UTC)`, 
		`EDS cloture - Idt`, 
		`EDS cloture - Nom long`,
		`Date rétabliss. ticket (UTC)`, 
		`EDS rétablissement - Idt`, 
		`EDS rétablissement - Nom long`, 
		`Date réparation (UTC)`, 
		`EDS réparation - Nom long`, 
		`EDS réparation - Idt`, 
		`Référence tiers`,
		`Commentaire complet détail`, 
		`Complément interne`, 
		`Détail problème`, 
		`Libellé imputation`, 
		`dateTime_record` 
	;

	-- Alimentation tab_oceane_tickets_inter
	REPLACE INTO `tab_oceane_tickets_inter` (
		`N° ticket`, 
		`Date acquittement (UTC)`, 
		`Date début (UTC)`, 
		`Date fin (UTC)`, 
		`EDS demandeur`, 
		`EDS demandeur - Idt`, 
		`EDS intervenant`, 
		`EDS intervenant - Idt`, 
		`Technicien intervenant`, 
		`Utilisateur demandeur`,
		`Utilisateur demandeur int`,
		`dateTime_record`
	)
	SELECT `N° ticket`, 
		`Date prise charge (UTC)`, 
		`Date début (UTC)`, 
		`Date fin (UTC)`, 
		`EDS demandeur`, 
		`EDS demandeur - Idt`, 
		`EDS intervenant`, 
		`EDS intervenant - Idt`, 
		`Technicien intervenant`, 
		`Utilisateur demandeur`,
		`Utilisateur demandeur int`,
		`dateTime_record`
	FROM  `rec_oceane_tickets_core` 
	WHERE 1=1
        AND (
            `EDS demandeur - Idt` != ""
            OR
            IFNULL(LOCATE(`Initiateur - Code entité`,v_eds),0) != 0
        )
	GROUP BY `N° ticket`, 
		`Date prise charge (UTC)`, 
		`Date début (UTC)`, 
		`Date fin (UTC)`, 
		`EDS demandeur`, 
		`EDS demandeur - Idt`, 
		`EDS intervenant`, 
		`EDS intervenant - Idt`, 
		`Technicien intervenant`, 
		`Utilisateur demandeur`,
		`Utilisateur demandeur int`,
		`dateTime_record`
	;

	-- Alimentation tab_oceane_tickets_histo_descrip
	REPLACE INTO `tab_oceane_tickets_histo_descrip` (
		`N° ticket`, 
		`Ancienne description ticket`, 
		`Date ancienne description ticket`, 
		`EDS util. modif description ticket`, 
		`ID util. modif description ticket`, 
		`dateTime_record`
	)
	SELECT `N° ticket`, 
		`Ancienne description ticket`, 
		`Date ancienne description ticket`, 
		`EDS util. modif description ticket`, 
		`ID util. modif description ticket`, 
		`dateTime_record`
	FROM  `rec_oceane_tickets_core` 
	WHERE 1=1
		AND `Ancienne description ticket` != ""
	GROUP BY `N° ticket`,  
		`Ancienne description ticket`, 
		`Date ancienne description ticket`, 
		`EDS util. modif description ticket`, 
		`ID util. modif description ticket`, 
		`dateTime_record`
	;

	-- Alimentation tab_oceane_tickets_etats
	REPLACE INTO `tab_oceane_tickets_etats` (
		`N° ticket`, 
		`Date modification état (UTC)`, 
		`EDS modification - Idt`, 
		`EDS modification - Nom long`, 
		`Etat ticket`,  
		`Etat ticket - Idt`, 
		`dateTime_record`
	)
	SELECT `N° ticket`, 
		`Date modification état (UTC)`, 
		`EDS modification - Idt`, 
		`EDS modification - Nom long`, 
		`Etat ticket`,  
		`Etat ticket - Idt`, 
		`dateTime_record`
	FROM  `rec_oceane_tickets_core` 
	WHERE 1=1
	GROUP BY `N° ticket`,  
		`Date modification état (UTC)`, 
		`EDS modification - Idt`, 
		`EDS modification - Nom long`, 
		`Etat ticket`,  
		`Etat ticket - Idt`, 
		`dateTime_record`
	;

	-- Alimentation tab_oceane_tickets_etats
	REPLACE INTO `tab_oceane_tickets_commentaires` (
		`N° ticket`,  
		`Date commentaire (UTC)`, 
		`EDS ayant saisi commentaire`, 
		`Utilisateur - Code`, 
		`Identifiant pièce jointe`,  
		`Commentaire`,  
		`dateTime_record`
	)
	SELECT `N° ticket`, 
		`Date commentaire (UTC)`, 
		`EDS ayant saisi commentaire`, 
		`Utilisateur - Code`, 
		`Identifiant pièce jointe`,  
		`Commentaire`, 
		`dateTime_record`
	FROM  `rec_oceane_tickets_commentaires` 
	WHERE 1=1
	GROUP BY `N° ticket`,   
		`Date commentaire (UTC)`, 
		`EDS ayant saisi commentaire`, 
		`Utilisateur - Code`, 
		`Identifiant pièce jointe`,  
		`Commentaire`, 
		`dateTime_record`
	;
			 
	RETURN 1; 
END$$