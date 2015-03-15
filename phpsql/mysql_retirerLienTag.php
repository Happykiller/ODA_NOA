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
// phpsql/mysql_retirerLienTag.php?milis=123450&id_lien=446304&id_tag=72&str_section=impacts_tags&id_type_tag=21&id_toc=68332&code_user=FRO

// IN obligatoire
$arrayInput = array(
    "str_section" => null,
    "id_lien" => null,
    "id_tag" => null,
    "id_type_tag" => null,
    "id_toc" => null,
    "code_user" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$resultat = new stdClass();
$resultat->str_section = $arrayValeur["str_section"];
$resultat->type_tag_id = $arrayValeur["id_type_tag"];
$object_retour->data = $resultat;
//--------------------------------------------------------------------------
$message = "<ul>[".$arrayValeur["str_section"]."]".$arrayValeur["id_tag"]."=></ul>";

$strSql = "UPDATE `".$prefixTable."tab_tags_affecte` a
SET `actif` = 0,
    `dateTime_modification` = NOW(),
    `auteur_modification` = '".$arrayValeur["code_user"]."'
WHERE 1=1
AND a.`id` = ".$arrayValeur["id_lien"]."
;
select insert_histo('".$arrayValeur['id_toc']."','".$arrayValeur['code_user']."','".$message."');
";
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