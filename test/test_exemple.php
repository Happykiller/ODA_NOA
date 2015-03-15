<?php
//Config : Les informations personnels de l'instance (log, pass, etc)
require("../include/config.php");

//API Fonctions : les fonctions fournis de base par l'API
require("../API/php/fonctions.php");

//--------------------------------------------------------------------------
// On transforme les résultats en tableaux d'objet
$retours = array();

//--------------------------------------------------------------------------
$retours[] = test("get_string_between",function() {
        $v_test = get_string_between("01234", "1", "3");
        equal($v_test, "2", "Test OK : Passed!");
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