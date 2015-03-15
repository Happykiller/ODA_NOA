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
// phpsql/mysql_getTagsStatut.php?milis=123450&id_toc=67420

// IN obligatoire
$arrayInput = array(
    "id_toc" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------

$cruStatut = 0;
$strSql = "SELECT `id_tag` 
    FROM `".$prefixTable."tab_tags_affecte` a
    WHERE 1=1
    AND a.`id_type` = 9/*Statut*/
    AND a.`id_toc` = ".$arrayValeur["id_toc"]."
    AND a.`actif` = 1
;";
$req = $connection->prepare($strSql);

$rows = array();
if($req->execute()){
    $rows = $req->fetch();
    $cruStatut = $rows["id_tag"];
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

$strSql = "SELECT c.`id`, c.`label` 
    FROM (
        SELECT a.`id_statut_destination` as `id`, b.`label` 
        FROM `".$prefixTable."tab_ticket_statut_change` a, `".$prefixTable."tab_tags` b
        WHERE 1=1
        AND a.`id_statut_destination` = b.`id`
        AND a.`id_statut_origin` = '".$cruStatut."'
        UNION
        SELECT b.`id`, b.`label`
        FROM `".$prefixTable."tab_tags_affecte` a, `".$prefixTable."tab_tags` b
        WHERE 1=1
        AND a.`id_tag` = b.`id`
        AND a.`id_type` = 9/*Statut*/
        AND a.`id_toc` = ".$arrayValeur["id_toc"]."
        AND a.`actif` = 1
    ) c
    ORDER BY c.`id` asc
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $resultats = new stdClass();
    $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
    $resultats->nombre = count($resultats->data);
    $object_retour->data["resultat"] = $resultats;
}else{
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur = $error;
}
$req->closeCursor();

//--------------------------------------------------------------------------
if($modeDebug){
    print_r($strSql);
}

//---------------------------------------------------------------------------

//Cloture de l'interface
require("../API/php/footer.php");
?>