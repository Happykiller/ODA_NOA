DROP VIEW IF EXISTS `vue_oceane_EDS`;
CREATE VIEW `vue_oceane_EDS` AS 
SELECT DISTINCT `EDS demandeur - Idt` as `eds_code`, `EDS demandeur` as `eds_label`
FROM  `rec_oceane_tickets_core`
WHERE `EDS demandeur - Idt` != ""
UNION 
SELECT DISTINCT `EDS cloture - Idt` as `eds_code`, `EDS cloture - Nom long` as `eds_label`
FROM  `tab_oceane_tickets_core`
WHERE `EDS cloture - Idt` != ""
UNION 
SELECT DISTINCT `EDS rétablissement - Idt` as `eds_code`, `EDS rétablissement - Nom long` as `eds_label`
FROM  `tab_oceane_tickets_core`
WHERE `EDS rétablissement - Idt` != ""
UNION 
SELECT DISTINCT `EDS réparation - Idt` as `eds_code`, `EDS réparation - Nom long` as `eds_label`
FROM  `tab_oceane_tickets_core`
WHERE `EDS réparation - Idt` != ""