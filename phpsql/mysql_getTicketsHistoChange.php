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
// phpsql/mysql_getTicketsHistoChange.php?milis=123450&ctrl=ok&id=10606

// IN obligatoire
$arrayInput = array(
    "ctrl" => null,
    "id" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//--------------------------------------------------------------------------
$strSql = "SELECT a.`id`, a.`code_user`
    FROM  `".$prefixTable."tab_utilisateurs` a
    WHERE 1=1
;";

$array_users = array();
$req = $connection->prepare($strSql);
if($req->execute()){
    while ($row = $req->fetch())
    {
        $array_users[$row['id']] = $row['code_user'];
    }
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//--------------------------------------------------------------------------
$strSql = "SELECT a.`id`, a.`description`
    FROM  `".$prefixTable."tab_tags` a
    WHERE 1=1
;";

$array_tags = array();
$req = $connection->prepare($strSql);
if($req->execute()){
    while ($row = $req->fetch())
    {
        $array_tags[$row['id']] = $row['description'];
    }
}else{
    die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
}
$req->closeCursor();

//--------------------------------------------------------------------------
$strSql = "SELECT a.`id`,a.`auteur`,DATE_FORMAT(a.`dateTime_change`,'%d/%m/%Y %H:%i:%s') as `dateTime_change`,a.`changement`
    FROM  `".$prefixTable."tab_ticket_histo_change` a
    WHERE 1=1
    AND `id_toc` = :id
    ORDER BY a.`id` desc
    LIMIT 0 , 10 
;";

// On envois la requète
$req = $connection->prepare($strSql);
$req->bindValue(":id", $arrayValeur["id"], PDO::PARAM_INT);

if($req->execute()){
    // On indique que nous utiliserons les résultats en tant qu'objet
    $req->setFetchMode(PDO::FETCH_OBJ);

    // On transforme les résultats en tableaux d'objet
    $resultats = new stdClass();
    $resultats->data = $req->fetchAll(PDO::FETCH_OBJ);
    $resultats->nombre = count($resultats->data);
    
    foreach ($resultats->data as $k => $v) {  
        $commentaire = $v->changement;

        $match_commentaire = array();
        preg_match_all("/[0-9]+/", $commentaire, $match_commentaire); 

        $split_commentaire = array();
        $split_commentaire = preg_split("/[0-9]+/", $commentaire); 
        
        $new_commentaire = "";
        foreach ($split_commentaire as $k0 => $v0) {
            $new_commentaire .= $v0;
            if(!empty($match_commentaire[0])){
                if(!empty($match_commentaire[0][$k0])){
                    $tmp = $match_commentaire[0][$k0];
                    
                    if(strpos($commentaire, 'Affectation') == FALSE){
                        if(!empty($array_tags[$match_commentaire[0][$k0]])){
                            $tmp = $array_tags[$match_commentaire[0][$k0]];
                        }
                    }  else {
                        if(!empty($array_users[$match_commentaire[0][$k0]])){
                            $tmp = $array_users[$match_commentaire[0][$k0]];
                        }
                    }
                    
                    $new_commentaire .= $tmp;
                }
            }
        }
        
        $v->changement = $new_commentaire;
    }

    $object_retour->data["resultat"] = $resultats;
}else{
    $error = 'Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")";
    $object_retour->strErreur = $error;
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