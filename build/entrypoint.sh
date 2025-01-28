#!/bin/bash

if [ -z "$PGADMIN_SERVER_JSON_FILE" ]; then
    export PGADMIN_SERVER_JSON_FILE="/tmp/servers.json"
fi

if [ ! -f "$PGADMIN_SERVER_JSON_FILE" ]; then

    # Initialisation du fichier JSON avec l'en-tête
    echo -e '{\n    "Servers": {' > "$PGADMIN_SERVER_JSON_FILE" 

    # Initialisation du compteur
    i=1
    first_entry=true

    while true; do
        # Gestion du suffixe
        if [ $i -eq 1 ]; then
            sfx=""
        else
            sfx=$i
        fi

        # Récupération des variables d'environnement
        name="SETUP_SERVER${sfx}_NAME"
        host="SETUP_SERVER${sfx}_HOST"
        port="SETUP_SERVER${sfx}_PORT"
        user="SETUP_SERVER${sfx}_USER"
        pass="SETUP_SERVER${sfx}_PASS"

        # Vérification de l'existence des variables requises
        if [ -z "${!name}" ] || [ -z "${!host}" ] || [ -z "${!port}" ] || [ -z "${!user}" ]; then
            break
        fi

        # Ajout de la virgule si ce n'est pas la première entrée
        if [ "$first_entry" = true ]; then
            first_entry=false
        else
            echo "        ," >> "$PGADMIN_SERVER_JSON_FILE"
        fi

        # Écriture de l'entrée du serveur
        cat >> "$PGADMIN_SERVER_JSON_FILE" << EOL
        "$i": {
            "Name": "${!name}"
          , "Group": 1
          , "Port": ${!port}
          , "Username": "${!user}"
          , "Host": "${!host}"
          , "SSLMode": "prefer"
          , "MaintenanceDB": "postgres"
          , "ConnectionParameters": {
                "SSLMode": "prefer"
EOL

        # Ajout du mot de passe s'il existe
        if [ ! -z "${!pass}" ]; then
            echo "${!host}:${!port}:postgres:${!user}:${!pass}" >> /tmp/pgpass
            chmod 600 /tmp/pgpass
            cat >> "$PGADMIN_SERVER_JSON_FILE" << EOL
              , "PassFile": "/tmp/pgpass"
EOL
        fi

        # Fermeture de l'objet serveur
        echo -e "            }\n        }" >> "$PGADMIN_SERVER_JSON_FILE" 

        # Incrémentation du compteur
        ((i++))
    done

    # Fermeture du fichier JSON
    echo -e '    }\n}' >> "$PGADMIN_SERVER_JSON_FILE"

fi

exec /entrypoint-pgadmin4.sh "$@"
