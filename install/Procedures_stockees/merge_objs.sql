/*
* Merge.
*
* @param {text} p_date (ex : 2013-08-01)
* @return {int} : Si pas d'erreur sortie par defaut (ex : 1)
* @example : select merge_tickets('');
*/
DROP FUNCTION IF EXISTS `merge_tickets`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `merge_tickets`( p_date TEXT ) RETURNS int(11)
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
	
	DROP TEMPORARY TABLE IF EXISTS tmp_0;
	CREATE TEMPORARY TABLE tmp_0
	AS
	SELECT DISTINCT 
		a.`id_toc` as 'id_toc'
		, STR_TO_DATE(a.`date_creation`, '%d/%m/%Y %H:%i') as 'dateTime_creation'
		, STR_TO_DATE(a.`dernière_action`, '%d/%m/%Y %H:%i') as 'dateTime_modification'
		, IF(a.`emis`='oui',1,0) as 'emis'
		, a.`dateTime_record`
		,'automate' as 'auteur'
		FROM `tab_automate_ticket_details` a
		WHERE 1=1
		AND not exists (select 1 from `tab_tickets` b where b.`label` = a.`id_toc`)
	UNION
	SELECT DISTINCT 
		c.`N° ticket` as 'id_toc'
		, IF(LOCATE(c.`Initiateur - Code entité`,v_eds),convert_tz(STR_TO_DATE(c.`Date création ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris'),e.`min_date_debut`) as 'dateTime_creation'
		, convert_tz(STR_TO_DATE(c.`Date modif. ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'dateTime_modification'
		, IFNULL(LOCATE(c.`Initiateur - Code entité`,v_eds),0) as 'emis'
		, c.`dateTime_record`
		, 'oceane' as 'auteur'
		FROM `tab_oceane_tickets_core` c, (
			SELECT d.`N° ticket`, MIN(convert_tz(STR_TO_DATE(d.`Date début (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris')) as 'min_date_debut'
			FROM  `tab_oceane_tickets_inter` d
			WHERE 1=1
			AND (
				IFNULL(LOCATE(d.`EDS demandeur - Idt`,v_eds),0) != 0
				OR 
				IFNULL(LOCATE(d.`EDS intervenant - Idt`,v_eds),0) != 0
			)
			GROUP BY d.`N° ticket`
		) e
		WHERE 1=1
		AND c.`N° ticket` = e.`N° ticket`
		AND not exists (select 1 from `tab_tickets` d where d.`label` = c.`N° ticket`)
	;
	
	DROP TEMPORARY TABLE IF EXISTS tmp_1;
	CREATE TEMPORARY TABLE tmp_1
	AS
	SELECT a.`id_toc`, MAX(a.`dateTime_record`) as `dateTime_record`
		FROM tmp_0 a
		WHERE 1=1
		GROUP BY  a.`id_toc`
	;
	
	DROP TEMPORARY TABLE IF EXISTS tmp_2;
	CREATE TEMPORARY TABLE tmp_2
	AS
	SELECT DISTINCT *
		FROM `tmp_0` a
		WHERE 1=1
		AND EXISTS (SELECT 1 
			FROM `tmp_1` b 
			WHERE 1=1
			AND b.`id_toc` = a.`id_toc`
			AND b.`dateTime_record` = a.`dateTime_record`
		)
	;
	
	/*Creation tickets*/
	INSERT INTO `tab_tickets` 
	(`label`, `dateTime_creation`, `auteur`, `dateTime_modification`, `auteur_modification`)
	SELECT a.`id_toc`, a.`dateTime_creation`, a.`auteur`, a.`dateTime_modification`, a.`auteur`
	FROM `tmp_2` a
	WHERE 1=1
	;
	
	/*Liste des tickets*/
	DROP TEMPORARY TABLE IF EXISTS tmp_3;
	CREATE TEMPORARY TABLE tmp_3
	AS
	SELECT b.`id`
	, a.`id_toc` as 'label'
	, a.`dateTime_modification` as 'laDate'
	, a.`emis`
	, a.`auteur`
	FROM `tmp_2` a, `tab_tickets` b
	WHERE 1=1
	AND a.`id_toc` = b.`label`
	;
	
	/*Nature(28) par defaut Incident(29), ou Emis(92)*/
	INSERT INTO  `tab_tags_affecte` 
	(`id` ,`id_toc` ,`id_type` ,`id_tag` ,`actif` ,`dateTime_creation` ,`auteur_creation` ,`dateTime_modification` ,`auteur_modification`)
	SELECT NULL, `id`, 28,  IF(`emis` <> 0,92,29),  1,  `laDate`,  `auteur`,  '',  '' 
		FROM `tmp_3`
	;
	
	/*Visible(26) par defaut collaborateur(5)*/
	INSERT INTO  `tab_tags_affecte` 
	(`id` ,`id_toc` ,`id_type` ,`id_tag` ,`actif` ,`dateTime_creation` ,`auteur_creation` ,`dateTime_modification` ,`auteur_modification`)
	SELECT NULL, `id`, 26,  5,  1,  `laDate`,  `auteur`,  '',  '' 
		FROM `tmp_3`
	;
	
	/*Editable(27) par defaut collaborateur(5)*/
	INSERT INTO  `tab_tags_affecte` 
	(`id` ,`id_toc` ,`id_type` ,`id_tag` ,`actif` ,`dateTime_creation` ,`auteur_creation` ,`dateTime_modification` ,`auteur_modification`)
	SELECT NULL, `id`, 27,  5,  1,  `laDate`,  `auteur`,  '',  '' 
		FROM `tmp_3`
	;

	RETURN 1; 
END$$