/*
* creer_detail_notif
*
* @param {text} p_label : Le label d'un ticket (ex : 1308368044)
* @param {text} p_date_signal : date signalé (ex : Vendredi 18/10/2013 08:45)
* @param {text} p_date_mail : date signalé (ex : Vendredi 18/10/2013 08:47)
* @param {text} p_basicat : le basicat (ex : M19)
* @param {text} p_eds_origine : le eds d'origine (ex : GENERGY)
* @param {text} p_eds_destinataire : le eds destination (ex : JVOH19)
* @param {text} p_criticite : la criticite (ex : Mineur)
* @param {text} p_priorite : la priorite (ex : P1)
* @param {text} p_commentaires : le commentaire (ex : M19)
*
* @return {int} : Si pas d'erreur sortie par defaut (ex : 1)
* @example : select creer_detail_notif('1308368044','','','','','','Mineur','P3','nd 0683378418 compte 61599902');
*/
DROP FUNCTION IF EXISTS `creer_detail_notif`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `creer_detail_notif`( p_label TEXT, p_date_signal TEXT, p_date_mail TEXT, p_basicat TEXT, p_eds_origine TEXT, p_eds_destinataire TEXT, p_criticite TEXT, p_priorite TEXT, p_commentaires TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE nb0,nb1,nb2,nb3,nb4,nb5,nb5v2,nb6,nb7,nb7bis,nb8,nb9,nb10,nb10bis,nb11,nb12,nb13,nb14,nb15,nb16,nb17,nb18,nb19,nb20 INT DEFAULT 0;
	DECLARE v_type_synchro VARCHAR(100);
	DECLARE v_eds VARCHAR(100);
	
	DECLARE debug BOOLEAN DEFAULT FALSE;
	DECLARE trace BOOLEAN DEFAULT TRUE;
	
	DECLARE v_ticketExist INT DEFAULT 0;
	DECLARE v_id_incident INTEGER DEFAULT 0;
	DECLARE v_criticite INTEGER DEFAULT 0;
	DECLARE v_priorite INTEGER DEFAULT 0;
	DECLARE v_nature INTEGER DEFAULT 0;
	DECLARE v_test INTEGER DEFAULT 0;
	
	/*0)Trace input*/
	/* POUR TRACE*/
	IF trace THEN
		INSERT INTO `tab_log`
		(`dateTime`,`commentaires`)
		VALUES 
		(NOW(),concat('[NOTIFICATION]Paramètrage =>  p_label:',p_label,',p_date_signal:',p_date_signal,',p_date_mail:',p_date_mail
			,',p_basicat:',p_basicat,',p_eds_origine:',p_eds_origine,',p_eds_destinataire:',p_eds_destinataire,',p_criticite:',p_criticite,',p_priorite:',p_priorite,',p_commentaires:',p_commentaires)
		)
		;
	END IF;
	
	/*1) Récupération parametrage*/
	SELECT `param_value`
	INTO v_type_synchro
	FROM `tab_parametres`
	WHERE 1=1
	AND `param_name` = 'type_synchro_oceane_noa'
	;
	
	SELECT `param_value`
	INTO v_eds
	FROM `tab_parametres`
	WHERE 1=1
	AND `param_name` = 'eds'
	;
	
	/* POUR debug*/
	IF debug THEN
		INSERT INTO `tab_log`
		(`dateTime`,`commentaires`)
		VALUES 
		(NOW(),concat('[NOTIFICATION]Paramètrage =>  v_type_synchro:',v_type_synchro))
		;
	END IF;
	
	/*2)Vérification l'existance*/
	SELECT COUNT(*) as 'nb'
	INTO v_ticketExist
	FROM `tab_tickets` a
	WHERE 1=1
	AND a.`label` = p_label
	;
	
	/* POUR debug*/
	IF debug THEN
		INSERT INTO `tab_log`
		(`dateTime`,`commentaires`)
		VALUES 
		(NOW(),concat('[NOTIFICATION]Paramètrage =>  v_ticketExist:',v_ticketExist))
		;
	END IF;
	
	/*3)Si n'existe pas, on crée*/
	IF (v_ticketExist = '0') THEN
		INSERT INTO `tab_tickets` 
		(`label`, `dateTime_creation`, `auteur`, `dateTime_modification`, `auteur_modification`)
		VALUES 
		(p_label , STR_TO_DATE(SUBSTRING(p_date_mail,INSTR(p_date_mail,' ')), '%d/%m/%Y %H:%i'), 'notification',  '',  '')
		;
		
		/* POUR debug*/
		IF debug THEN
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[NOTIFICATION]Insertion du ticket :',p_label))
			;
		END IF;
		
		SELECT a.`id`
		INTO v_id_incident
		FROM `tab_tickets` a
		WHERE 1=1
		AND a.`label` = p_label
		;
		
		/* POUR debug*/
		IF debug THEN
			INSERT INTO `tab_log`
			(`dateTime`,`commentaires`)
			VALUES 
			(NOW(),concat('[NOTIFICATION]Ticket v_id_incident :',v_id_incident))
			;
		END IF;
		
		/*criticité(16) map*/
		SELECT 
		CASE WHEN p_criticite = 'Mineur'  THEN 42 
			ELSE 42
		END 
		INTO v_criticite
		;
		
		/*priorité(15) map*/
		SELECT 
		CASE WHEN p_priorite = 'P4'  THEN 38 
			WHEN p_priorite = 'P3'  THEN 37  
			WHEN p_priorite = 'P2'  THEN 36  
			WHEN p_priorite = 'P1'  THEN 35 
			ELSE 38
		END 
		INTO v_priorite
		;
		
		/*nature(28)*/
		SELECT LOCATE(p_eds_origine,v_eds) as 'found'
		INTO v_test
		;
		
		IF (v_test = "0") THEN
			SET v_nature = 29;/*Incident*/
		ELSE
			SET v_nature = 92;/*Emis*/
		END IF;
		
		IF (v_id_incident <> 0) THEN
			/*Tags defauts*/
		   INSERT INTO `tab_tags_affecte` 
			(`id` ,`id_toc` ,`id_type` ,`id_tag` ,`actif` ,`dateTime_creation` ,`auteur_creation` ,`dateTime_modification` ,`auteur_modification`)
			VALUES 
			/*Nature(28) par defaut Incident(29)*/
			(	NULL ,  v_id_incident,  28,  v_nature,  1,  STR_TO_DATE(SUBSTRING(p_date_mail,INSTR(p_date_mail,' ')), '%d/%m/%Y %H:%i'),  'notification',  '',  ''),
			/*Visible(26) par defaut collaborateur(5)*/
			(	NULL ,  v_id_incident,  26,  5,  1,  STR_TO_DATE(SUBSTRING(p_date_mail,INSTR(p_date_mail,' ')), '%d/%m/%Y %H:%i'),  'notification',  '',  ''),
			/*Editable(27) par defaut collaborateur(5)*/
			(	NULL ,  v_id_incident,  27,  5,  1,  STR_TO_DATE(SUBSTRING(p_date_mail,INSTR(p_date_mail,' ')), '%d/%m/%Y %H:%i'),  'notification',  '',  ''),
			/*Statut(9) par defaut Nouveau(1)*/
			(	NULL ,  v_id_incident,  9,  1,  1,  STR_TO_DATE(SUBSTRING(p_date_mail,INSTR(p_date_mail,' ')), '%d/%m/%Y %H:%i'),  'notification',  '',  '');
			
			if(v_priorite <> 0) THEN
			   INSERT INTO  `tab_tags_affecte` 
				(`id` ,`id_toc` ,`id_type` ,`id_tag` ,`actif` ,`dateTime_creation` ,`auteur_creation` ,`dateTime_modification` ,`auteur_modification`)
				VALUES 
				/*priorité(15)*/
				(NULL ,  v_id_incident,  15,  v_priorite,  1,  STR_TO_DATE(SUBSTRING(p_date_mail,INSTR(p_date_mail,' ')), '%d/%m/%Y %H:%i'),  'notification',  '',  '');
			END IF;
			
			if(v_criticite <> 0) THEN
			   INSERT INTO  `tab_tags_affecte` 
				(`id` ,`id_toc` ,`id_type` ,`id_tag` ,`actif` ,`dateTime_creation` ,`auteur_creation` ,`dateTime_modification` ,`auteur_modification`)
				VALUES 
				/*criticite(16)*/
				(NULL ,  v_id_incident,  16,  v_criticite,  1,  STR_TO_DATE(SUBSTRING(p_date_mail,INSTR(p_date_mail,' ')), '%d/%m/%Y %H:%i'),  'notification',  '',  '');
			END IF;
			
			if(v_id_incident <> '') THEN
				INSERT INTO  `tab_notes` 
				(`id` ,`id_toc` ,`note` ,`id_type` ,`actif` ,`dateTime_creation` ,`auteur_creation` ,`dateTime_modification` ,`auteur_modification`)
				VALUES 
				(NULL ,  v_id_incident,  p_commentaires,  70,  1,  STR_TO_DATE(SUBSTRING(p_date_mail,INSTR(p_date_mail,' ')), '%d/%m/%Y %H:%i'),  'notification',  '',  '');
			END IF;
		ELSE
			RETURN 0;
		END IF;
	END IF;
	
	/* POUR TRACE*/
	IF trace THEN
		INSERT INTO `tab_log`
		(`dateTime`,`commentaires`)
		VALUES 
		(NOW(),concat('[NOTIFICATION]Ticket créer avec succés :',v_id_incident))
		;
	END IF;

	RETURN 1; 
END$$