#!/bin/bash

set -x
set -euo pipefail

# Create a directory to store APT repository keys if it doesn't exist:
sudo install -d -m 0755 /etc/apt/keyrings

# Import the Mozilla APT repository signing key:
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# The fingerprint should be 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'

# Next, add the Mozilla APT repository to your sources list:
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

# Update your package list
sudo apt-get update

# Check if a locale was passed in as an argument
if [ "$#" -eq 1 ]; then
    LOCALE=$1
    PACKAGE_NAME="firefox-nightly-l10n-${LOCALE}"
else
    PACKAGE_NAME="firefox-nightly"
fi

# Install the Firefox Nightly package, localized if a locale was specified
sudo apt-get install -y $PACKAGE_NAME
