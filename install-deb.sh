# Create a directory to store APT repository keys if it doesn't exist:
sudo install -d -m 0755 /etc/apt/keyrings

# Import the releng APT dev repository signing key:
wget -q https://northamerica-northeast2-apt.pkg.dev/doc/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/northamerica-northeast2-apt.pkg.dev.asc > /dev/null

# The fingerprint should be 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3
gpg -n -q --import --import-options import-show /etc/apt/keyrings/northamerica-northeast2-apt.pkg.dev.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'

# Next, add the Mozilla APT repository to your sources list:
echo "deb [signed-by=/etc/apt/keyrings/northamerica-northeast2-apt.pkg.dev.asc] https://northamerica-northeast2-apt.pkg.dev/projects/moz-fx-dev-releng releng-apt-dev main" | sudo tee -a /etc/apt/sources.list.d/releng.list > /dev/null

echo '
Package: *
Pin: origin northamerica-northeast2-apt.pkg.dev
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

sudo apt-get update && sudo apt-get install firefox
