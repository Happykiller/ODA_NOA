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
// php/delete.php?milis=123450&id_toc=1&id_pj=1&id_type=1&code_user=FRO&label_fich=essai.txt

// IN obligatoire
$arrayInput = array(
    "id_toc" => null,
    "id_pj" => null,
    "id_type" => null,
    "code_user" => null,
    "label_fich" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//------------------------------------------------------------------------------
error_reporting(E_ERROR);

//function delete
$retour_array = array('code' => null,
    'message' => null
);

$dossier = '../pjs/';

if(isset($arrayValeur['label_fich'])) {
    $fichier = $arrayValeur['id_pj']."_".$arrayValeur['label_fich'];
    $path = $dossier . $fichier;
    if(unlink($path)) {
        $retour_array['code'] = 'ok';
        $details_array = array('message'=>'Fichier supprime avec succes.','path'=>$path);
        $retour_array['message'] = $details_array; 
     } else { //Sinon (la fonction renvoie FALSE)
        $retour_array['code'] = 'ko';
        $details_array = array('message'=>'Echec de la suppression.','path'=>$path);
        $retour_array['message'] = $details_array;
     }
}else{
    $retour_array['code'] = 'ko';
    $retour_array['message'] = 'Pas torrent passe en parametre ...';
}

if($retour_array['code'] == 'ok'){
    $strSql = "UPDATE `".$prefixTable."tab_pjs` a
        SET a.`actif` = 0
        , `dateTime_modification` = NOW()
        , `auteur_modification` = '".$arrayValeur['code_user']."'
        WHERE 1=1
        AND `id` = ".$arrayValeur['id_pj']."
        AND `id_toc` = ".$arrayValeur['id_toc']."
        AND `id_type` = ".$arrayValeur['id_type']."
        AND a.`actif` = 1
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();

    $message = "<ul>[Ticket Pièces Jointes][".$arrayValeur['id_type']."]<li>Supression du fichier : ".$arrayValeur['label_fich']."</li></ul>";
    $strSql = "select insert_histo('".$arrayValeur['id_toc']."','".$arrayValeur['code_user']."','".$message."');";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
}

$object_retour->data = $retour_array;

//--------------------------------------------------------------------------

if($modeDebug){
    $strSorti .= ('<br><br><br><br>'.$sql);
}

require("../API/php/footer.php");
?>