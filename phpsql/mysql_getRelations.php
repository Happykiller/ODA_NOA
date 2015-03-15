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
// phpsql/mysql_getRelations.php?milis=123450&ctrl=ok&id_toc=67420

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

$strSql = "SELECT a.`id`, a.`obj_origine`,a.`obj_dest`,a.`id_type_relation`, b.`label` as 'label_ori', c.`label` as 'label_dest'
    FROM `".$prefixTable."tab_relations` a, `".$prefixTable."tab_tickets` b, `".$prefixTable."tab_tickets` c
    WHERE 1=1
    AND a.obj_origine = b.`id`
    AND a.obj_dest = c.`id`
    AND (
        a.`obj_origine` = ".$arrayValeur["id_toc"]."
        OR
        a.`obj_dest` = ".$arrayValeur["id_toc"]."
    )
    AND a.`actif` = 1
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $resultats = new stdClass();
    $resultats->relations = $req->fetchAll(PDO::FETCH_OBJ);
    $resultats->nombre = count($resultats->relations);
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