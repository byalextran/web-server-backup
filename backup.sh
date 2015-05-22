#!/bin/bash

# BEGIN CONFIGURATION ==========================================================

BACKUP_DIR="/home/alextran/web-server-backup"  # The directory in which you want backups placed

DUMP_MYSQL=true
KEEP_MYSQL="14" # How many days worth of mysql dumps to keep
MYSQL_BACKUP_DIR="$BACKUP_DIR/mysql/"

TAR_SITES=true
KEEP_SITES="2" # How many days worth of site tarballs to keep
SITES_BACKUP_DIR="$BACKUP_DIR/sites/"
SITES_DIR="/var/www/"

# You probably won't have to change these
THE_DATE="$(date '+%Y-%m-%d')"

MYSQL_PATH="$(which mysql)"
MYSQLDUMP_PATH="$(which mysqldump)"
FIND_PATH="$(which find)"
TAR_PATH="$(which tar)"

# END CONFIGURATION ============================================================

# Announce the backup time
echo "Backup Started: $(date)"

# Create the backup dirs if they don't exist
if [[ ! -d $BACKUP_DIR ]]
  then
  mkdir -p "$BACKUP_DIR"
fi
if [[ ! -d $MYSQL_BACKUP_DIR ]]
  then
  mkdir -p "$MYSQL_BACKUP_DIR"
fi
if [[ ! -d $SITES_BACKUP_DIR ]]
  then
  mkdir -p "$SITES_BACKUP_DIR"
fi

if [ "$DUMP_MYSQL" = "true" ]
  then

  # Get a list of mysql databases and dump them one by one
  echo "------------------------------------"
  DBS="$($MYSQL_PATH -Bse 'show databases')"
  for db in $DBS
  do
    if [[ $db != "information_schema" && $db != "mysql" && $db != "performance_schema" ]]
      then
      echo "Dumping: $db..."
      $MYSQLDUMP_PATH --opt --skip-add-locks $db | gzip > $MYSQL_BACKUP_DIR$db\_$THE_DATE.sql.gz
    fi
  done

  # Delete old dumps
  echo "------------------------------------"
  echo "Deleting old backups..."
  # List dumps to be deleted to stdout (for report)
  $FIND_PATH $MYSQL_BACKUP_DIR*.sql.gz -mtime +$KEEP_MYSQL
  # Delete dumps older than specified number of days
  $FIND_PATH $MYSQL_BACKUP_DIR*.sql.gz -mtime +$KEEP_MYSQL -exec rm {} +

fi

if [ "$TAR_SITES" == "true" ]
  then

  # Get a list of files in the sites directory and tar them one by one
  echo "------------------------------------"
  cd $SITES_DIR
  for d in *
  do
      if [[ $d != "22222" && $d != "html" ]]
      then
      echo "Archiving $d..."
      $TAR_PATH -C $SITES_DIR -czf $SITES_BACKUP_DIR/$d\_$THE_DATE.tgz $d
    fi
  done

  # Delete old site backups
  echo "------------------------------------"
  echo "Deleting old backups..."
  # List files to be deleted to stdout (for report)
  $FIND_PATH $SITES_BACKUP_DIR*.tgz -mtime +$KEEP_SITES
  # Delete files older than specified number of days
  $FIND_PATH $SITES_BACKUP_DIR*.tgz -mtime +$KEEP_SITES -exec rm {} +

fi

# Announce the completion time
echo "------------------------------------"
echo "Backup Completed: $(date)"
