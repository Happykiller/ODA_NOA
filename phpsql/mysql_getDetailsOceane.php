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
// phpsql/mysql_getDetailsOceane.php?milis=123450&ctrl=ok&id_toc=1404160437

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
// $object_retour->id_transaction  string
// $object_retour->metro  string

//--------------------------------------------------------------------------
$strSql = "SELECT * 
FROM `".$prefixTable."tab_oceane_tickets_core` b, (
    SELECT a.`N° ticket`, MAX(a.`dateTime_record`) as `dateTime_record`
    FROM `".$prefixTable."tab_oceane_tickets_core` a
    WHERE 1=1
    AND a.`N° ticket` = '".$arrayValeur["id_toc"]."'
    GROUP BY a.`N° ticket`
    ) c
WHERE 1=1
AND b.`N° ticket` = c.`N° ticket`
AND b.`dateTime_record` = c.`dateTime_record`
;";
$req = $connection->prepare($strSql);
$rows = array();
if($req->execute()){
    $rows = $req->fetch();
    $object_retour->data["Corps"] = $rows;
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor(); 

//--------------------------------------------------------------------------
//Les commentaires
$strSql = "SELECT * 
FROM `".$prefixTable."tab_oceane_tickets_commentaires` a
WHERE 1=1
AND a.`N° ticket` = '".$rows["N° ticket"]."'
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    // On indique que nous utiliserons les résultats en tant qu'objet
    $req->setFetchMode(PDO::FETCH_OBJ);

    // On transforme les résultats en tableaux d'objet
    $resultats = new stdClass();
    $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
    $resultats->nombre = count($resultats->data);

    $object_retour->data["Commentaires"] = $resultats;
}else{
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur = $error;
}
$req->closeCursor();

//--------------------------------------------------------------------------
//Histo descriptions
$strSql = "SELECT * 
FROM `".$prefixTable."tab_oceane_tickets_histo_descrip` a
WHERE 1=1
AND a.`N° ticket` = '".$rows["N° ticket"]."'
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    // On indique que nous utiliserons les résultats en tant qu'objet
    $req->setFetchMode(PDO::FETCH_OBJ);

    // On transforme les résultats en tableaux d'objet
    $resultats = new stdClass();
    $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
    $resultats->nombre = count($resultats->data);

    $object_retour->data["HistoDescription"] = $resultats;
}else{
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur = $error;
}
$req->closeCursor();

//--------------------------------------------------------------------------
//Interventions
$strSql = "SELECT * 
FROM `".$prefixTable."tab_oceane_tickets_inter` a
WHERE 1=1
AND a.`N° ticket` = '".$rows["N° ticket"]."'
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    // On indique que nous utiliserons les résultats en tant qu'objet
    $req->setFetchMode(PDO::FETCH_OBJ);

    // On transforme les résultats en tableaux d'objet
    $resultats = new stdClass();
    $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
    $resultats->nombre = count($resultats->data);

    $object_retour->data["Interventions"] = $resultats;
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