#!/bin/sh

set -eux

PY_VERSIONS="3.11.0 3.10.6 3.9.13" # 
BORG_VERSIONS="1.2.2 "  # 2.0.0b3
eval "$(pyenv init -)"

for PY_VERSION in $PY_VERSIONS
do
    for BORG_VERSION in $BORG_VERSIONS
    do
        pyenv virtualenv --force $PY_VERSION borg-$BORG_VERSION-$PY_VERSION
        pyenv shell borg-$BORG_VERSION-$PY_VERSION
        BORG_OPENSSL_PREFIX=$(brew --prefix)/opt/openssl@1.1 pip install "borgbackup==$BORG_VERSION"
        borg --version
        mkdir data-$BORG_VERSION-$PY_VERSION
        export BORG_NEW_PASSPHRASE=mysecret
        export BORG_PASSPHRASE=mysecret
        export BORG_REPO=./repo-$BORG_VERSION-$PY_VERSION
        
        # borg rcreate -e repokey-blake2-chacha20-poly1305
        # borg benchmark crud data-$BORG_VERSION-$PY_VERSION > result-$BORG_VERSION-$PY_VERSION.txt

        borg init -e repokey-blake2 $BORG_REPO
        borg benchmark crud $BORG_REPO data-$BORG_VERSION-$PY_VERSION > result-$BORG_VERSION-$PY_VERSION.txt
        
        rm -rf data-$BORG_VERSION-$PY_VERSION repo-$BORG_VERSION-$PY_VERSION
    done
done
