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
// phpsql/mysql_getTicketsDetails.php?milis=123450&id=67420

// IN obligatoire
$arrayInput = array(
    "id" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$id = "0";
$strSql = "SELECT a.`id`,a.`label`,DATE_FORMAT(a.`dateTime_creation`,'%d/%m/%Y %H:%i:%s') as `date_creation`,a.`auteur`
    ,DATE_FORMAT(a.`dateTime_modification`,'%d/%m/%Y %H:%i:%s') as `date_modification`,a.`auteur_modification`
    ,DATE_FORMAT(a.`lock_time`,'%d/%m/%Y %H:%i:%s') as `date_lock`,a.`lock_auteur`
    FROM  `".$prefixTable."tab_tickets` a
    WHERE 1=1
    AND id = ".$arrayValeur["id"]."
;";
$req = $connection->prepare($strSql);

$rows = array();
if($req->execute()){
    $rows = $req->fetch();
    $object_retour->data = $rows;
    $id = $rows["id"];
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//----------------------------------------------------------------------
//visibilité
$strSql = "SELECT * 
    FROM `".$prefixTable."tab_tags_affecte` a
    WHERE 1=1
    AND a.`id_type` = 26/*visibilite*/
    AND a.`id_toc` = '".$id."'
    AND a.`actif` = 1
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $object_retour->data["visibilite"] = $req->fetchAll(PDO::FETCH_OBJ);
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//----------------------------------------------------------------------
//editable
$strSql = "SELECT * 
    FROM `".$prefixTable."tab_tags_affecte` a
    WHERE 1=1
    AND a.`id_type` = 27/*editable*/
    AND a.`id_toc` = '".$id."'
    AND a.`actif` = 1
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $object_retour->data["editable"] = $req->fetchAll(PDO::FETCH_OBJ);
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//----------------------------------------------------------------------
//Nature
$retour = chargerListTagParType($id, 28);
$object_retour->data["nature"] = $retour->data;

//----------------------------------------------------------------------
//priorite
$retour = chargerListTagParType($id, 15);
$object_retour->data["priorite"] = $retour->data;

//----------------------------------------------------------------------
//criticite
$retour = chargerListTagParType($id, 16);
$object_retour->data["criticite"] = $retour->data;

//----------------------------------------------------------------------
//complexite
$retour = chargerListTagParType($id, 17);
$object_retour->data["complexite"] = $retour->data;

//----------------------------------------------------------------------
//repro
$retour = chargerListTagParType($id, 18);
$object_retour->data["repro"] = $retour->data;

//----------------------------------------------------------------------
//statut
$retour = chargerListTagParType($id, 9);
$object_retour->data["statut"] = $retour->data;

//----------------------------------------------------------------------
//env_ori
$retour = chargerListTagParType($id, 19);
$object_retour->data["env_ori"] = $retour->data;

//----------------------------------------------------------------------
//env_dest
$retour = chargerListTagParType($id, 50);
$object_retour->data["env_dest"] = $retour->data;

//----------------------------------------------------------------------
//categorie
$retour = chargerListTagParType($id, 12);
$object_retour->data["categorie"] = $retour->data;

//----------------------------------------------------------------------
//sous-categorie
$retour = chargerListTagParType($id, 13);
$object_retour->data["sous-categorie"] = $retour->data;

//----------------------------------------------------------------------
//Description
$retour = chargerNotes($id, 70);
$object_retour->data["description"] = $retour->data;

//----------------------------------------------------------------------
//causes_tags
$retour = chargerListTagParType($id, 20);
$object_retour->data["causes_tags"] = $retour->data;

//----------------------------------------------------------------------
//causes_note
$retour = chargerNotes($id, 78);
$object_retour->data["causes_note"] = $retour->data;

//----------------------------------------------------------------------
//impacts_tags
$retour = chargerListTagParType($id, 21);
$object_retour->data["impacts_tags"] = $retour->data;

//----------------------------------------------------------------------
//impacts_note
$retour = chargerNotes($id, 79);
$object_retour->data["impacts_note"] = $retour->data;

//----------------------------------------------------------------------
//repro_tags
$retour = chargerListTagParType($id, 22);
$object_retour->data["repro_tags"] = $retour->data;

//----------------------------------------------------------------------
//repro_note
$retour = chargerNotes($id, 80);
$object_retour->data["repro_note"] = $retour->data;

//----------------------------------------------------------------------
//reso_tags
$retour = chargerListTagParType($id, 23);
$object_retour->data["reso_tags"] = $retour->data;

//----------------------------------------------------------------------
//reso_note
$retour = chargerNotes($id, 81);
$object_retour->data["reso_note"] = $retour->data;

//----------------------------------------------------------------------
//relations
$strSql = "SELECT a.*, b.`label` as label_ori, c.`label` as label_dest
    FROM `".$prefixTable."tab_relations` a, `".$prefixTable."tab_tickets` b, `".$prefixTable."tab_tickets` c
    WHERE 1=1
    AND a.obj_origine = b.`id`
    AND a.obj_dest = c.`id`
    AND (
        a.`obj_origine` = ".$id."
        OR
        a.`obj_dest` = ".$id."
    )
    AND a.`actif` = 1
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $object_retour->data["relations"] = $req->fetchAll(PDO::FETCH_OBJ);
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//----------------------------------------------------------------------
//temps_passe 34
$strSql = "SELECT a.*
    FROM `".$prefixTable."tab_notes` a
    WHERE 1=1
    AND a.`id_toc` = ".$id."
    AND a.`id_type` = 34
    AND a.`actif` = 1
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $object_retour->data["tp"] = $req->fetchAll(PDO::FETCH_OBJ);
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//----------------------------------------------------------------------
//respon
$strSql = "SELECT a.*,b.`code_user`,b.`nom` ,b.`prenom`, CONCAT(b.`code_user`,':',b.`nom`,' ',b.`prenom`) as 'label'
    FROM `".$prefixTable."tab_tags_affecte` a, `".$prefixTable."tab_utilisateurs` b
    WHERE 1=1
    and a.`id_tag` = b.`id`
    AND a.`id_type` = 14
    AND a.`id_toc` = ".$id."
    AND a.`actif` = 1
;";
$req = $connection->prepare($strSql);

if($req->execute()){
    $req->setFetchMode(PDO::FETCH_OBJ);
    $object_retour->data["respon"] = $req->fetchAll(PDO::FETCH_OBJ);
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//----------------------------------------------------------------------
//Version
$retour = getTagByType($id, 91);
$object_retour->data["version"] = $retour->id_tag;

//--------------------------------------------------------------------------
if($modeDebug){
    print_r($strSql);
}

//---------------------------------------------------------------------------

//Cloture de l'interface
require("../API/php/footer.php");
?>