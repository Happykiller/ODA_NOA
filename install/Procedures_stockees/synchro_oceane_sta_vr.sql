/*
* La synchronisation par DELTA BRISE-NOA pour les statuts et version.
*
* @param {text} p_date : les éléments dont leur modification est aprés la date seront analysés YYYY-MM-DD (ex : 2013-08-01)
* @return {int} : Si pas d'erreur sortie par defaut (ex : 1)
* @example : select synchro_oceane_sta_vr("2013-10-01");
*/
DROP FUNCTION IF EXISTS `synchro_oceane_sta_vr`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `synchro_oceane_sta_vr`( p_date TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE nb0,nb1,nb2,nb3,nb4,nb4_1,nb4_2,nb5,nb5v2,nb5_0,nb6,nb7,nb7bis,nb8,nb9,nb10,nb10bis,nb11,nb12,nb13,nb14,nb15,nb16,nb17,nb18,nb19,nb20 INT DEFAULT 0;
	DECLARE v_type_synchro VARCHAR(100);
	DECLARE v_eds VARCHAR(100);
	
	DECLARE debug BOOLEAN DEFAULT FALSE;
	DECLARE trace BOOLEAN DEFAULT FALSE;
	
	DECLARE done INT DEFAULT 0;
	DECLARE a,b INT;
	DECLARE cur1 CURSOR FOR SELECT DISTINCT `id_toc` FROM `syn_id_toc`;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
	
	/*Constitution de la table pour stocker les tickets à mettre à jour*/
	DROP TEMPORARY TABLE IF EXISTS syn_id_toc;
	CREATE TEMPORARY TABLE syn_id_toc
	AS
	SELECT `id` as 'id_toc' FROM `tab_tickets` WHERE 1=0
	;
	
	/*--------------------------------------------------------*/
	/*statut*/
		/*1) Inventaire des éléments concernés*/
		DROP TEMPORARY TABLE IF EXISTS `syn_0`;
		CREATE TEMPORARY TABLE `syn_0`
			AS
		SELECT DISTINCT `N° ticket`
		FROM `tab_oceane_tickets_core` a 
		WHERE 1=1 
		AND (
			convert_tz(STR_TO_DATE(a.`Date modif. ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') >= STR_TO_DATE(p_date, '%Y-%m-%d')
			OR
			convert_tz(STR_TO_DATE(a.`Date création ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') >= STR_TO_DATE(p_date, '%Y-%m-%d')
		)
		GROUP BY a.`N° ticket`
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_0`;
			INSERT INTO `tmp_syn_0`
			SELECT * FROM `syn_0`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb0
			FROM `syn_0`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_0) avec ',p_date,' en input : ',nb0))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*2) Récupération parametrage type synchro*/
		SELECT `param_value`
		INTO v_type_synchro
		FROM `tab_parametres`
		WHERE 1=1
		AND `param_name` = 'type_synchro_oceane_noa'
		;
		
		/* POUR TRACE*/
		IF trace THEN
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Paramètrage :  ',v_type_synchro))
			;
		END IF;
		
		SELECT `param_value`
		INTO v_eds
		FROM `tab_parametres`
		WHERE 1=1
		AND `param_name` = 'eds'
		;
		
		/* POUR TRACE*/
		IF trace THEN
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]EDS :  ',v_eds))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*3) Récupération des données par les interventions*/
		DROP TEMPORARY TABLE IF EXISTS `syn_1`;
		CREATE TEMPORARY TABLE IF NOT EXISTS `syn_1` (
		  `id_toc` varchar(255) DEFAULT NULL,
		  `statut` varchar(6) NOT NULL DEFAULT '',
		  `date_statut` datetime DEFAULT NULL,
		  `source` varchar(5) NOT NULL DEFAULT ''
		);
		
		INSERT INTO `syn_1`
		SELECT a.`N° ticket` as 'id_toc', 'entree' as 'statut', convert_tz(STR_TO_DATE(a.`Date début (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'date_statut', 'inter' as 'source'
		FROM `tab_oceane_tickets_inter` a
		WHERE 1=1
		AND a.`Date début (UTC)` != ''
		AND IFNULL(LOCATE(a.`EDS intervenant - Idt`,v_eds),0) != 0
		AND EXISTS (SELECT 1 FROM `syn_0` b WHERE b.`N° ticket` = a.`N° ticket`)
		;
		
		INSERT INTO `syn_1`
		SELECT a.`N° ticket` as 'id_toc', 'aquit' as 'statut', convert_tz(STR_TO_DATE(a.`Date acquittement (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'date_statut', 'inter' as 'source'
		FROM `tab_oceane_tickets_inter` a
		WHERE 1=1
		AND a.`Date acquittement (UTC)` != ''
		AND IFNULL(LOCATE(a.`EDS intervenant - Idt`,v_eds),0) != 0
		AND EXISTS (SELECT 1 FROM `syn_0` b WHERE b.`N° ticket` = a.`N° ticket`)
		;
		
		INSERT INTO `syn_1`
		SELECT a.`N° ticket` as 'id_toc','sortie' as 'statut', convert_tz(STR_TO_DATE(a.`Date fin (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'date_statut', 'inter' as 'source'
		FROM `tab_oceane_tickets_inter` a
		WHERE 1=1
		AND a.`Date fin (UTC)` != ''
		AND IFNULL(LOCATE(a.`EDS intervenant - Idt`,v_eds),0) != 0
		AND EXISTS (SELECT 1 FROM `syn_0` b WHERE b.`N° ticket` = a.`N° ticket`)
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_1`;
			INSERT INTO `tmp_syn_1`
			SELECT * FROM `syn_1`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb1
			FROM `syn_1`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_1) : ',nb1))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*4) Récupération des données par les changements d'états => Supprimer car inchohérence des dates de changement de statut*/
		
		/*--------------------------------------------------------*/
		/*5) Récupération des données par le corps de l'éléments*/
		DROP TEMPORARY TABLE IF EXISTS `syn_3`;
		CREATE TEMPORARY TABLE IF NOT EXISTS `syn_3` (
		  `id_toc` varchar(255) DEFAULT NULL,
		  `statut` varchar(8) NOT NULL DEFAULT '',
		  `date_statut` datetime DEFAULT NULL,
		  `source` varchar(4) NOT NULL DEFAULT ''
		);
		
		INSERT INTO `syn_3`
		SELECT DISTINCT `N° ticket` as 'id_toc','creation' as 'statut',  convert_tz(STR_TO_DATE(`Date début ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'date_statut', 'core' as 'source'
		FROM `tab_oceane_tickets_core` a 
		WHERE 1=1
		AND EXISTS (SELECT 1 FROM `syn_0` b WHERE b.`N° ticket` = a.`N° ticket`)
		;
		
		INSERT INTO `syn_3`
		SELECT DISTINCT `N° ticket` as 'id_toc','nouveau' as 'statut',  convert_tz(STR_TO_DATE(`Date création ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'date_statut', 'core' as 'source'
		FROM `tab_oceane_tickets_core` a 
		WHERE 1=1
		AND EXISTS (SELECT 1 FROM `syn_0` b WHERE b.`N° ticket` = a.`N° ticket`)
		;
		
		INSERT INTO `syn_3`
		SELECT DISTINCT `N° ticket` as 'id_toc','rétabli' as 'statut',  convert_tz(STR_TO_DATE(`Date rétabliss. ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'date_statut', 'core' as 'source'
		FROM `tab_oceane_tickets_core` c 
		WHERE 1=1
		AND `Date rétabliss. ticket (UTC)` != ''
		AND EXISTS (SELECT 1 FROM `syn_0` d WHERE d.`N° ticket` = c.`N° ticket`)
		;
		
		INSERT INTO `syn_3`
		SELECT DISTINCT `N° ticket` as 'id_toc','réparé' as 'statut',  convert_tz(STR_TO_DATE(`Date réparation (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'date_statut', 'core' as 'source'
		FROM `tab_oceane_tickets_core` c 
		WHERE 1=1
		AND `Date réparation (UTC)` != ''
		AND EXISTS (SELECT 1 FROM `syn_0` d WHERE d.`N° ticket` = c.`N° ticket`)
		;
		
		INSERT INTO `syn_3`
		SELECT DISTINCT `N° ticket` as 'id_toc','clos' as 'statut',  convert_tz(STR_TO_DATE(`Date clôture ticket (UTC)`, '%Y/%m/%d %H:%i:%s'), 'UTC', 'Europe/Paris') as 'date_statut', 'core' as 'source'
		FROM `tab_oceane_tickets_core` c 
		WHERE 1=1
		AND `Date clôture ticket (UTC)` != ''
		AND EXISTS (SELECT 1 FROM `syn_0` d WHERE d.`N° ticket` = c.`N° ticket`)
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_3`;
			INSERT INTO `tmp_syn_3`
			SELECT * FROM `syn_3`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb3
			FROM `syn_3`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_3) : ',nb3))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*6) Assemblage des données des différentes sources*/
		DROP TEMPORARY TABLE IF EXISTS `syn_4`;
		CREATE TEMPORARY TABLE `syn_4` (
		  `id_toc` varchar(255) DEFAULT NULL,
		  `statut` varchar(255) DEFAULT NULL,
		  `date_statut` datetime DEFAULT NULL,
		  `source` varchar(6) NOT NULL DEFAULT '',
		  `ordre` int(2) DEFAULT 0
		);
		
		INSERT INTO `syn_4`
		SELECT DISTINCT a.`id_toc`, a.`statut`, a.`date_statut`, a.`source`,0  FROM `syn_1` a
		;
		
		INSERT INTO `syn_4`
		SELECT DISTINCT c.`id_toc`, c.`statut`, c.`date_statut`, c.`source`,0  FROM `syn_3` c
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_4`;
			INSERT INTO `tmp_syn_4`
			SELECT * FROM `syn_4`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb4
			FROM `syn_4`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_4) : ',nb4))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*Lever des horodatages identiques */
		DROP TEMPORARY TABLE IF EXISTS `syn_4_1`;
		CREATE TEMPORARY TABLE `syn_4_1`
		SELECT id_toc, date_statut, count(*) as 'nombre'
			FROM `syn_4` b
			WHERE 1=1
			GROUP BY id_toc, date_statut
			HAVING COUNT(*) > 1
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_4_1`;
			INSERT INTO `tmp_syn_4_1`
			SELECT * FROM `syn_4_1`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb4_1
			FROM `syn_4_1`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_4_1) : ',nb4_1))
			;
		END IF;

		/*--------------------------------------------------------*/
		/*Création d'un identifiant unique */
		SET @rownum := 0; 
		DROP TEMPORARY TABLE IF EXISTS `syn_4_2`;
		CREATE TEMPORARY TABLE `syn_4_2`
		SELECT a.*, @rownum := @rownum + 1 AS rank
		FROM `syn_4` a
		WHERE 1=1
		AND EXISTS(
			SELECT 1
			FROM `syn_4_1` b
			WHERE 1=1
			AND b.id_toc = a.id_toc
			AND b.date_statut = a.date_statut
		)
		ORDER BY id_toc, date_statut asc, FIELD( statut, 'creation','nouveau','entree','aquit','rétabli','réparé','sortie','clos') asc
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_4_2`;
			INSERT INTO `tmp_syn_4_2`
			SELECT * FROM `syn_4_2`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb4_2
			FROM `syn_4_2`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_4_2) : ',nb4_2))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/* Rapatrie l'ordre*/
		DROP TEMPORARY TABLE IF EXISTS `syn_4_2_1`;
		CREATE TEMPORARY TABLE `syn_4_2_1`
			AS
		SELECT a.*
		FROM `syn_4_2` a
		;
		
		UPDATE `syn_4` a
		SET a.`ordre` = (SELECT b.`rank` 
			FROM `syn_4_2` b 
			WHERE 1=1 
			AND b.`id_toc` = a.`id_toc`
			AND b.`statut` = a.`statut`
			AND b.`date_statut` = a.`date_statut`
		)
		WHERE 1=1
		AND EXISTS (SELECT 1 
			FROM `syn_4_2_1` c 
			WHERE 1=1 
			AND c.`id_toc` = a.`id_toc`
			AND c.`statut` = a.`statut`
			AND c.`date_statut` = a.`date_statut`
		)
		;
		
		/*--------------------------------------------------------*/
		DROP TEMPORARY TABLE IF EXISTS `syn_4_3`;
		CREATE TEMPORARY TABLE `syn_4_3` (
		  `id` int(11) NOT NULL AUTO_INCREMENT,
		  `id_toc` varchar(255) DEFAULT NULL,
		  `statut` varchar(255) DEFAULT NULL,
		  `date_statut` datetime DEFAULT NULL,
		  `source` varchar(6) NOT NULL DEFAULT '',
		  PRIMARY KEY (`id`)
		);

		INSERT INTO `syn_4_3`
		SELECT null, `id_toc`,`statut`,`date_statut`,`source`
		FROM `syn_4`
		ORDER BY `id_toc`, `date_statut`, `ordre`
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_4_3`;
			INSERT INTO `tmp_syn_4_3`
			SELECT * FROM `syn_4_3`;
		END IF;
		
		/*--------------------------------------------------------*/
		DROP TEMPORARY TABLE IF EXISTS `syn_4_4`;
		CREATE TEMPORARY TABLE `syn_4_4`
			AS
		SELECT a.*
		FROM `syn_4_3` a
		;
		
		/*7) Construction du numéro de version*/
		DROP TEMPORARY TABLE IF EXISTS `syn_5`;
		CREATE TEMPORARY TABLE `syn_5`
			AS
		SELECT a.*, (
			select CASE a.`statut`
				WHEN 'entree' THEN count(*) + 1
				ELSE count(*)
				END as 'result'
			from `syn_4_3` b 
			where 1=1
			AND b.`id_toc` = a.`id_toc` 
			AND b.`statut` = 'entree' 
			AND b.`id` < a.`id`
		) as 'version'
		FROM `syn_4_4` a
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_5`;
			INSERT INTO `tmp_syn_5`
			SELECT * FROM `syn_5`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb5
			FROM `syn_5`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_5) : ',nb5))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*8) Filtre les états 'création' qui est la date genergy*/
		DELETE FROM `syn_5`
		WHERE 1=1
		AND `statut` in ('creation')
		;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb5v2
			FROM `syn_5`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket restant (syn_5 v2) : ',nb5v2))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*9_0) On garde le statut nouveau que pour les tickets Emis pour lequel l'eds n'a pas été activé donc pas d'entree*/
		CREATE TEMPORARY TABLE `syn_5_0`
		(
			`id_toc` varchar(250) NOT NULL,
			`nb` tinyint(2),
			INDEX (`id_toc`)
		) 
		SELECT a.`id_toc`, count(*) as 'nb'
		FROM `syn_5` a
		WHERE 1=1
		AND a.`statut` = 'entree'
		GROUP BY a.`id_toc`
		HAVING COUNT(*) > 0
		;

		DELETE a FROM `syn_5` a
		INNER JOIN `syn_5_0` b
		ON b.`id_toc` = a.`id_toc`
		WHERE 1=1
		AND a.`statut` = 'nouveau'
		;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb5_0
			FROM `syn_5_0`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de statut concerné (syn_5_0) : ',nb5_0))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*9) On récupére la dernière entrée ou sortie*/
		DROP TEMPORARY TABLE IF EXISTS `syn_6`;
		CREATE TEMPORARY TABLE `syn_6`
			AS
		SELECT `id_toc`, max(`id`) as 'max_id'
		FROM `syn_5`
		WHERE 1=1
		AND `statut` in ('entree','sortie')
		GROUP BY `id_toc`
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_6`;
			INSERT INTO `tmp_syn_6`
			SELECT * FROM syn_6;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb6
			FROM `syn_6`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_6) : ',nb6))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*10) Récupère les informations correspondantes*/
		DROP TEMPORARY TABLE IF EXISTS `syn_7`;
		CREATE TEMPORARY TABLE `syn_7`
			AS
		SELECT a.`id`, a.`id_toc`, a.`statut`, a.`date_statut`, a.`source`  
		FROM `syn_5` a, `syn_6` b
		WHERE 1=1
		AND a.id_toc = b.id_toc
		AND a.`id` = b.`max_id`
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_7`;
			INSERT INTO `tmp_syn_7`
			SELECT * FROM `syn_7`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb7
			FROM `syn_7`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_7) : ',nb7))
			;
		END IF;

		/*--------------------------------------------------------*/
		/*11) On filtre les entrees */
		DELETE FROM `syn_7`
		WHERE 1=1
		AND `statut` = 'entree'
		;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb7bis
			FROM `syn_7`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_7 v2) : ',nb7bis))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*12) On ne récupère que ce qu'il y avant les sorties*/
		DROP TEMPORARY TABLE IF EXISTS `syn_8`;
		CREATE TEMPORARY TABLE `syn_8`
			AS
		SELECT a.*  
		FROM `syn_5` a
		WHERE 1=1
		AND NOT EXISTS (SELECT 1 
			FROM `syn_7` b 
			WHERE 1=1 
			AND b.`id_toc` = a.`id_toc` 
			AND b.`id` < a.`id`
		)
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_8`;
			INSERT INTO `tmp_syn_8`
			SELECT * FROM `syn_8`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb8
			FROM `syn_8`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_8) : ',nb8))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*13) On récupère la dernière écriture */
		DROP TEMPORARY TABLE IF EXISTS `syn_9`;
		CREATE TEMPORARY TABLE `syn_9`
			AS
		SELECT a.id_toc, max(a.`id`) as 'max_id'
		FROM `syn_8` a
		GROUP BY a.id_toc
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_9`;
			INSERT INTO `tmp_syn_9`
			SELECT * FROM `syn_9`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb9
			FROM `syn_9`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_9) : ',nb9))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*14) On crée le tag actif*/
		DROP TEMPORARY TABLE IF EXISTS `syn_10`;
		CREATE TEMPORARY TABLE `syn_10`
			AS
		SELECT a.*,
		(
			SELECT COUNT(*) 
			FROM `syn_9` b 
			WHERE 1=1
			AND b.id_toc = a.id_toc 
			AND b.`max_id` = a.`id` 
		) as 'actif'
		FROM `syn_8` a
		ORDER BY a.`id_toc` asc, a.`date_statut` asc, a.`version` asc
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_10`;
			INSERT INTO `tmp_syn_10`
			SELECT * FROM `syn_10`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb10
			FROM `syn_10`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_10) : ',nb10))
			;
		END IF;

		/*--------------------------------------------------------*/
		/*15) On change le statut entree quant la version n'est pas la première */
		Update `syn_10` a
		SET `statut` = 'reouvert'
		WHERE 1=1
		AND `statut` = 'entree'
		AND `version` != 1
		;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb10bis
			FROM `syn_10`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_10 v2) : ',nb10bis))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*16) Mapping de correspondance NOA*/
		CASE v_type_synchro
			WHEN 'SN3DISE' THEN 
				BEGIN
					DROP TEMPORARY TABLE IF EXISTS `syn_11`;
					CREATE TEMPORARY TABLE `syn_11`
						AS
					SELECT a.*,
					CASE a.`statut`
						WHEN 'entree' THEN 1 /*Nouveau*/
						WHEN 'nouveau' THEN 1 /*Nouveau*/
						WHEN 'aquit' THEN 2 /*Pris en main*/
						WHEN 'rétabli' THEN 4 /*En attente*/
						WHEN 'réparé' THEN 8 /*Résolu*/
						WHEN 'reouvert' THEN 7 /*Ré-ouvert*/
						WHEN 'sortie' THEN 5 /*Fermé*/
						WHEN 'clos' THEN 5 /*Fermé*/
						ELSE null
					END as 'id_tag'
					FROM `syn_10` a
					WHERE 1=1
					ORDER BY a.`id_toc` asc, a.`date_statut` asc, a.`version` asc
					;
				END;
			
			WHEN 'ADV' THEN 
				BEGIN
					DROP TEMPORARY TABLE IF EXISTS `syn_11`;
					CREATE TEMPORARY TABLE `syn_11`
						AS
					SELECT a.*,
					CASE a.`statut`
						WHEN 'entree' THEN 1 /*Nouveau*/
						WHEN 'nouveau' THEN 1 /*Nouveau*/
						WHEN 'aquit' THEN 2 /*Pris en main*/
						WHEN 'rétabli' THEN 8  /*Résolu*/
						WHEN 'réparé' THEN 8 /*Résolu*/
						WHEN 'reouvert' THEN 7 /*Ré-ouvert*/
						WHEN 'sortie' THEN 5 /*Fermé*/
						WHEN 'clos' THEN 5 /*Fermé*/
						ELSE null
					END as 'id_tag'
					FROM `syn_10` a
					WHERE 1=1
					ORDER BY a.`id_toc` asc, a.`date_statut` asc, a.`version` asc
					;
				END;
		END CASE
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_11`;
			INSERT INTO `tmp_syn_11`
			SELECT * FROM `syn_11`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb11
			FROM `syn_11`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_11) : ',nb11))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*17) L'existant*/
		DROP TEMPORARY TABLE IF EXISTS `syn_12`;
		CREATE TEMPORARY TABLE `syn_12`
			AS
		SELECT a.id, a.label, b.id_tag, b.dateTime_creation, b.actif
		FROM `tab_tickets` a, `tab_tags_affecte` b
		WHERE 1=1
		AND a.id = b.id_toc
		AND b.id_type = 9/*statut*/
		AND EXISTS (SELECT 1 FROM `syn_0` c WHERE c.`N° ticket` = a.label)
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_12`;
			INSERT INTO `tmp_syn_12`
			SELECT * FROM `syn_12`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb12
			FROM `syn_12`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_12) : ',nb12))
			;
		END IF;

		/*--------------------------------------------------------*/
		/*18) Recoupement entre le calculé et l'existant */
		DROP TEMPORARY TABLE IF EXISTS `syn_13`;
		CREATE TEMPORARY TABLE `syn_13`
			AS
		SELECT a.`id_toc`, a.`statut`, a.`date_statut`, a.`source`, a.`version`, a.`actif`, a.`id_tag`, c.`id`
		FROM `syn_11` a, `tab_tickets` c
		WHERE 1=1
		AND a.`id_toc` = c.label
		AND NOT EXISTS (SELECT 1 FROM `syn_12` b WHERE 1=1
			AND b.`label` = a.`id_toc`
			AND b.id_tag = a.id_tag
			AND b.dateTime_creation = a.`date_statut`
			AND b.actif = a.actif
		)
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM `tmp_syn_13`;
			INSERT INTO `tmp_syn_13`
			SELECT * FROM `syn_13`;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb13
			FROM `syn_13`
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné (syn_13) : ',nb13))
			;
		END IF;
		
		/*--------------------------------------------------------*/
		/*19) Desactivation des tags actifs présents*/
		IF NOT debug THEN
			UPDATE `tab_tags_affecte` a
			SET a.actif = 0
			, a.dateTime_modification = NOW()
			, a.auteur_modification = 'synchro'
			WHERE 1=1
			AND a.actif = 1
			AND a.id_type = 9
			AND EXISTS (select 1 from `syn_13` b WHERE b.`id` = a.id_toc AND b.actif = 1)
			;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb14
			FROM `tab_tags_affecte` a
			WHERE 1=1
			AND a.actif = 1
			AND a.id_type = 9/*statut*/
			AND EXISTS (select 1 from `syn_13` b WHERE b.`id` = a.id_toc AND b.actif = 1)
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné 19 : ',nb14))
			;
		END IF;

		/*--------------------------------------------------------*/
		/*20) Insertion des nouveaux tags*/
		IF NOT debug THEN
			INSERT INTO `tab_tags_affecte`
			(id_toc,id_type,id_tag,actif,dateTime_creation,auteur_creation)
			SELECT a.id, 9, a.id_tag, a.actif, a.`date_statut`, 'synchro'
			FROM `syn_13` a
			WHERE 1=1
			AND NOT EXISTS (SELECT 1 FROM `tab_tags_affecte` b
				WHERE 1=1
				AND b.id_toc = a.id
				AND b.id_type = 9
				AND b.id_tag = a.id_tag
				AND b.actif = a.actif
				AND b.dateTime_creation = a.`date_statut`
			)
			;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb15
			FROM `syn_13` a
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné 20 : ',nb15))
			;
		END IF;

		/*--------------------------------------------------------*/
		/*21) Mise à jour pour les existants pour les versions*/
		DROP TEMPORARY TABLE IF EXISTS `syn_13_1`;
		CREATE TEMPORARY TABLE `syn_13_1`
			AS
		SELECT a.*
		FROM `syn_13` a
		;
		
		IF NOT debug THEN
			UPDATE `tab_tags_affecte` a
			SET a.`id_tag` = (select c.`version` from `syn_13` c WHERE c.`id` = a.`id_toc` AND c.`actif` = 1)
			, a.`dateTime_modification` = NOW()
			, a.`auteur_modification` = 'synchro'
			WHERE 1=1
			AND a.`actif` = 1
			AND a.`id_type` = 91
			AND EXISTS (select 1 from `syn_13_1` b WHERE b.`id` = a.`id_toc` AND b.`actif` = 1 AND b.`version` != a.`id_tag`)
			;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb16
			FROM `tab_tags_affecte` a
			WHERE 1=1
			AND a.`actif` = 1
			AND a.`id_type` = 91/*Version*/
			AND EXISTS (select 1 from `syn_13` b WHERE b.`id` = a.`id_toc` AND b.`actif` = 1 AND b.`version` != a.`id_tag`)
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné 21 : ',nb16))
			;
		END IF;

		/*--------------------------------------------------------*/
		/*22) Insertion de version pour les non init*/
		IF NOT debug THEN
			INSERT INTO `tab_tags_affecte`
			(id_toc,id_type,id_tag,actif,dateTime_creation,auteur_creation)
			SELECT a.id, 91, a.version, a.actif, a.`date_statut`, 'synchro'
			FROM `syn_13` a
			WHERE 1=1
			AND actif = 1
			AND NOT EXISTS (select 1 from `tab_tags_affecte` b WHERE b.id_toc = a.id AND b.actif = 1 AND a.version = b.id_tag)
			;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb17
			FROM `syn_13` a
			WHERE 1=1
			AND actif = 1
			AND NOT EXISTS (select 1 from `tab_tags_affecte` b WHERE b.id_toc = a.id AND b.actif = 1 AND a.version = b.id_tag)
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné 22 : ',nb17))
			;
		END IF;

		/*--------------------------------------------------------*/
		/*23) Ajout des éléments à mettre à jour pour le corps*/
		INSERT INTO `syn_id_toc`
		(`id_toc`)
		SELECT DISTINCT `id` FROM `syn_13`
		;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(DISTINCT `id`)
			INTO nb18
			FROM `syn_13` a
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné 23 : ',nb18))
			;
		END IF;

	/*--------------------------------------------------------*/
	/*24)Lance reconsiliation de la date de mise à jour core*/
	IF trace THEN
		SELECT COUNT(DISTINCT `id_toc`)
		INTO nb19
		FROM `syn_id_toc`
		;
		
		INSERT INTO `tab_log`
		(`dateTime`,`commentaires`)
		VALUES 
		(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Nombre de ticket concerné 24 : ',nb19))
		;
	END IF;
	
	
	IF NOT debug THEN
		OPEN cur1;

		REPEAT
		FETCH cur1 INTO a;
		IF NOT done THEN
			SELECT reconcil_modif(a)
			INTO b;
			/* POUR DEBUG*/
			IF debug THEN
				INSERT INTO `tab_log`
				(`dateTime`,`commentaires`)
				VALUES 
				(NOW(),concat('[SYNCHRO_OCEANE_STA_VR]Reconciliation des modifs sur : ',a))
				;
			END IF;
		END IF;
		UNTIL done END REPEAT;

		CLOSE cur1;
	END IF;
		
	RETURN 1; 
END$$