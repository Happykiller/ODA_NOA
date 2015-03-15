Convertir en UTF8 sans BOM

--Import rec_automate_tickets
LOAD DATA LOCAL INFILE  'D:\\FRO\\APP\\UploadDir/data_automate_ticket_Details.csv' REPLACE INTO TABLE  `rec_automate_ticket_Details` FIELDS TERMINATED BY ';' ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\r\n' IGNORE 1 LINES

--Import rec_automate_documents
LOAD DATA LOCAL INFILE  'D:\\FRO\\APP\\UploadDir/data_automate_ticket_Docs.csv' REPLACE INTO TABLE  `rec_automate_ticket_Docs` FIELDS TERMINATED BY  ';' ENCLOSED BY  '"' ESCAPED BY  '\\' LINES TERMINATED BY  '\r\n' IGNORE 1 LINES

--Import rec_automate_ticket_Liens
LOAD DATA LOCAL INFILE  'D:\\FRO\\APP\\UploadDir/data_automate_ticket_Liens.csv' REPLACE INTO TABLE  `rec_automate_ticket_Liens` FIELDS TERMINATED BY  ';' ENCLOSED BY  '"' ESCAPED BY  '\\' LINES TERMINATED BY  '\r\n' IGNORE 1 LINES

--Import rec_automate_ticket_Liens
LOAD DATA LOCAL INFILE  'D:\\FRO\\APP\\UploadDir/data_automate_ticket_Msgs.csv' REPLACE INTO TABLE  `rec_automate_ticket_Msgs` FIELDS TERMINATED BY  ';' ENCLOSED BY  '"' ESCAPED BY  '\\' LINES TERMINATED BY  '\r\n' IGNORE 1 LINES


--Import rec_automate_ticket_Liens
LOAD DATA LOCAL INFILE  'D:\\FRO\\APP\\UploadDir/data_automate_ticket_Statuts.csv' REPLACE INTO TABLE  `rec_automate_ticket_Statuts` FIELDS TERMINATED BY  ';' ENCLOSED BY  '"' ESCAPED BY  '\\' LINES TERMINATED BY  '\r\n' IGNORE 1 LINES
