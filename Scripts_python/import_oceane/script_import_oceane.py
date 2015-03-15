import sys
import os
import json
import urllib.request
from pprint import pprint
import datetime
from datetime import timedelta
import mysql.connector
import csv
import codecs

import MyLogger
import MyLib

#Déclaration
arguments = dict() #dict
i = 0 #Int
config_json = {} #Json
statusSupervision = "OK"

#Procedure chargement du fichier config JSON
def charger_config() :
    global config_json
    try:
        MyLogger.logger.debug("Début chargement configuration")
        config=codecs.open(arguments["param"], 'r','utf-8')
        config_json = json.load(config)
        MyLogger.logger.debug("Chargement configuration réussi")
    except ValueError as exc:
        MyLogger.logger.error("Erreur pendant le chargement du fichier de configuration : " + arguments["param"])
        sys.exit("Erreur")

#importe un obj
def import_url(p_url, p_file_out, p_table) :
    try:
        #En prod oui
        #proxies = {'http': 'http://fr-proxy.groupinfra.com:3128'}
        #opener = urllib.request.FancyURLopener(proxies)
        opener = urllib.request.FancyURLopener({})
        response = opener.open(p_url)
        page = response.read().decode('utf-8')

        fo = open(config_json["parameters"]["path"]+p_file_out, "wb")
        fo.write(page.encode('utf-8'))
        fo.close()

        MyLogger.logger.debug("Création du fichier : "+p_file_out+", réussi")

        cnx = mysql.connector.connect(user=config_json["config_db_integration"]["db"], database=config_json["config_db_integration"]["db"], password=config_json["config_db_integration"]["mdp"], host=config_json["config_db_integration"]["host"])
        cur = cnx.cursor(buffered=True)

        with open(config_json["parameters"]["path"]+p_file_out, encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile, delimiter=',', quotechar='"')
            headers = reader.__next__()

            sql = "DROP TABLE `rec_"+p_table+"`"
            try:
                cur.execute(sql)
            except mysql.connector.Error as err:
                MyLogger.logger.error("Erreur : "+format(err))
                MyLogger.logger.debug("SQL : "+sql)
                    
            retour = cur.fetchone()
            if(retour is not None):
                MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)

            sql = "CREATE TABLE `rec_"+p_table+"` (`id` int(11) NOT NULL AUTO_INCREMENT,"

            for header in headers:
                sql += "`"+header.replace("'", "\\'")+"` varchar(255),"
                    
            sql += "`dateTime_record` datetime, PRIMARY KEY (`id`));"

            try:
                cur.execute(sql)
            except mysql.connector.Error as err:
                MyLogger.logger.error("Erreur : "+format(err))
                MyLogger.logger.debug("SQL : "+sql)

            retour = cur.fetchone()
            if(retour is not None):
                MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)

            nb_ligne_succes = 0
            nb_ligne_warning = 0
            nb_ligne_erreur = 0
                
            for rows in reader:
                sql = "INSERT INTO `rec_"+p_table+"` ("
                for header in headers:
                    sql += "`"+header.replace("'", "\\'")+"`,"
                sql += "`id`, `dateTime_record`) VALUES ("
                for row in rows:
                    sql += "'"+row.replace("'", "\\'")+"',"
                sql += "NULL,NOW());"

                try:
                    cur.execute(sql)
                except mysql.connector.Error as err:
                    MyLogger.logger.error("Erreur : "+format(err))
                    MyLogger.logger.debug("SQL : "+sql)
                    nb_ligne_erreur += 1

                retour = cur.fetchone()
                if(retour is not None):
                    MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)
                    nb_ligne_warning += 1
                else :
                    nb_ligne_succes += 1

            cnx.commit()

        cnx.close()
            
        MyLogger.logger.debug("Importation réussi ("+str(nb_ligne_succes)+" lignes succées, "+str(nb_ligne_warning)+" lignes warning, "+str(nb_ligne_erreur)+", lignes erreur)")

        os.rename(config_json["parameters"]["path"]+p_file_out, config_json["parameters"]["path"]+"Archives/"+p_file_out)
        
        #supervision
        if nb_ligne_succes == 0 :
            statusSupervision = "WARNING"
        
        cnx_ring = mysql.connector.connect(user=config_json["config_db_supervision"]["db"], database=config_json["config_db_supervision"]["db"], password=config_json["config_db_supervision"]["mdp"], host=config_json["config_db_supervision"]["host"])
        cur_ring = cnx_ring.cursor(buffered=True)
        sql = "INSERT INTO `tab_log` (`id` ,`dateTime` ,`type` ,`commentaires`) VALUES (NULL ,  NOW(),  "+config_json["parameters"]["type_log"]+",  '[INFO][Etape:Importation][fichier:"+p_file_out+"][nb_ligne_succes:"+str(nb_ligne_succes)+"][nb_ligne_warning:"+str(nb_ligne_warning)+"][nb_ligne_erreur:"+str(nb_ligne_erreur)+"]Synchro Brise-NOA');"
        try:
            cur_ring.execute(sql)
            cnx_ring.commit()
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)   
        cnx_ring.close()
        
    except Exception as e:
        MyLogger.logger.error("Erreur pendant import_url : ("+format(e)+")")
        sys.exit("Erreur")

#Procedure Mise à jour
def importer() :
    global config_json
    try:
        MyLogger.logger.debug("Début importation")

        #supervision
        cnx_ring = mysql.connector.connect(user=config_json["config_db_supervision"]["db"], database=config_json["config_db_supervision"]["db"], password=config_json["config_db_supervision"]["mdp"], host=config_json["config_db_supervision"]["host"])
        cur_ring = cnx_ring.cursor(buffered=True)
        sql = "INSERT INTO `tab_log` (`id` ,`dateTime` ,`type` ,`commentaires`) VALUES (NULL ,  NOW(),  "+config_json["parameters"]["type_log"]+",  '[INFO][Etape:start]Synchro Brise-NOA');"
        try:
            cur_ring.execute(sql)
            cnx_ring.commit()
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)       
        cnx_ring.close()

        now = datetime.datetime.now()
        dateTime = now.strftime("%y%m%d_%H%M")
        datTimSemDerniere = datetime.datetime.now()-timedelta(days=7)
        strSemDerniere = datTimSemDerniere.strftime("%Y-%m-%d")

        for objs in config_json["config_brise"]:
            url = config_json["config_brise"][objs]
            name_file_out = "data_"+objs+"_"+dateTime+".csv"
            MyLogger.logger.debug("Objet à importer : "+objs)
            MyLogger.logger.debug("Url de l'objet : "+url)
            MyLogger.logger.debug("Fichier de sortie : "+name_file_out)

            import_url(url, name_file_out, objs)

        cnx = mysql.connector.connect(user=config_json["config_db_integration"]["db"], database=config_json["config_db_integration"]["db"], password=config_json["config_db_integration"]["mdp"], host=config_json["config_db_integration"]["host"])
        cur = cnx.cursor(buffered=True)

        MyLogger.logger.debug("Chargement des données")
        
        sql = "SELECT charger_data_oceane('');"
        try:
            cur.execute(sql)
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)
                
        retour = cur.fetchone()
        if(retour[0] is not 1):
            MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)

        MyLogger.logger.debug("Chargement des données réussi")

        #Merge des tickets debut
        MyLogger.logger.debug("Merge des tickets")
        
        sql = "select merge_tickets('');"
        try:
            cur.execute(sql)
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)
                
        retour = cur.fetchone()
        if(retour[0] is not 1):
            MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)

        cnx.commit()    

        MyLogger.logger.debug("Merge des tickets réussi")
        #Merge des tickets fin

        #synchro oceane debut
        MyLogger.logger.debug("Synchronisation Oceane")
        
        sql = "select synchro_oceane('"+strSemDerniere+"');"
        MyLogger.logger.debug("Lancement du SQL : "+ sql)
        try:
            cur.execute(sql)
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)
                
        retour = cur.fetchone()
        if(retour[0] is not 1):
            MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)

        sql = "select synchro_oceane_sta_vr('"+strSemDerniere+"');"
        MyLogger.logger.debug("Lancement du SQL : "+ sql)
        try:
            cur.execute(sql)
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)
                
        retour = cur.fetchone()
        if(retour[0] is not 1):
            MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)

        cnx.commit()        

        MyLogger.logger.debug("Synchronisation Oceane réussi")
        #synchro oceane fin
        
        cnx.close()

        #supervision
        cnx_ring = mysql.connector.connect(user=config_json["config_db_supervision"]["db"], database=config_json["config_db_supervision"]["db"], password=config_json["config_db_supervision"]["mdp"], host=config_json["config_db_supervision"]["host"])
        cur_ring = cnx_ring.cursor(buffered=True)
        sql = "INSERT INTO `tab_log` (`id` ,`dateTime` ,`type` ,`commentaires`) VALUES (NULL ,  NOW(),  "+config_json["parameters"]["type_log"]+",  '[INFO][Etape:fin][Statut:"+statusSupervision+"]Synchro Brise-NOA');"
        try:
            cur_ring.execute(sql)
            cnx_ring.commit()
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)   
        cnx_ring.close()
        
    except Exception as e:
        MyLogger.logger.error("Erreur pendant importer : ("+format(e)+")")
        #supervision
        cnx_ring = mysql.connector.connect(user=config_json["config_db_supervision"]["db"], database=config_json["config_db_supervision"]["db"], password=config_json["config_db_supervision"]["mdp"], host=config_json["config_db_supervision"]["host"])
        cur_ring = cnx_ring.cursor(buffered=True)
        sql = "INSERT INTO `tab_log` (`id` ,`dateTime` ,`type` ,`commentaires`) VALUES (NULL ,  NOW(),  "+config_json["parameters"]["type_log"]+",  '[INFO][Etape:fin][Statut:KO]Synchro Brise-NOA');"
        try:
            cur_ring.execute(sql)
            cnx_ring.commit()
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)   
        cnx_ring.close()
        sys.exit("Erreur")

#Procedure Say More
def more() :
    MyLogger.logger.info("Les options disponible sont : 'importer'.")
    MyLogger.logger.info("Exemple de syntax pour 'decode' : 'python script_import_oceane.py exemple.config.api.oda_noa.json importer'.")
    MyLogger.logger.info("Exemple de syntax pour 'more' : 'python script_import_oceane.py more'.")
    

#Message de bienvenu.
MyLogger.logger.info ("Bienvenue dans le script d'importation des tickets Océnane.")

#Récupération des arguments.
for x in sys.argv :
    i += 1
    if i == 2 :
        arguments["param"] = x
    elif i == 3 :
        arguments["action"] = x
        if x not in ["importer"] :
            MyLogger.logger.warning("Votre premier argument ("+x+") est incorrect, seul 'importer' sont aurorisés.")
            sys.exit("Erreur")
        else :
            MyLogger.logger.info("Mode d'action choisi : "+x+".")
            arguments["action"] = x
            
    if len(arguments) == 0 :
        arguments["action"] = "more"

#Affichage        
if arguments["action"] == "importer" :
    charger_config()
    importer()
elif arguments["action"] == "more" :
    more()

#Message de fin.
MyLogger.logger.info ("Fin du script.")
sys.exit(0)

    
