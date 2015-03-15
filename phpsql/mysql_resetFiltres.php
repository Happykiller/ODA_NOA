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
// phpsql/mysql_resetFiltres.php?milis=123450&code_user=FRO

// IN obligatoire
$arrayInput = array(
    "code_user" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$strSql = "DELETE FROM `".$prefixTable."tab_filtres_users`
    WHERE 1=1
    AND code_user = :code_user
;";
$req = $connection->prepare($strSql);
$req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);

$resultat = new stdClass();
if(!($req->execute())){
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}else{
    $resultat->statut = "ok"; 
}
$req->closeCursor();
$object_retour->data["resultatDelete"] = $resultat;

//--------------------------------------------------------------------------
$strSql = "INSERT INTO `".$prefixTable."tab_filtres_users` 
    (`dateTime_creation`,`dateTime_creation_option`,`code_user`)
    SELECT `param_value`, 'AP', :code_user
    FROM `".$prefixTable."tab_parametres` a
    WHERE 1=1
    AND a.`param_name` = 'mostOld'
;";
$req = $connection->prepare($strSql);
$req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);

$resultat = new stdClass();
if(!($req->execute())){
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}else{
    $resultat->statut = "ok"; 
}
$req->closeCursor();
$object_retour->data["resultatInsert"] = $resultat;

//--------------------------------------------------------------------------
//A TRAVAILLER
if($modeDebug){
    $strSorti .= ($strSql);
}

//---------------------------------------------------------------------------
//Cloture de l'interface
require("../API/php/footer.php");
?>