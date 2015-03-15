import sys
import os
import json
import urllib.request
from pprint import pprint
import datetime
import mysql.connector
import csv
import codecs

import MyLogger
import MyLib

#Déclaration
arguments = dict() #dict
i = 0 #Int
config_json = {} #Json

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
def import_url(p_file, p_table) :
    
    cnx = mysql.connector.connect(user='db_oda_noa', database='db_oda_noa', password='odanoapass01', host='10.85.32.5')
    cur = cnx.cursor(buffered=True)

    with open(p_file, encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile, delimiter=';', quotechar='"')
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

        print("")
        print(headers)

##        for header in headers:
##            sql += "`"+row+"` varchar(255),"
##                
##        sql += "`dateTime_record` datetime, PRIMARY KEY (`id`));"
##
##        try:
##            cur.execute(sql)
##        except mysql.connector.Error as err:
##            MyLogger.logger.error("Erreur : "+format(err))
##            MyLogger.logger.debug("SQL : "+sql)
##
##        retour = cur.fetchone()
##        if(retour is not None):
##            MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)

        nb_ligne_succes = 0
        nb_ligne_warning = 0
        nb_ligne_erreur = 0
            
        for rows in reader:
            print("")
            print(rows)
##            sql = "INSERT INTO `rec_"+p_table+"` ("
##            for header in headers:
##                sql += "`"+header.replace("'", "\\'")+"`,"
##            sql += "`id`, `dateTime_record`) VALUES ("
##            for row in rows:
##                sql += "'"+row.replace("'", "\\'")+"',"
##            sql += "NULL,NOW());"
##            
##            try:
##                cur.execute(sql)
##            except mysql.connector.Error as err:
##                MyLogger.logger.error("Erreur : "+format(err))
##                MyLogger.logger.debug("SQL : "+sql)
##                nb_ligne_erreur += 1
##
##            retour = cur.fetchone()
##            if(retour is not None):
##                MyLogger.logger.warning("Retour : "+retour+", SQL : "+sql)
##                nb_ligne_warning += 1
##            else :
##                nb_ligne_succes += 1

        cnx.commit()

    cnx.close()
        
    MyLogger.logger.debug("Importation réussi ("+str(nb_ligne_succes)+" lignes succées, "+str(nb_ligne_warning)+" lignes warning, "+str(nb_ligne_erreur)+", lignes erreur)")

    now = datetime.datetime.now()
    dateTime = now.strftime("%y%m%d_%H%M")

    os.rename(p_file, "Archives/data_"+p_table+"_"+dateTime+".csv")

#Procedure Mise à jour
def importer() :
    global config_json
    try:
        MyLogger.logger.debug("Début importation")

        for objs in config_json["config_automate"]:
            csv = config_json["config_automate"][objs]
            name_file = "data_"+objs+".csv"
            MyLogger.logger.debug("Objet à importer : "+objs)
            MyLogger.logger.debug("Csv de l'objet à importer : "+csv)

            import_url(name_file, objs)

        MyLogger.logger.debug("Chargement des données réussi")
        
    except Exception as exc:
        MyLogger.logger.error("Erreur ("+format(exc)+")")
        sys.exit("Erreur")

#Procedure Say More
def more() :
    MyLogger.logger.info("Les options disponible sont : 'importer'.")
    MyLogger.logger.info("Exemple de syntax pour 'decode' : 'python script_import_automate.py exemple.config.api.oda_noa.json importer'.")
    MyLogger.logger.info("Exemple de syntax pour 'more' : 'python script_import_automate.py more'.")
    

#Message de bienvenu.
MyLogger.logger.info ("Bienvenue dans le script d'importation des tickets automate.")

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

    
