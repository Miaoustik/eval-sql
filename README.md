Réference étudiant: GDWFSCAUBDDEXAIII1B_296117_20221120181614

Base de données conçues pour MariaDB

Commande d’execution du fichier sql : mysql -u root -p -e 'source database.sql’

Commande d’export : mysqldump -u cinema -p cinemadb -r backup.sql

Commande d’insertion de l’export dans la BDD : mysql -u cinema -p cinemadb -e 'source backup.sql'