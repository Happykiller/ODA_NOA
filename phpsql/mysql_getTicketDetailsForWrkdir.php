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
// phpsql/mysql_getTicketDetailsForWrkdir.php?milis=123450&ctrl=ok&label=1308645242

// IN obligatoire
$arrayInput = array(
    "ctrl" => null,
    "label" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$strSql = "SELECT a.`id`,a.`label`
    , IF(LENGTH(b.`note`)>50, CONCAT(SUBSTRING(REPLACE(REPLACE(b.`note`, '\r', ' '), '\n', ' ') ,1,50),'...'), SUBSTRING(REPLACE(REPLACE(b.`note`, '\r', ' '), '\n', ' ') ,1,50)) as 'description'
    , b.`note` as 'description_long'
    FROM  `".$prefixTable."tab_tickets` a
        LEFT OUTER JOIN `".$prefixTable."tab_notes` b
        ON a.`id` = b.`id_toc`
        AND b.`id_type` = 70
        AND b.`actif` = 1
    WHERE 1=1
    AND `label` = :label
;";
$req = $connection->prepare($strSql);
$req->bindValue(":label", $arrayValeur["label"], PDO::PARAM_STR);

$rows = array();
if($req->execute()){
    $rows = $req->fetch();
    $object_retour->data = $rows;
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//--------------------------------------------------------------------------
if($modeDebug){
    $strSorti .= ($strSql);
}

require("../API/php/footer.php");
?>