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
// phpsql/mysql_updateNote.php?milis=123450&ctrl=ok&id_toc=68455&code_user=FRO&id_note=&id_type=79&note=fermé

// IN obligatoire
$arrayInput = array(
    "ctrl" => null,
    "id_toc" => null,
    "code_user" => null,
    "id_note" => null,
    "id_type" => null,
    "note" => null
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

$object = new stdClass();
$object->strRetour = "";
$object->bolUpdate = false;
$object->bolCreate = false;
$object->idNewNote = 0;
$object->strUpdateHisto = "";

if($arrayValeur["id_note"]!=""){
    $strSql = "UPDATE `".$prefixTable."tab_notes` a
        SET `note` = '".addslashes($arrayValeur["note"])."',
            `dateTime_modification` = NOW(),
            `auteur_modification` = '".$arrayValeur["code_user"]."'
        WHERE 1=1
        AND a.`id` = ".$arrayValeur["id_note"]."
    ;";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    
    $object->bolUpdate = true;
    $object->strUpdateHisto .= "<li>[Ticket Détails Context][".$arrayValeur["id_type"]."]=>Mise à jour.</li>"; 
}else{
    $strSql = "INSERT INTO `".$prefixTable."tab_notes`
        (`id_toc`,`id_type`,`note`,`actif`,`dateTime_creation`,`auteur_creation`)
        VALUES
        (".$arrayValeur["id_toc"].",".$arrayValeur["id_type"].",'".addslashes($arrayValeur["note"])."',1,NOW(),'".$arrayValeur["code_user"]."')
    ;";
    $req = $connection->prepare($strSql);
    if($req->execute()){
        $object->idNewNote = $connection->lastInsertId(); 
    }else{
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
    
    $object->bolCreate = true;
    $object->strUpdateHisto .= "<li>[Ticket Détails Context][".$arrayValeur["id_type"]."]=>Nouvelle note</li>"; 
}

//--------------------------------------------------------------------------
if(($object->bolUpdate)OR($object->bolCreate)){
    $message = "<ul>".$object->strUpdateHisto."</ul>";
    $strSql = "select insert_histo('".$arrayValeur['id_toc']."','".$arrayValeur['code_user']."','".$message."');";
    $req = $connection->prepare($strSql);
    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
}

$object_retour->bolCreate = $object->bolCreate;
$object_retour->bolUpdate = $object->bolUpdate;
$object_retour->idNewNote = $object->idNewNote;
$object_retour->strRetour = $object->strRetour;
//--------------------------------------------------------------------------

if($modeDebug){
    $strSorti .= ('<br><br><br><br>'.$sql);
}

require("../API/php/footer.php");
?>