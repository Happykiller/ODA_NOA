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
//phpsql/mysql_upDateTicketSysDetails.php?milis=123450&id=10611&label=1307201158a&visible=1&editable=1&code_user=FRO

// IN obligatoire
$arrayInput = array(
    "id" => null,
    "label" => null,
    "visible" => null,
    "editable" => null,
    "code_user" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$result = "1";
$update = false;
$update_histo_str = "";

//On récupère les infos en base
$strSql = "SELECT `label`, b.`id_tag` as 'visibilite', c.`id_tag` as 'editable'
FROM `".$prefixTable."tab_tickets` a
LEFT OUTER JOIN `".$prefixTable."tab_tags_affecte` b
ON b.`id_toc` = a.`id`
AND b.`id_type` = 26/*visibilite*/
AND b.`actif` = 1
LEFT OUTER JOIN `".$prefixTable."tab_tags_affecte` c 
ON c.`id_toc` = a.`id`
AND c.`id_type` = 27/*editable*/
AND c.`actif` = 1
WHERE 1=1
AND a.`id` = :id_toc
;";
$req = $connection->prepare($strSql);
$req->bindValue(":id_toc", $arrayValeur["id"], PDO::PARAM_INT);

$rows = array();
if($req->execute()){
    $rows = $req->fetch();
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//--------------------------------------------------------------------------
if($rows["label"] != $arrayValeur["label"]){
    $strSql = "UPDATE `".$prefixTable."tab_tickets` a
        SET `label` = :label,
            `dateTime_modification` = NOW(),
            `auteur_modification` = :code_user
        WHERE 1=1
        AND id = :id_toc
    ;";
    $req = $connection->prepare($strSql);
    $req->bindValue(":id_toc", $arrayValeur["id"], PDO::PARAM_INT);
    $req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
    $req->bindValue(":label", $arrayValeur["label"], PDO::PARAM_STR);

    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }else{
        $update = true;
        $update_histo_str .= "<li>[Ticket Détails Système][Label]".$old_label."=>".$arrayValeur["label"]."</li>"; 
    }
    $req->closeCursor();
}

//--------------------------------------------------------------------------
if(($arrayValeur["visible"] != "") && ($arrayValeur["visible"] != $rows["visibilite"])){
    if($rows["visibilite"] != NULL){
        $strSql = "UPDATE `".$prefixTable."tab_tags_affecte` a
            SET `id_tag` = :visible,
                `dateTime_modification` = NOW(),
                `auteur_modification` = :code_user
            WHERE 1=1
            AND a.`id_type` = 26/*visibilite*/
            AND a.`id_toc` = :id_toc
            AND a.`actif` = 1
        ;";
        $req = $connection->prepare($strSql);
        $req->bindValue(":id_toc", $arrayValeur["id"], PDO::PARAM_INT);
        $req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
        $req->bindValue(":visible", $arrayValeur["visible"], PDO::PARAM_INT);

        if(!($req->execute())){
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }else{
            $update = true;
            $update_histo_str .= "<li>[Ticket Détails Système][Visible]".$rows["visibilite"]."=>".$arrayValeur["visible"]."</li>";
        }
        $req->closeCursor();
    }else{
        $strSql = "INSERT INTO `".$prefixTable."tab_tags_affecte`
            (`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`)
            VALUES
            (:id_toc,26,:visible,1,NOW(),:code_user)
        ;";
        $req = $connection->prepare($strSql);
        $req->bindValue(":id_toc", $arrayValeur["id"], PDO::PARAM_INT);
        $req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
        $req->bindValue(":visible", $arrayValeur["visible"], PDO::PARAM_INT);

        if(!($req->execute())){
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }else{
            $update = true;
            $update_histo_str .= "<li>[Ticket Détails Système][Visible]=>".$arrayValeur["visible"]."</li>"; 
        }
        $req->closeCursor();
    }
}

//--------------------------------------------------------------------------
if(($arrayValeur["editable"] != "") && ($arrayValeur["editable"] != $rows["editable"])){
    if($rows["editable"] != NULL){
        $strSql = "UPDATE `".$prefixTable."tab_tags_affecte` a
            SET `id_tag` = :editable,
                `dateTime_modification` = NOW(),
                `auteur_modification` = :code_user
            WHERE 1=1
            AND a.`id_type` = 27/*editable*/
            AND a.`id_toc` = :id_toc
            AND a.`actif` = 1
        ;";
        $req = $connection->prepare($strSql);
        $req->bindValue(":id_toc", $arrayValeur["id"], PDO::PARAM_INT);
        $req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
        $req->bindValue(":editable", $arrayValeur["editable"], PDO::PARAM_INT);

        if(!($req->execute())){
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }else{
            $update = true;
            $update_histo_str .= "<li>[Ticket Détails Système][Editable]".$rows["editable"]."=>".$arrayValeur["editable"]."</li>"; 
        }
        $req->closeCursor();
    }else{
        $strSql = "INSERT INTO `".$prefixTable."tab_tags_affecte`
            (`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`)
            VALUES
            (:id_toc,27,:editable,1,NOW(),:code_user)
        ;";
        $req = $connection->prepare($strSql);
        $req->bindValue(":id_toc", $arrayValeur["id"], PDO::PARAM_INT);
        $req->bindValue(":code_user", $arrayValeur["code_user"], PDO::PARAM_STR);
        $req->bindValue(":editable", $arrayValeur["editable"], PDO::PARAM_INT);

        if(!($req->execute())){
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }else{
            $update = true;
            $update_histo_str .= "<li>[Ticket Détails Système][Editable]=>".$arrayValeur["editable"]."</li>"; 
        }
        $req->closeCursor();
    }
}
//--------------------------------------------------------------------------

if($update){
    $message = "<ul>".$update_histo_str."</ul>";
    $strSql = "select insert_histo('".$arrayValeur['id']."','".$arrayValeur['code_user']."','".$message."');";
    $req = $connection->prepare($strSql);

    if(!($req->execute())){
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();
}

//--------------------------------------------------------------------------

if($modeDebug){
    $strSorti .= ('<br><br><br><br>'.$strSql);
}

require("../API/php/footer.php");
?>