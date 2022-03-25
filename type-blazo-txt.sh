#!/bin/bash

# Variables
fileServicePrimaryEndpoint=$1

# Parameters validation
if [[ -z $fileServicePrimaryEndpoint ]]; then
    echo "fileServicePrimaryEndpoint parameter cannot be null or empty"
    exit 1
fi

echo $fileServicePrimaryEndpoint > $HOME/test-script-log.txt
echo "Tony Halik: Tu bylem!" >> $HOME/test-script-log.txt
