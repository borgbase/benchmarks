#!/bin/bash

set -ux

export BORG_NEW_PASSPHRASE=mysecret
export BORG_PASSPHRASE=mysecret
export BORG_DELETE_I_KNOW_WHAT_I_AM_DOING=YES

function timeit() {
    /bin/time -v -o results/$TEST_BIN/$1.txt ./bin/$TEST_BIN "${@:2}"
}

# Borg v1.2
function test_borg-12() {
    export TEST_BIN=borg-12
    mkdir -p results/$TEST_BIN

    ./bin/$TEST_BIN init -e repokey-blake2
    timeit create-1 create --compression zstd ::initial corpa-1
    timeit create-2 create --compression zstd ::second corpa-1 corpa-2
    timeit create-3 create --compression zstd ::third corpa-1
    ./bin/$TEST_BIN info > results/$TEST_BIN/final-size.txt
    timeit prune-1 prune --keep-last 1
    timeit prune-2 compact
}


# Borg v2.0b4
function test_borg-20() {
    export TEST_BIN=borg-20
    mkdir -p results/$TEST_BIN

    ./bin/$TEST_BIN rcreate -e repokey-blake2-chacha20-poly1305
    timeit create-1 create --compression zstd initial corpa-1
    timeit create-2 create --compression zstd second corpa-1 corpa-2
    timeit create-3 create --compression zstd third corpa-1
    timeit info-0 info > results/$TEST_BIN/final-size.txt
    timeit prune-1 prune --keep-last 1
    timeit prune-2 compact
}

# Restic 0.14
function test_restic-14() {
    export RESTIC_PASSWORD=mysecret
    export TEST_BIN=restic-14
    mkdir -p results/$TEST_BIN

    ./bin/$TEST_BIN init
    timeit create-1 backup corpa-1
    timeit create-2 backup corpa-1 corpa-2
    timeit create-3 backup corpa-1
    ./bin/$TEST_BIN stats > results/$TEST_BIN/final-size.txt
    timeit prune-1 forget --keep-last 1 --prune
}
