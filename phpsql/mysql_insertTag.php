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
// phpsql/mysql_insertTag.php?milis=123450&type_tag_name=&type_tag_id=&input_new_label=&input_new_descri=&id_toc=&code_user=&simpleTag=

// IN obligatoire
$arrayInput = array(
    "type_tag_name" => null,
    "type_tag_id" => null,
    "input_new_label" => null,
    "input_new_descri" => null,
    "id_toc" => null,
    "code_user" => null,
    "simpleTag" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$object_retour->data["id"] = "";

//recherche si existe déjà
$nb = "0";
$strSql = "SELECT count(*) as nb 
    FROM `".$prefixTable."tab_tags` a
    WHERE 1=1
    AND a.`label` = '".$arrayValeur["input_new_label"]."'
    AND a.`id_type_tag` = '".$arrayValeur["type_tag_id"]."'
    AND a.`actif` = 1
;";
$req = $connection->prepare($strSql);

$rows = array();
if($req->execute()){
    $rows = $req->fetch();
    $nb = $rows["nb"];
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

if($nb == "0"){
    $strSql = "INSERT INTO `".$prefixTable."tab_tags`
        (`label`,`description`,`actif`,`id_type_tag`,`dateTime_creation`,`auteur`)
        VALUES
        ('".$arrayValeur["input_new_label"]."','".$arrayValeur["input_new_descri"]."',1,".$arrayValeur["type_tag_id"].", NOW(), '".$arrayValeur["code_user"]."')
    ;";
    $req = $connection->prepare($strSql);

    if($req->execute()){
        $object_retour->data["id"] = $connection->lastInsertId(); 
        
        if($arrayValeur["simpleTag"]=="true"){
            //Mise à jour du tags affecté si besoin
            $retour = updateSimpleTag($arrayValeur["id_toc"], $arrayValeur["code_user"],$arrayValeur["type_tag_id"], $object_retour->data["id"],"[".$arrayValeur["type_tag_name"]."]");
            $message = $retour->strUpdateHisto;
        }else{
            $message = "<ul><li>[".$arrayValeur["type_tag_name"]."]"."=>".$object_retour->data["id"]."</li></ul>"; 
            $strSql = "INSERT INTO `".$prefixTable."tab_tags_affecte`
                (`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`)
                VALUES
                (".$arrayValeur["id_toc"].",".$arrayValeur["type_tag_id"].",".$object_retour->data["id"].",1,NOW(),'".$arrayValeur["code_user"]."')
            ;";
            $req = $connection->prepare($strSql);
            if(!($req->execute())){
                die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
            }
            $req->closeCursor();
        }
        $strSql = "select insert_histo('".$arrayValeur['id_toc']."','".$arrayValeur['code_user']."','".$message."');";
        $req = $connection->prepare($strSql);
        if(!($req->execute())){
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();
    }else{
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
}else{
    $object_retour->strErreur = "Un tag esiste déjà sous se Label.";
}

//--------------------------------------------------------------------------
if($modeDebug){
    print_r($strSql);
}

//---------------------------------------------------------------------------

//Cloture de l'interface
require("../API/php/footer.php");
?>