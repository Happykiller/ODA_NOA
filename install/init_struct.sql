DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `rec_automate_ticket_details`
--

CREATE TABLE `rec_automate_ticket_details` (
  `id_toc` varchar(50) NOT NULL,
  `responsable` varchar(50) NOT NULL,
  `resp_depuis` varchar(50) NOT NULL,
  `resp_nom` varchar(50) NOT NULL,
  `resp_prenom` varchar(50) NOT NULL,
  `date_creation` varchar(50) NOT NULL,
  `dernière_action` varchar(50) NOT NULL,
  `statut` varchar(50) NOT NULL,
  `date_statut` varchar(50) NOT NULL,
  `version` varchar(50) NOT NULL,
  `transfert` varchar(50) NOT NULL,
  `date_retablissement` varchar(50) NOT NULL,
  `date_cloture` varchar(50) NOT NULL,
  `eds_origine` varchar(50) NOT NULL,
  `eds_destinataire` varchar(50) NOT NULL,
  `type_initial` varchar(50) NOT NULL,
  `type_synchronisé` varchar(50) NOT NULL,
  `code_ft_carto` varchar(50) NOT NULL,
  `classe_ticket` varchar(50) NOT NULL,
  `priorite` varchar(50) NOT NULL,
  `emis` varchar(50) NOT NULL,
  `libelle` varchar(50) NOT NULL,
  `application` varchar(50) NOT NULL,
  `origine` varchar(50) NOT NULL,
  `pf_détection` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `suivi_rcoor` varchar(50) NOT NULL,
  `libelle_detaille` text NOT NULL,
  `impact` text NOT NULL,
  `description_causes` text NOT NULL,
  `actions` text NOT NULL,
  `alerte` varchar(50) NOT NULL,
  `prioritee_consolidee` varchar(50) NOT NULL,
  `demandeur` varchar(50) NOT NULL,
  `cause` varchar(50) NOT NULL,
  `charges_consommees` varchar(50) NOT NULL,
  `amelioration_qs` varchar(50) NOT NULL,
  `no_fiche_qs` varchar(50) NOT NULL,
  `charges_consommees_dise` varchar(50) NOT NULL,
  `domaine_fonctionnel` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `rec_automate_ticket_docs`
--

CREATE TABLE `rec_automate_ticket_docs` (
  `id_toc` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `titre` varchar(50) NOT NULL,
  `Mot_cle` varchar(50) NOT NULL,
  `Nom_fichier` varchar(50) NOT NULL,
  `pose_par` varchar(50) NOT NULL,
  `chemin_relatif` varchar(50) NOT NULL,
  KEY `id_toc` (`id_toc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `rec_automate_ticket_liens`
--

CREATE TABLE `rec_automate_ticket_liens` (
  `id_toc` varchar(255) NOT NULL,
  `filiation` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `Version` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `rec_automate_ticket_msgs`
--

CREATE TABLE `rec_automate_ticket_msgs` (
  `id_toc` varchar(255) NOT NULL,
  `date` varchar(255) NOT NULL,
  `poste_par` varchar(255) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `rec_automate_ticket_statuts`
--

CREATE TABLE `rec_automate_ticket_statuts` (
  `id_toc` varchar(255) NOT NULL,
  `etat` varchar(255) NOT NULL,
  `resp` varchar(255) NOT NULL,
  `date` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `rec_oceane_tickets_commentaires`
--

CREATE TABLE `rec_oceane_tickets_commentaires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `N° ticket` varchar(255) DEFAULT NULL,
  `Date commentaire (UTC)` varchar(255) DEFAULT NULL,
  `EDS ayant saisi commentaire` varchar(255) DEFAULT NULL,
  `Utilisateur - Code` varchar(255) DEFAULT NULL,
  `Identifiant pièce jointe` varchar(255) DEFAULT NULL,
  `Commentaire` varchar(255) DEFAULT NULL,
  `dateTime_record` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `rec_oceane_tickets_core`
--

CREATE TABLE `rec_oceane_tickets_core` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `N° ticket` varchar(255) DEFAULT NULL,
  `Initiateur - Code entité` VARCHAR( 255 ) DEFAULT NULL,
  `Date création ticket (UTC)` varchar(255) DEFAULT NULL,
  `Date modif. ticket (UTC)` varchar(255) DEFAULT NULL,
  `EDS de modification` varchar(255) DEFAULT NULL,
  `Code état` varchar(255) DEFAULT NULL,
  `Etat` varchar(255) DEFAULT NULL,
  `Dernier acteur` varchar(255) DEFAULT NULL,
  `Criticité` varchar(255) DEFAULT NULL,
  `Criticité - Idt` varchar(255) DEFAULT NULL,
  `Criticité - poids` varchar(255) DEFAULT NULL,
  `Priorité traitement` varchar(255) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Technicien responsable` varchar(255) DEFAULT NULL,
  `Téléphone` varchar(255) DEFAULT NULL,
  `Date acquittement (UTC)` varchar(255) DEFAULT NULL,
  `Date début (UTC)` varchar(255) DEFAULT NULL,
  `Date fin (UTC)` varchar(255) DEFAULT NULL,
  `EDS demandeur` varchar(255) DEFAULT NULL,
  `EDS demandeur - Idt` varchar(255) DEFAULT NULL,
  `EDS intervenant` varchar(255) DEFAULT NULL,
  `EDS intervenant - Idt` varchar(255) DEFAULT NULL,
  `Technicien intervenant` varchar(255) DEFAULT NULL,
  `Utilisateur demandeur` varchar(255) DEFAULT NULL,
  `Utilisateur demandeur int` varchar(255) DEFAULT NULL,
  `Date début ticket (UTC)` varchar(255) DEFAULT NULL,
  `Date clôture ticket (UTC)` varchar(255) DEFAULT NULL,
  `EDS cloture - Idt` varchar(255) DEFAULT NULL,
  `EDS cloture - Nom long` varchar(255) DEFAULT NULL,
  `Date rétabliss. ticket (UTC)` varchar(255) DEFAULT NULL,
  `EDS rétablissement - Idt` varchar(255) DEFAULT NULL,
  `EDS rétablissement - Nom long` varchar(255) DEFAULT NULL,
  `Date réparation (UTC)` varchar(255) DEFAULT NULL,
  `EDS réparation - Nom long` varchar(255) DEFAULT NULL,
  `EDS réparation - Idt` varchar(255) DEFAULT NULL,
  `Référence tiers` varchar(255) DEFAULT NULL,
  `Commentaire complet détail` varchar(255) DEFAULT NULL,
  `Complément interne` varchar(255) DEFAULT NULL,
  `Détail problème` varchar(255) DEFAULT NULL,
  `Libellé imputation` varchar(255) DEFAULT NULL,
  `Date modification état (UTC)` varchar(255) DEFAULT NULL,
  `EDS modification - Idt` varchar(255) DEFAULT NULL,
  `EDS modification - Nom long` varchar(255) DEFAULT NULL,
  `Etat ticket` varchar(255) DEFAULT NULL,
  `Etat ticket - Idt` varchar(255) DEFAULT NULL,
  `Ancienne description ticket` varchar(255) DEFAULT NULL,
  `Date ancienne description ticket` varchar(255) DEFAULT NULL,
  `EDS util. modif description ticket` varchar(255) DEFAULT NULL,
  `ID util. modif description ticket` varchar(255) DEFAULT NULL,
  `Commentaire interne EDS` varchar(255) DEFAULT NULL,
  `dateTime_record` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_automate_ticket_details`
--

CREATE TABLE `tab_automate_ticket_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` varchar(50) NOT NULL,
  `responsable` varchar(50) NOT NULL,
  `resp_depuis` varchar(50) NOT NULL,
  `resp_nom` varchar(50) NOT NULL,
  `resp_prenom` varchar(50) NOT NULL,
  `date_creation` varchar(50) NOT NULL,
  `dernière_action` varchar(50) NOT NULL,
  `statut` varchar(50) NOT NULL,
  `date_statut` varchar(50) NOT NULL,
  `version` varchar(50) NOT NULL,
  `transfert` varchar(50) NOT NULL,
  `date_retablissement` varchar(50) NOT NULL,
  `date_cloture` varchar(50) NOT NULL,
  `eds_origine` varchar(50) NOT NULL,
  `eds_destinataire` varchar(50) NOT NULL,
  `type_initial` varchar(50) NOT NULL,
  `type_synchronisé` varchar(50) NOT NULL,
  `code_ft_carto` varchar(50) NOT NULL,
  `classe_ticket` varchar(50) NOT NULL,
  `priorite` varchar(50) NOT NULL,
  `emis` varchar(50) NOT NULL,
  `libelle` varchar(50) NOT NULL,
  `application` varchar(50) NOT NULL,
  `origine` varchar(50) NOT NULL,
  `pf_détection` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `suivi_rcoor` varchar(50) NOT NULL,
  `libelle_detaille` text NOT NULL,
  `impact` text NOT NULL,
  `description_causes` text NOT NULL,
  `actions` text NOT NULL,
  `alerte` varchar(50) NOT NULL,
  `prioritee_consolidee` varchar(50) NOT NULL,
  `demandeur` varchar(50) NOT NULL,
  `cause` varchar(50) NOT NULL,
  `charges_consommees` varchar(50) NOT NULL,
  `amelioration_qs` varchar(50) NOT NULL,
  `no_fiche_qs` varchar(50) NOT NULL,
  `charges_consommees_dise` varchar(50) NOT NULL,
  `domaine_fonctionnel` varchar(50) NOT NULL,
  `dateTime_record` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_toc` (`id_toc`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_automate_ticket_docs`
--

CREATE TABLE `tab_automate_ticket_docs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `titre` varchar(50) NOT NULL,
  `Mot_cle` varchar(50) NOT NULL,
  `Nom_fichier` varchar(50) NOT NULL,
  `pose_par` varchar(50) NOT NULL,
  `chemin_relatif` varchar(50) NOT NULL,
  `dateTime_record` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_toc` (`id_toc`,`Nom_fichier`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_automate_ticket_liens`
--

CREATE TABLE `tab_automate_ticket_liens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` varchar(255) NOT NULL,
  `filiation` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `Version` varchar(255) NOT NULL,
  `dateTime_record` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_toc` (`id_toc`,`code`,`Version`,`type`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_automate_ticket_msgs`
--

CREATE TABLE `tab_automate_ticket_msgs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` varchar(255) NOT NULL,
  `date` varchar(255) NOT NULL,
  `poste_par` varchar(255) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `dateTime_record` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_toc` (`id_toc`,`date`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_automate_ticket_statuts`
--

CREATE TABLE `tab_automate_ticket_statuts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` varchar(255) NOT NULL,
  `etat` varchar(255) NOT NULL,
  `resp` varchar(255) NOT NULL,
  `date` varchar(255) NOT NULL,
  `dateTime_record` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_toc` (`id_toc`,`etat`,`date`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_filtres_users`
--

CREATE TABLE `tab_filtres_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code_user` varchar(255) NOT NULL,
  `auteurs` varchar(255) NOT NULL DEFAULT ';',
  `dateTime_creation` datetime NOT NULL,
  `dateTime_creation_option` varchar(255) NOT NULL,
  `dateTime_modification` datetime NOT NULL,
  `dateTime_modification_option` varchar(255) NOT NULL,
  `nature` varchar(500) NOT NULL DEFAULT ';',
  `categorie` varchar(500) NOT NULL DEFAULT ';',
  `sous_categorie` varchar(500) NOT NULL DEFAULT ';',
  `priorite` varchar(500) NOT NULL DEFAULT ';',
  `criticite` varchar(500) NOT NULL DEFAULT ';',
  `statut` varchar(500) NOT NULL DEFAULT ';',
  `affectation` varchar(500) NOT NULL DEFAULT ';',
  `causes_tags` varchar(500) NOT NULL DEFAULT ';',
  `impacts_tags` varchar(500) NOT NULL DEFAULT ';',
  `repro_tags` varchar(500) NOT NULL DEFAULT ';',
  `reso_tags` varchar(500) NOT NULL DEFAULT ';',
  `complexite` varchar(500) NOT NULL DEFAULT ';',
  `env_ori` varchar(500) NOT NULL DEFAULT ';',
  `env_dest` varchar(500) NOT NULL DEFAULT ';',
  `respon` varchar(500) NOT NULL DEFAULT ';',
  `label` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `relations` varchar(500) NOT NULL DEFAULT ';',
  `impactNote` varchar(255) NOT NULL,
  `causeNote` varchar(255) NOT NULL,
  `resoNote` varchar(255) NOT NULL,
  `reproNote` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_user` (`code_user`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_notes`
--

CREATE TABLE `tab_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` int(11) NOT NULL,
  `note` text NOT NULL,
  `id_type` int(11) NOT NULL,
  `actif` int(2) NOT NULL,
  `dateTime_creation` datetime NOT NULL,
  `auteur_creation` varchar(255) NOT NULL,
  `dateTime_modification` datetime NOT NULL,
  `auteur_modification` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_toc` (`id_toc`),
  KEY `rechercher` (`id_type`,`actif`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_oceane_tickets_commentaires`
--

CREATE TABLE `tab_oceane_tickets_commentaires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `N° ticket` varchar(255) DEFAULT NULL,
  `Date commentaire (UTC)` varchar(255) DEFAULT NULL,
  `EDS ayant saisi commentaire` varchar(255) DEFAULT NULL,
  `Utilisateur - Code` varchar(255) DEFAULT NULL,
  `Identifiant pièce jointe` varchar(255) DEFAULT NULL,
  `Commentaire` varchar(255) DEFAULT NULL,
  `dateTime_record` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `N° ticket` (`N° ticket`,`Date commentaire (UTC)`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_oceane_tickets_core`
--

CREATE TABLE `tab_oceane_tickets_core` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `N° ticket` varchar(255) DEFAULT NULL,
  `Initiateur - Code entité` VARCHAR( 255 ) DEFAULT NULL,
  `Date création ticket (UTC)` varchar(255) DEFAULT NULL,
  `Date modif. ticket (UTC)` varchar(255) DEFAULT NULL,
  `EDS de modification` varchar(255) DEFAULT NULL,
  `Code état` varchar(255) DEFAULT NULL,
  `Etat` varchar(255) DEFAULT NULL,
  `Dernier acteur` varchar(255) DEFAULT NULL,
  `Criticité` varchar(255) DEFAULT NULL,
  `Criticité - Idt` varchar(255) DEFAULT NULL,
  `Criticité - poids` varchar(255) DEFAULT NULL,
  `Priorité traitement` varchar(255) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Technicien responsable` varchar(255) DEFAULT NULL,
  `Téléphone` varchar(255) NOT NULL,
  `Date acquittement (UTC)` varchar(255) DEFAULT NULL,
  `Date début ticket (UTC)` varchar(255) DEFAULT NULL,
  `Date clôture ticket (UTC)` varchar(255) DEFAULT NULL,
  `EDS cloture - Idt` varchar(255) DEFAULT NULL,
  `EDS cloture - Nom long` varchar(255) DEFAULT NULL,
  `Date rétabliss. ticket (UTC)` varchar(255) DEFAULT NULL,
  `EDS rétablissement - Idt` varchar(255) DEFAULT NULL,
  `EDS rétablissement - Nom long` varchar(255) DEFAULT NULL,
  `Date réparation (UTC)` varchar(255) DEFAULT NULL,
  `EDS réparation - Nom long` varchar(255) DEFAULT NULL,
  `EDS réparation - Idt` varchar(255) DEFAULT NULL,
  `Référence tiers` varchar(255) NOT NULL,
  `Commentaire complet détail` varchar(255) DEFAULT NULL,
  `Complément interne` varchar(255) DEFAULT NULL,
  `Détail problème` varchar(255) DEFAULT NULL,
  `Libellé imputation` varchar(255) DEFAULT NULL,
  `dateTime_record` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `N° ticket` (`N° ticket`,`Date modif. ticket (UTC)`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_oceane_tickets_etats`
--

CREATE TABLE `tab_oceane_tickets_etats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `N° ticket` varchar(255) DEFAULT NULL,
  `Date modification état (UTC)` varchar(255) DEFAULT NULL,
  `EDS modification - Idt` varchar(255) DEFAULT NULL,
  `EDS modification - Nom long` varchar(255) DEFAULT NULL,
  `Etat ticket` varchar(255) DEFAULT NULL,
  `Etat ticket - Idt` varchar(255) DEFAULT NULL,
  `dateTime_record` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `N° ticket` (`N° ticket`,`Date modification état (UTC)`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_oceane_tickets_histo_descrip`
--

CREATE TABLE `tab_oceane_tickets_histo_descrip` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `N° ticket` varchar(255) DEFAULT NULL,
  `Ancienne description ticket` varchar(255) DEFAULT NULL,
  `Date ancienne description ticket` varchar(255) DEFAULT NULL,
  `EDS util. modif description ticket` varchar(255) DEFAULT NULL,
  `ID util. modif description ticket` varchar(255) DEFAULT NULL,
  `dateTime_record` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `N° ticket` (`N° ticket`,`Date ancienne description ticket`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_oceane_tickets_inter`
--

CREATE TABLE `tab_oceane_tickets_inter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `N° ticket` varchar(255) DEFAULT NULL,
  `Date acquittement (UTC)` varchar(255) DEFAULT NULL,
  `Date début (UTC)` varchar(255) DEFAULT NULL,
  `Date fin (UTC)` varchar(255) DEFAULT NULL,
  `EDS demandeur` varchar(255) DEFAULT NULL,
  `EDS demandeur - Idt` varchar(255) DEFAULT NULL,
  `EDS intervenant` varchar(255) DEFAULT NULL,
  `EDS intervenant - Idt` varchar(255) DEFAULT NULL,
  `Technicien intervenant` varchar(255) DEFAULT NULL,
  `Utilisateur demandeur` varchar(255) DEFAULT NULL,
  `Utilisateur demandeur int` varchar(255) DEFAULT NULL,
  `dateTime_record` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `N° ticket` (`N° ticket`,`Date début (UTC)`,`EDS demandeur - Idt`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_pjs`
--

CREATE TABLE `tab_pjs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` int(11) NOT NULL,
  `id_type` int(11) NOT NULL,
  `label` varchar(255) NOT NULL,
  `actif` int(2) NOT NULL,
  `dateTime_creation` datetime NOT NULL,
  `auteur_creation` varchar(255) NOT NULL,
  `dateTime_modification` datetime NOT NULL,
  `auteur_modification` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_toc` (`id_toc`,`id_type`,`label`,`actif`,`dateTime_creation`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_relations`
--

CREATE TABLE `tab_relations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `obj_origine` int(11) NOT NULL,
  `obj_dest` int(11) NOT NULL,
  `id_type_relation` int(11) NOT NULL,
  `actif` int(2) NOT NULL,
  `dateTime_creation` datetime NOT NULL,
  `auteur_creation` varchar(255) NOT NULL,
  `dateTime_modification` datetime NOT NULL,
  `auteur_modification` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `obj_origine` (`obj_origine`,`obj_dest`,`id_type_relation`,`actif`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_tags`
--

CREATE TABLE `tab_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `ordre` int(10) NOT NULL,
  `actif` int(2) NOT NULL,
  `id_type_tag` int(11) NOT NULL,
  `dateTime_creation` datetime NOT NULL,
  `auteur` varchar(255) NOT NULL,
  `dateTime_modification` datetime NOT NULL,
  `auteur_modification` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `label` (`label`,`actif`,`id_type_tag`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_tags_affecte`
--

CREATE TABLE `tab_tags_affecte` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` int(11) NOT NULL,
  `id_type` int(11) NOT NULL,
  `id_tag` int(11) NOT NULL,
  `actif` varchar(2) NOT NULL,
  `dateTime_creation` datetime NOT NULL,
  `auteur_creation` varchar(255) NOT NULL,
  `dateTime_modification` datetime NOT NULL,
  `auteur_modification` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_tag` (`id_tag`),
  KEY `id_toc` (`id_toc`),
  KEY `rechercher` (`id_type`,`actif`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_tickets`
--

CREATE TABLE `tab_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) NOT NULL,
  `dateTime_creation` datetime NOT NULL,
  `auteur` varchar(255) NOT NULL,
  `dateTime_modification` datetime NOT NULL,
  `auteur_modification` varchar(255) NOT NULL,
  `lock` int(2) NOT NULL,
  `lock_time` datetime NOT NULL,
  `lock_auteur` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nom` (`label`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_ticket_histo_change`
--

CREATE TABLE `tab_ticket_histo_change` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_toc` int(11) NOT NULL,
  `auteur` varchar(255) NOT NULL,
  `dateTime_change` datetime NOT NULL,
  `changement` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `tab_ticket_statut_change`
--

CREATE TABLE `tab_ticket_statut_change` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_statut_origin` int(11) NOT NULL,
  `id_statut_destination` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_statut_origin` (`id_statut_origin`,`id_statut_destination`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la vue `vue_oceane_criticite`
--
DROP TABLE IF EXISTS `vue_oceane_criticite`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vue_oceane_criticite` AS select distinct `tab_oceane_tickets_core`.`Criticité - Idt` AS `criticite_code`,`tab_oceane_tickets_core`.`Criticité - poids` AS `criticite_poid`,`tab_oceane_tickets_core`.`Criticité` AS `criticite_label` from `tab_oceane_tickets_core` where (`tab_oceane_tickets_core`.`Criticité - Idt` <> '');

-- --------------------------------------------------------

--
-- Structure de la vue `vue_oceane_eds`
--
DROP TABLE IF EXISTS `vue_oceane_eds`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vue_oceane_eds` AS select distinct `rec_oceane_tickets_core`.`EDS demandeur - Idt` AS `eds_code`,`rec_oceane_tickets_core`.`EDS demandeur` AS `eds_label` from `rec_oceane_tickets_core` where (`rec_oceane_tickets_core`.`EDS demandeur - Idt` <> '') union select distinct `tab_oceane_tickets_core`.`EDS cloture - Idt` AS `eds_code`,`tab_oceane_tickets_core`.`EDS cloture - Nom long` AS `eds_label` from `tab_oceane_tickets_core` where (`tab_oceane_tickets_core`.`EDS cloture - Idt` <> '') union select distinct `tab_oceane_tickets_core`.`EDS rétablissement - Idt` AS `eds_code`,`tab_oceane_tickets_core`.`EDS rétablissement - Nom long` AS `eds_label` from `tab_oceane_tickets_core` where (`tab_oceane_tickets_core`.`EDS rétablissement - Idt` <> '') union select distinct `tab_oceane_tickets_core`.`EDS réparation - Idt` AS `eds_code`,`tab_oceane_tickets_core`.`EDS réparation - Nom long` AS `eds_label` from `tab_oceane_tickets_core` where (`tab_oceane_tickets_core`.`EDS réparation - Idt` <> '');

-- --------------------------------------------------------

--
-- Structure de la vue `vue_oceane_etats`
--
DROP TABLE IF EXISTS `vue_oceane_etats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vue_oceane_etats` AS select distinct `tab_oceane_tickets_core`.`Code état` AS `etat_code`,`tab_oceane_tickets_core`.`Etat` AS `etat_label` from `tab_oceane_tickets_core` where (`tab_oceane_tickets_core`.`Code état` <> '');

-- --------------------------------------------------------

--
-- Structure de la vue `vue_oceane_utilisateurs`
--
DROP TABLE IF EXISTS `vue_oceane_utilisateurs`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vue_oceane_utilisateurs` AS select distinct `tab_oceane_tickets_inter`.`Utilisateur demandeur int` AS `utilisateur_code`,`tab_oceane_tickets_inter`.`Utilisateur demandeur` AS `utilisateur_label` from `tab_oceane_tickets_inter` where (`tab_oceane_tickets_inter`.`Utilisateur demandeur int` <> '');