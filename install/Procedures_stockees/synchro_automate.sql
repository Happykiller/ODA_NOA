/*
* La synchronisation.
*
* @param {text} p_date (ex : 2013-08-01)
* @return {int} : Si pas d'erreur sortie par defaut (ex : 1)
* @example : select synchro_automate('yyyy-mm-dd');
*/
DROP FUNCTION IF EXISTS `synchro_automate`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `synchro_automate`( p_date TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE nb0,nb1,nb2,nb3,nb4,nb5,nb5v2,nb6,nb7,nb7bis,nb8,nb9,nb10,nb10bis,nb11,nb12,nb13,nb14,nb15,nb16,nb17,nb18,nb19,nb20 INT DEFAULT 0;
	DECLARE v_type_synchro VARCHAR(100);
	
	DECLARE debug BOOLEAN DEFAULT FALSE;
	DECLARE trace BOOLEAN DEFAULT TRUE;
	
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
	
	/*Récupération parametrage*/
	SELECT `param_value`
	INTO v_type_synchro
	FROM `tab_parametres`
	WHERE 1=1
	AND `param_name` = 'type_synchro_oceane_noa'
	;
	
	/*------------------------------------------------------------*/
	/*Recup que la dernier version des tickets*/
	DROP TEMPORARY TABLE IF EXISTS syn_0;
	CREATE TEMPORARY TABLE syn_0
	AS
	SELECT a.`id_toc` as 'label', MAX(a.`id`) as 'id_tab_auto_max' 
	FROM `tab_automate_ticket_details` a 
	WHERE 1=1 
	AND (
		STR_TO_DATE(a.`dernière_action`, '%d/%m/%Y %H:%i') >= STR_TO_DATE(p_date, '%Y-%m-%d') 
		OR
		STR_TO_DATE(a.`date_creation`, '%d/%m/%Y %H:%i') >= STR_TO_DATE(p_date, '%Y-%m-%d')
	)
	GROUP BY a.`id_toc`
	;
	
	/* POUR DEBUG*/
	IF debug THEN
		DELETE FROM tmp_0scritp;
		INSERT INTO tmp_0scritp
		SELECT * FROM syn_0;
	END IF;
	
	/* POUR TRACE*/
	IF trace THEN
		SELECT COUNT(*)
		INTO nb0
		FROM syn_0
		;
		
		INSERT INTO `tab_log`
		(`dateTime`,`commentaires`)
		VALUES 
		(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_0) avec ',p_date,' en input : ',nb0))
		;
	END IF;
	
	/*------------------------------------------------------------*/
	/*Alimentation détails*/
	DROP TEMPORARY TABLE IF EXISTS syn_1;
	CREATE TEMPORARY TABLE syn_1
	AS
	SELECT a.`id` as 'id_tab_auto'
	, c.`id` as 'id_tab_noa'
	, b.`label`
	, 42 as 'criticite'
	, CASE 
		WHEN a.`priorite` like '%P4%'  THEN 38 
		WHEN a.`priorite` like '%P3%'  THEN 37  
		WHEN a.`priorite` like '%P2%'  THEN 36  
		WHEN a.`priorite` like '%P1%'  THEN 35 
		ELSE 38 END
		as 'priorite'
	, a.`libelle` as 'description'
	, get_mapping_statut_automate(v_type_synchro, a.`statut`) as 'statut'
	, STR_TO_DATE(a.`dernière_action`, '%d/%m/%Y %H:%i') as 'date_der_action'
	, 'automate' as `auteur` 
	FROM `tab_automate_ticket_details` a, `syn_0` b, `tab_tickets` c
	WHERE 1=1
	AND a.`id` = b.`id_tab_auto_max`
	AND a.`id_toc` = c.`label`
	;
	
	/* POUR DEBUG*/
	IF debug THEN
		DELETE FROM tmp_1scritp;
		INSERT INTO tmp_1scritp
		SELECT * FROM syn_1;
	END IF;
	
	/* POUR TRACE*/
	IF trace THEN
		SELECT COUNT(*)
		INTO nb1
		FROM syn_1
		;
		
		INSERT INTO `tab_log`
		(`dateTime`,`commentaires`)
		VALUES 
		(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_1) avec ',p_date,' en input : ',nb1))
		;
	END IF;
	
	/*------------------------------------------------------------*/
	/*Statut(9)*/
		/*Le croisement*/
		DROP TEMPORARY TABLE IF EXISTS syn_2;
		CREATE TEMPORARY TABLE syn_2
		AS
		SELECT a.`id_tab_noa`
		, a.`id_tab_auto`
		, a.`label`
		, a.`statut` as 'statut_automate'
		, a.`date_der_action` as 'date_max_auto'
		, IFNULL(b.`id_tag`,0) as 'statut_noa'
		, IFNULL(GREATEST(b.`dateTime_creation`, b.`dateTime_modification`),'0000-00-00 00:00:00') as 'date_max_noa'
		FROM `syn_1` a
			LEFT JOIN `tab_tags_affecte` b
			ON a.`id_tab_noa` = b.`id_toc`
			AND b.`id_type` = 9/*Statut*/
			AND b.`actif` = 1
		WHERE 1=1
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM tmp_2scritp;
			INSERT INTO tmp_2scritp
			SELECT * FROM syn_2;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb2
			FROM syn_2
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_2) avec ',p_date,' en input : ',nb2))
			;
		END IF;
		
		/*Liste du delta*/
		DROP TEMPORARY TABLE IF EXISTS syn_3;
		CREATE TEMPORARY TABLE syn_3
		AS
		SELECT *
		FROM `syn_2` a
		WHERE 1=1
		AND a.`date_max_noa` < a.`date_max_auto`
		AND a.`statut_automate` != a.`statut_noa`
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM tmp_3scritp;
			INSERT INTO tmp_3scritp
			SELECT * FROM syn_3;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb3
			FROM syn_3
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_3) avec ',p_date,' en input : ',nb3))
			;
		END IF;
		
		/*On desactive*/
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb4
			FROM `tab_tags_affecte` a
			WHERE 1=1
			AND a.`id_type` = 9/*Statut*/
			AND a.`actif` = 1
			AND EXISTS (SELECT 1 FROM `syn_3` b WHERE b.`id_tab_noa` = a.`id_toc`)
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_4) avec ',p_date,' en input : ',nb4))
			;
		END IF;
		
		UPDATE `tab_tags_affecte` a
		SET a.`actif` = 0
		, a.`dateTime_modification` = NOW()
		, a.`auteur_modification` = 'synchro_automate'
		WHERE 1=1
		AND a.`id_type` = 9/*Statut*/
		AND a.`actif` = 1
		AND EXISTS (SELECT 1 FROM `syn_3` b WHERE b.`id_tab_noa` = a.`id_toc`)
		;
		
		/*On inject*/
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb5
			FROM `syn_3` a
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_5) avec ',p_date,' en input : ',nb5))
			;
		END IF;
		
		/*insertion du nouvel element*/
		INSERT INTO `tab_tags_affecte`
		(`id`,`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
		SELECT null, a.`id_tab_noa`, 9, a.`statut_automate`, 1, a.`date_max_auto`, 'synchro_automate', null, null
		FROM `syn_3` a
		;
		
		/*Alimentation historique*/
		INSERT INTO `tab_ticket_histo_change`
		(`id`,`id_toc`,`auteur`,`dateTime_change`,`changement`)
		SELECT null, a.`id_tab_noa`, 'synchro_automate', NOW(), CONCAT("<ul><li>[Ticket Détails Context][Statut]Redescente Synchronisation => ",a.`statut_automate`,"</li></ul>")
		FROM `syn_3` a
		;
		
		/*Alimentation table pour reconsiliation*/
		INSERT INTO `syn_id_toc`
		(`id_toc`)
		SELECT `id_tab_noa` FROM `syn_3`
		;
		
	/*------------------------------------------------------------*/
	/*priorité(15)*/
		/*Le croisement*/
		DROP TEMPORARY TABLE IF EXISTS syn_6;
		CREATE TEMPORARY TABLE syn_6
		AS
		SELECT a.`id_tab_noa`
		, a.`id_tab_auto`
		, a.`label`
		, a.`priorite` as 'priorite_automate'
		, a.`date_der_action` as 'date_max_auto'
		, IFNULL(b.`id_tag`,0) as 'priorite_noa'
		, IFNULL(GREATEST(b.`dateTime_creation`, b.`dateTime_modification`),'0000-00-00 00:00:00') as 'date_max_noa'
		FROM `syn_1` a
			LEFT JOIN `tab_tags_affecte` b
			ON a.`id_tab_noa` = b.`id_toc`
			AND b.`id_type` = 15/*priorité*/
			AND b.`actif` = 1
		WHERE 1=1
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM tmp_6scritp;
			INSERT INTO tmp_6scritp
			SELECT * FROM syn_6;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb6
			FROM syn_6
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_6) avec ',p_date,' en input : ',nb6))
			;
		END IF;
		
		/*Liste du delta*/
		DROP TEMPORARY TABLE IF EXISTS syn_7;
		CREATE TEMPORARY TABLE syn_7
		AS
		SELECT *
		FROM `syn_6` a
		WHERE 1=1
		AND a.`date_max_noa` < a.`date_max_auto`
		AND a.`priorite_automate` != a.`priorite_noa`
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM tmp_7scritp;
			INSERT INTO tmp_7scritp
			SELECT * FROM syn_7;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb7
			FROM syn_7
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_7) avec ',p_date,' en input : ',nb7))
			;
		END IF;
		
		/*On desactive*/
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb8
			FROM `tab_tags_affecte` a
			WHERE 1=1
			AND a.`id_type` = 15/*priorité*/
			AND a.`actif` = 1
			AND EXISTS (SELECT 1 FROM `syn_7` b WHERE b.`id_tab_noa` = a.`id_toc`)
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_8) avec ',p_date,' en input : ',nb8))
			;
		END IF;
		
		UPDATE `tab_tags_affecte` a
		SET a.`actif` = 0
		, a.`dateTime_modification` = NOW()
		, a.`auteur_modification` = 'synchro_automate'
		WHERE 1=1
		AND a.`id_type` = 15/*priorité*/
		AND a.`actif` = 1
		AND EXISTS (SELECT 1 FROM `syn_7` b WHERE b.`id_tab_noa` = a.`id_toc`)
		;
		
		/*On inject*/
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb9
			FROM `syn_7` a
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_9) avec ',p_date,' en input : ',nb9))
			;
		END IF;
		
		/*insertion du nouvel element*/
		INSERT INTO `tab_tags_affecte`
		(`id`,`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
		SELECT null, a.`id_tab_noa`, 15, a.`priorite_automate`, 1, a.`date_max_auto`, 'synchro_automate', null, null
		FROM `syn_7` a
		;
		
		/*Alimentation historique*/
		INSERT INTO `tab_ticket_histo_change`
		(`id`,`id_toc`,`auteur`,`dateTime_change`,`changement`)
		SELECT null, a.`id_tab_noa`, 'synchro_automate', NOW(), CONCAT("<ul><li>[Ticket Détails Context][Priorité]Redescente Synchronisation => ",a.`priorite_automate`,"</li></ul>")
		FROM `syn_7` a
		;
		
		/*Alimentation table pour reconsiliation*/
		INSERT INTO `syn_id_toc`
		(`id_toc`)
		SELECT `id_tab_noa` FROM `syn_7`
		;
		
	/*------------------------------------------------------------*/
	/*criticite(16)*/
		/*Le croisement*/
		DROP TEMPORARY TABLE IF EXISTS syn_10;
		CREATE TEMPORARY TABLE syn_10
		AS
		SELECT a.`id_tab_noa`
		, a.`id_tab_auto`
		, a.`label`
		, a.`criticite` as 'criticite_automate'
		, a.`date_der_action` as 'date_max_auto'
		, IFNULL(b.`id_tag`,0) as 'criticite_noa'
		, IFNULL(GREATEST(b.`dateTime_creation`, b.`dateTime_modification`),'0000-00-00 00:00:00') as 'date_max_noa'
		FROM `syn_1` a
			LEFT JOIN `tab_tags_affecte` b
			ON a.`id_tab_noa` = b.`id_toc`
			AND b.`id_type` = 16/*criticite*/
			AND b.`actif` = 1
		WHERE 1=1
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM tmp_10scritp;
			INSERT INTO tmp_10scritp
			SELECT * FROM syn_10;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb10
			FROM syn_10
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_10) avec ',p_date,' en input : ',nb10))
			;
		END IF;
		
		/*Liste du delta*/
		DROP TEMPORARY TABLE IF EXISTS syn_11;
		CREATE TEMPORARY TABLE syn_11
		AS
		SELECT *
		FROM `syn_10` a
		WHERE 1=1
		AND a.`date_max_noa` < a.`date_max_auto`
		AND a.`criticite_automate` != a.`criticite_noa`
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM tmp_11scritp;
			INSERT INTO tmp_11scritp
			SELECT * FROM syn_11;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb11
			FROM syn_11
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_11) avec ',p_date,' en input : ',nb11))
			;
		END IF;
		
		/*On desactive*/
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb12
			FROM `tab_tags_affecte` a
			WHERE 1=1
			AND a.`id_type` = 16/*criticite*/
			AND a.`actif` = 1
			AND EXISTS (SELECT 1 FROM `syn_11` b WHERE b.`id_tab_noa` = a.`id_toc`)
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_12) avec ',p_date,' en input : ',nb12))
			;
		END IF;
		
		UPDATE `tab_tags_affecte` a
		SET a.`actif` = 0
		, a.`dateTime_modification` = NOW()
		, a.`auteur_modification` = 'synchro_automate'
		WHERE 1=1
		AND a.`id_type` = 16/*criticite*/
		AND a.`actif` = 1
		AND EXISTS (SELECT 1 FROM `syn_11` b WHERE b.`id_tab_noa` = a.`id_toc`)
		;
		
		/*On inject*/
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb13
			FROM `syn_11` a
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_13) avec ',p_date,' en input : ',nb13))
			;
		END IF;
		
		/*insertion du nouvel element*/
		INSERT INTO `tab_tags_affecte`
		(`id`,`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
		SELECT null, a.`id_tab_noa`, 16, a.`criticite_automate`, 1, a.`date_max_auto`, 'synchro_automate', null, null
		FROM `syn_11` a
		;
		
		/*Alimentation historique*/
		INSERT INTO `tab_ticket_histo_change`
		(`id`,`id_toc`,`auteur`,`dateTime_change`,`changement`)
		SELECT null, a.`id_tab_noa`, 'synchro_automate', NOW(), CONCAT("<ul><li>[Ticket Détails Context][Criticité]Redescente Synchronisation => ",a.`criticite_automate`,"</li></ul>")
		FROM `syn_11` a
		;
		
		/*Alimentation table pour reconsiliation*/
		INSERT INTO `syn_id_toc`
		(`id_toc`)
		SELECT `id_tab_noa` FROM `syn_11`
		;
		
	/*------------------------------------------------------------*/
	/*Description(70)*/
		/*Le croisement*/
		DROP TEMPORARY TABLE IF EXISTS syn_14;
		CREATE TEMPORARY TABLE syn_14
		AS
		SELECT a.`id_tab_noa`
		, a.`id_tab_auto`
		, a.`label`
		, a.`description` as 'description_automate'
		, a.`date_der_action` as 'date_max_auto'
		, IFNULL(b.`note`,"") as 'description_noa'
		, IFNULL(GREATEST(b.`dateTime_creation`, b.`dateTime_modification`),'0000-00-00 00:00:00') as 'date_max_noa'
		FROM `syn_1` a
			LEFT JOIN `tab_notes` b
			ON a.`id_tab_noa` = b.`id_toc`
			AND b.`id_type` = 70/*Description*/
			AND b.`actif` = 1
		WHERE 1=1
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM tmp_14scritp;
			INSERT INTO tmp_14scritp
			SELECT * FROM syn_14;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb14
			FROM syn_14
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_14) avec ',p_date,' en input : ',nb14))
			;
		END IF;
		
		/*Liste du delta*/
		DROP TEMPORARY TABLE IF EXISTS syn_15;
		CREATE TEMPORARY TABLE syn_15
		AS
		SELECT *
		FROM `syn_14` a
		WHERE 1=1
		AND a.`date_max_noa` < a.`date_max_auto`
		AND a.`description_automate` != a.`description_noa`
		;
		
		/* POUR DEBUG*/
		IF debug THEN
			DELETE FROM tmp_15scritp;
			INSERT INTO tmp_15scritp
			SELECT * FROM syn_15;
		END IF;
		
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb15
			FROM syn_15
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_15) avec ',p_date,' en input : ',nb15))
			;
		END IF;
		
		/*On desactive*/
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb16
			FROM `tab_notes` a
			WHERE 1=1
			AND a.`id_type` = 70/*criticite*/
			AND a.`actif` = 1
			AND EXISTS (SELECT 1 FROM `syn_15` b WHERE b.`id_tab_noa` = a.`id_toc`)
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_12) avec ',p_date,' en input : ',nb12))
			;
		END IF;
		
		UPDATE `tab_notes` a
		SET a.`actif` = 0
		, a.`dateTime_modification` = NOW()
		, a.`auteur_modification` = 'synchro_automate'
		WHERE 1=1
		AND a.`id_type` = 70/*criticite*/
		AND a.`actif` = 1
		AND EXISTS (SELECT 1 FROM `syn_15` b WHERE b.`id_tab_noa` = a.`id_toc`)
		;
		
		/*On inject*/
		/* POUR TRACE*/
		IF trace THEN
			SELECT COUNT(*)
			INTO nb17
			FROM `syn_15` a
			;
			
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[SYNCHRO_AUTOMATE]Nombre de ticket concerné (syn_17) avec ',p_date,' en input : ',nb17))
			;
		END IF;
		
		/*insertion du nouvel element*/
		INSERT INTO `tab_notes`
		(`id`,`id_toc`,`note`,`id_type`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
		SELECT null, a.`id_tab_noa`, a.`description_automate`, 70, 1, a.`date_max_auto`, 'synchro_automate', null, null
		FROM `syn_15` a
		;
		
		/*Alimentation historique*/
		INSERT INTO `tab_ticket_histo_change`
		(`id`,`id_toc`,`auteur`,`dateTime_change`,`changement`)
		SELECT null, a.`id_tab_noa`, 'synchro_automate', NOW(), CONCAT("<ul><li>[Ticket Détails Context][Description]Redescente Synchronisation</li></ul>")
		FROM `syn_15` a
		;
		
		/*Alimentation table pour reconsiliation*/
		INSERT INTO `syn_id_toc`
		(`id_toc`)
		SELECT `id_tab_noa` FROM `syn_15`
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