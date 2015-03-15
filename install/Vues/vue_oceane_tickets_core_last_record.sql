DROP VIEW IF EXISTS `vue_oceane_tickets_core_last_record`;
CREATE VIEW `vue_oceane_tickets_core_last_record` AS
SELECT a.`N° ticket`, MAX(a.`dateTime_record`) as 'last_dateTime_record'
FROM `tab_oceane_tickets_core` a
GROUP BY `N° ticket`
;