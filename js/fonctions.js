///////////////////
//BLOCK VARIABLE GLOBAL
///////////////////

///////////////////
//BLOCK FONCTIONS 
///////////////////
/**
 * Ajouter les params par defaut
 * 
 * 
 * @param {type} p_input
 * @returns {buildFiltresTickets.filtre_defaut}
 */ 
function buildFiltresTickets(p_input) {
    try {
        var filtre_defaut = {
          core_id : "",   
          core_auteur : "",
          core_auteur_option : "notList", 
          core_dateTime_creation : "",
          core_dateTime_creation_option : "", 
          core_dateTime_modification : "",
          core_dateTime_modification_option : "", 
          core_nature : "",
          core_nature_option : "notList", 
          core_categorie : "",
          core_categorie_option : "notList",
          core_sous_categorie : "",
          core_sous_categorie_option : "notList",
          core_priorite : "",
          core_priorite_option : "notList",
          core_criticite : "",
          core_criticite_option : "notList",
          core_statut : "",
          core_statut_option : "notList",
          core_causes_tags : "",
          core_causes_tags_option : "notList",
          core_impacts_tags : "",
          core_impacts_tags_option : "notList",
          core_repro_tags : "",
          core_repro_tags_option : "notList",
          core_reso_tags : "",
          core_reso_tags_option : "notList",
          core_complexite : "",
          core_complexite_option : "notList",
          core_env_ori : "",
          core_env_ori_option : "notList",
          core_env_dest: "",
          core_env_dest_option : "notList",
          core_respon : "",
          core_respon_option : "notList",
          core_label : "",
          core_description : "",
          core_relations : "",
          core_relations_option : "notList",
          core_version : "",
          vue_respon : "",
          vue_version : "",
          vue_categorie : ""
        };

        for(indice in p_input){
            filtre_defaut[indice] = p_input[indice];
        }

        return filtre_defaut;
    } catch (er) {
        log(0, "ERROR(chargerTickets):" + er.message);
    }
}

/**
 * @name buildParams
 * @param {type} p_input
 * @returns {String}
 */
function buildParams(p_input) {
    try {
        var strParams = "";

        for(indice in p_input){
            strParams += "&"+indice+"="+p_input[indice];
        }

        return strParams;
    } catch (er) {
        log(0, "ERROR(buildParams):" + er.message);
    }
}

/**
 * @name change_vide
 * @param {type} p_obj
 * @param {type} p_indice
 * @param {type} p_key
 * @returns {String}
 */
function change_vide(p_obj, p_indice, p_key){
    try {
        var str_retour = "N.A.";
        
        if(typeof p_obj == "undefined"){
            return str_retour;
        } else if (typeof p_obj == "object") {
            try{
                return p_obj[p_indice][p_key];
            } catch (er){
                return str_retour;
            }
        } else {
            switch (p_obj) 
            { 
                case "": 
                    return str_retour; 
                break; 
                case "00/00/0000 00:00:00": 
                    return str_retour; 
                break; 
                default: 
                    return p_obj;
                break; 
            }
        }
    } catch (er) {
        log(0, "ERROR(change_vide):" + er.message);
    }
}

/**
 * Charge tous les tags 
 */
function chargerTags() {
    try {
        var tabInput = { id_type_tag : '' };
        var retour_json = callBD("phpsql/mysql_getTags.php", "POST", "json", tabInput);
        g_tags = retour_json["data"]["resultat"]["data"];
    } catch (er) {
        log(0, "ERROR(chargerTags):" + er.message);
    }
}

/**
 * 
 * @param {type} p_strDateUs 2013-06-01 08:08:00
 * @returns {undefined} 1996-12-19T16:39
 */
function getDateTfromDateUs(p_strDateUs){
try {
        var str_retour = "";
        
        str_retour = p_strDateUs.replace(' ', 'T');
        //str_retour = str_retour.substring(0,(str_retour.length-3));
        
        return str_retour;
    }
    catch (er) {
        log(0, "ERROR(getDateTfromDateUs):" + er.message);
    }
}

/**
 * getShortStrDateTimeFrFromUs
 * @param {String} p_strDateTime
 * @returns {String}
 */
function getShortStrDateTimeFrFromUs(p_strDateTime) {
    try {
        var strDate = "";
        
        strDate = p_strDateTime.substr(8,2) + "/" + p_strDateTime.substr(5,2) + "/" + p_strDateTime.substr(2,2) + " " + p_strDateTime.substr(10,(p_strDateTime.length - 10)); 
        
        return strDate;
    } catch (er) {
        log(0, "ERROR(getStrDateFrFromUs):" + er.message);
        return null;
    }
}

/**
 * getShortStrDateTimeFrFromUs
 * @param {String} p_strDateTime
 * @returns {String}
 */
function getTagsByType(p_list_tags, p_id_type) {
    try {
        var array = new Array();
        
        for(var indice in p_list_tags){
            var id_type_tag = parseInt(p_list_tags[indice]["id_type_tag"]);
            var id_type = parseInt(p_id_type);
            if(id_type_tag == id_type){
                array[array.length] =  p_list_tags[indice];
            }
        }
        
        return array;
    } catch (er) {
        log(0, "ERROR(getTagsByType):" + er.message);
        return null;
    }
}

/**
 * Traduit un id
 * 
 * @param {String} p_id
 * @param {String} p_type
 * @returns {String}
 */
function tradId(p_id, p_type) {
    try {
        var strRetour = "";

        if(p_type == "tag"){
            for(var indice in g_tags){
                if(g_tags[indice]["id"] == p_id){
                    strRetour =  g_tags[indice]["label"];
                    break;
                }
            }
        }

        return strRetour;
    } catch (er) {
        log(0, "ERROR(tradId):" + er.message);
        return null;
    }
}

