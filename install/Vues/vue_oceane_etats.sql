DROP VIEW IF EXISTS `vue_oceane_etats`;
CREATE VIEW `vue_oceane_etats` AS 
SELECT DISTINCT `Code état` as `etat_code`, `Etat` as `etat_label`
FROM  `tab_oceane_tickets_core`
WHERE `Code état` != ""