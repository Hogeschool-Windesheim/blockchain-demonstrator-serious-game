# Blockchain Demonstrator - Deployment Guide

This guide explains how to deploy the Blockchain Demonstrator Serious Game (Beer Game) to a production server.

## Prerequisites

- Ubuntu/Debian Linux server
- .NET Core 3.1 SDK installed
- SQL Server 2019+ (running on localhost:1433)
- Reverse proxy (Traefik, Nginx, or Apache) for HTTPS/routing
- Domain name pointing to your server (optional but recommended)

## Architecture

The application consists of two ASP.NET Core applications:

- **BlockchainDemonstratorApi** - REST API and SignalR hub (runs on port 5002)
- **BlockchainDemonstratorWebApp** - MVC web application (runs on port 5000)

## Quick Start

### 1. Clone and Build

```bash
cd /root  # or your preferred directory
git clone <your-repo-url> blockchain-demonstrator-serious-game
cd blockchain-demonstrator-serious-game
chmod +x install.sh
./install.sh
```

### 2. Configure Database

Ensure SQL Server is running and accessible on `127.0.0.1:1433` with:
- Database: `BeerGameContext` (will be created automatically)
- User: `sa`
- Password: `B33rgam3`

Or modify the connection string in `BlockchainDemonstratorApi/Startup.cs:89`

### 3. Configure Deployment

Copy the example configuration:

```bash
cp deployment.env.example deployment.env
```

Edit `deployment.env`:

```bash
# Your public-facing domain (HTTPS)
PUBLIC_API_URL=https://your-domain.com

# CORS origins (comma-separated)
CORS_ORIGINS=https://your-domain.com,http://your-server-ip:5000

# Server IP for internal communication
SERVER_IP=your-server-ip:8080
```

**Example configuration:**

```bash
PUBLIC_API_URL=https://demonstrator.valuechainhackers.xyz
CORS_ORIGINS=https://demonstrator.valuechainhackers.xyz,http://10.0.5.13:5000
SERVER_IP=10.0.5.13:8080
```

### 4. Configure Reverse Proxy

#### Traefik Example

Create `/etc/traefik/dynamic/demonstrator.yml`:

```yaml
http:
  routers:
    demonstrator-api:
      rule: "Host(`your-domain.com`) && (PathPrefix(`/api`) || PathPrefix(`/GameHub`))"
      entryPoints:
        - websecure
      service: demonstrator-api-service
      tls:
        certResolver: myresolver
      priority: 10

    demonstrator-web:
      rule: "Host(`your-domain.com`)"
      entryPoints:
        - websecure
      service: demonstrator-web-service
      tls:
        certResolver: myresolver
      priority: 1

  services:
    demonstrator-web-service:
      loadBalancer:
        servers:
          - url: "http://your-server-ip:5000"

    demonstrator-api-service:
      loadBalancer:
        servers:
          - url: "http://your-server-ip:5002"
```

**Important routing notes:**
- `/api/*` routes to API (port 5002)
- `/GameHub` routes to API for SignalR WebSocket
- All other paths route to WebApp (port 5000)
- API router must have higher priority (10 vs 1)

#### Nginx Example

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    # SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # API and SignalR routes
    location ~ ^/(api|GameHub) {
        proxy_pass http://localhost:5002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # WebApp routes
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 5. Install Systemd Services

Copy and customize the service files:

```bash
cp systemd/beergame-api.service.example /etc/systemd/system/beergame-api.service
cp systemd/beergame-webapp.service.example /etc/systemd/system/beergame-webapp.service
```

Edit the service files:
- Replace `YOUR_SERVER_IP_HERE` with your actual server IP (e.g., `10.0.5.13:8080`)
- Replace `YOUR_DOMAIN_HERE` with your public domain
- Adjust `WorkingDirectory` and `ExecStart` paths if you installed elsewhere

**Example beergame-webapp.service:**

```ini
Environment=PUBLIC_API_URL=https://demonstrator.valuechainhackers.xyz
Environment=CORS_ORIGINS=https://demonstrator.valuechainhackers.xyz
```

Enable and start services:

```bash
systemctl daemon-reload
systemctl enable beergame-api beergame-webapp
systemctl start beergame-api beergame-webapp
```

Check status:

```bash
systemctl status beergame-api
systemctl status beergame-webapp
```

View logs:

```bash
journalctl -u beergame-api -f
journalctl -u beergame-webapp -f
```

### 6. Test Deployment

Manual test:

1. Navigate to `https://your-domain.com`
2. Click "Login"
3. Create admin account (first time only)
4. Login as admin
5. Create a new game
6. Open 4 browser tabs/windows
7. Join as Retailer, Wholesaler, Distributor, Factory
8. Start game and play a few rounds

Automated test (optional):

```bash
chmod +x test-e2e-deployment.sh
./test-e2e-deployment.sh https://your-domain.com
```

## Configuration Reference

### Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `ASPNETCORE_ENVIRONMENT` | Yes | ASP.NET environment | `Production` |
| `PUBLIC_API_URL` | Yes | Public-facing API URL for browsers | `https://your-domain.com` |
| `CORS_ORIGINS` | Yes | Allowed CORS origins (comma-separated) | `https://your-domain.com,http://10.0.5.13:5000` |
| `SERVER_IP` | Yes | Server IP for internal communication | `10.0.5.13:8080` |
| `CLR_ICU_VERSION_OVERRIDE` | Recommended | ICU version override for .NET | `70` |

### Application Arguments

Both applications accept a command-line argument for server IP:

```bash
dotnet BlockchainDemonstratorApi.dll YOUR_SERVER_IP
dotnet BlockchainDemonstratorWebApp.dll YOUR_SERVER_IP
```

This IP is used for:
- API: Determines allowed CORS origins (`http://IP`, `https://IP`)
- WebApp: Server-side API calls (uses `localhost:5002` if `localhost` is specified)

### Ports

- **5000** - WebApp (MVC frontend)
- **5002** - API (REST endpoints and SignalR hub)
- **1433** - SQL Server (must be accessible on localhost)

## Troubleshooting

### Application shows "Development Mode"

**Cause:** `ASPNETCORE_ENVIRONMENT` not set to `Production`

**Fix:** Ensure environment variable is set in systemd service or deployment.env

```bash
systemctl status beergame-webapp | grep ASPNETCORE_ENVIRONMENT
```

### Database connection failed

**Cause:** SQL Server not accessible on `127.0.0.1:1433`

**Fix:** Check SQL Server status and connection string

```bash
systemctl status mssql-server
sqlcmd -S 127.0.0.1,1433 -U sa -P B33rgam3
```

### CORS errors in browser console

**Cause:** Domain not in CORS allowed origins

**Fix:** Add your domain to `CORS_ORIGINS` environment variable and restart services

```bash
# In deployment.env or systemd service
CORS_ORIGINS=https://your-domain.com,http://your-ip:5000

systemctl restart beergame-api beergame-webapp
```

### SignalR connection failed

**Cause:** `/GameHub` endpoint not routed to API

**Fix:** Ensure reverse proxy routes both `/api/*` and `/GameHub` to port 5002

### Can't login or create game

**Cause:** JavaScript calling wrong API URL

**Fix:** Verify `PUBLIC_API_URL` is set to public HTTPS domain

```bash
# Check logs for "Public API URL"
journalctl -u beergame-webapp -n 50 | grep "Public API URL"
```

### API not accessible from WebApp

**Cause:** API only listening on localhost

**Fix:** Verify API is listening on `0.0.0.0:5002` (should be default in `Program.cs`)

```bash
netstat -tlnp | grep 5002
# Should show: 0.0.0.0:5002 (not 127.0.0.1:5002)
```

## Security Considerations

1. **Change default database password** - Update connection string in `Startup.cs`
2. **Use HTTPS only** - Configure your reverse proxy to redirect HTTP → HTTPS
3. **Restrict CORS origins** - Only allow your specific domains in `CORS_ORIGINS`
4. **Firewall rules** - Only expose ports 80/443 publicly, keep 5000/5002 internal
5. **Regular updates** - Keep .NET Core and SQL Server updated

## Updating the Application

To update to a new version:

```bash
cd /root/blockchain-demonstrator-serious-game
git pull
systemctl stop beergame-api beergame-webapp
./install.sh  # Rebuild and publish
systemctl start beergame-api beergame-webapp
```

## Architecture Diagram

```
Internet
   ↓
[Reverse Proxy (Traefik/Nginx)]
   ├─→ /api, /GameHub → API (port 5002)
   │                      ├─→ REST endpoints
   │                      └─→ SignalR WebSocket
   └─→ /* → WebApp (port 5000)
              ├─→ MVC Views
              └─→ Client-side JavaScript → API (via PUBLIC_API_URL)
                                             ↓
                                    [SQL Server (port 1433)]
```

## Support

For issues or questions, check:
- Application logs: `journalctl -u beergame-api -f` and `journalctl -u beergame-webapp -f`
- Browser console (F12) for client-side errors
- Network tab in browser DevTools for API calls
