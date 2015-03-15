DROP FUNCTION IF EXISTS `reconcil_modif_full`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `reconcil_modif_full`( p_date TEXT ) RETURNS int(11)
    DETERMINISTIC
BEGIN
	/*select reconcil_modif_full("2013-08-26");*/
	DECLARE done INT DEFAULT 0;
	DECLARE a,b INT;
	DECLARE cur1 CURSOR FOR SELECT DISTINCT `id_toc` FROM `tmp_id_toc`;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
	
	/*les tickets qui n'ont pas des descriptions*/
	DROP TEMPORARY TABLE IF EXISTS tmp_id_toc;
	CREATE TEMPORARY TABLE tmp_id_toc
	AS
	SELECT `id` as 'id_toc' FROM `tab_tickets` 
	WHERE 1=1
	AND `dateTime_creation`  >  STR_TO_DATE(p_date,'%Y-%m-%d')
	;

	/*------------------------------------------------------------*/
	/*Lance reconsiliation de la date de mise à jour core*/
	OPEN cur1;

	REPEAT
	FETCH cur1 INTO a;
	IF NOT done THEN
		INSERT tmp (`msg`) VALUES (a);
		SELECT reconcil_modif(a)
		INTO b;
	END IF;
	UNTIL done END REPEAT;

	CLOSE cur1;
		
	RETURN 1; 
END$$