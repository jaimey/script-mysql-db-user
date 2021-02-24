#!/bin/bash

# Shell script to create MySQL database and user.

function printUsage()
{
    echo -n "$(basename "$0") [OPTION]...

Create MySQL database and user.

    Options:
        -h, --host        MySQL Host
        -d, --database    MySQL Database
        -u, --user        MySQL User
        -p, --pass        MySQL Password (If empty, auto-generated)

    Examples:
        $(basename "$0") -u=user -d=database

Version $VERSION

"
    exit 1
}

function processArgs()
{
    # Parse Arguments
    for arg in "$@"
    do
        case $arg in
            -h=*|--host=*)
                DB_HOST="${arg#*=}"
            ;;
            -d=*|--database=*)
                DB_NAME="${arg#*=}"
            ;;
            -u=*|--user=*)
                DB_USER="${arg#*=}"
            ;;
             -p=*|--pass=*)
                DB_PASS="${arg#*=}"
            ;;
            *)
                
            ;;
        esac
    done
    [[ -z $DB_NAME ]] && echo "Database name cannot be empty." && exit 1
    [[ $DB_USER ]] || DB_USER=$DB_NAME
}

function createMysqlDbUser()
{
    SQL1="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    SQL2="CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    SQL3="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    SQL4="FLUSH PRIVILEGES;"

        echo "Please enter root user MySQL password!"
        read -r rootPassword

     
        if ! $BIN_MYSQL --silent -h "$DB_HOST" -u root -p"${rootPassword}" -e "${SQL1}${SQL2}${SQL3}${SQL4}" ; then
        	exit 0
        fi
}

function printSuccessMessage()
{
    echo "MySQL DB / User creation completed!"

    echo "################################################################"
    echo ""
    echo " >> Host      : ${DB_HOST}"
    echo " >> Database  : ${DB_NAME}"
    echo " >> User      : ${DB_USER}"
    echo " >> Pass      : ${DB_PASS}"
    echo ""
    echo "################################################################"

}

function CheckIsRoot()
{
	if [ "$EUID" -ne 0 ]; then
		echo "Sorry, you need to run this as root"
		exit 1
	fi

}
################################################################################
# Main
################################################################################


VERSION="0.1.0"

BIN_MYSQL=$(which mysql)

DB_HOST='localhost'
DB_NAME=
DB_USER=
DB_PASS="$(openssl rand -base64 12)"

function main()
{
    [[ $# -lt 1 ]] && printUsage
    echo "Processing arguments..."
    processArgs "$@"
    echo "Done!"

    echo "Creating MySQL db and user..."
    createMysqlDbUser
    echo "Done!"

    printSuccessMessage

    exit 0
}

CheckIsRoot
main "$@"