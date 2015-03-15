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
// phpsql/mysql_supprimerRespon.php?milis=123450&id_toc=67420&code_user=FRO

// IN obligatoire
$arrayInput = array(
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
$message = "<ul><li>[Responsable]=></li></ul>";
$strSql = "UPDATE `".$prefixTable."tab_tags_affecte`
    SET `actif` = 0,
        `dateTime_modification` = NOW(),
        `auteur_modification` = '".$arrayValeur["code_user"]."'
    WHERE 1=1
    AND `actif` = 1
    AND id_type = 14
    AND id_toc = ".$arrayValeur["id_toc"]."
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