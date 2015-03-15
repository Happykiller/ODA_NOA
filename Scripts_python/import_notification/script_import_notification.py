import sys
import os
import json
import datetime
import mysql.connector
import csv
import codecs
import re

array_tag = []

from html.parser import HTMLParser
class MyHTMLParser(HTMLParser):
    def handle_data(self, data):
        try:
            data = data.rstrip()
            data = data.lstrip()
            data.encode('utf8')
            if data is not "" :
                array_tag.append(data.replace('€',''))
        except Exception as e:
            MyLogger.logger.error("Erreur pendant l'importation ("+format(e)+")")

import MyLogger
import MyLib

#Déclaration
arguments = dict() #dict
i = 0 #Int
config_json = {} #Json
config_ticket = {} #Json

def get_tag(p_tag, p_array) :
    try:
        tag_debut = config_json["config_tag"][p_tag]["tag_debut"]
        longueur = int(config_json["config_tag"][p_tag]["longueur"])
        tag_partie = config_json["config_tag"][p_tag]["tag_partie"]
        tag_fin = config_json["config_tag"][p_tag]["tag_fin"]

        tag_out = ''

        #recherche par sub string
        if tag_partie is not '' :
            for tag in p_array :
                match = re.search(r''+tag_partie, tag)
                if match :
                    tag_out = tag.replace(tag_partie,'')
                    return tag_out

        #recherche par tag suivant
        gardien = False
        if (tag_debut is not '') and (longueur is not 0) :
            for tag in p_array :
                if gardien :
                    tag_out += tag
                    longueur -= 1
                    if longueur is 0 :
                        gardien = False
                match = re.search(r''+tag_debut, tag)
                if match :
                    gardien = True

        #recherche entre tag
        gardien = False
        if (tag_debut is not '') and (tag_fin is not '') :
            for tag in p_array :
                match = re.search(r''+tag_fin, tag)
                if match :
                    gardien = False

                if gardien :
                    tag_out += tag
                    
                match = re.search(r''+tag_debut, tag)
                if match :
                    gardien = True
        
        return tag_out
    except Exception as e:
        MyLogger.logger.error("Erreur pendant 'get_tag' : " + +format(e))
        
#Procedure chargement du fichier config JSON
def charger_config() :
    global config_json
    try:
        MyLogger.logger.debug("Début chargement configuration")
        config=codecs.open(arguments["param"], 'r','utf-8')
        config_json = json.load(config)
        MyLogger.logger.debug("Chargement configuration réussi")
    except Exception as e:
        MyLogger.logger.error("Erreur pendant le chargement du fichier de configuration ("+format(e)+")")
        sys.exit("Erreur")

#Procedure Mise à jour
def importer() :
    global config_json
    try:
        MyLogger.logger.debug("Début importation")

        now = datetime.datetime.now()
        dateTime = now.strftime("%y%m%d_%H%M")

        str_file_notif = config_json["config_notif"]["dir_notif"] + '/'+arguments["file_notif"]
        MyLogger.logger.debug("Lecture du fichier de notification : "+str_file_notif)

        # Ouverture du fichier source
        source=codecs.open(str_file_notif, 'r','utf-8')
        str_fichier = ""

        for lig in source.readlines():
            str_fichier += lig
   
        source.close()

        parser = MyHTMLParser()
        parser.feed(str_fichier)

        for tag in config_json["config_tag"] :
            str_tag = get_tag (tag, array_tag)
            config_ticket[tag] = str_tag

        cnx = mysql.connector.connect(user=config_json["config_db"]["db"], database=config_json["config_db"]["db"], password=config_json["config_db"]["mdp"], host=config_json["config_db"]["host"])
        cur = cnx.cursor(buffered=True)

        sql = "select creer_detail_notif('"+config_ticket['id_toc']+"','"+config_ticket['date_signal']+"','"+config_ticket['date_mail']+"','"+config_ticket['basicat']+"','"+config_ticket['eds_origine']+"','"+config_ticket['eds_destinataire']+"','"+config_ticket['criticite']+"','"+config_ticket['priorite']+"','"+config_ticket['commentaires'].replace("'","\\'")+"');"
        MyLogger.logger.debug("SQL : "+sql)
        try:
            cur.execute(sql)
        except mysql.connector.Error as err:
            MyLogger.logger.error("Erreur : "+format(err))
            MyLogger.logger.debug("SQL : "+sql)
            
        cnx.commit()
        cnx.close()

        str_file_notif_arch = config_json["config_notif"]["dir_notif"] + '/Archives/'+arguments["file_notif"]
        os.rename(str_file_notif, str_file_notif_arch)
        
    except Exception as e:
        MyLogger.logger.error("Erreur pendant l'importation ("+format(e)+")")
        sys.exit("Erreur")

#Procedure Say More
def more() :
    MyLogger.logger.info("Les options disponible sont : 'importer'.")
    MyLogger.logger.info("Exemple de syntax pour 'decode' : 'python script_import_notification.py exemple.config.api.oda_noa.json importer notification_20130722_174810.txt'.")
    MyLogger.logger.info("Exemple de syntax pour 'more' : 'python script_import_notification.py more'.")
    

#Message de bienvenu.
MyLogger.logger.info ("Bienvenue dans le script d'importation des notifications.")

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
    elif i == 4 :
        arguments["file_notif"] = x
            
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

    
