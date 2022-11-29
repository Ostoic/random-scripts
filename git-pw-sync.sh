#!/bin/bash

SECRETS_DB="Passwords.kdbx"
SECRETS_REPO="/tmp/git-pw-sync-$(date %+s)"

echo -n "Enter encrypted secrets password: "
read -s SECRET
echo $SECRET

exit
pushd $SECRETS_REPO
git clone git@github.com:Ostoic/personal
popd

backup-kdb() {
  TO_BACKUP=$(realpath $1)
  if [ ! -d "$BACKUP_DIR" ]; then
		mkdir "$BACKUP_DIR"
	fi
						  
	cp "$TO_BACKUP" "$BACKUP_DIR"
}


