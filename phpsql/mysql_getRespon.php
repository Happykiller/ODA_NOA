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
// phpsql/mysql_getRespon.php?milis=123450&ctrl=ok&recherche=fr&id_toc=10829

// IN obligatoire
$arrayInput = array(
    "recherche" => null
);

//Définition des entrants optionel
$arrayInputOpt = array(
    "id_toc" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput,$arrayInputOpt);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------

//Nature
$strFiltreToc = "";
if(($arrayValeur["id_toc"] != null)&&($arrayValeur["id_toc"] != "")){
    $strFiltreToc = " AND not exists (select 1 FROM `".$prefixTable."tab_tags_affecte` b
        WHERE 1=1
        AND a.`id` = b.`id_toc`
        AND b.`id_type` = 14
        AND b.`id_toc` = ".$arrayValeur["id_toc"]."
        AND b.`actif` = 1
     )
     ";
}

$strSql = "SELECT a.`id`, a.`code_user`, a.`nom`, a.`prenom`, CONCAT(a.`code_user`,':',a.`nom`,' ',a.`prenom`) as 'label', a.`code_user` as 'valeur'
    FROM `".$prefixTable."tab_utilisateurs` a
    WHERE 1=1
    AND a.`actif` = 1
    ".$strFiltreToc."
    UNION 
    SELECT 0 , 'SANSRESPON' AS  'code_user',  'Sans responsable' AS  'nom',  '' AS  'prenom', CONCAT(  'SANSRESPON',  ':',  'Sans responsable',  ' ',  'Sans responsable' ) AS  'label',  'SANSRESPON' AS  'valeur'
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $resultats = new stdClass();
    $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
    $resultats->nombre = count($resultats->data);
    $object_retour->data["resultat"] = $resultats;
}else{
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur = $error;
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