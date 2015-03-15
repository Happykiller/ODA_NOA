INSERT INTO `tab_menu` (`id`, `Description`, `Description_courte`, `id_categorie`, `Lien`) VALUES
(21, 'Ticket', 'Ticket', 2, 'page_ticket.html'),
(22, 'L''inventaire', 'Inventaire', 1, 'page_inventaire.html'),
(23,'Supervision projet','Supervision projet',2,'page_supervision_projet.html'),
(24,'Doc Fonctionnelle','Doc Fonctionnelle',99,'https://code.google.com/p/oda-na/wiki/Fonctionnelle'),
(25,'Saisir une anomalie','Saisir une anomalie',99,'https://code.google.com/p/oda-na/issues/list'),
(26,'Banette','Banette',1,'page_banette.html')
;

--
-- Contenu de la table `tab_parametres`
--

INSERT INTO `tab_parametres` (`param_name`, `param_type`, `param_value`) VALUES
('type_synchro_oceane_noa', 'varchar', 'SN3DISE'),
('eds', 'varchar', "'JVOH19', 'JVOF33', 'JVOG05', 'JVOH20'"),
('mostOld','varchar','2012-01-01')
;


--
-- Contenu de la table `tab_tags`
--

INSERT INTO `tab_tags` (`id`, `label`, `description`, `ordre`, `actif`, `id_type_tag`, `dateTime_creation`, `auteur`, `dateTime_modification`, `auteur_modification`) VALUES
(1, 'Nouveau', 'Nouveau', 0, 1, 9, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(2, 'Pris en main', 'Pris en main', 0, 1, 9, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(3, 'En analyse', 'En analyse', 0, 1, 9, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(4, 'En attente', 'En attente', 0, 1, 9, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(5, 'Fermé', 'Fermé', 0, 1, 9, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(6, 'Rejeté', 'Rejeté', 0, 1, 9, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(7, 'Ré-ouvert', 'Ré-ouvert', 0, 1, 9, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(8, 'Résolu', 'Résolu', 0, 1, 9, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(9, 'Statut', 'Statut', 0, 1, 10, '2013-07-24 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(10, 'Composant', 'Composant', 0, 1, 0, '2013-07-24 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(11, 'Utilisateur', 'Utilisateur', 0, 1, 0, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(12, 'Catégorie', 'Catégorie', 0, 1, 0, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(13, 'Sous-Catégorie', 'Sous-Catégorie', 0, 1, 0, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(14, 'Responsable', 'Responsable', 0, 1, 0, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(15, 'Priorité', 'Priorité', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(16, 'Criticité', 'Criticité', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(17, 'Complexité', 'Complexité', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(18, 'Reproductible', 'Reproductible', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(19, 'Environnement Origine', 'Environnement Origine', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(20, 'causes_tags', 'causes_tags', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(21, 'impacts_tags', 'impacts_tags', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(22, 'repro_tags', 'repro_tags', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(23, 'reso_tags', 'reso_tags', 0, 1, 10, '2013-07-23 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(26, 'Visibilité', 'Visibilité', 0, 1, 10, '2013-07-24 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(27, 'Editable', 'Editable', 0, 1, 10, '2013-07-24 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(28, 'Nature', 'Nature', 0, 1, 10, '2013-07-25 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(29, 'Incident', 'Incident', 0, 1, 28, '2013-07-25 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(30, 'OPS', 'Opération de service', 0, 1, 28, '2013-07-25 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(31, 'Evolution', 'Evolution', 0, 1, 28, '2013-07-25 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(32, 'Anomalie', 'Anomalie', 0, 1, 28, '2013-07-25 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(34, 'TP', 'Temps passé', 0, 1, 10, '2013-07-25 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(35, 'Critique', 'Critique', 0, 1, 15, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(36, 'Haute', 'Haute', 0, 1, 15, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(37, 'Moyenne', 'Moyenne', 0, 1, 15, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(38, 'Base', 'Base', 0, 1, 15, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(39, 'Critique', 'Critique', 0, 1, 16, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(40, 'Haute', 'Haute', 0, 1, 16, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(41, 'Moyenne', 'Moyenne', 0, 1, 16, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(42, 'Base', 'Base', 0, 1, 16, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(43, 'Critique', 'Critique', 0, 1, 17, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(44, 'Haute', 'Haute', 0, 1, 17, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(45, 'Moyenne', 'Moyenne', 0, 1, 17, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(46, 'Base', 'Base', 0, 1, 17, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(48, 'Oui', 'Oui', 1, 1, 18, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(49, 'Non', 'Non', 2, 1, 18, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(50, 'Environnement Destination', 'Environnement Destination', 0, 1, 10, '2013-07-26 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(70, 'Description', 'Description', 0, 1, 10, '2013-07-29 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(78, 'causes_note', 'causes_note', 0, 1, 10, '2013-07-29 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(79, 'impacts_note', 'impacts_note', 0, 0, 10, '0000-00-00 00:00:00', '', '0000-00-00 00:00:00', ''),
(80, 'repro_note', 'repro_note', 0, 0, 10, '2013-07-29 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(81, 'reso_note', 'reso_note', 0, 1, 10, '2013-07-29 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(82, 'Relation', 'Relation', 0, 1, 0, '2013-07-30 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(84, 'Notes', 'Notes', 0, 1, 10, '2013-08-12 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(85, 'causes_pjs', 'causes_pjs', 1, 1, 10, '2013-08-14 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(86, 'impacts_pjs', 'impacts_pjs', 1, 1, 10, '2013-08-14 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(87, 'repro_pjs', 'repro_pjs', 1, 1, 10, '2013-08-14 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(88, 'reso_pjs', 'reso_pjs', 1, 1, 10, '2013-08-14 00:00:00', 'FRO', '0000-00-00 00:00:00', ''),
(91, 'Version', 'Version', 0, 1, 10, '2013-09-13 00:00:00', 'FRO', '0000-00-00 00:00:00', '');


--
-- Réserve un plage de tag pour le système
--
ALTER TABLE `tab_tags` AUTO_INCREMENT = 1000;