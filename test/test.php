<?php
//Config : Les informations personnels de l'instance (log, pass, etc)
require("../include/config.php");

//API Fonctions : les fonctions fournis de base par l'API
require("../API/php/fonctions.php");

//--------------------------------------------------------------------------
// On transforme les résultats en tableaux d'objet
$retours = array();

//Test Vérification getTickets
$retours[] = test("Vérification GetTickets",function() {
        global $domaine;
        
        $url = $domaine."phpsql/mysql_getTickets.php?milis=123450&ctrl=ok&core_id=1&core_dateTime_creation=2000-01-01%2000:00:01&core_dateTime_creation_option=AP";
        $page = file_get_contents($url);
        $resultats_json = json_decode($page);
        $attendu = 1;
        equal($resultats_json->data->resultat->nombre, $attendu, "Contrôle OK, avec vue personalisée");
    }         
);

//Test Recherche Ticket label
$retours[] = test("Recherche doublon de ticket sur label",function() {
        global $domaine;
        
        $url = $domaine."phpsql/checkDoublonLabelTicket.php?milis=123450&ctrl=ok";
        $page = file_get_contents($url);
        $resultats_json = json_decode($page);
        $attendu = 0;
        equal($resultats_json->data->resultat->nombre, $attendu, "Contrôle OK");
    }         
);

//Test Recherche Doublon Tag
$retours[] = test("Recherche doublon de tag",function() {
        global $domaine;
        
        $url = $domaine."phpsql/checkDoublonTag.php?milis=123450&ctrl=ok";
        $page = file_get_contents($url);
        $resultats_json = json_decode($page);
        $attendu = 0;
        equal($resultats_json->data->resultat->nombre, $attendu, "Contrôle OK");
    }         
);

//Test Recherche Doublon Note
$retours[] = test("Recherche doublon de note",function() {
        global $domaine;
        
        $url = $domaine."phpsql/checkDoublonNote.php?milis=123450&ctrl=ok";
        $page = file_get_contents($url);
        $resultats_json = json_decode($page);
        $attendu = 0;
        equal($resultats_json->data->resultat->nombre, $attendu, "Contrôle OK");
    }         
);

//Test Absence Statut
$retours[] = test("Recherche d'absence de statut",function() {
        global $domaine;
    
        $url = $domaine."phpsql/checkTicketSansTag.php?milis=123450&ctrl=ok&id_type=9";
        $page = file_get_contents($url);
        $resultats_json = json_decode($page);
        $attendu = 0;
        equal($resultats_json->data->resultat->nombre, $attendu, "Contrôle OK");
    }         
);

//Test Absence Nature
$retours[] = test("Recherche d'absence de nature",function() {
        global $domaine;
    
        $url = $domaine."phpsql/checkTicketSansTag.php?milis=123450&ctrl=ok&id_type=28";
        $page = file_get_contents($url);
        $resultats_json = json_decode($page);
        $attendu = 0;
        equal($resultats_json->data->resultat->nombre, $attendu, "Contrôle OK");
    }         
);



$resultats = new stdClass();
$resultats->details = $retours;
$resultats->succes = 0;
$resultats->echec = 0;
$resultats->total = 0;
foreach($retours as $key => $value) {
    $resultats->succes += $value->succes;
    $resultats->echec += $value->echec;
    $resultats->total += $value->total;
 }

//--------------------------------------------------------------------------
$resultats_json = json_encode($resultats);

$strSorti = $resultats_json;

print_r($strSorti);
?>