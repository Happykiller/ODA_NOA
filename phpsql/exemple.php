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
//Pour le text utiliser $strSorti pour la sortie.
//Pour le json $object_retour sera decoder
//Pour le xml et csv $object_retour->data["resultat"]->data doit contenir qu'un est unique array.
$modeSortie = "json";

//Liens de test
// phpsql/exemple.php?milis=123450&keyAuthODA=42c643cc44c593c5c2b4c5f6d40489dd&ctrl=ok&test=hello

//Définition des entrants
$arrayInput = array(
    "ctrl" => null
);

//Définition des entrants optionel
$arrayInputOpt = array(
    "option" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput,$arrayInputOpt);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string
// $object_retour->id_transaction  string
// $object_retour->metro  string

//--------------------------------------------------------------------------
//EXEMPLE SELECT 1 ROW
$strSql = "Select * from `".$prefixTable."tab_parametres` a
        WHERE 1=1
        AND a.`param_name` = :param_name
;";
$req = $connection->prepare($strSql);
$req->bindValue(":param_name", $arrayValeur["error"], PDO::PARAM_STR);

$rows = array();
$object_retour->data["resultat0"] = $rows;
if($req->execute()){
    $rows = $req->fetch();
    $object_retour->data["resultat0"] = $rows;
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//--------------------------------------------------------------------------
//EXEMPLE SELECT N ROWS
$strSql = "Select * from `".$prefixTable."tab_parametres` a
        WHERE 1=1
;";
$req = $connection->prepare($strSql);

$resultats = new stdClass();
$resultats->data = array();
$resultats->nombre = 0;
$object_retour->data["resultat"] = $resultats;
if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
    $resultats->nombre = count($resultats->data);
    $object_retour->data["resultat"] = $resultats;
}else{
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur = $error;
}
$req->closeCursor();

//--------------------------------------------------------------------------
//EXEMPLE EXEC
$strSql = "CREATE TEMPORARY TABLE coucou (
    `idElem` int(11) NOT NULL,
    `nature` varchar(100),
    PRIMARY KEY(`idElem`)
)
    SELECT a.`id` as 'idElem', a.`param_name` as 'nature' FROM `".$prefixTable."tab_parametres` a
;";
$req = $connection->prepare($strSql);

$resultat = new stdClass();
$resultat->statut = "null"; 
if($req->execute()){
    $resultat->statut = "ok"; 
}else{
    $resultat->statut = "ko"; 
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur = $error;
}
$req->closeCursor();
$object_retour->data["resultat1"] = $resultat;

//--------------------------------------------------------------------------
//EXEMPLE INSERT 1 DATA
$strSql = "INSERT INTO  `coucou` (
        `idElem` ,
        `nature` 
    )
    VALUES (
        99 ,  :nature
    )
;";
$req = $connection->prepare($strSql);
$req->bindValue(":nature", "coucou", PDO::PARAM_STR);

$resultat = new stdClass();
$resultat->id = 0; 
if($req->execute()){
    $resultat->id = $connection->lastInsertId(); 
}else{
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur = $error;
}
$req->closeCursor();
$object_retour->data["resultat2"] = $resultat;

//--------------------------------------------------------------------------
//EXEMPLE UPDATE
$strSql = "UPDATE `coucou`
    SET `idElem` = 100
    WHERE 1=1
    AND `idElem` = 1
;";
$req = $connection->prepare($strSql);

$resultat = new stdClass();
$resultat->statut = "null"; 
if(!($req->execute())){
    $resultat->statut = "ko";
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}else{
    $resultat->statut = "ok"; 
}
$req->closeCursor();
$object_retour->data["resultat3"] = $resultat;

//--------------------------------------------------------------------------
if($modeDebug){
    print_r($strSql);
}

//---------------------------------------------------------------------------

//Cloture de l'interface
require("../API/php/footer.php");