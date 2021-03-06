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
// phpsql/mysql_getNotes.php?milis=123450&ctrl=ok&id_toc=67420&id_type=84&id_note=

// IN obligatoire
$arrayInput = array(
    "id_toc" => null,
    "id_type" => null,
    "id_note" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------

$strFiltrIdNote = "";
if($arrayValeur["id_note"] != ""){
    $strFiltrIdNote = " AND `id` = ".$arrayValeur["id_note"]."";
}

$strSql = "SELECT *
    FROM  `".$prefixTable."tab_notes` a
    WHERE 1=1
    ".$strFiltrIdNote."
    AND a.`id_type` = ".$arrayValeur["id_type"]."
    AND a.`id_toc` = ".$arrayValeur["id_toc"]."
    AND a.`actif` = 1
    ORDER BY a.`dateTime_creation` desc
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