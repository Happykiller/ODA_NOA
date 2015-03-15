<?php
///////////////////
//Function commune
///////////////////
/**
 * Met à jour un tag simple
 * 
 * @param type $p_prefixTable
 * @param type $p_id_toc
 * @param type $p_code_user
 * @param type $p_tag_type
 * @param type $p_tag_id
 * @param type $p_msg
 * @return \stdClass
 */
function updateSimpleTag($p_id_toc, $p_code_user, $p_tag_type, $p_tag_id, $p_msg) {
    global $prefixTable, $connection;
    try {
        $retour = new stdClass();
        $retour->strErreur = "";
        $retour->strUpdateHisto = "";

        $old_tag = NULL;
        $strSql = "SELECT `id_tag` 
            FROM `".$prefixTable."tab_tags_affecte` a
            WHERE 1=1
            AND a.`id_type` = ".$p_tag_type."
            AND a.`id_toc` = ".$p_id_toc."
            AND a.`actif` = 1
        ;";
        $req = $connection->prepare($strSql);
        $rows = array();
        if($req->execute()){
            $rows = $req->fetch();
            $old_tag = $rows["id_tag"];
        }else{
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();

        if(($p_tag_id != "") && ($p_tag_id != $old_tag)){
            if($old_tag != NULL){
                $strSql = "UPDATE `".$prefixTable."tab_tags_affecte` a
                    SET `actif` = '0',
                        `dateTime_modification` = NOW(),
                        `auteur_modification` = '".$p_code_user."'
                    WHERE 1=1
                    AND a.`id_type` = ".$p_tag_type."
                    AND a.`id_toc` = ".$p_id_toc."
                    AND a.`actif` = 1
                ;
                INSERT INTO `".$prefixTable."tab_tags_affecte`
                    (`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`)
                    VALUES
                    (".$p_id_toc.",".$p_tag_type.",".$p_tag_id.",1,NOW(),'".$p_code_user."')
                ;";
                $req = $connection->prepare($strSql);
                if(!($req->execute())){
                    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
                }else{
                    $retour->strUpdateHisto .= "<li>".$p_msg.$old_tag."=>".$p_tag_id."</li>";
                }
                $req->closeCursor();
            }else{
                $strSql = "INSERT INTO `".$prefixTable."tab_tags_affecte`
                    (`id_toc`,`id_type`,`id_tag`,`actif`,`dateTime_creation`,`auteur_creation`)
                    VALUES
                    (".$p_id_toc.",".$p_tag_type.",".$p_tag_id.",1,NOW(),'".$p_code_user."')
                ;";
                $req = $connection->prepare($strSql);
                if(!($req->execute())){
                    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
                }else{
                    $retour->strUpdateHisto .= "<li>".$p_msg."=>".$p_tag_id."</li>"; 
                }
                $req->closeCursor();
            }
        }

        return $retour;
    } catch (Exception $e) {
        $retour = new stdClass();
        $msg = $e->getMessage();
        $retour->strErreur = $msg;
        $retour->strUpdateHisto = "";
        return $retour;
    }
}

/**
 * Met à jour une note simple
 * 
 * @param type $p_prefixTable
 * @param type $p_id_toc
 * @param type $p_code_user
 * @param type $p_tag_type
 * @param type $p_note
 * @param type $p_msg
 * @return \stdClass
 */
function updateSimpleNote($p_id_toc, $p_code_user, $p_tag_type, $p_note, $p_msg) {
    global $prefixTable, $connection;
    try {
        $retour = new stdClass();
        $retour->strErreur = "";
        $retour->strUpdateHisto = "";

        $old_id = null;
        $strSql = "SELECT a.`id`, a.`note`
            FROM `".$prefixTable."tab_notes` a
            WHERE 1=1
            AND a.`id_toc` = ".$p_id_toc."
            AND a.`id_type` = ".$p_tag_type."
            AND a.`actif` = 1
        ;";
        $req = $connection->prepare($strSql);
        $rows = array();
        if($req->execute()){
            $rows = $req->fetch();
            $old_id = $rows["id"];
        }else{
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();

        if(($old_id != "") && ($old_id != NULL)){
            $strSql = "UPDATE `".$prefixTable."tab_notes` a
                SET `note` = '".$p_note."',
                    `dateTime_modification` = NOW(),
                    `auteur_modification` = '".$p_code_user."'
                WHERE 1=1
                AND a.`id_type` = ".$p_tag_type."
                AND a.`id_toc` = ".$p_id_toc."
                AND a.`actif` = 1
            ;";
            $req = $connection->prepare($strSql);
            if(!($req->execute())){
                die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
            }else{
                $retour->strUpdateHisto .= "<li>".$p_msg."Mise &agrave; jour</li>"; 
            }
            $req->closeCursor();
        }else{
            $sql = "INSERT INTO `".$prefixTable."tab_notes`
                (`id_toc`, `note`, `id_type`, `actif`, `dateTime_creation`, `auteur_creation`)
                VALUES
                (".$p_id_toc.",'".$p_note."',".$p_tag_type.",1,NOW(),'".$p_code_user."')
            ;";
            if(!($req->execute())){
                die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
            }else{
                $retour->strUpdateHisto .= "<li>".$p_msg."Cr&eacute;ation</li>"; 
            }
            $req->closeCursor(); 
        }

        return $retour;
    } catch (Exception $e) {
        $retour = new stdClass();
        $msg = $e->getMessage();
        $retour->strErreur = $msg;
        $retour->strUpdateHisto = "";
        return $retour;
    }
}

/**
 * Charge les tag affectés pour un type de tag et un toc
 * 
 * @param type $p_prefixTable
 * @param type $p_id_toc
 * @param type $p_tag_type
 * @return \stdClass
 */
function chargerListTagParType($p_id_toc, $p_tag_type) {
    global $prefixTable, $connection;
    try {
        $strSql = "SELECT a.*,b.`label` 
            FROM `".$prefixTable."tab_tags_affecte` a, `".$prefixTable."tab_tags` b
            WHERE 1=1
            and a.`id_tag` = b.`id`
            AND a.`id_type` = ".$p_tag_type."
            AND a.`id_toc` = '".$p_id_toc."'
            AND a.`actif` = 1
            ORDER BY b.`label` asc
        ;";
        $req = $connection->prepare($strSql);

        $resultats = new stdClass();
        if($req->execute()){
            $req->setFetchMode(PDO::FETCH_OBJ);
            $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
            $resultats->nombre = count($resultats->data);
        }else{
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();
        
        return $resultats;
    } catch (Exception $e) {
        $retour = new stdClass();
        $msg = $e->getMessage();
        $retour->strErreur = $msg;
        return $retour;
    }
}

/**
 * Charge des notes
 * 
 * @param type $p_prefixTable
 * @param type $p_id_toc
 * @param type $p_tag_type
 * @return \stdClass
 */
function chargerNotes($p_id_toc, $p_tag_type) {
    global $prefixTable, $connection;
    try {
        $strSql = "SELECT a.* 
            FROM `".$prefixTable."tab_notes` a
            WHERE 1=1
            AND a.`id_type` = ".$p_tag_type."
            AND a.`id_toc` = '".$p_id_toc."'
            AND a.`actif` = 1
        ;";

        $req = $connection->prepare($strSql);

        $resultats = new stdClass();
        if($req->execute()){
            $req->setFetchMode(PDO::FETCH_OBJ);
            $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
            $resultats->nombre = count($resultats->data);
        }else{
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();
        
        return $resultats;
    } catch (Exception $e) {
        $retour = new stdClass();
        $msg = $e->getMessage();
        $retour->strErreur = $msg;
        return $retour;
    }
}

/**
 * Charge un tag pour un type
 * 
 * @param type $p_prefixTable
 * @param type $p_id_toc
 * @param type $p_tag_type
 * @return \stdClass
 */
function getTagByType($p_id_toc, $p_tag_type) {
    global $prefixTable, $connection;
    try {
        $retour = new stdClass();
        $retour->strErreur = "";
        $retour->id_tag = "0";

        $strSql = "SELECT a.`id_tag` 
            FROM `".$prefixTable."tab_tags_affecte` a
            WHERE 1=1
            AND a.`id_type` = ".$p_tag_type."
            AND a.`id_toc` = '".$p_id_toc."'
            AND a.`actif` = 1
        ;";
        $req = $connection->prepare($strSql);
        $rows = array();
        if($req->execute()){
            $rows = $req->fetch();
            $retour->id_tag = $rows["id_tag"];
        }else{
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();

        return $retour;
    } catch (Exception $e) {
        $retour = new stdClass();
        $msg = $e->getMessage();
        $retour->strErreur = $msg;
        $retour->id_tag = "0";
        return $retour;
    }
}
?>