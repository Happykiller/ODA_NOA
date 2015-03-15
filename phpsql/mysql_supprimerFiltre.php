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
// phpsql/mysql_supprimerFiltre.php?milis=123450&champs=nature&code_user=FRO&valeur=32

//Liens de test
// IN obligatoire
$arrayInput = array(
    "ctrl" => null,
    "champs" => null,
    "code_user" => null,
    "valeur" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$strSql = "UPDATE `tab_filtres_users` a
    SET a.`".$arrayValeur["champs"]."` = REPLACE(a.`".$arrayValeur["champs"]."`, '\"".$arrayValeur["valeur"]."\";', '')
    WHERE 1=1
    AND a.`code_user` = :code_user
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
$object_retour->data["resultat"] = $resultat;

//--------------------------------------------------------------------------
if($modeDebug){
    print_r($strSql);
}

//---------------------------------------------------------------------------

//Cloture de l'interface
require("../API/php/footer.php");
?>