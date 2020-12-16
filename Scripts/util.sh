#!/usr/bin/env bash

LOGFILE='/dev/null'

function ilogger {
    if [ $# -eq 2 ];
    then
        local msg_lvl="$(echo $1 | tr 'A-Z' 'a-z')"
        local msg_str="$2"
    else
        local msg_lvl="info"
        local msg_str="$1"
    fi

    case "${msg_lvl}" in
        "suc" ) echo -e [$(date +"%F %X")]"\033[32m ✓ ${msg_str} \033[0m" | tee -a "${LOGFILE}" 
                ;;
        "err" ) echo -e [$(date +"%F %X")]"\033[31m ✗ ${msg_str} \033[0m" | tee -a "${LOGFILE}" 
                ;;
        "warn" ) echo -e [$(date +"%F %X")]"\033[33m ⚠ ${msg_str} \033[0m" | tee -a "${LOGFILE}" 
                 ;;
        * ) echo [$(date +"%F %X")]" ${msg_str}" | tee -a "${LOGFILE}" 
            ;;
    esac
}
