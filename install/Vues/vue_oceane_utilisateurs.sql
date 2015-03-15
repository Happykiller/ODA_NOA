DROP VIEW IF EXISTS `vue_oceane_utilisateurs`;
CREATE VIEW `vue_oceane_utilisateurs` AS
SELECT DISTINCT `Utilisateur demandeur int` as `utilisateur_code`, `Utilisateur demandeur` as `utilisateur_label`
FROM  `tab_oceane_tickets_inter`
WHERE `Utilisateur demandeur int` != ""