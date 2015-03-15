DROP FUNCTION IF EXISTS `update_modif`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `update_modif`( p_id_toc TEXT, p_auteur TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN             
	/*select update_modif("10829","FRO");*/
                                                                      
	UPDATE `tab_tickets` a
	SET a.`dateTime_modification` = NOW()
	, auteur_modification = p_auteur
	WHERE 1=1
	AND a.`id` = p_id_toc
	;
			 
	RETURN 1; 
END$$