# Create a directory to store APT repository keys if it doesn't exist:
sudo install -d -m 0755 /etc/apt/keyrings

# Import the staging APT dev repository signing key:
wget -q https://repository.stage.productdelivery.nonprod.webservices.mozgcp.net/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/repository.stage.productdelivery.nonprod.webservices.mozgcp.net.asc > /dev/null

# The fingerprint should be 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3
gpg -n -q --import --import-options import-show /etc/apt/keyrings/repository.stage.productdelivery.nonprod.webservices.mozgcp.net.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'

# Next, add the staging APT repository to your sources list:
echo "deb [signed-by=/etc/apt/keyrings/repository.stage.productdelivery.nonprod.webservices.mozgcp.net.asc] https://repository.stage.productdelivery.nonprod.webservices.mozgcp.net/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla-stage.list > /dev/null
