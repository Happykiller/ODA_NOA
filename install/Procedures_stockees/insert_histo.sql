DROP FUNCTION IF EXISTS `insert_histo`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `insert_histo`( p_id_toc TEXT, p_auteur TEXT, p_message TEXT) RETURNS int(11)
    DETERMINISTIC
BEGIN             
	/*select insert_histo("10829","FRO","truc");*/
	DECLARE retour_call INT;
                                                                      
	INSERT INTO `tab_ticket_histo_change`
	(`id`,`id_toc`,`auteur`,`dateTime_change`,`changement`)
	VALUES
	(null, p_id_toc, p_auteur, NOW(), p_message)
	;
	
	select update_modif(p_id_toc,p_auteur)
	INTO retour_call
	; 
			 
	RETURN 1; 
END$$