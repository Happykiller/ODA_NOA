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
// phpsql/mysql_updateFiltres.php?milis=123450&code_user=FRO

// IN obligatoire
$arrayInput = array(
    "code_user" => null,
    "core_dateTime_creation" => null,
    "core_dateTime_creation_option" => null
);

//Définition des entrants optionel
$arrayInputOpt = array(
    "impactNote" => null,
    "causeNote" => null,
    "resoNote" => null,
    "reproNote" => null,
    "core_dateTime_modification" => null,
    "core_dateTime_modification_option" => null,
    "core_label" => null,
    "core_description" => null,
    "core_version" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput,$arrayInputOpt);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$bolUpdate = false;

//--------------------------------------------------------------------------
$strDateTime_creation = "";
if(($arrayValeur["core_dateTime_creation_option"] != null)&&($arrayValeur["core_dateTime_creation"] != null)){
    if($arrayValeur["core_dateTime_creation"] != ''){
        $strDateTime_creation = ", `dateTime_creation` = '".str_replace('T', ' ',$arrayValeur["core_dateTime_creation"])."'";
        $strDateTime_creation .= ", `dateTime_creation_option` = '".$arrayValeur["core_dateTime_creation_option"]."'";
        $bolUpdate = true;
    }
}

$strDateTime_modification = "";
if(($arrayValeur["core_dateTime_modification"] != null)&&($arrayValeur["core_dateTime_modification_option"] != null)){
    if($arrayValeur["core_dateTime_modification_option"] == "reset") {
        $strDateTime_modification = ", `dateTime_modification` = null ";
        $strDateTime_modification .= ", `dateTime_modification_option` = null ";
        $bolUpdate = true;
    }elseif($arrayValeur["core_dateTime_modification"] != ''){
        $strDateTime_modification = ", `dateTime_modification` = '".str_replace('T', ' ',$arrayValeur["core_dateTime_modification"])."'";
        $strDateTime_modification .= ", `dateTime_modification_option` = '".$arrayValeur["core_dateTime_modification_option"]."'";
        $bolUpdate = true;
    }
}

$strLabel = "";
if($arrayValeur["core_label"] != null){
    if($arrayValeur["core_label"] == "##reset##") {
        $strLabel = ", `label` = null ";
        $bolUpdate = true;
    }elseif($arrayValeur["core_label"] != ''){
        $strLabel = ", `label` = '".$arrayValeur["core_label"]."'";
        $bolUpdate = true;
    }
}

$strDescription = "";
if($arrayValeur["core_description"] != null){
    if($arrayValeur["core_description"] == "##reset##") {
        $strDescription = ", `description` = null ";
        $bolUpdate = true;
    }elseif($arrayValeur["core_description"] != ''){
        $strDescription = ", `description` = '".$arrayValeur["core_description"]."'";
        $bolUpdate = true;
    }
}

$strVersion = "";
if($arrayValeur["core_version"] != null){
    if($arrayValeur["core_version"] == "##reset##") {
        $strVersion = ", `version` = 0 ";
        $bolUpdate = true;
    }elseif($arrayValeur["core_version"] != ''){
        $strVersion = ", `version` = ".$arrayValeur["core_version"]."";
        $bolUpdate = true;
    }
}

$strImpactNote = "";
if($arrayValeur["impactNote"] != null){
    if($arrayValeur["impactNote"] == "##reset##") {
        $strImpactNote = ", `impactNote` = null ";
        $bolUpdate = true;
    }elseif($arrayValeur["impactNote"] != ''){
        $strImpactNote = ", `impactNote` = '".$arrayValeur["impactNote"]."'";
        $bolUpdate = true;
    }
}

$strCauseNote = "";
if($arrayValeur["causeNote"] != null){
    if($arrayValeur["causeNote"] == "##reset##") {
        $strCauseNote = ", `causeNote` = null ";
        $bolUpdate = true;
    }elseif($arrayValeur["causeNote"] != ''){
        $strCauseNote = ", `causeNote` = '".$arrayValeur["causeNote"]."'";
        $bolUpdate = true;
    }
}

$strResoNote = "";
if($arrayValeur["resoNote"] != null){
    if($arrayValeur["resoNote"] == "##reset##") {
        $strResoNote = ", `resoNote` = null ";
        $bolUpdate = true;
    }elseif($arrayValeur["resoNote"] != ''){
        $strResoNote = ", `resoNote` = '".$arrayValeur["resoNote"]."'";
        $bolUpdate = true;
    }
}

$strReproNote = "";
if($arrayValeur["reproNote"] != null){
    if($arrayValeur["reproNote"] == "##reset##") {
        $strReproNote = ", `reproNote` = null ";
        $bolUpdate = true;
    }elseif($arrayValeur["reproNote"] != ''){
        $strReproNote = ", `reproNote` = '".$arrayValeur["reproNote"]."'";
        $bolUpdate = true;
    }
}

if($bolUpdate){
    $strSql = "UPDATE `".$prefixTable."tab_filtres_users` a
        SET `code_user` = :code_user/*pour la concatenation*/ 
        ".$strDateTime_creation."
        ".$strDateTime_modification."
        ".$strLabel."
        ".$strDescription."
        ".$strImpactNote."
        ".$strCauseNote."
        ".$strResoNote."
        ".$strReproNote."
        ".$strVersion."
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
}else{
    $object_retour->strErreur = "Aucune modification";
}
//--------------------------------------------------------------------------

if($modeDebug){
    $strSorti .= ('<br><br><br><br>'.$strSql);
}

require("../API/php/footer.php");
?>