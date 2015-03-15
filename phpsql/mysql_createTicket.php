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
// phpsql/mysql_createTicket.php?milis=123450&label=essai&visible=5&editable=5&code_user=FRO

// IN obligatoire
$arrayInput = array(
    "label" => null,
    "visible" => null,
    "editable" => null,
    "code_user" => null
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

$object_retour->data["id"] = 0;
        
//--------------------------------------------------------------------------
//recherche si existe déjà
$nb = 0;
$strSql = "SELECT count(*) as 'nb'
    FROM `".$prefixTable."tab_tickets` a
    WHERE 1=1
    AND a.`label` = :label
;";
$req = $connection->prepare($strSql);
$req->bindValue(":label", $arrayValeur["label"], PDO::PARAM_STR);

$rows = array();
if($req->execute()){
    $rows = $req->fetch();
    $nb = $rows["nb"];
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

if($nb == "0"){
    $strSql = "INSERT INTO `".$prefixTable."tab_tickets`
        (`label`,`dateTime_creation`,`auteur`)
        VALUES
        ('".$arrayValeur["label"]."', NOW(), '".$arrayValeur["code_user"]."');
    ";
    $req = $connection->prepare($strSql);

    if($req->execute()){
        $object_retour->data["id"] = $connection->lastInsertId(); 
    }else{
        $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
        $object_retour->strErreur = $error;
    }
    $req->closeCursor();
    
    $strSql = "INSERT INTO `".$prefixTable."tab_tags_affecte`
        (`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`)
        VALUES
        (".$object_retour->data["id"].",26,".$arrayValeur["visible"].",1,NOW(),'".$arrayValeur["code_user"]."')
        ,(".$object_retour->data["id"].",27,".$arrayValeur["editable"].",1,NOW(),'".$arrayValeur["code_user"]."');
    ";
    $req = $connection->prepare($strSql);

    $resultat = new stdClass();
    if($req->execute()){
        $resultat->statut = "ok"; 
    }else{
        $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
        $object_retour->strErreur = $error;
    }
    $req->closeCursor();
    $object_retour->data["resultat"] = $resultat;
}else{
    $object_retour->strErreur = "Un ticket existe d&eacute;j&agrave; sous ce Label.";
}

//--------------------------------------------------------------------------
if($modeDebug){
    print_r($strSql);
}

//---------------------------------------------------------------------------

//Cloture de l'interface
require("../API/php/footer.php");
?>