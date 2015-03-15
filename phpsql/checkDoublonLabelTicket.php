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
// phpsql/checkDoublonLabelTicket.php?milis=123450&ctrl=ok

// IN obligatoire
$arrayInput = array(
    "ctrl" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$strSql = "SELECT a.`label`, count(*) as 'nb'
    FROM `".$prefixTable."tab_tickets` a
    GROUP BY a.`label`
    HAVING COUNT(*) > 1
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    // On indique que nous utiliserons les résultats en tant qu'objet
    $req->setFetchMode(PDO::FETCH_OBJ);

    // On transforme les résultats en tableaux d'objet
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
//A TRAVAILLER
if($modeDebug){
    $strSorti .= ($strSql);
}

require("../API/php/footer.php");
?>