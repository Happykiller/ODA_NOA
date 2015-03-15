DROP VIEW IF EXISTS `vue_oceane_tickets_core_last`;
CREATE VIEW `vue_oceane_tickets_core_last` AS
SELECT a.*
FROM `tab_oceane_tickets_core` a, `vue_oceane_tickets_core_last_record` b
WHERE 1=1
AND a.`N° ticket` = b.`N° ticket`
AND a.`dateTime_record` = b.`last_dateTime_record`
ORDER BY a.`dateTime_record` DESC
;