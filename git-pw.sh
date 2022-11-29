#!/bin/bash

PW="Passwords.kdbx"
EPW=$PW.gpg
set -e 

WORK=$(mktemp -d)
pushd $WORK

# Backup current pw
cp ~/$PW .current-pw.kdbx.bk
git clone git@github.com:Ostoic/personal.git
cp personal/$EPW git-pw.kdbx.gpg

# Decrypt secrets from git repo
gpg -d -o git-pw.kdbx git-pw.kdbx.gpg

cp ~/$PW .

# Merge the current pw and git pws
keepassxc-cli merge -s $PW git-pw.kdbx
if [ "$(sha256sum $PW)" = "$(sha256sum ~/$PW)" ]; then
  echo "No changes"
	exit
fi

gpg -c -o $EPW $PW
cp $EPW personal/$EPW

pushd personal
git add .
git commit -m 'kdbx update'
git push

popd 
cp $PW ~/
rm -rf $WORK
