test( "Vérification GetTickets", function() {
    var currentTime = new Date();
    currentTime.setDate(currentTime.getDate() - 365);
    var annee = currentTime.getFullYear();
    var mois = pad2(currentTime.getMonth()+1);
    var jour = pad2(currentTime.getDate());
    var strDateTime = annee+"-"+mois+"-"+jour+" 00:00:01";
    
    var tabInput = buildFiltresTickets({ core_dateTime_creation : strDateTime, 
        core_dateTime_creation_option : "AP"
    });
    var retour = callBD(domaine+"phpsql/mysql_getTickets.php", "POST", "json", tabInput);
    var boolTest = (parseInt(retour["data"]["resultat"]["nombre"]) > 0);
    equal( boolTest, true, "Contrôle OK" ); 
    
    var tabInput = buildFiltresTickets({ core_dateTime_creation : strDateTime,
        core_dateTime_creation_option : "AP",
        vue_respon : "true"
    });
    var retour = callBD(domaine+"phpsql/mysql_getTickets.php", "POST", "json", tabInput);
    var boolTest = (parseInt(retour["data"]["resultat"]["nombre"]) > 0);
    equal( boolTest, true, "Contrôle OK, avec vue personalisée" ); 
});

test( "Recherche doublon de ticket sur label", function() {

    var tabInput = {  };
    var retour = callBD(domaine+"phpsql/checkDoublonLabelTicket.php", "POST", "json", tabInput);
    var attendu = 0;
    equal( retour["data"]["resultat"]["nombre"], attendu, "Contrôle OK" ); 
  
});

test( "Recherche doublon de tag", function() {

    var tabInput = {  };
    var retour = callBD(domaine+"phpsql/checkDoublonTag.php", "POST", "json", tabInput);
    var attendu = 0;
    equal( retour["data"]["resultat"]["nombre"], attendu, "Contrôle OK" ); 
  
});

test( "Recherche doublon de note", function() {

    var tabInput = {  };
    var retour = callBD(domaine+"phpsql/checkDoublonNote.php", "POST", "json", tabInput);
    var attendu = 0;
    equal( retour["data"]["resultat"]["nombre"], attendu, "Contrôle OK" ); 
  
});

test( "Recherche d'absence de statut", function() {

    var tabInput = { id_type : 9 };
    var retour = callBD(domaine+"phpsql/checkTicketSansTag.php", "POST", "json", tabInput);
    var attendu = 0;
    equal( retour["data"]["resultat"]["nombre"], attendu, "Contrôle OK" ); 
  
});

test( "Recherche d'absence de nature", function() {

    var tabInput = { id_type : 28 };
    var retour = callBD(domaine+"phpsql/checkTicketSansTag.php", "POST", "json", tabInput);
    var attendu = 0;
    equal( retour["data"]["resultat"]["nombre"], attendu, "Contrôle OK" ); 
  
});