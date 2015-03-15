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
// phpsql/mysql_supprimerNote.php?milis=123450&id_toc=67420&code_user=FRO&id_type=84&id_note=68802

// IN obligatoire
$arrayInput = array(
    "id_toc" => null,
    "code_user" => null,
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
$message = "<ul><li>[Notes]=>Suppression de la note(".$arrayValeur["id_note"].")</li></ul>"; 

$strSql = "UPDATE `".$prefixTable."tab_notes`
    SET `actif` = 0,
        `dateTime_modification` = NOW(),
        `auteur_modification` = '".$arrayValeur["code_user"]."'
    WHERE 1=1
    AND `id_toc` = ".$arrayValeur["id_toc"]."
    AND `id_type` = ".$arrayValeur["id_type"]."
    AND `actif` = 1
    AND `id` = ".$arrayValeur["id_note"]."
;
select insert_histo('".$arrayValeur['id_toc']."','".$arrayValeur['code_user']."','".$message."');";
$req = $connection->prepare($strSql);
if(!($req->execute())){
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
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