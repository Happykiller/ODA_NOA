DROP VIEW IF EXISTS `vue_oceane_criticite`;
CREATE VIEW `vue_oceane_criticite` AS
SELECT DISTINCT `Criticité - Idt` as `criticite_code`, `Criticité - poids` as `criticite_poid`, `Criticité` as `criticite_label`
FROM  `tab_oceane_tickets_core`
WHERE `Criticité - Idt` != ""