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

//Définition des entrants
$arrayInput = array(
    "id" => null,
    "id_type" => null,
    "code_user" => null
);

//Récupération des entrants
$arrayValeur = recupInput($arrayInput);

//Object retour minima
// $object_retour->strErreur string
// $object_retour->data  string
// $object_retour->statut  string

//init retour
$retour_array = array(
    'code' => null,
    'message' => null,
    'id_pj' => null
);

//Init traitement
$dossier = '../pjs/';
$fichier = basename($_FILES['file-0']['name']);
//On formate le nom du fichier ici...
$fichier_format = strtr($fichier, 
     'ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðòóôõöùúûüýÿ$&#%!§', 
     'AAAAAACEEEEIIIIOOOOOUUUUYaaaaaaceeeeiiiioooooouuuuyy------');
$fichier_format = preg_replace('/([^.a-z0-9]+)/i', '-', $fichier_format);
$fichier_format = addslashes($fichier_format);
$taille_maxi = 500000;
$taille = filesize($_FILES['file-0']['tmp_name']);
$extensions = array('.jpg','.png','.txt','.doc','.docx','.xls','.xlsx','.msg','.pdf');
$extension = strrchr($_FILES['file-0']['name'], '.'); 
$extension = strtolower($extension);

//Vérification extension
if(!in_array($extension, $extensions)) //Si l'extension n'est pas dans le tableau
{
    $retour_array['code'] = 'ko';
    $retour_array['message'] = 'Mauvais format de fichier (.jpg,.png,.txt,.doc,.docx,.xls,.xlsx,.msg,.pdf).';
}

//Vérification taille
if($taille>$taille_maxi)
{
    $retour_array['code'] = 'ko';
    $retour_array['message'] = 'Le fichier est trop gros 500ko max.'; 
}

//Si tj ok on trait(e
if(!isset($retour_array['code'])) //S'il n'y a pas d'erreur, on upload
{
    //Ajoute la PJ en base
    $strSql = "INSERT INTO `".$prefixTable."tab_pjs`
       (`id`, `id_toc`, `id_type`, `label`, `actif`, `dateTime_creation`, `auteur_creation`, `dateTime_modification`, `auteur_modification`)
       VALUES 
       (NULL, ".$arrayValeur['id'].", ".$arrayValeur['id_type'].", '".$fichier_format."', '1', NOW(), '".$arrayValeur['code_user']."', '', '');
    ;";
    $req = $connection->prepare($strSql);

    $max_id = "";
    if($req->execute()){
        $max_id = $connection->lastInsertId();  
    }else{
        die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
    }
    $req->closeCursor();

    //Upload le fichier
    $fichier_format_id = $max_id.'_'.$fichier_format;
    $path = $dossier . $fichier_format_id;
    if(move_uploaded_file($_FILES['file-0']['tmp_name'], $path)) //Si la fonction renvoie TRUE, c'est que ça a fonctionné...
    {
       $retour_array['code'] = 'ok';
       $retour_array['id_pj'] = $max_id;
       $details_array = array('message'=>'Upload effectue avec succes.','path'=>$path,'dossier'=>$dossier,'fichier'=>$fichier_format,'taille_maxi'=>$taille_maxi,'taille'=>$taille,'extensions'=>$extensions,'extension'=>$extension);
       $retour_array['message'] = $details_array; 

        //Valorise l'historique
        $message = "<ul>[Ticket Pièces Jointes][".$arrayValeur['id_type']."]<li>Ajout du fichier : ".$fichier_format."</li></ul>";
        $strSql = "select insert_histo('".$arrayValeur['id']."','".$arrayValeur['code_user']."','".$message."');";
        $req = $connection->prepare($strSql);
        $resultat = new stdClass();
        if($req->execute()){
            $resultat->statut = "ok"; 
        }else{
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();
    } else {
        $retour_array['code'] = 'ko';
        $details_array = array('message'=>'Echec de l upload.','path'=>$path,'dossier'=>$dossier,'fichier'=>$fichier_format,'taille_maxi'=>$taille_maxi,'taille'=>$taille,'extensions'=>$extensions,'extension'=>$extension);
        $retour_array['message'] = $details_array;

        //Retire de la base
        $strSql = "DELETE FROM `".$prefixTable."tab_pjs` WHERE `id` = ".$max_id.";";
        $req = $connection->prepare($strSql);
        $resultat = new stdClass();
        if($req->execute()){
            $resultat->statut = "ok"; 
        }else{
            die('Erreur SQL:'.print_r($req->errorInfo(), true)." (".$strSql.")");
        }
        $req->closeCursor();
    }
}

$object_retour->data = $retour_array;

//Cloture de l'interface
require("../API/php/footer.php");
?>