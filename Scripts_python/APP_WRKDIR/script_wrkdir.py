import sys
import os
import json
import datetime
import codecs
import urllib.request
import datetime

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
    except Exception as e:
        MyLogger.logger.error("Erreur pendant le chargement du fichier de configuration ("+format(e)+")")
        sys.exit("Erreur")

#Procedure Mise à jour
def build() :
    global config_json
    try:
        now = datetime.datetime.now()
        dateTime = now.strftime("%y%m%d_%H%M")
        
        MyLogger.logger.debug("Début build")

        #Récupère le label si pas en param
        if "label" not in arguments :
            arguments["label"] = input('Entrer le nom du ticket : ').strip()
            
        MyLogger.logger.debug(arguments["label"])

        try:
            #Récupére les informations
            opener = urllib.request.FancyURLopener({})

            strUrl = config_json["instance"]+"/phpsql/mysql_getTicketDetailsForWrkdir.php?milis=123450&ctrl=ok&label="+arguments["label"]
            MyLogger.logger.debug(strUrl)
            
            response = opener.open(strUrl)
            page = response.read().decode('utf-8')

            fichierData = "Archives/infos_"+arguments["label"]+"_"+dateTime+".json"
            fo = open(fichierData, "wb")
            fo.write(page.encode('utf-8'))
            fo.close()

            #Chargement des infos
            fichier=codecs.open(fichierData, 'r','utf-8')
            infos_json = json.load(fichier)

            #construction du repertoire de travail
            path_dir = config_json["config"]["path_dir_items"] + "Item " + str(config_json["compteur"]) + " - " + arguments["label"] + " - " + infos_json["data"]["description"]
            MyLogger.logger.debug(path_dir)

            os.mkdir(path_dir)

            #construction du rfichier de travail
            strContenu =  "/*********************************/ \r\n"
            strContenu += "/***   "+arguments["label"]+"   ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "Lien oceane : http://oceane-sav2000.vente.francetelecom.fr/binoceane/defaultPopup.asp?COOKIENAME=ticketOceane&PAGEPOPUP=/binoceane/FR/Ticket/Detail/Affichage/FrameTic.asp%3FITEM%3D"+arguments["label"]+"%26BLNGESTIONDROIT%3DFALSE%26ARCHIVE%3D0%26COOKIENAME%3DticketOceane&PAGE_REFERER=/binoceane/FR/BodyMnuGen.asp&NUMFEN=1  \r\n"
            strContenu += "Lien NOA : "+config_json["instance"]+"/page_ticket.html?id="+infos_json["data"]["id"]+" \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Informations           ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "Description : "+infos_json["data"]["description_long"]+" \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Analyse                ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Action                 ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Causes                 ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Conclusion             ****/ \r\n"
            strContenu += "/*********************************/ \r\n"

            fichierItem = path_dir + "/item_" + str(config_json["compteur"]) + "_" + arguments["label"]+"_"+dateTime+".sql"
            MyLogger.logger.debug(fichierItem)
            fo = open(fichierItem, "wb")
            fo.write(strContenu.encode('utf-8'))
            fo.close()
        except Exception as e:
            MyLogger.logger.error("Erreur pendant contruction du sandbox ("+format(e)+")")
            #construction du repertoire de travail
            path_dir = config_json["config"]["path_dir_items"] + "Item " + str(config_json["compteur"]) + " - " + arguments["label"]
            MyLogger.logger.debug(path_dir)

            os.mkdir(path_dir)

            #construction du rfichier de travail
            strContenu =  "/*********************************/ \r\n"
            strContenu += "/***   "+arguments["label"]+"   ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "Lien oceane : http://oceane-sav2000.vente.francetelecom.fr/binoceane/defaultPopup.asp?COOKIENAME=ticketOceane&PAGEPOPUP=/binoceane/FR/Ticket/Detail/Affichage/FrameTic.asp%3FITEM%3D"+arguments["label"]+"%26BLNGESTIONDROIT%3DFALSE%26ARCHIVE%3D0%26COOKIENAME%3DticketOceane&PAGE_REFERER=/binoceane/FR/BodyMnuGen.asp&NUMFEN=1  \r\n"
            strContenu += "Lien NOA : "+config_json["instance"]+"/ODA_NOA/page_ticket.html?id= \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Informations           ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "Description : \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Analyse                ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Action                 ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Causes                 ****/ \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += " \r\n"
            strContenu += "/*********************************/ \r\n"
            strContenu += "/***   Conclusion             ****/ \r\n"
            strContenu += "/*********************************/ \r\n"

            fichierItem = path_dir + "/item_" + str(config_json["compteur"]) + "_" + arguments["label"]+"_"+dateTime+".sql"
            MyLogger.logger.debug(fichierItem)
            fo = open(fichierItem, "wb")
            fo.write(strContenu.encode('utf-8'))
            fo.close()
            

        #Maj du compteur et réécriture du fichier de conf
        config_json["compteur"] += 1 
        with open(arguments["param"], 'w') as outfile:
          json.dump(config_json, outfile)
        
        MyLogger.logger.debug("Fin build")
    except Exception as e:
        MyLogger.logger.error("Erreur pendant build ("+format(e)+")")
        sys.exit()

#Procedure Say More
def more() :
    MyLogger.logger.info("Les options disponible sont : 'build'.")
    MyLogger.logger.info("Exemple de syntax pour 'decode' : 'python script_wrkdir.py exemple.config.wrkdir.json build 1308760679'.")
    MyLogger.logger.info("Exemple de syntax pour 'more' : 'python script_wrkdir.py more'.")
    

#Message de bienvenu.
MyLogger.logger.info ("Bienvenue dans le script de construction des dossiers de travails.")

#Récupération des arguments.
for x in sys.argv :
    i += 1
    if i == 2 :
        arguments["param"] = x
    elif i == 3 :
        arguments["action"] = x
        if x not in ["build"] :
            MyLogger.logger.warning("Votre premier argument ("+x+") est incorrect, seul 'build' sont aurorisés.")
            sys.exit("Erreur")
        else :
            MyLogger.logger.info("Mode d'action choisi : "+x+".")
            arguments["action"] = x
    elif i == 4 :
        arguments["label"] = x
            
    if len(arguments) == 0 :
        arguments["action"] = "more"

#Affichage        
if arguments["action"] == "build" :
    charger_config()
    build()
elif arguments["action"] == "more" :
    more()

#Message de fin.
MyLogger.logger.info ("Fin du script.")
sys.exit(0)

    
