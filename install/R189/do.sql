--
-- Contenu de la table `tab_menu`
--
INSERT INTO `tab_menu` (`id`, `Description`, `Description_courte`, `id_categorie`, `Lien`) VALUES
(26, 'Bannette', 'Bannette', 1, 'page_banette.html')
;

-- --------------------------------------------------------
--
-- Contenu de la table `tab_menu_rangs_droit`
--
UPDATE `tab_menu_rangs_droit`
SET `id_menu` = CONCAT(`id_menu`,"26;")
WHERE `id_rang` in (1,10,20,30)
; 