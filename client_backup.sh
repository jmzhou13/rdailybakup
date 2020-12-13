#!/bin/sh
#
# Author   : Terminator
# Copyright: GPL
# ChangeLog: 12/13/2020 Initial release
#
# This is a rsync wrapper to backup SRC_DIR to BAK_ROOT on remote
# backup server. On the remote backup server, you need to place
# rsync-rotate script into appropriate directory (for example, 
# /home/user/bin/rsync-rotate in this script) since we will invoke
# it instead of rsync.

SELF="${0}"
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin:/usr/X11R6/bin
export PATH



# The location rsync-rotate script resides on server
SERVER_SCRIPT="/home/user/bin/rsync-rotate"

SRC_DIR="/home/user/"
if [ ! -d ${SRC_DIR} ]; then
	echo "ERROR: Cannot find directory ${SRC_DIR}!"
	exit 1
fi
LOG_FILE="/tmp/rsnapshot.log"

BAK_ROOT="/mnt/backup_volume/user/backup"
BAK_DIR="${BAK_ROOT}/snapshot.day1"

# email to notify after backup completes
NOTIFY_EMAIL="user@gmail.com"
# server ip or name in local network
LOCAL_SERVER="server.local"
# server ip or name on the Internet, if you backup from the Internet
DYNDNS_SERVER="server.dyndns.org"

# Bandwidth limit (in kilobytes) during backup if you are on a slow
# bandwidth network and do not want to saturate the bandwidth.
# BWLIMIT="--bwlimit=41"
BWLIMIT=
EXCLUDE_FILE="${SRC_DIR}/.rsnapshot-exclude-file"

# create time-stamp of today in home directory
TOUCH_DATE=`date +%F`
rm -f ${SRC_DIR}/.today-is-*
touch ${SRC_DIR}/.today-is-${TOUCH_DATE}


usage() {
	echo "This program will backup the data of laptop home directory"
	echo "to a backup server."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Please make sure to grant full disk access to /usr/bin/rsync"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "Usage: ${SELF} server|dyndns|list"
	exit 1
}

if [ "$1" = "" ]; then
    usage
fi


rsyncmd=`which rsync`
# Enable checksum only if you are paranoid. It will slow down the
# backup significantly!
#paranoid="--checksum"
paranoid=
opthome="--verbose --archive --partial --progress --recursive --links --times --perms --update --delete --delete-excluded --delete-after --exclude-from=${EXCLUDE_FILE} -e ssh --rsync-path=${SERVER_SCRIPT}"

if [ "$1" = "server" ]; then
	echo "Backup home directory to backup server..."
	logger "Backup home directory to backup server..."
	${rsyncmd} ${paranoid} ${opthome} ${SRC_DIR} \
		user@${LOCAL_SERVER}:${BAK_DIR} 2>&1 | tee ${LOG_FILE}
    scp ${LOG_FILE} user@${LOCAL_SERVER}:${BAK_DIR}/

    echo "Completed at ${BAK_DIR} on server." | \
    mailx -s "Backing up ${HOSTNAME} at ${TOUCH_DATE}!" ${NOTIFY_EMAIL}
	exit 0
elif [ "$1" = "dyndns" ]; then
	echo "Backup home directory to backup server server.dybndns.com..."
	logger "Backup home directory to backup server server.dybndns.com..."
	${rsyncmd} ${paranoid} ${opthome} ${SRC_DIR} \
		user@${DYNDNS_SERVER}:${BAK_DIR} 2>&1 | tee ${LOG_FILE}
    scp ${LOG_FILE} user@${DYNDNS_SERVER}:${BAK_DIR}/

    echo "Completed at ${BAK_DIR} on server." | \
    mailx -s "Backing up ${HOSTNAME} at ${TOUCH_DATE}!" ${NOTIFY_EMAIL}
	exit 0
elif [ "$1" = "list" ]; then
	echo "List of backups on backup server..."
    ssh user@${LOCAL_SERVER} ls -lt ${BAK_ROOT}
    exit 0
fi


echo "This program will backup the data of laptop home directory"
echo "to a backup server."
echo "Usage: $0 server|dyndns"
exit 1
