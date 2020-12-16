#!/usr/bin/env bash


ACTOPT="$( echo ${1:-'usage'} | tr 'A-Z' 'a-z')"

WRKROOT="$PWD"
CONFDIR="${WRKROOT}/conf"
SCRIPTDIR="${WRKROOT}/Scripts"
PLEROMA_CONF_DIR="${WRKROOT}/pleroma_config"
UPDIR="${WRKROOT}/uploads"
PGDIR="${WRKROOT}/postgres"
ARCDIR="${WRKROOT}/export"

. "${SCRIPTDIR}/util.sh"
. "${CONFDIR}/env.sh"

show_usage(){
    echo "+============================================================+"
    echo "| ./run.sh [opts]                                            |"
    echo "|    opts:                                                   |"
    echo "|       usage            : Show this information.            |"
    echo "|       install_docker   : Install Docker CE packages.       |"
    echo "|       prepare          : Install basic packages.           |"
    echo "|       build_image      : Build docker image.               |"
    echo "|       setup_firewall   : Setup firewall rules.             |"
    echo "|       run              : Launch a pleroma instance.        |"
    echo "|       update           : Update pleroma software.          |"
    echo "|       get_cert         : Get a SSL certificate.            |"
    echo "|       renew_cert       : Renew a SSL certificate.          |"
    echo "|       check_cert       : Show expire date of certificate.  |"
    echo "|       export_data      : Export custom data of pleroma.    |"
    echo "|       import_database  : Import old pleroma database data. |"
    echo "+============================================================+"
    exit 0
}


function prepare_scripts {
    test -d "${UPDIR}" || mkdir -p "${UPDIR}"
    sudo chown -R ${PUID}:${PGID} "${UPDIR}"

    test -d "${PGDIR}" || mkdir -p "${PGDIR}"

    test -d "${ARCDIR}" || mkdir -p "${ARCDIR}"


    sed -i 's#\(\s*server_name\s\+\)DOMAIN\(.*\)#\1'${DOMAIN_NAME}'\2#g' "${PLEROMA_CONF_DIR}/pleroma.nginx"
    sed -i 's#live/DOMAIN#live/'${DOMAIN_NAME}'#g' "${PLEROMA_CONF_DIR}/pleroma.nginx"
    sed -i 's#root /home/pleroma#root /home/'${DOMAIN_NAME}'#g' "${PLEROMA_CONF_DIR}/pleroma.nginx"

    sed -i 's#USER pleroma#USER '${INSTANCE_USER}'#g' "${SCRIPTDIR}/setup_postgres/init_postgres.sql"
    sed -i 's#TO pleroma#TO '${INSTANCE_USER}'#g' "${SCRIPTDIR}/setup_postgres/init_postgres.sql"

    for conf_file in "${PLEROMA_CONF_DIR}/prod.secret.exs"  "${PLEROMA_CONF_DIR}/generated_config.exs" ;
    do
        sed -i 's#url:\s*\[host:\s*\"DOMAIN\"#url: \[host: \"'${DOMAIN_NAME}'\"#g' "${conf_file}"
        sed -i 's#secret_key_base:.*#secret_key_base: \"'${SECRET_KEY_BASE}'\",#g' "${conf_file}"
        sed -i 's#signing_salt:.*#signing_salt: \"'${SIGNING_SALT}'\"#g' "${conf_file}"
        sed -i 's#name:\s*\"InstanceNameOfPleroma\"#name: \"'${INSTANCE_NAME}'\"#g' "${conf_file}"
        sed -i 's#email:\s*\"YourEmailAddress\"#email: \"'${INSTANCE_EMAIL}'\"#g' "${conf_file}"
        sed -i 's#notify_email:\s*\"YourEmailAddress\"#notify_email: \"'${INSTANCE_EMAIL}'\"#g' "${conf_file}"
        sed -i 's#username:\s*\"YourPGUsername\"#username: \"'${INSTANCE_USER}'\"#g' "${conf_file}"
        sed -i 's#password:\s*\"YourPGPassword\"#password: \"'${POSTGRES_PASSWORD}'\"#g' "${conf_file}"
        sed -i 's#subject:\s*\"mailto:YourEmailAddress\"#subject: \"mailto:'${INSTANCE_EMAIL}'\"#g' "${conf_file}"
    done

    test -d '/var/log/nginx' || { sudo mkdir -p '/var/log/nginx' ; sudo chown -R ${PUID}:${PGID} '/var/log/nginx' ; }
    test -d '/var/log/postgresql' || { sudo mkdir -p '/var/log/postgresql' ; sudo chown -R ${PUID}:${PGID} '/var/log/postgresql' ; }
    test -d "${WRKROOT}/tmppg" || { mkdir -p "${WRKROOT}/tmppg" ; sudo chown -R ${PUID}:${PGID} "${WRKROOT}/tmppg" ; }
    test -d '/var/log/letsencrypt' || sudo mkdir -p '/var/log/letsencrypt'
    test -d '/var/lib/letsencrypt' || sudo mkdir -p '/var/lib/letsencrypt'
    test -d '/etc/letsencrypt' || sudo mkdir -p '/etc/letsencrypt'
}



function install_basic_on_host {
    sudo timedatectl set-timezone ${TZ:-'Asia/Shanghai'}

    for pkg in curl unzip build-essential wget ufw certbot ;
    do
        sudo apt-get install -y "${pkg}"
    done
}


function install_docker {
    /bin/bash "${SCRIPTDIR}/install_docker.sh"
    sudo usermod -aG docker "${INSTANCE_USER}"
}


function setup_ufw {
    ilogger "Setuping UFW firewall ..."
    sudo ufw allow ssh
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw allow 123
    sudo ufw allow from 127.0.0.1 to any port 5432
    sudo ufw enable
    ilogger "Setup UFW firewall done." 
}


function build_docker_image {
    ilogger "Building docker image ..."
    docker-compose build --build-arg puid=${PUID} --build-arg pgid=${PGID} --build-arg instance_user=${INSTANCE_USER}
    docker-compose run --rm pleroma mix ecto.migrate
    docker-compose run --rm pleroma mix web_push.gen.keypair
    ilogger 'warn' "DO NOT CLOSE THIS SHELL OR TYPE ANYTHING !!!"
    ilogger 'warn' "Copy the values of web push keys and copy them to pleroma_config/prod.secret.exs"
    ilogger 'warn' "  and hit <Enter> key to continue."
    read
    docker-compose build --build-arg puid=${PUID} --build-arg pgid=${PGID} --build-arg instance_user=${INSTANCE_USER}
}


function run_pleroma {
    docker-compose up -d
}


function update_pleroma {
    docker stop pleroma_web
    docker build --build-arg puid=${PUID} --build-arg pgid=${PGID} --build-arg instance_user=${INSTANCE_USER} --no-cache -t pleroma .
    docker-compose run --rm pleroma mix ecto.migrate
    docker-compose up -d
}


function get_cert {
    test -f '/etc/letsencrypt/cli.ini' || sudo ln -s "${PLEROMA_CONF_DIR}/cli.ini" '/etc/letsencrypt/cli.ini'

    sudo certbot certonly --email "${DOMAIN_CERT_EMAIL}" --webroot -w /var/lib/letsencrypt/ -d "${DOMAIN_NAME}"
    docker-compose restart nginx
}


function check_cert_from_client {
    echo | openssl s_client -servername ifttl.com -connect "pleroma.aksura.tk":443 2>/dev/null | openssl x509 -noout -dates
}


function export_pleroma_data {
    ilogger "Backup data files will be put in directory 'export' ."

    ilogger "- backup database data into file pleroma.pgdump ..."
    docker exec -i pleroma_postgres pg_dump -d pleroma -Fc "/tmp/export/pleroma.pgdump" 
    sudo cp "${WRKROOT}/tmppg/pleroma.pgdump" "${ARCDIR}/pleroma.pgdump"

    ilogger "- backup custom configuration files ..."
    test -d "${ARCDIR}/config" || mkdir -p "${ARCDIR}/config"
    docker cp "pleroma_web:/pleroma/config/prod.secret.exs" "${ARCDIR}/config/prod.secret.exs"
    docker cp "pleroma_web:/pleroma/config/emoji.txt" "${ARCDIR}/config/emoji.txt"

    ilogger "- backup custom images and html template files ..."
    test -d "${ARCDIR}/priv" || mkdir -p "${ARCDIR}/priv"
    test -d "${ARCDIR}/priv/static/static" || mkdir -p "${ARCDIR}/priv/static/static"
    docker cp "pleroma_web:/pleroma/priv/static/favicon.png" "${ARCDIR}/priv/static/favicon.png"
    docker cp "pleroma_web:/pleroma/priv/static/static/terms-of-service.html" "${ARCDIR}/priv/static/static/terms-of-service.html"
    docker cp "pleroma_web:/pleroma/priv/static/static/*.png" "${ARCDIR}/priv/static/static/*"
    test -d "${ARCDIR}/priv/static/instance" || mkdir -p "${ARCDIR}/priv/static/instance"
    docker cp "pleroma_web:/pleroma/priv/static/instance/panel.html" "${ARCDIR}/priv/static/instance/panel.html"

    ilogger "- backup custom emoji files ..."
    test -d "${ARCDIR}/priv/static/emoji" || mkdir -p "${ARCDIR}/priv/static/emoji"
    docker cp "pleroma_web:/pleroma/priv/static/emoji/blobs" "${ARCDIR}/priv/static/emoji/blobs"

    ilogger 'suc' "Backup process done. Data files in 'export' and 'uploads' ."
}


function restore_database {
    if [ -f "${ARCDIR}/pleroma.pgdump" ];
    then
        ilogger "Restore database from dump file ${ARCDIR}/pleroma.pgdump ..."
        sudo cp  "${ARCDIR}/pleroma.pgdump" "${WRKROOT}/tmppg/pleroma.pgdump"
        sudo chmod 666 "${WRKROOT}/tmppg/pleroma.pgdump"
        docker exec -i pleroma_postgres pg_restore -d pleroma -Fc "/tmp/export/pleroma.pgdump" 
    else
        ilogger 'err' "Expected PG dump file ${ARCDIR}/pleroma.pgdump not found!"
    fi
}


## Process routine
case "${ACTOPT}" in
    "usage") show_usage
             ;;
    "prepare") install_basic_on_host
               prepare_scripts
               ;;
    "install_docker") install_docker
                      ;;
    "build_image") build_docker_image
                   ;;
    "setup_firewall") setup_ufw
                      ;;
    "run") run_pleroma
           ;;
    "update") update_pleroma
              ;;
    "get_cert") get_cert
                ;;
    "renew_cert") get_cert
                  ;;
    "check_cert") check_cert_from_client
                  ;;
    "export_data") export_pleroma_data
                   ;;
    "import_database") restore_database
                       ;;
    "*") show_usage
         ;;
esac
