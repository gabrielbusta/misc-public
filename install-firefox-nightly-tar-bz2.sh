#!/bin/bash

set -x
set -euo pipefail

# URL to the Firefox nightly build tar.bz2 file

FILE_URL="https://archive.mozilla.org/pub/firefox/nightly/latest-mozilla-central/firefox-120.0a1.en-US.linux-x86_64.tar.bz2"

# Filename for the downloaded file
FILE_NAME="firefox-120.0a1.en-US.linux-x86_64.tar.bz2"

# Use wget to download the file
wget $FILE_URL

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "Download successful. Uncompressing the file..."

    # Use tar to extract the file
    tar -xvjf $FILE_NAME

    if [ $? -eq 0 ]; then
        echo "File uncompressed successfully."
    else
        echo "Error occurred during file uncompression."
    fi
else
    echo "Download failed."
fi
