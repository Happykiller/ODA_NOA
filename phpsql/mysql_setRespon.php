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
// phpsql/mysql_setRespon.php?milis=123450&id_toc=68124&id_respon=1&code_user=FRO

// IN obligatoire
$arrayInput = array(
    "id_toc" => null,
    "id_respon" => null,
    "code_user" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$strUpdateHisto = "";

//--------------------------------------------------------------------------
$strSql = "SELECT a.`id_tag` 
    FROM `".$prefixTable."tab_tags_affecte` a
    WHERE 1=1
    AND a.`id_type` = 14
    AND a.`id_toc` = :id_toc
    AND a.`actif` = 1
;";

$req = $connection->prepare($strSql);
$req->bindValue(":id_toc", $arrayValeur["id_toc"], PDO::PARAM_INT);

$rows = array();
if($req->execute()){
    $rows = $req->fetch();
    $old_tag = $rows["id_tag"];
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//--------------------------------------------------------------------------
if($old_tag != NULL){
    $strSql = "UPDATE `".$prefixTable."tab_tags_affecte` a
        SET `id_tag` = :id_respon,
            `dateTime_modification` = NOW(),
            `auteur_modification` = :code_user
        WHERE 1=1
        AND a.`id_type` = 14
        AND a.`id_toc` = :id_toc
        AND a.`actif` = 1
    ;";
    $req = $connection->prepare($strSql);
    $req->bindValue(":id_respon", $arrayValeur["id_respon"], PDO::PARAM_INT);
    $req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
    $req->bindValue(":id_toc", $arrayValeur["id_toc"], PDO::PARAM_INT);

    $resultat = new stdClass();
    if($req->execute()){
        $strUpdateHisto .= "<li>[Ticket Détails Context][Affectation]".$old_tag."=>".$arrayValeur["id_respon"]."</li>"; 
    }else{
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
}else{
    $strSql = "INSERT INTO `".$prefixTable."tab_tags_affecte`
        (`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`)
        VALUES
        (:id_toc,14,:id_respon,1,NOW(),:code_user)
    ;";
    $req = $connection->prepare($strSql);
    $req->bindValue(":id_respon", $arrayValeur["id_respon"], PDO::PARAM_INT);
    $req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
    $req->bindValue(":id_toc", $arrayValeur["id_toc"], PDO::PARAM_INT);

    $resultat = new stdClass();
    if($req->execute()){
        $strUpdateHisto .= "<li>[Ticket Détails Context][Affectation]=>".$arrayValeur["id_respon"]."</li>"; 
    }else{
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
}

//--------------------------------------------------------------------------
$message = "<ul>".$strUpdateHisto."</ul>";
$strSql = "select insert_histo(:id_toc,:code_user,:message);";

$req = $connection->prepare($strSql);
$req->bindValue(":message", $message, PDO::PARAM_STR);
$req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
$req->bindValue(":id_toc", $arrayValeur["id_toc"], PDO::PARAM_INT);

$resultat = new stdClass();
if(!$req->execute()){
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//--------------------------------------------------------------------------
//A TRAVAILLER
if($modeDebug){
    $strSorti .= ($strSql);
}

//---------------------------------------------------------------------------

//Cloture de l'interface
require("../API/php/footer.php");
?>