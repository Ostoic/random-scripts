#!/bin/bash

set -e 
PW="main"

WORK_SUFFIX=$RANDOM$RANDOM$RANDOM
WORK=/tmp/$WORK_SUFFIX
pushd /tmp
mkdir -p $WORK_SUFFIX
popd

pushd $WORK

backup-current-pw() {
  cp ~/$1 ~/."$(date +%s)"-current-pw.kdbx.bk
}

git-clone-pw() {
  git clone git@github.com:Ostoic/pw.git
  # cp pw/$1 git-pw.kdbx.gpg

  # Decrypt secrets from git repo
  gpg -d -o git-pw.kdbx "pw/kdbx.gpg"
}

update-current-pw() {
  cp $1 ~/$PW
}

merge-into-current() {
  # Merge the databases: (git, pw) -> pw
  keepassxc-cli merge -s $1 git-pw.kdbx
  if [ "$(sha256sum $1)" = "$(sha256sum ~/$1)" ]; then
    echo "No changes"
    exit
  fi
}

encrypt-pw-into-repo() {
  rm "pw/$1.gpg"
  gpg -c -o "pw/$1.gpg" $1
}

push-repo() {
  pushd pw
  git add .
  git commit -m 'kdbx update'
  git push
  popd
}

if [ $# == 0 ]; then
  OP="merge"
else
  OP=$1
fi

backup-current-pw $PW
git-clone-pw $PW
cp ~/$PW .

if [ $OP == "merge" ]; then
  merge-into-current $PW
  push-repo

  # Move merged database into the user's home directory
  update-current-pw $PW
  
elif [ $OP == "pull" ]; then
  update-current-pw "git-pw.kdbx"

elif [ $OP == "push" ]; then
  # Encrypt pw into pw/$PW.gpg
  encrypt-pw-into-repo $PW
  push-repo
fi

popd
rm -rf $WORK
