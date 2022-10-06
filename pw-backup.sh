#!/bin/bash

set -e
cd "$HOME"
BACKUP_DIR=$(realpath "$HOME/.pw-backup")
backup-kdb() {
  TO_BACKUP=$(realpath $1)
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir "$BACKUP_DIR"
  fi
  
  cp "$TO_BACKUP" "$BACKUP_DIR"
}

PERSONAL_REPO_PATH="$HOME/repos/ostoic/personal"
git-pw-backup() {
  OLD_PWD="$PWD"

	cd "$PERSONAL_REPO_PATH"
	if ! git fetch && git pull ; then 
		echo "Error while updating from repo"
		exit 3; 
	fi
 
  cd "$OLD_PWD"	
	cp "$1" "$PERSONAL_REPO_PATH"
	cd "$PERSONAL_REPO_PATH"
  
	git add .
	git commit -m "kdbx backup"
  if ! git push; then
    echo "Error while pushing to repo"
	 	exit 4
	fi

	cd "$OLD_PWD"
}

KDB="Passwords.kdbx"
backup-kdb "$KDB"

ENC_KDB="$KDB.gpg"
if [ -f "$ENC_KDB" ]; then
	rm "$ENC_KDB"
fi

# Encrypt then backup through git
gpg -c -o "$ENC_KDB" "$KDB"
git-pw-backup "$ENC_KDB"

# Update desktop kdbx
rsync -azP owner@desktop:"$KDB" .other-pw.kdbx
if [ ! -f ".other-pw.kdbx" ]; then
  echo "Error: Desktop database was not found"
  exit 1
fi

# Merge databases
if ! keepassxc-cli merge -s "$KDB" .other-pw.kdbx; then
  echo "Error: Unable to merge databases"
  exit 2
fi

#git-pw-backup "$ENC_KDB"

# Send new one back to desktop
rsync -azP "$KDB" owner@desktop:
#rm .pw.kdbx
