/*Initialise la nature des tickets*/
INSERT INTO `tab_tags_affecte`
(`id`,`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
SELECT null,a.`id`,28, 29, 1, NOW(), 'FRO', null, null
FROM `tab_tickets` a
WHERE 1=1
AND not exists (SELECT 1 FROM `tab_tags_affecte` b WHERE b.`id_toc` = a.`id` and b.`id_type` = 28/*nature*/)

/*Reprend le statut NOA avec statut AUTOMATE pour des tickets créer autaumate et pas mise à jour par oceane*/
/*ADV*/
DROP TABLE IF EXISTS REPRISE_STATUT_AUTOMATE;
CREATE TABLE REPRISE_STATUT_AUTOMATE
AS
SELECT d.`id`, d.`label`, d.`tag_noa`, d.`statut`, d.`dateStatut`, d.`tag_automate`
FROM (
	SELECT a.`id`, a.`label`, b.`id_tag` as 'tag_noa', c.`statut`, STR_TO_DATE(c.`date_statut`, '%d/%m/%Y %H:%i') as 'dateStatut',
	CASE c.`statut`
		WHEN 'RECEPTION' THEN 1 /*Nouveau*/
		WHEN 'PRISE_EN_MAIN' THEN 2/*Pris en main*/
		WHEN 'ANALYSE' THEN 3/*En analyse*/
		WHEN 'SUPPORT/SOUTIEN' THEN 5 /*Fermé*/
		WHEN 'CORRECTION' THEN 5 /*Fermé*/
		WHEN 'ENREGISTREE' THEN 5 /*Fermé*/
		WHEN 'FERMEE' THEN 5 /*Fermé*/
	END
	as 'tag_automate'
	FROM `tab_tickets` a, `tab_tags_affecte` b, `tab_automate_ticket_details` c
	WHERE 1=1
	AND a.`id` = b.`id_toc`
	AND a.`label` = c.`id_toc`
	AND a.`auteur` = 'automate'
	AND a.`auteur_modification` = ''
	AND b.`id_type` = 9
	AND b.`actif` = 1
)d
WHERE 1=1
AND d.`tag_noa` != d.`tag_automate`
;
--23 391

UPDATE `tab_tags_affecte` a
SET a.`actif` = 0,
`auteur_modification` = 'FRO',
dateTime_modification = NOW()
WHERE 1=1
AND a.`id_type` = 9
AND a.`actif` = 1
AND a.`id_toc` in (select b.`id` FROM REPRISE_STATUT_AUTOMATE b)
;

INSERT INTO `tab_tags_affecte`
(`id`,`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
SELECT DISTINCT null,a.`id`,9, a.`tag_automate`, 1, NOW(), 'FRO', null, null
FROM `reprise_statut_automate` a
WHERE 1=1
;

DROP TABLE REPRISE_STATUT_AUTOMATE;

/*DISE*/
DROP TABLE IF EXISTS REPRISE_STATUT_AUTOMATE;
CREATE TABLE REPRISE_STATUT_AUTOMATE
AS
SELECT d.`id`, d.`label`, d.`tag_noa`, d.`statut`, d.`dateStatut`, d.`tag_automate`
FROM (
	SELECT a.`id`, a.`label`, b.`id_tag` as 'tag_noa', c.`statut`, STR_TO_DATE(c.`date_statut`, '%d/%m/%Y %H:%i') as 'dateStatut',
	CASE c.`statut`
		WHEN 'RECEPTION' THEN 1 /*Nouveau*/
		WHEN 'PRISE_EN_MAIN' THEN 2/*Pris en main*/
		WHEN 'ANALYSE' THEN 3/*En analyse*/
		WHEN 'SUPPORT/SOUTIEN' THEN 4 /*En attente*/
		WHEN 'CORRECTION' THEN 5 /*Fermé*/
		WHEN 'ENREGISTREE' THEN 5 /*Fermé*/
		WHEN 'FERMEE' THEN 5 /*Fermé*/
	END
	as 'tag_automate'
	FROM `tab_tickets` a, `tab_tags_affecte` b, `tab_automate_ticket_details` c
	WHERE 1=1
	AND a.`id` = b.`id_toc`
	AND a.`label` = c.`id_toc`
	AND a.`auteur` = 'automate'
	AND a.`auteur_modification` = ''
	AND b.`id_type` = 9
	AND b.`actif` = 1
)d
WHERE 1=1
AND d.`tag_noa` != d.`tag_automate`
;
--23 391

UPDATE `tab_tags_affecte` a
SET a.`actif` = 0,
`auteur_modification` = 'FRO',
dateTime_modification = NOW()
WHERE 1=1
AND a.`id_type` = 9
AND a.`actif` = 1
AND a.`id_toc` in (select b.`id` FROM REPRISE_STATUT_AUTOMATE b)
;

INSERT INTO `tab_tags_affecte`
(`id`,`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`,`dateTime_modification`,`auteur_modification`)
SELECT DISTINCT null,a.`id`,9, a.`tag_automate`, 1, NOW(), 'FRO', null, null
FROM `reprise_statut_automate` a
WHERE 1=1
;

DROP TABLE REPRISE_STATUT_AUTOMATE;

/*Retrofit*/
SELECT a.id, a.label, b.id_tag
FROM `tab_tickets` a
LEFT OUTER JOIN `tab_tags_affecte` b
ON a.id = b.id_toc
AND b.id_type = 28 /*Nature*/ 
WHERE 1=1
AND b.id_tag is null

--------------------------------------------------------------------
--RECHERCHE DOUBLON TICKET
SELECT a.`label`, count(*)
FROM `tab_tickets` a
GROUP BY a.`label`
HAVING COUNT(*) > 1
;

--RECHERCHE DOUBLON TAG
DROP TABLE IF EXISTS tmp_tag_double;
CREATE TABLE tmp_tag_double 
AS
SELECT a.`id_toc`,a.`id_type`, MAX(a.`dateTime_creation`) as 'max_date_create', count(*) as 'nb'
FROM `tab_tags_affecte` a
WHERE 1=1
AND a.`actif` = 1
GROUP BY a.`id_toc`,a.`id_type`
HAVING COUNT(*) > 1
;

SELECT *
FROM `tab_tags_affecte` a
WHERE 1=1
AND a.`actif` = 1
AND a.`id_toc` in (
	SELECT DISTINCT c.`id_toc`
	FROM `tmp_tag_double` c
	WHERE 1=1
)
AND EXISTS( SELECT 1
	FROM `tmp_tag_double` b
	WHERE 1=1
	AND b.`id_toc` = a.`id_toc`
	AND b.`id_type` = a.`id_type`
	AND b.`max_date_create` = a.`dateTime_creation`
)
ORDER BY a.`id_toc`,a.`id_type`
;

DELETE a FROM `tab_tags_affecte` as a
WHERE 1=1
AND a.`actif` = 1
AND a.`id_toc` in (
	SELECT DISTINCT c.`id_toc`
	FROM `tmp_tag_double` c
	WHERE 1=1
)
AND EXISTS( SELECT 1
	FROM `tmp_tag_double` b
	WHERE 1=1
	AND b.`id_toc` = a.`id_toc`
	AND b.`id_type` = a.`id_type`
	AND b.`max_date_create` = a.`dateTime_creation`
)
;

--RECHERCHE DOUBLON NOTE
DROP TABLE IF EXISTS tmp_tag_double;
CREATE TABLE tmp_tag_double 
AS
SELECT a.`id_toc`,a.`id_type`, MAX(a.`dateTime_creation`) as 'max_date_create', count(*)
FROM `tab_notes` a
WHERE 1=1
AND a.`actif` = 1
GROUP BY a.`id_toc`,a.`id_type`
HAVING COUNT(*) > 1
;

SELECT *
FROM `tab_notes` a
WHERE 1=1
AND a.`actif` = 1
AND a.`id_toc` in (
	SELECT DISTINCT c.`id_toc`
	FROM `tmp_tag_double` c
	WHERE 1=1
)
AND EXISTS( SELECT 1
	FROM `tmp_tag_double` b
	WHERE 1=1
	AND b.`id_toc` = a.`id_toc`
	AND b.`id_type` = a.`id_type`
	AND b.`max_date_create` = a.`dateTime_creation`
)
ORDER BY a.`id_toc`,a.`id_type`
;

DELETE a FROM `tab_notes` as a
WHERE 1=1
AND a.`actif` = 1
AND a.`id_toc` in (
	SELECT DISTINCT c.`id_toc`
	FROM `tmp_tag_double` c
	WHERE 1=1
)
AND EXISTS( SELECT 1
	FROM `tmp_tag_double` b
	WHERE 1=1
	AND b.`id_toc` = a.`id_toc`
	AND b.`id_type` = a.`id_type`
	AND b.`max_date_create` = a.`dateTime_creation`
)
;

--------------------------------------------------------------------
--Ticket sans statut
DROP TABLE IF EXISTS tmp_tag_manquant;
CREATE TABLE tmp_tag_manquant 
AS
SELECT a.`id`,a.`label`
FROM `tab_tickets` a
WHERE 1=1
AND NOT EXISTS (SELECT 1
	FROM `tab_tags_affecte` b
	WHERE 1=1
	AND b.`id_toc` = a.`id`
	AND b.`actif` = 1
	AND b.`id_type` = 9
)
;

SELECT *
FROM `tab_tickets` a
WHERE 1=1
AND a.`id` in (
	SELECT DISTINCT c.`id`
	FROM `tmp_tag_manquant` c
	WHERE 1=1
)
;

DELETE a FROM `tab_tickets` as a
WHERE 1=1
AND a.`id` in (
	SELECT DISTINCT c.`id`
	FROM `tmp_tag_manquant` c
	WHERE 1=1
)
;

DROP TABLE `tmp_tag_manquant`;
