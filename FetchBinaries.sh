#!/bin/bash
# Script to fetch binaries needed for UT3Vehicles from various online sources by parsing Binaries.csv
# Copyright ⓒ GreatEmerald, 2018

## Set environmental variables for output directories ##
TEXTURES_DIR=${TEXTURES_DIR:-"../Textures"}
ANIMATIONS_DIR=${ANIMATIONS_DIR:-"../Animations"}
SOUNDS_DIR=${SOUNDS_DIR:-"../Sounds"}
STATICMESHES_DIR=${STATICMESHES_DIR:-"../StaticMeshes"}
SYSTEM_DIR=${SYSTEM_DIR:-"../System"}
WGET_EXTRA_OPTS=${WGET_EXTRA_OPTS:-"-nv"}

## Utility functions ##

# Validate checksums: Checksum, file path
function checksum {
    echo ${1} ${2} | sha256sum -c -
}
# Print a message in case the checksum is bad after download
function bad_checksum {
    echo "ERROR: checksum validation failed after download! Make sure Binaries.csv has the right hash!"
    exit 1
}

## Handle each file in Binaries.csv ##
for line in $(tail -n +2 Binaries.csv); do
    IFS=","
    line=($line)
    dirtype=${line[0]} # or: dirtype=$(echo $line | awk -F "," '{print $1}')
    filename=${line[1]}
    url=${line[2]}
    checksum=${line[3]}
    opts=${line[4]}
    unset IFS
    
    # Obtain the destination directory
    case $dirtype in
    Animations)
        destdir=${ANIMATIONS_DIR}
        ;;
    Sounds)
        destdir=${SOUNDS_DIR}
        ;;
    StaticMeshes)
        destdir=${STATICMESHES_DIR}
        ;;
    System)
        destdir=${SYSTEM_DIR}
        ;;
    Textures)
        destdir=${TEXTURES_DIR}
        ;;
    *)
        echo "Warning: unable to get destination directory, downloading to working directory."
        destdir="."
        ;;
    esac
    
    file=${destdir}/${filename}
    
    # Make sure the directory exists
    if [[ ! -d ${destdir} ]]; then
        mkdir ${destdir}
    fi
    
    # Is the file already there?
    if [[ -f ${file} ]]; then
        # Do checksums match? If no, download the files and recheck
        checksum ${checksum} ${file} || (wget $opts ${WGET_EXTRA_OPTS} -O ${file} ${url} && checksum ${checksum} ${file} || bad_checksum)
    else
        # Just download and then check that it's OK
        wget $opts ${WGET_EXTRA_OPTS} -O ${file} ${url}
        checksum ${checksum} ${file} || bad_checksum
    fi
done
