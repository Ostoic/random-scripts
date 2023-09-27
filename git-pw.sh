#!/bin/bash

set -e 
PW_PATH="$HOME/main.kdbx"

WORK_SUFFIX=$RANDOM$RANDOM$RANDOM
WORK=/tmp/$WORK_SUFFIX
pushd /tmp
mkdir -p $WORK_SUFFIX
popd

pushd $WORK

backup-current-pw() {
  if [ -f $PW_PATH ]; then 
    cp $PW_PATH ~/."$(date +%s)-$(basename $PW_PATH)".bk
  fi
}

git-clone-pw() {
  git clone git@github.com:Ostoic/pw.git
  
  # Decrypt secrets from git repo
  gpg -d -o "$WORK/git-pw.kdbx" "$WORK/pw/kdbx.gpg"
}

update-current-pw() {
  cp $1 $PW_PATH
}

merge-into-current() {
  # Merge $PW_PATH and git-pw into $PW_PATH.
  keepassxc-cli merge --dry-run -s $PW_PATH "$WORK/git-pw.kdbx"
  if [ "$(sha256sum $1)" = "$(sha256sum ~/$1)" ]; then
    echo "No changes"
    exit
  fi
}

encrypt-pw-into-repo() {
  # This is better than `gpg --yes` since that might ignore security prompts.
  rm "$WORK/pw/kdbx.gpg"
  gpg -c -o "$WORK/pw/kdbx.gpg" $PW_PATH
}

push-repo() {
  pushd "$WORK/pw"
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

backup-current-pw 
git-clone-pw 
# $OWKR/git-pw.kdbx is our working pw database
# cp "$WORK/git-pw.kdbx" ~

if [ $OP == "merge" ]; then
  merge-into-current
  #
  # Move merged database into the user's home directory
  update-current-pw $PW_PATH
  
elif [ $OP == "pull" ]; then
  update-current-pw "git-pw.kdbx"

elif [ $OP == "push" ]; then
  # Encrypt pw into pw/$PW.gpg
  encrypt-pw-into-repo $PW_PATH
  push-repo
fi

popd
rm -rf $WORK
