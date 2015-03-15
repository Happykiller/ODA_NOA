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
//phpsql/mysql_supprimerRelation.php?milis=123450&id_relation=1&id_toc=68332&id_toc_autre=68331&courant=asc&code_user=FRO

// IN obligatoire
$arrayInput = array(
    "id_relation" => null,
    "id_toc" => null,
    "id_toc_autre" => null,
    "courant" => null,
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
$message = "<ul><li>[Relation]=>Relation ".$arrayValeur["courant"]." avec ".$arrayValeur["id_toc_autre"]." supprimé</li></ul>";

$strSql = "UPDATE `".$prefixTable."tab_relations`
    SET actif = 0,
        `dateTime_modification` = NOW(),
        `auteur_modification` = '".$arrayValeur["code_user"]."'
    WHERE 1=1
    AND `actif` = 1
    AND id = ".$arrayValeur["id_relation"]."
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