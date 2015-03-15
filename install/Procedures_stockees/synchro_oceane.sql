/*
* La synchronisation.
*
* @param {text} p_date (ex : 2013-08-01)
* @return {int} : Si pas d'erreur sortie par defaut (ex : 1)
* @example : select synchro_oceane("2013-10-01");
*/
DROP FUNCTION IF EXISTS `synchro_oceane`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `synchro_oceane`( p_date TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE nb0,nb1,nb2,nb3,nb4,nb5,nb5v2,nb6,nb7,nb7bis,nb8,nb9,nb10,nb10bis,nb11,nb12,nb13,nb14,nb15,nb16,nb17,nb18,nb19,nb20 INT DEFAULT 0;
	DECLARE v_type_synchro VARCHAR(100);
	DECLARE v_eds VARCHAR(100);
	
	DECLARE debug BOOLEAN DEFAULT FALSE;
	DECLARE trace BOOLEAN DEFAULT TRUE;

	DECLARE done INT DEFAULT 0;
	DECLARE a,b INT;
	DECLARE cur1 CURSOR FOR SELECT DISTINCT `id_toc` FROM `syn_id_toc`;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
	
	/*recup params*/
	SELECT `param_value`
	INTO v_eds
	FROM `tab_parametres`
	WHERE 1=1
	AND `param_name` = 'eds'
	;
	
	/*Constitution de la table pour stocker les tickets à mettre à jour*/
	DROP TEMPORARY TABLE IF EXISTS syn_id_toc;
	CREATE TEMPORARY TABLE syn_id_toc
	AS
	SELECT `id` as 'id_toc' FROM `tab_tickets` WHERE 1=0
	;
	
	/*Recup que la dernier version de l'invo oceane*/
	DROP TEMPORARY TABLE IF EXISTS syn_0;
	CREATE TEMPORARY TABLE syn_0
	AS
	SELECT a.`N° ticket`, MAX(a.`id`) as 'id_max' 
	FROM `tab_oceane_tickets_core` a 
	WHERE 1=1 
	AND (
		convert_tz(STR_TO_DATE(a.`Date modif. ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') >= STR_TO_DATE(p_date, '%Y-%m-%d')
		OR
		convert_tz(STR_TO_DATE(a.`Date création ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') >= STR_TO_DATE(p_date, '%Y-%m-%d')
	)
	GROUP BY a.`N° ticket`
	;
	
	/*recup info utiles*/
	DROP TEMPORARY TABLE IF EXISTS syn_1;
	CREATE TEMPORARY TABLE syn_1
	AS
	SELECT a.`id`, a.`N° ticket`, a.`Description`, convert_tz(STR_TO_DATE(a.`Date création ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'dateCreation'
		, CASE 
			WHEN a.`Criticité` = 'Mineur'  THEN 42 
			ELSE 42
		END 
		as 'criticite'
		, CASE 
			WHEN a.`Priorité traitement` like '%P4%'  THEN 38 
			WHEN a.`Priorité traitement` like '%P3%'  THEN 37  
			WHEN a.`Priorité traitement` like '%P2%'  THEN 36  
			WHEN a.`Priorité traitement` like '%P1%'  THEN 35 
			ELSE 38 END
		as 'priorite'
		, a.`Dernier acteur` as 'dernierActeur'
	FROM `tab_oceane_tickets_core` a
	WHERE 1=1
	AND EXISTS (SELECT 1 FROM `syn_0` b WHERE b.`id_max` = a.`id`)
	;
	
	/*------------------------------------------------------------*/
	/*Description*/
	/*les tickets qui n'ont pas des descriptions*/
	DROP TEMPORARY TABLE IF EXISTS syn_2;
	CREATE TEMPORARY TABLE syn_2
	AS
	SELECT a.`id`, a.`label`, c.`Description`, c.`dateCreation`
	FROM `tab_tickets` a, `syn_1` c
	WHERE 1=1
	AND c.`N° ticket` = a.`label`
	AND c.`Description` != ''
	AND not exists (SELECT 1 FROM `tab_notes` b
			WHERE a.`id` = b.`id_toc`
			AND b.`id_type` = 70
			AND b.`actif` = 1
	)
	;
	
	INSERT INTO `syn_id_toc`
	(`id_toc`)
	SELECT `id` FROM `syn_2`
	;
	
	/*Desactive les descriptions en cours*/
	UPDATE `tab_notes` a
	SET a.`actif` = 0
	, a.`dateTime_modification` = NOW()
	, a.`auteur_modification` = 'synchro_oceane'
	WHERE 1=1
	AND a.`actif` = 1
	AND EXISTS (SELECT 1 FROM `syn_2` b WHERE b.`id` = a.`id_toc`)
	;
	
	/*insertion nouvelle desc*/
	INSERT INTO `tab_notes`
	(`id`,`id_toc`,`note`,`id_type`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
	SELECT null, a.`id`, a.`Description`, 70, 1, a.`dateCreation`, 'synchro', null, null
	FROM `syn_2` a
	;
	
	/*ajout à l'historique*/
	INSERT INTO `tab_ticket_histo_change`
	(`id`,`id_toc`,`auteur`,`dateTime_change`,`changement`)
	SELECT null, a.`id`, 'synchro', NOW(), "<ul><li>[Ticket Détails Context][Description]Redescente Synchronisation</li></ul>"
	FROM `syn_2` a
	;
	
	/*------------------------------------------------------------*/
	/*priorite*/
	/*On croise avec les tickets NOA qui ne sont pas synchro*/
	DROP TEMPORARY TABLE IF EXISTS syn_4;
	CREATE TEMPORARY TABLE syn_4
	AS
	SELECT a.`id`, a.`label`, c.`priorite`, c.`dateCreation`
	FROM `tab_tickets` a, `syn_1` c
	WHERE 1=1
	AND c.`N° ticket` = a.`label`
	AND not exists (SELECT 1 FROM `tab_tags_affecte` b
			WHERE a.`id` = b.`id_toc`
			AND b.`id_type` = 15/*prio*/
			AND b.`actif` = 1
			AND b.`id_tag` = c.`priorite`
	)
	;
	
	INSERT INTO `syn_id_toc`
	(`id_toc`)
	SELECT `id` FROM `syn_4`
	;
	
	/*Desactive les éléments en cours*/
	UPDATE `tab_tags_affecte` a
	SET a.`actif` = 0
	, a.`dateTime_modification` = NOW()
	, a.`auteur_modification` = 'synchro_oceane'
	WHERE 1=1
	AND a.`id_type` = 15/*prio*/
	AND a.`actif` = 1
	AND EXISTS (SELECT 1 FROM `syn_4` b WHERE b.`id` = a.`id_toc`)
	;
	
	/*insertion du nouvel element*/
	INSERT INTO `tab_tags_affecte`
	(`id`,`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
	SELECT null, a.`id`, 15, a.`priorite`, 1, a.`dateCreation`, 'synchro', null, null
	FROM `syn_4` a
	;
	
	/*ajout à l'historique*/
	INSERT INTO `tab_ticket_histo_change`
	(`id`,`id_toc`,`auteur`,`dateTime_change`,`changement`)
	SELECT null, a.`id`, 'synchro', NOW(), CONCAT("<ul><li>[Ticket Détails Context][Priorité]Redescente Synchronisation => ",a.`priorite`,"</li></ul>")
	FROM `syn_4` a
	;
		
	/*------------------------------------------------------------*/
	/*criticite*/
	/*On croise avec les tickets NOA qui ne sont pas synchro*/
	DROP TEMPORARY TABLE IF EXISTS syn_5;
	CREATE TEMPORARY TABLE syn_5
	AS
	SELECT a.`id`, a.`label`, c.`criticite`, c.`dateCreation`
	FROM `tab_tickets` a, `syn_1` c
	WHERE 1=1
	AND c.`N° ticket` = a.`label`
	AND not exists (SELECT 1 FROM `tab_tags_affecte` b
			WHERE a.`id` = b.`id_toc`
			AND b.`id_type` = 16/*criti*/
			AND b.`actif` = 1
			AND b.`id_tag` = c.`criticite`
	)
	;
	
	INSERT INTO `syn_id_toc`
	(`id_toc`)
	SELECT `id` FROM `syn_5`
	;
	
	/*Desactive les éléments en cours*/
	UPDATE `tab_tags_affecte` a
	SET a.`actif` = 0
	, a.`dateTime_modification` = NOW()
	, a.`auteur_modification` = 'synchro_oceane'
	WHERE 1=1
	AND a.`id_type` = 16/*criti*/
	AND a.`actif` = 1
	AND EXISTS (SELECT 1 FROM `syn_5` b WHERE b.`id` = a.`id_toc`)
	;
	
	/*insertion du nouvel element*/
	INSERT INTO `tab_tags_affecte`
	(`id`,`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
	SELECT null, a.`id`, 16, a.`criticite`, 1, a.`dateCreation`, 'synchro', null, null
	FROM `syn_5` a
	;
	
	/*ajout à l'historique*/
	INSERT INTO `tab_ticket_histo_change`
	(`id`,`id_toc`,`auteur`,`dateTime_change`,`changement`)
	SELECT null, a.`id`, 'synchro', NOW(), CONCAT("<ul><li>[Ticket Détails Context][Criticité]Redescente Synchronisation => ",a.`criticite`,"</li></ul>")
	FROM `syn_5` a
	;
		
	/*------------------------------------------------------------*/
	/*Issue 123:Tagger les tickets Emis avec l'eds de destination*/
	/*création des tags pour les eds*/
	DROP TEMPORARY TABLE IF EXISTS syn_6;
	CREATE TEMPORARY TABLE syn_6
	AS
	SELECT a.`id` as 'id_toc', a.`label`, b.`dernierActeur`, e.`id` as 'tagEds'
	FROM `tab_tickets` a, `syn_1` b, `tab_tags` e
	WHERE 1=1
	AND b.`N° ticket` = a.`label`
	AND b.`dernierActeur` = e.`label`
	AND b.`dernierActeur` is not null
	AND b.`dernierActeur` <> ''
	AND b.`dernierActeur` <> 'GENERGY'
	AND IFNULL(LOCATE(b.`dernierActeur`,v_eds),0) = 0
	AND not exists (SELECT 1 FROM `tab_tags_affecte` c
		WHERE 1=1
		AND a.`id` = c.`id_toc`
		AND c.`id_type` = 20/*causes_tags*/
		AND c.`actif` = 1
		AND e.`id` =  c.`id_tag`
	)
	;

	/*insertion du nouvel element*/
	INSERT INTO `tab_tags_affecte`
	(`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`)
	SELECT a.`id_toc`, 20, a.`tagEds`, 1, NOW(), 'synchro'
	FROM `syn_6` a
	;

	/*ajout à l'historique*/
	INSERT INTO `tab_ticket_histo_change`
	(`id_toc`,`auteur`,`dateTime_change`,`changement`)
	SELECT a.`id_toc`, 'synchro', NOW(), CONCAT("<ul><li>[Causes][Tags causes]Redescente Synchronisation, EDS destination => ",a.`tagEds`,"</li></ul>")
	FROM `syn_6` a
	;
	
		
	/*------------------------------------------------------------*/
	/*Lance reconsiliation de la date de mise à jour core*/
	OPEN cur1;

	REPEAT
	FETCH cur1 INTO a;
	IF NOT done THEN
		SELECT reconcil_modif(a)
		INTO b;
	END IF;
	UNTIL done END REPEAT;

	CLOSE cur1;
		
	RETURN 1; 
END$$