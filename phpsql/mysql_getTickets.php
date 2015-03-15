<?php 
//Config : Les informations personnels de l'instance (log, pass, etc)
require("../include/config.php");

//API Fonctions : les fonctions fournis de base par l'API
require("../API/php/fonctions.php");

//Header établie la connection à la base $connection
require("../API/php/header.php");

//Fonctions : Fonctions personnelles de l'instance
require("../php/fonctions.php");

//Mode debug
$modeDebug = false;

//Public ou privé (clé obligatoire)
$modePublic = true;

//Mode de sortie text,json,xml,csv
//pour xml et csv $object_retour->data["resultat"] doit contenir qu'un est unique array
$modeSortie = "json";

//Liens de test
// phpsql/mysql_getTickets.php?milis=123450&core_dateTime_creation=2014-03-05%2000:00:01&core_dateTime_creation_option=AP

// IN obligatoire
$arrayInput = array(
    "core_dateTime_creation" => null,
    "core_dateTime_creation_option" => null
);

//Définition des entrants optionel
$arrayInputOpt = array(
    "core_id" => "",  
    "core_auteur" => "",
    "core_auteur_option" => "notList",
    "core_dateTime_modification" => "",
    "core_dateTime_modification_option" => "",
    "core_nature" => "",
    "core_nature_option" => "notList",
    "core_categorie" => "",
    "core_categorie_option" => "notList",
    "core_sous_categorie" => "",
    "core_sous_categorie_option" => "notList",
    "core_priorite" => "",
    "core_priorite_option" => "notList",
    "core_criticite" => "",
    "core_criticite_option" => "notList",
    "core_statut" => "",
    "core_statut_option" => "notList",
    "core_causes_tags" => "",
    "core_causes_tags_option" => "notList",
    "core_impacts_tags" => "",
    "core_impacts_tags_option" => "notList",
    "core_repro_tags" => "",
    "core_repro_tags_option" => "notList",
    "core_reso_tags" => "",
    "core_reso_tags_option" => "notList",
    "core_complexite" => "",
    "core_complexite_option" => "notList",
    "core_env_ori" => "",
    "core_env_ori_option" => "notList",
    "core_env_dest" => "",
    "core_env_dest_option" => "notList",
    "core_respon" => "",
    "core_respon_option" => "notList",
    "core_label" => "",
    "core_description" => "",
    "core_relations" => "",
    "core_relations_option" => "notList",
    "core_version" => "",
    "core_version_option" => "notList",
    "causeNote" => "",
    "impactNote" => "",
    "reproNote" => "",
    "resoNote" => "",
    "vue_respon" => "",
    "vue_version" => "",
    "vue_categorie" => "",
    "vue_dateStatut" => ""
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput,$arrayInputOpt);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$object_retour->metro["etape00"] = getDateTimeWithMili();

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//FILTRES
//CORPS
//id
$strFiltre_id = "";
if($arrayValeur["core_id"] != ""){
    $strFiltre_id = " AND a.`id` = ".$arrayValeur["core_id"];
}

//label
$strFiltre_label = "";
if($arrayValeur["core_label"] != ""){
    $strFiltre_label = " AND a.`label` like '".$arrayValeur["core_label"]."'";
}

//core_auteur
$strFiltreAuteur = "";
if($arrayValeur["core_auteur"] != ""){
    switch ($arrayValeur["core_auteur_option"]) {
        case "list":
            $strFiltreNature = " AND a.`auteur` in (".$arrayValeur["core_auteur"].")";        
            break;
        case "notList":
        default:
            $strFiltreNature = " AND a.`auteur` = ".$arrayValeur["core_auteur"]."";
            break;
    }
} 

//DateCreation 2013-01-01 00:00:01
$strFiltreDateCreation = "";
if($arrayValeur["core_dateTime_creation"] != ""){
    switch ($arrayValeur["core_dateTime_creation_option"]) {
        case "AV":
            $strFiltreDateCreation = " AND a.`dateTime_creation` < STR_TO_DATE('".$arrayValeur["core_dateTime_creation"]."', '%Y-%m-%d %H:%i:%s') ";       
            break;
        case "EG":
            $strFiltreDateCreation = " AND a.`dateTime_creation` = STR_TO_DATE('".$arrayValeur["core_dateTime_creation"]."', '%Y-%m-%d %H:%i:%s') ";       
            break;
        case "AP":
        default:
            $strFiltreDateCreation = " AND a.`dateTime_creation`  >  STR_TO_DATE('".$arrayValeur["core_dateTime_creation"]."', '%Y-%m-%d %H:%i:%s') ";
            break;
    }
}

//DateModification
$strFiltreDateModification = "";
if($arrayValeur["core_dateTime_modification"] != ""){
    switch ($arrayValeur["core_dateTime_modification_option"]) {
        case "AV":
            $strFiltreDateModification = " AND a.`dateTime_modification` <  STR_TO_DATE('".$arrayValeur["core_dateTime_modification"]."', '%Y-%m-%d %H:%i:%s') ";       
            break;
        case "EG":
            $strFiltreDateModification = " AND a.`dateTime_modification`  =  STR_TO_DATE('".$arrayValeur["core_dateTime_modification"]."', '%Y-%m-%d %H:%i:%s') ";       
            break;
        case "AP":
        default:
            $strFiltreDateModification = " AND a.`dateTime_modification`  >  STR_TO_DATE('".$arrayValeur["core_dateTime_modification"]."', '%Y-%m-%d %H:%i:%s') ";
            break;
    }
}


$strSql = "CREATE TEMPORARY TABLE temp_getTicket_corps (
`idElem` int(11) NOT NULL,
INDEX (`idElem`)
) 
SELECT a.`id` as 'idElem'
FROM  `".$prefixTable."tab_tickets` a
WHERE 1=1  
".$strFiltre_id."
".$strFiltre_label."
".$strFiltreDateCreation."
".$strFiltreAuteur."
".$strFiltreDateCreation."
".$strFiltreDateModification."
;";
$req = $connection->prepare($strSql);
if(!($req->execute())){
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();
$object_retour->metro["etape10"] = getDateTimeWithMili();

//--------------------------------------------------------------------------
//nature - 28
$strFiltreNature = "";
$strJointureFiltreNature = "";
if($arrayValeur["core_nature"] != ""){
    switch ($arrayValeur["core_nature_option"]) {
        case "list":
            $strFiltreNature = " AND a.`id_tag` in (".$arrayValeur["core_nature"].")";        
            break;
        case "notList":
        default:
            $strFiltreNature = " AND a.`id_tag` = ".$arrayValeur["core_nature"]."";
            break;
    }
}

if($strFiltreNature != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_nature (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 28
    ".$strFiltreNature."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreNature = " INNER JOIN `temp_getTicket_nature` USING (`idElem`)
    ";
    $object_retour->metro["etape10_1"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//statut - 9
$strFiltreStatut = "";
$strJointureFiltreStatut = "";
if($arrayValeur["core_statut"] != ""){
    switch ($arrayValeur["core_statut_option"]) {
        case "list":
            $strFiltreStatut = " AND a.`id_tag` in (".$arrayValeur["core_statut"].")";        
            break;
        case "notList":
        default:
            $strFiltreStatut = " AND a.`id_tag` = ".$arrayValeur["core_statut"]."";
            break;
    }
}

if($strFiltreStatut != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_statut (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 9
    ".$strFiltreStatut."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreStatut = " INNER JOIN `temp_getTicket_statut` USING (`idElem`)
    ";
    $object_retour->metro["etape10_2"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//priorite - 15
$strFiltrePriorite = "";
$strJointureFiltrePriorite = "";
if($arrayValeur["core_priorite"] != ""){
    switch ($arrayValeur["core_priorite_option"]) {
        case "list":
            $strFiltrePriorite = " AND a.`id_tag` in (".$arrayValeur["core_priorite"].")";        
            break;
        case "notList":
        default:
            $strFiltrePriorite = " AND a.`id_tag` = ".$arrayValeur["core_priorite"]."";
            break;
    }
}

if($strFiltrePriorite != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_priorite (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 15
    ".$strFiltrePriorite."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltrePriorite = " INNER JOIN `temp_getTicket_priorite` USING (`idElem`)
    ";
    $object_retour->metro["etape10_3"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//criticite 16
$strFiltreCriticite= "";
$strJointureFiltreCriticite = "";
if($arrayValeur["core_criticite"] != ""){
    switch ($arrayValeur["core_criticite_option"]) {
        case "list":
            $strFiltreCriticite = " AND a.`id_tag` in (".$arrayValeur["core_criticite"].")";        
            break;
        case "notList":
        default:
            $strFiltreCriticite = " AND a.`id_tag` = ".$arrayValeur["core_criticite"]."";
            break;
    }
}

if($strFiltreCriticite != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_criticite (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 16
    ".$strFiltreCriticite."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreCriticite = " INNER JOIN `temp_getTicket_criticite` USING (`idElem`)
    ";
    $object_retour->metro["etape10_4"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//description - 70
$strJointureFiltreDescription = "";
if($arrayValeur["core_description"] != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_description (
            `idElem` int(11) NOT NULL,
            INDEX (`idElem`)
        )
        SELECT a.`id_toc` as 'idElem'
        FROM  `tab_notes` a, `temp_getTicket_corps` b
        WHERE 1=1  
        AND a.`id_toc` = b.`idElem`
        AND a.`actif` = 1
        AND a.`id_type` = 70
        AND a.`note` like '".$arrayValeur["core_description"]."'
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreDescription = " INNER JOIN `temp_getTicket_description` USING (`idElem`)
    ";
    $object_retour->metro["etape10_5"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//categorie - 12
$strFiltreCategorie= "";
$strJointureFiltreCategorie = "";
if($arrayValeur["core_categorie"] != ""){
    switch ($arrayValeur["core_categorie_option"]) {
        case "list":
            $strFiltreCategorie = " AND a.`id_tag` in (".$arrayValeur["core_categorie"].")";        
            break;
        case "notList":
        default:
            $strFiltreCategorie = " AND a.`id_tag` = ".$arrayValeur["core_categorie"]."";
            break;
    }
}

if($strFiltreCategorie != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_categorie (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 12
    ".$strFiltreCategorie."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreCategorie = " INNER JOIN `temp_getTicket_categorie` USING (`idElem`)
    ";
    $object_retour->metro["etape10_6"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//categorie - 13
$strFiltreSousCategorie= "";
$strJointureFiltreSousCategorie = "";
if($arrayValeur["core_sous_categorie"] != ""){
    switch ($arrayValeur["core_sous_categorie_option"]) {
        case "list":
            $strFiltreSousCategorie = " AND a.`id_tag` in (".$arrayValeur["core_sous_categorie"].")";        
            break;
        case "notList":
        default:
            $strFiltreSousCategorie = " AND a.`id_tag` = ".$arrayValeur["core_sous_categorie"]."";
            break;
    }
}

if($strFiltreSousCategorie != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_sous_categorie (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 13
    ".$strFiltreSousCategorie."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreSousCategorie = " INNER JOIN `temp_getTicket_sous_categorie` USING (`idElem`)
    ";
    $object_retour->metro["etape10_7"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//complexite - 17
$strFiltreComplexite= "";
$strJointureFiltreComplexite = "";
if($arrayValeur["core_complexite"] != ""){
    switch ($arrayValeur["core_complexite_option"]) {
        case "list":
            $strFiltreComplexite = " AND a.`id_tag` in (".$arrayValeur["core_complexite"].")";        
            break;
        case "notList":
        default:
            $strFiltreComplexite = " AND a.`id_tag` = ".$arrayValeur["core_complexite"]."";
            break;
    }
}

if($strFiltreComplexite != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_complexite (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 17
    ".$strFiltreComplexite."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreComplexite = " INNER JOIN `temp_getTicket_complexite` USING (`idElem`)
    ";
    $object_retour->metro["etape10_8"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//causes_tags - 20
$strFiltreCausesTags= "";
$strJointureFiltreCausesTags = "";
if($arrayValeur["core_causes_tags"] != ""){
    switch ($arrayValeur["core_causes_tags_option"]) {
        case "list":
            $strFiltreCausesTags = " AND a.`id_tag` in (".$arrayValeur["core_causes_tags"].")";        
            break;
        case "notList":
        default:
            $strFiltreCausesTags = " AND a.`id_tag` = ".$arrayValeur["core_causes_tags"]."";
            break;
    }
}

if($strFiltreCausesTags != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_causes_tags (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 20
    ".$strFiltreCausesTags."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreCausesTags = " INNER JOIN `temp_getTicket_causes_tags` USING (`idElem`)
    ";
    $object_retour->metro["etape10_9"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//impacts_tags - 21
$strFiltreImpactsTags= "";
$strJointureFiltreImpactsTags = "";
if($arrayValeur["core_impacts_tags"] != ""){
    switch ($arrayValeur["core_impacts_tags_option"]) {
        case "list":
            $strFiltreImpactsTags = " AND a.`id_tag` in (".$arrayValeur["core_impacts_tags"].")";        
            break;
        case "notList":
        default:
            $strFiltreImpactsTags = " AND a.`id_tag` = ".$arrayValeur["core_impacts_tags"]."";
            break;
    }
}

if($strFiltreImpactsTags != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_impacts_tags (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 20
    ".$strFiltreImpactsTags."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreImpactsTags = " INNER JOIN `temp_getTicket_impacts_tags` USING (`idElem`)
    ";
    $object_retour->metro["etape10_10"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//repro_tags - 22
$strFiltreReproTags= "";
$strJointureFiltreReproTags = "";
if($arrayValeur["core_repro_tags"] != ""){
    switch ($arrayValeur["core_repro_tags_option"]) {
        case "list":
            $strFiltreReproTags = " AND a.`id_tag` in (".$arrayValeur["core_repro_tags"].")";        
            break;
        case "notList":
        default:
            $strFiltreReproTags = " AND a.`id_tag` = ".$arrayValeur["core_repro_tags"]."";
            break;
    }
}

if($strFiltreReproTags != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_repro_tags (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 20
    ".$strFiltreReproTags."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreReproTags = " INNER JOIN `temp_getTicket_repro_tags` USING (`idElem`)
    ";
    $object_retour->metro["etape10_11"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//reso_tags - 23
$strFiltreResoTags= "";
$strJointureFiltreResoTags = "";
if($arrayValeur["core_reso_tags"] != ""){
    switch ($arrayValeur["core_reso_tags_option"]) {
        case "list":
            $strFiltreResoTags = " AND a.`id_tag` in (".$arrayValeur["core_reso_tags"].")";        
            break;
        case "notList":
        default:
            $strFiltreResoTags = " AND a.`id_tag` = ".$arrayValeur["core_reso_tags"]."";
            break;
    }
}

if($strFiltreResoTags != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_reso_tags (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 20
    ".$strFiltreResoTags."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreResoTags = " INNER JOIN `temp_getTicket_reso_tags` USING (`idElem`)
    ";
    $object_retour->metro["etape10_12"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//env_ori - 19
$strFiltreEnvOri= "";
$strJointureFiltreEnvOri = "";
if($arrayValeur["core_env_ori"] != ""){
    switch ($arrayValeur["core_env_ori_option"]) {
        case "list":
            $strFiltreEnvOri = " AND a.`id_tag` in (".$arrayValeur["core_env_ori"].")";        
            break;
        case "notList":
        default:
            $strFiltreEnvOri = " AND a.`id_tag` = ".$arrayValeur["core_env_ori"]."";
            break;
    }
}

if($strFiltreEnvOri != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_env_ori (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 19
    ".$strFiltreEnvOri."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreEnvOri = " INNER JOIN `temp_getTicket_env_ori` USING (`idElem`)
    ";
    $object_retour->metro["etape10_13"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//env_dest - 50
$strFiltreEnvDest= "";
$strJointureFiltreEnvDest = "";
if($arrayValeur["core_env_dest"] != ""){
    switch ($arrayValeur["core_env_dest_option"]) {
        case "list":
            $strFiltreEnvDest = " AND a.`id_tag` in (".$arrayValeur["core_env_dest"].")";        
            break;
        case "notList":
        default:
            $strFiltreEnvDest = " AND a.`id_tag` = ".$arrayValeur["core_env_dest"]."";
            break;
    }
}

if($strFiltreEnvDest != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_env_dest (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 50
    ".$strFiltreEnvDest."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreEnvDest = " INNER JOIN `temp_getTicket_env_dest` USING (`idElem`)
    ";
    $object_retour->metro["etape10_14"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//core_respon - 14
$strFiltreRespon= "";
$strJointureFiltreRespon = "";

if($arrayValeur["core_respon"] == "SANSRESPON"){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_respon (
        `idElem` int(11) NOT NULL,
        INDEX (`idElem`)
    )
    SELECT a.`idElem`
    FROM `temp_getTicket_corps` a
    LEFT OUTER JOIN `tab_tags_affecte` b
    ON b.`id_toc` = a.`idElem`
    AND b.`actif` = 1
    AND b.`id_type` = 14
    WHERE 1=1  
    AND b.`id_toc` is null
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
      die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreRespon = " INNER JOIN `temp_getTicket_respon` USING (`idElem`)
    ";
    $object_retour->metro["etape10_15"] = getDateTimeWithMili();
}elseif($arrayValeur["core_respon"] != ""){
    switch ($arrayValeur["core_respon_option"]) {
        case "list":
            $strFiltreRespon = " AND c.`code_user` in (".$arrayValeur["core_respon"].")";        
            break;
        case "notList":
        default:
            $strFiltreRespon = " AND c.`code_user` = '".$arrayValeur["core_respon"]."'";
            break;
        }
    
        if($strFiltreRespon != ""){
        $strSql = "CREATE TEMPORARY TABLE temp_getTicket_respon (
          `idElem` int(11) NOT NULL,
          INDEX (`idElem`)
        )
        SELECT a.`id_toc` as 'idElem'
        FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b, `".$prefixTable."tab_utilisateurs` c
        WHERE 1=1  
        AND a.`id_toc` = b.`idElem`
        AND a.`id_tag` = c.`id`
        AND a.`actif` = 1
        AND a.`id_type` = 14
        ".$strFiltreRespon."
        ;";
        $req = $connection->prepare($strSql);
        if(!($req->execute())){
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();
        $strJointureFiltreRespon = " INNER JOIN `temp_getTicket_respon` USING (`idElem`)
        ";
        $object_retour->metro["etape10_15"] = getDateTimeWithMili();
    }
}



//--------------------------------------------------------------------------
//Relations
$strFiltreRelation= "";
$strJointureFiltreRelation = "";
if($arrayValeur["core_relations"] != ""){
    switch ($arrayValeur["core_relations_option"]) {
        case "list":
            $strFiltreRelation = " in (".$arrayValeur["core_relations"].")";        
            break;
        case "notList":
        default:
            $strFiltreRelation = " = ".$arrayValeur["core_relations"]."";
            break;
    }
}

if($strFiltreRelation != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_relations (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`obj_dest` as 'idElem'
    FROM `".$prefixTable."tab_relations` a
    WHERE 1=1
    AND a.`actif` = 1
    AND a.`id_type_relation` = 82
    AND a.`obj_origine` ".$strFiltreRelation."
    UNION 
    SELECT a.`obj_origine` as 'idElem'
    FROM `".$prefixTable."tab_relations` a
    WHERE 1=1
    AND a.`actif` = 1
    AND a.`id_type_relation` = 82
    AND a.`obj_dest` ".$strFiltreRelation."    
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreRelation = " INNER JOIN `temp_getTicket_relations` USING (`idElem`)
    ";
    $object_retour->metro["etape10_16"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//Version - 91
$strFiltreVersion= "";
$strJointureFiltreVersion = "";
if($arrayValeur["core_version"] != ""){
    switch ($arrayValeur["core_version_option"]) {
        case "list":
            $strFiltreVersion = " AND a.`id_tag` in (".$arrayValeur["core_version"].")";        
            break;
        case "sup":
            $strFiltreVersion = " AND a.`id_tag` > ".$arrayValeur["core_version"]."";        
            break;
        case "inf":
            $strFiltreVersion = " AND a.`id_tag` < (".$arrayValeur["core_version"].")";        
            break;
        case "notList":
        default:
            $strFiltreVersion = " AND a.`id_tag` = ".$arrayValeur["core_version"]."";
            break;
    }
}

if($strFiltreVersion != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_env_dest (
      `idElem` int(11) NOT NULL,
      INDEX (`idElem`)
    )
    SELECT a.`id_toc` as 'idElem'
    FROM  `tab_tags_affecte` a, `temp_getTicket_corps` b
    WHERE 1=1  
    AND a.`id_toc` = b.`idElem`
    AND a.`actif` = 1
    AND a.`id_type` = 91
    ".$strFiltreVersion."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreVersion = " INNER JOIN `temp_getTicket_env_dest` USING (`idElem`)
    ";
    $object_retour->metro["etape10_17"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//causeNote - 78
$strJointureFiltreCauseNote = "";
if($arrayValeur["causeNote"] != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_causeNote (
            `idElem` int(11) NOT NULL,
            INDEX (`idElem`)
        )
        SELECT a.`id_toc` as 'idElem'
        FROM  `tab_notes` a, `temp_getTicket_corps` b
        WHERE 1=1  
        AND a.`id_toc` = b.`idElem`
        AND a.`actif` = 1
        AND a.`id_type` = 78
        AND a.`note` like '".$arrayValeur["causeNote"]."'
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreCauseNote = " INNER JOIN `temp_getTicket_causeNote` USING (`idElem`)
    ";
    $object_retour->metro["etape10_18"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//impactNote - 79 
$strJointureFiltreImpactNote = "";
if($arrayValeur["impactNote"] != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_impactNote (
            `idElem` int(11) NOT NULL,
            INDEX (`idElem`)
        )
        SELECT a.`id_toc` as 'idElem'
        FROM  `tab_notes` a, `temp_getTicket_corps` b
        WHERE 1=1  
        AND a.`id_toc` = b.`idElem`
        AND a.`actif` = 1
        AND a.`id_type` = 79
        AND a.`note` like '".$arrayValeur["impactNote"]."'
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreImpactNote = " INNER JOIN `temp_getTicket_impactNote` USING (`idElem`)
    ";
    $object_retour->metro["etape10_19"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//reproNote - 80
$strJointureFiltreReproNote = "";
if($arrayValeur["reproNote"] != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_reproNote (
            `idElem` int(11) NOT NULL,
            INDEX (`idElem`)
        )
        SELECT a.`id_toc` as 'idElem'
        FROM  `tab_notes` a, `temp_getTicket_corps` b
        WHERE 1=1  
        AND a.`id_toc` = b.`idElem`
        AND a.`actif` = 1
        AND a.`id_type` = 80
        AND a.`note` like '".$arrayValeur["reproNote"]."'
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreReproNote = " INNER JOIN `temp_getTicket_reproNote` USING (`idElem`)
    ";
    $object_retour->metro["etape10_20"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//resoNote - 81
$strJointureFiltreResoNote = "";
if($arrayValeur["resoNote"] != ""){
    $strSql = "CREATE TEMPORARY TABLE temp_getTicket_resoNote (
            `idElem` int(11) NOT NULL,
            INDEX (`idElem`)
        )
        SELECT a.`id_toc` as 'idElem'
        FROM  `tab_notes` a, `temp_getTicket_corps` b
        WHERE 1=1  
        AND a.`id_toc` = b.`idElem`
        AND a.`actif` = 1
        AND a.`id_type` = 81
        AND a.`note` like '".$arrayValeur["resoNote"]."'
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    $strJointureFiltreResoNote = " INNER JOIN `temp_getTicket_resoNote` USING (`idElem`)
    ";
    $object_retour->metro["etape10_21"] = getDateTimeWithMili();
}

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//Liste des éléments finaux
$strSql = "CREATE TEMPORARY TABLE temp_getTicket_elems (
`idElem` int(11) NOT NULL,
INDEX (`idElem`)
) 
SELECT a.`idElem`
FROM `temp_getTicket_corps` a
".$strJointureFiltreNature."
".$strJointureFiltreStatut."
".$strJointureFiltrePriorite."
".$strJointureFiltreCriticite."
".$strJointureFiltreDescription."
".$strJointureFiltreCategorie."
".$strJointureFiltreSousCategorie."
".$strJointureFiltreComplexite."
".$strJointureFiltreCausesTags."
".$strJointureFiltreImpactsTags."
".$strJointureFiltreReproTags."
".$strJointureFiltreResoTags."
".$strJointureFiltreEnvOri."
".$strJointureFiltreEnvDest."
".$strJointureFiltreRespon."
".$strJointureFiltreRelation."
".$strJointureFiltreVersion."
".$strJointureFiltreCauseNote."
".$strJointureFiltreImpactNote."
".$strJointureFiltreReproNote."
".$strJointureFiltreResoNote."
WHERE 1=1  
;";
$req = $connection->prepare($strSql);
if(!($req->execute())){
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();
$object_retour->metro["etape20"] = getDateTimeWithMili();

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//LES DATAS OPTIONELS
$strJointure_vue_respon = "";
$strSelect_vue_respon = "";
if($arrayValeur["vue_respon"] != ""){
    $strSelect_vue_respon = ", respon.`respon` as 'respon'
    ";

    $strJointure_vue_respon = "LEFT OUTER JOIN (
            SELECT  a.`id_toc`, respon.`code_user` as 'respon'
            FROM `tab_tags_affecte` a, `tab_utilisateurs` respon
            WHERE 1=1
            AND a.`id_tag` = respon.`id`
            AND a.`actif` = 1
            AND a.`id_type` = 14
        ) respon
        ON liste.`idElem` = respon.`id_toc`
    ";
}

$strJointure_vue_version = "";
$strSelect_vue_version = "";
if($arrayValeur["vue_version"] != ""){
    $strSelect_vue_version = ",version.`id_tag` as 'version'
    ";

    $strJointure_vue_version = "LEFT OUTER JOIN `tab_tags_affecte` version
        ON liste.`idElem` = version.`id_toc`
        AND version.`actif` = 1
        AND version.`id_type` = 91
    ";
}

$strJointure_vue_categorie = "";
$strSelect_vue_categorie = "";
if($arrayValeur["vue_categorie"] != ""){
    $strSelect_vue_categorie = ",categorie.`id_tag` as 'categorie'
    ";

    $strJointure_vue_categorie = "LEFT OUTER JOIN `tab_tags_affecte` categorie
        ON liste.`idElem` = categorie.`id_toc`
        AND categorie.`actif` = 1
        AND categorie.`id_type` = 12
    ";
}

$strSelect_vue_dateStatut = "";
if($arrayValeur["vue_dateStatut"] != ""){
    $strSelect_vue_dateStatut = ",statut.`dateTime_creation` as 'date_statut'
    ";
}

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//DATAS
//Liste des éléments finaux
$strSql = "Select liste.`idElem`
    ,corps.`label`
    ,corps.`dateTime_creation`
    ,corps.`dateTime_modification`
    ,nature.`id_tag` as 'nature'
    ,statut.`id_tag` as 'statut'
    ,priorite.`id_tag` as 'priorite'
    ,criticite.`id_tag` as 'criticite'
    ,IF(LENGTH(description.`note`)>200, CONCAT(SUBSTRING(REPLACE(REPLACE(description.`note`, '\r', ' '), '\n', ' ') ,1,200),'...'), SUBSTRING(REPLACE(REPLACE(description.`note`, '\r', ' '), '\n', ' ') ,1,200)) as 'description'
    ".$strSelect_vue_respon."
    ".$strSelect_vue_version."
    ".$strSelect_vue_categorie."
    ".$strSelect_vue_dateStatut."
    FROM `temp_getTicket_elems` liste
    LEFT JOIN `".$prefixTable."tab_tickets` corps
        ON liste.`idElem` = corps.`id`
    LEFT OUTER JOIN `tab_tags_affecte` nature
        ON liste.`idElem` = nature.`id_toc`
        AND nature.`actif` = 1
        AND nature.`id_type` = 28
    LEFT OUTER JOIN `tab_tags_affecte` statut
        ON liste.`idElem` = statut.`id_toc`
        AND statut.`actif` = 1
        AND statut.`id_type` = 9
    LEFT OUTER JOIN `tab_tags_affecte` priorite
        ON liste.`idElem` = priorite.`id_toc`
        AND priorite.`actif` = 1
        AND priorite.`id_type` = 15
    LEFT OUTER JOIN `tab_tags_affecte` criticite
        ON liste.`idElem` = criticite.`id_toc`
        AND criticite.`actif` = 1
        AND criticite.`id_type` = 16
    LEFT OUTER JOIN `".$prefixTable."tab_notes` description
        ON liste.`idElem` = description.`id_toc`
        AND description.`actif` = 1
        AND description.`id_type` = 70
    ".$strJointure_vue_respon."
    ".$strJointure_vue_version."
    ".$strJointure_vue_categorie."
    WHERE 1=1
;";

//--------------------------------------------------------------------------
if(!$modeDebug){
    // On envois la requète
    $select = $connection->prepare($strSql);

    if($select->execute()){
        // On indique que nous utiliserons les résultats en tant qu'objet
        $select->setFetchMode(PDO::FETCH_OBJ);

        // On transforme les résultats en tableaux d'objet
        $resultats = new stdClass();
        $resultats->data = $select->fetchAll(PDO::FETCH_OBJ);
        $resultats->nombre = count($resultats->data);

        $object_retour->data["resultat"] = $resultats;
    }else{
        $error = 'Erreur SQL:'.print_r($select->errorInfo(), true)." (".$strSql.")";
        $object_retour->strErreur = $error;
    }
    $select->closeCursor();
}
$object_retour->metro["etape99"] = getDateTimeWithMili();

//--------------------------------------------------------------------------
if($modeDebug){
    die($strSql);
}

require("../API/php/footer.php");
?>