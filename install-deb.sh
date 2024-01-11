sudo apt install curl
curl https://northamerica-northeast2-apt.pkg.dev/doc/repo-signing-key.gpg | sudo apt-key add -
echo "deb ar+https://northamerica-northeast2-apt.pkg.dev/projects/moz-fx-dev-releng releng-apt-dev main" | sudo tee -a /etc/apt/sources.list.d/artifact-registry.list

echo '
Package: *
Pin: origin northamerica-northeast2-apt.pkg.dev
Pin-Priority: 1007
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

sudo apt-get update
sudo snap remove firefox
sudo apt-get install firefox
