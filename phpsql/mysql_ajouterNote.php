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
// phpsql/mysql_ajouterNote.php?milis=123450&&id_toc=66036&code_user=fro&id_type=78&note=fermé

// IN obligatoire
$arrayInput = array(
    "id_toc" => null,
    "code_user" => null,
    "id_type" => null,
    "note" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$strUpdateHisto = "";

//--------------------------------------------------------------------------
$strSql = "INSERT INTO `".$prefixTable."tab_notes`
    (`id_toc`,`id_type`,`note`,`actif`,`dateTime_creation`,`auteur_creation`)
    VALUES
    (:id_toc,:id_type,:note,1,NOW(),:code_user)
;";

$req = $connection->prepare($strSql);
$req->bindValue(":id_toc", $arrayValeur["id_toc"], PDO::PARAM_INT);
$req->bindValue(":id_type", $arrayValeur["id_type"], PDO::PARAM_INT);
$req->bindValue(":note", addslashes($arrayValeur["note"]), PDO::PARAM_STR);
$req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);

$resultat = new stdClass();
if($req->execute()){
    $resultat->id = $connection->lastInsertId(); 
    $strUpdateHisto .= "<li>[".$arrayValeur["id_type"]."]=>Nouvelle note</li>"; 
}else{
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur .= $error;
}
$req->closeCursor();
$object_retour->data["resultat"] = $resultat;

//--------------------------------------------------------------------------
$message = "<ul>".$strUpdateHisto."</ul>";
$strSql = "select insert_histo(:id_toc,:code_user,:message);";

$req = $connection->prepare($strSql);
$req->bindValue(":message", $message, PDO::PARAM_STR);
$req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
$req->bindValue(":id_toc", $arrayValeur["id_toc"], PDO::PARAM_INT);

$resultat = new stdClass();
if(!$req->execute()){
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur .= $error;
}
$req->closeCursor();

//--------------------------------------------------------------------------
//A TRAVAILLER
if($modeDebug){
    $strSorti .= ($strSql);
}

//---------------------------------------------------------------------------

//Cloture de l'interface
require("../API/php/footer.php");
?>