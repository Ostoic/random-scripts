#!/bin/bash
# TODO: git-like operations pull, merge, update, etc

PW="Passwords.kdbx"
EPW=$PW.gpg
set -e 

WORK=$(mktemp -d)
pushd $WORK

# Backup current pw
backup-current-pw() {
  cp ~/$1 ~/."$(date +%s)"-current-pw.kdbx.bk
}

git-clone-pw() {
  git clone git@github.com:Ostoic/personal.git
  # cp personal/$1 git-pw.kdbx.gpg

  # Decrypt secrets from git repo
  gpg -d -o git-pw.kdbx "personal/$1.gpg"
}

merge-into-current() {
  # Merge the databases: (git, pw) -> pw
  keepassxc-cli merge -s $1 git-pw.kdbx
  if [ "$(sha256sum $1)" = "$(sha256sum ~/$1)" ]; then
    echo "No changes"
    exit
  fi
}

push-git() {
  pushd personal
  git add .
  git commit -m 'kdbx update'
  git push
  popd
}

git-encrypt-pw() {
  rm "personal/$1.gpg"
  gpg -c -o "personal/$1.gpg" $1
}

if [ $# == 0 ]; then
  OP="merge"
else
  OP=$1
fi

backup-current-pw $PW
git-clone-pw $PW
cp ~/$PW .

# Encrypt pw into personal/$PW.gpg
git-encrypt-pw $PW

if [ $OP == "merge" ]; then
  merge-into-current $PW
  push-git

  # Move merged database into the user's home directory
  cp $PW ~/

elif [ $OP == "push" ]; then
  push-git
fi

rm -rf $WORK
