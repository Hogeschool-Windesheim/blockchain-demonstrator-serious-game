#!/bin/bash
sudo true

echo "-------------------- Updating package list --------------------"
sudo apt update

echo "-------------------- Installing necessary tools for checks --------------------"
sudo apt install -y net-tools lsof dnsutils curl

echo "-------------------- Checking Docker status --------------------"
if sudo systemctl is-active --quiet docker; then
    echo "✅ Docker service is running."
else
    echo "❌ Docker service is NOT running!"
fi

echo "-------------------- Checking .NET SDK --------------------"
if command -v dotnet &> /dev/null; then
    echo "✅ dotnet is installed."
    dotnet --version
else
    echo "❌ dotnet is NOT installed!"
fi

echo "-------------------- Checking ports --------------------"
echo ""
echo "Checking port 5000:"
sudo lsof -i :5000 || echo "⚠️ Nothing running on port 5000."
sudo netstat -tulpn | grep :5000 || echo "⚠️ No process listening on port 5000."

echo ""
echo "Checking port 5001:"
sudo lsof -i :5001 || echo "⚠️ Nothing running on port 5001."
sudo netstat -tulpn | grep :5001 || echo "⚠️ No process listening on port 5001."

echo "-------------------- Checking domain DNS --------------------"
DOMAIN="demonstrator.valuechainhackers.xyz"
IP_EXPECTED=$(curl -s ifconfig.me)

IP_DOMAIN=$(dig +short $DOMAIN | tail -n1)

if [ -z "$IP_DOMAIN" ]; then
    echo "❌ Domain $DOMAIN does not resolve!"
else
    echo "✅ $DOMAIN resolves to: $IP_DOMAIN"
    if [ "$IP_DOMAIN" == "$IP_EXPECTED" ]; then
        echo "✅ Domain IP matches your server's public IP ($IP_EXPECTED)."
    else
        echo "⚠️ Domain IP does NOT match your server's public IP ($IP_EXPECTED). Check your DNS config!"
    fi
fi

echo "-------------------- Checking HTTP response from domain --------------------"
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" http://$DOMAIN)

if [ "$HTTP_STATUS" == "200" ]; then
    echo "✅ Domain is reachable and returns HTTP 200 OK."
else
    echo "⚠️ Domain HTTP status: $HTTP_STATUS (expected 200). Check web server or app status!"
fi

echo "-------------------- Health check completed --------------------"
