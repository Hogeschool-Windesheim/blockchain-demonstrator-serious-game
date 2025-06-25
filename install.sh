#!/usr/bin/env bash
set -Eeuo pipefail

log()   { printf '⏺ [%s] %s\n' "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$*"; }
error() { log "❌ $*" >&2; exit 1; }

(( EUID == 0 )) || error "Run as root or with sudo"

log "Removing conflicting container runtimes and old Docker"
apt-get remove -y docker docker-engine docker.io docker-compose podman-docker containerd runc || true
apt-get purge -y containerd.io || true
apt-get autoremove -y

log "Installing prerequisites"
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release git dnsutils nginx wget apt-transport-https

log "Setting up Docker apt repo"
install -m0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

log "Installing Docker Engine and containerd.io"
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

log "Installing .NET Core 3.1"
wget -q https://dot.net/v1/dotnet-install.sh -O /usr/local/bin/dotnet-install.sh
chmod +x /usr/local/bin/dotnet-install.sh
/usr/local/bin/dotnet-install.sh --channel 3.1 --install-dir /opt/dotnet
ln -sf /opt/dotnet/dotnet /usr/bin/dotnet

export CLR_ICU_VERSION_OVERRIDE=70

REPO="/root/blockchain-demonstrator-serious-game"
if [[ -d "$REPO" ]]; then
  git -C "$REPO" pull --ff-only
else
  git clone https://github.com/Hogeschool-Windesheim/blockchain-demonstrator-serious-game.git "$REPO"
fi

sed -ri \
  's|Server=.*;Database=BeerGameContext;.*|Server=172.17.0.2;Database=BeerGameContext;Trusted_Connection=True;MultipleActiveResultSets=true;User id=sa;Password=B33rgam3;Integrated Security=false|' \
  "$REPO/BlockchainDemonstratorApi/appsettings.json"

docker rm -f database &>/dev/null || true
docker pull mcr.microsoft.com/mssql/server:2019-latest
docker run -d --name database --hostname database --restart=always \
  -e ACCEPT_EULA=Y -e SA_PASSWORD=B33rgam3 \
  -p 1433:1433 mcr.microsoft.com/mssql/server:2019-latest

sleep 30

dotnet publish "$REPO/BlockchainDemonstratorApi/BlockchainDemonstratorApi.csproj" \
  -c Release -f netcoreapp3.1 -o "$REPO/publish/api"
dotnet publish "$REPO/BlockchainDemonstratorWebApp/BlockchainDemonstratorWebApp.csproj" \
  -c Release -f netcoreapp3.1 -o "$REPO/publish/webapp"

cat > /etc/nginx/sites-available/blockchain-demo.conf <<EOF
server {
  listen 80;
  server_name demonstrator.valuechainhackers.xyz;
  location / { proxy_pass http://127.0.0.1:5000/; include proxy_params; }
}
server {
  listen 8080;
  server_name _;
  location / { proxy_pass http://127.0.0.1:5002/; include proxy_params; }
}
EOF
ln -sf /etc/nginx/sites-available/blockchain-demo.conf /etc/nginx/sites-enabled/
systemctl reload nginx
