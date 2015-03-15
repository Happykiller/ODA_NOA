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
// phpsql/mysql_upDateTicketContextDetails.php?milis=123450&code_user=FRO&complexite_tag=&complexite_type=17&criticite_tag=41&criticite_type=16&env_dest_tag=&env_dest_type=50&env_ori_tag=&env_ori_type=19&id_toc=67420&nature_tag=2000&nature_type=28&priorite_tag=37&priorite_type=15&repro_tag=&repro_type=18&statut_tag=7&statut_type=9&tp=N.A.

// IN obligatoire
$arrayInput = array(
    "id_toc" => null,
    "code_user" => null,
    "nature_type" => null,
    "nature_tag" => null,
    "priorite_type" => null,
    "priorite_tag" => null,
    "criticite_type" => null,
    "criticite_tag" => null,
    "complexite_type" => null,
    "complexite_tag" => null,
    "repro_type" => null,
    "repro_tag" => null,
    "statut_type" => null,
    "statut_tag" => null,
    "env_ori_type" => null,
    "env_ori_tag" => null,
    "env_dest_type" => null,
    "env_dest_tag" => null,
    "tp" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$update_histo_str = "";

//--------------------------------------------------------------------------
//Mise à jour nature
$retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"], $arrayValeur["nature_type"], $arrayValeur["nature_tag"], "[Nature]");
$update_histo_str .= $retour->strUpdateHisto;

//--------------------------------------------------------------------------
//Mise à jour priorite
$retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"], $arrayValeur["priorite_type"], $arrayValeur["priorite_tag"], "[Priorité]");
$update_histo_str .= $retour->strUpdateHisto;

//--------------------------------------------------------------------------
//Mise à jour criticite
$retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"], $arrayValeur["criticite_type"], $arrayValeur["criticite_tag"], "[Criticité]");
$update_histo_str .= $retour->strUpdateHisto;

//--------------------------------------------------------------------------
//Mise à jour complexite
$retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"],  $arrayValeur["complexite_type"], $arrayValeur["complexite_tag"], "[Complexité]");
$update_histo_str .= $retour->strUpdateHisto;

//--------------------------------------------------------------------------
//Mise à jour criticite
$retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"], $arrayValeur["repro_type"], $arrayValeur["repro_tag"], "[Reproductibilité]");
$update_histo_str .= $retour->strUpdateHisto;

//--------------------------------------------------------------------------
//Mise à jour statut
$retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"], $arrayValeur["statut_type"], $arrayValeur["statut_tag"], "[Statut]");
$update_histo_str .= $retour->strUpdateHisto;

//--------------------------------------------------------------------------
//Mise à jour env_ori
$retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"], $arrayValeur["env_ori_type"], $arrayValeur["env_ori_tag"],"[Environnement d\\'origine]");
$update_histo_str .= $retour->strUpdateHisto;

//--------------------------------------------------------------------------
//Mise à jour env_dest
$retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"], $arrayValeur["env_dest_type"], $arrayValeur["env_dest_tag"], "[Environnement de destination]");
$update_histo_str .= $retour->strUpdateHisto;

//--------------------------------------------------------------------------
//Mise à tp
if(($arrayValeur["tp"] != "") && ($arrayValeur["tp"] != "N.A.")){
    $retour = updateSimpleNote($arrayValeur["id_toc"], $arrayValeur["code_user"], 34, $arrayValeur["tp"], "[Temps passé]");
    $update_histo_str .= $retour->strUpdateHisto;
}

//--------------------------------------------------------------------------
//Valo de l'histo
$message = "<ul>".$update_histo_str."</ul>";
$strSql = "select insert_histo('".$arrayValeur['id_toc']."','".$arrayValeur['code_user']."','".$message."');";
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