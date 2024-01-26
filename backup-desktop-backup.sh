#!/bin/bash

set -e

FILE_TO_BACKUP="desktop-backup.tgz"
ENCRYPTED_FILE="$FILE_TO_BACKUP.gpg"
BACKUP_DEST="/run/media/fure/backup/desktop/"

cleanup-tmp-files() {
  rm $ENCRYPTED_FILE
}

encrypt() {
  echo "Encrypting $FILE_TO_BACKUP..."
  gpg -c -o $ENCRYPTED_FILE $FILE_TO_BACKUP

  if [ ! -f $ENCRYPTED_FILE ]; then
    echo "Error: Encrypted file not found!"
    cleanup-tmp-files
    exit -1
  fi

  if [[ $(du $FILE_TO_BACKUP) != $(du $ENCRYPTED_FILE) ]]; then
    echo "Error: Encrypted file is different from the original!"
    cleanup-tmp-files
    exit -2
  fi
}

copy-to-backup() {
  echo "Copying $ENCRYPTED_FILE to $BACKUP_DEST..."
  rsync -azP $ENCRYPTED_FILE $BACKUP_DEST
}

compress() {
  tar -cvzf $FILE_TO_BACKUP.tgz $FILE_TO_BACKUP
  FILE_TO_BACKUP=$FILE_TO_BACKUP.tgz
}

encrypt
copy-to-backup
cleanup-tmp-files
