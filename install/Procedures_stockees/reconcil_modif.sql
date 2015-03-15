DROP FUNCTION IF EXISTS `reconcil_modif`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `reconcil_modif`( p_id TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN
	/*select reconcil_modif("14");*/
	SET @row_number = 0;
	SET @new_dateTime_modification = '2013-01-17 00:00:00';
	SET @new_auteur = "";
	
	DROP TEMPORARY TABLE IF EXISTS tmp_0;
	CREATE TEMPORARY TABLE tmp_0
	AS
	SELECT @curRow := @curRow + 1 AS row_number, date_max, auteur_modif
	FROM (
		SELECT GREATEST(a.`dateTime_creation`, a.`dateTime_modification`) as 'date_max', if(a.`dateTime_creation`=GREATEST(a.`dateTime_creation`, a.`dateTime_modification`),a.`auteur_creation`,a.`auteur_modification`) as 'auteur_modif'
		FROM `tab_tags_affecte` a
		WHERE 1=1 
		AND a.`id_toc` = p_id
		UNION
		SELECT GREATEST(b.`dateTime_creation`, b.`dateTime_modification`) as 'date_max', if(b.`dateTime_creation`=GREATEST(b.`dateTime_creation`, b.`dateTime_modification`),b.`auteur_creation`,b.`auteur_modification`) as 'auteur_modif'
		FROM `tab_relations` b
		WHERE 1=1 
		AND (b.`obj_origine` = p_id OR b.`obj_dest` = p_id)
		UNION
		SELECT GREATEST(c.`dateTime_creation`, c.`dateTime_modification`) as 'date_max', if(c.`dateTime_creation`=GREATEST(c.`dateTime_creation`, c.`dateTime_modification`),c.`auteur_creation`,c.`auteur_modification`) as 'auteur_modif'
		FROM `tab_pjs` c
		WHERE 1=1 
		AND c.`id_toc` = p_id
		UNION
		SELECT GREATEST(d.`dateTime_creation`, d.`dateTime_modification`) as 'date_max', if(d.`dateTime_creation`=GREATEST(d.`dateTime_creation`, d.`dateTime_modification`),d.`auteur_creation`,d.`auteur_modification`) as 'auteur_modif'
		FROM `tab_notes` d
		WHERE 1=1 
		AND d.`id_toc` = p_id
	) z
	JOIN (SELECT @curRow := 0) r
	ORDER BY date_max
	;
	
	SELECT MAX(a.`row_number`)
	INTO @row_number
	FROM `tmp_0` a
	WHERE 1=1
	;
	
	SELECT a.`auteur_modif`, a.`date_max`
	INTO @new_auteur, @new_dateTime_modification
	FROM `tmp_0` a
	WHERE 1=1
	AND a.`row_number` = @row_number
	;
	
	UPDATE `tab_tickets` a
	SET a.`dateTime_modification` = @new_dateTime_modification
	, a.`auteur_modification` = @new_auteur
	WHERE 1=1
	AND a.`dateTime_modification` != @new_dateTime_modification
	AND a.`id` = p_id
	;

	RETURN 1; 
END$$