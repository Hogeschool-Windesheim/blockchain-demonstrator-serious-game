# Blockchain Demonstrator Deployment Plan

**Date Created:** 2025-10-06
**Status:** 🟡 In Progress
**Server:** 10.0.5.13
**Target Environment:** Production

---

## Executive Summary

This deployment plan addresses production deployment issues for the Blockchain Demonstrator Serious Game application. The primary issue is that the application runs in Development mode instead of Production mode, preventing proper login and gameplay functionality.

---

## Current State Analysis

### Technology Stack
- **Framework:** ASP.NET Core 3.1
- **Language:** C#
- **Components:**
  - BlockchainDemonstratorWebApp (Frontend MVC) - Port 5000
  - BlockchainDemonstratorApi (Backend REST API) - Port 5002
  - SQL Server 2019 (Docker container) - Port 1433
- **Web Server:** Nginx (reverse proxy on ports 80 and 8080)
- **Platform:** Linux (Debian-based)

### Identified Issues

| Issue # | Severity | Description | Impact |
|---------|----------|-------------|---------|
| 1 | 🔴 Critical | `ASPNETCORE_ENVIRONMENT` not set to Production | Application runs in Development mode, preventing login/gameplay |
| 2 | 🔴 Critical | API URL configuration mismatch | WebApp cannot communicate with API properly |
| 3 | 🟡 High | Database connection string points to 127.0.0.1 instead of Docker container | Potential database connection failures |
| 4 | 🟡 High | Applications not currently running | Service is down |
| 5 | 🟢 Low | Docker Compose not installed | Not blocking (using direct dotnet run) |

### Root Cause Analysis

**WebApp Startup.cs (Lines 41-48):**
```csharp
if (env.IsDevelopment())
{
    Config.RestApiUrl = "https://localhost:44393";  // Development mode
    app.UseDeveloperExceptionPage();
}
else
{
    Config.RestApiUrl = $"http://{Config.ServerIp}";  // Production mode
    // ...
}
```

**Problem:** The environment is defaulting to Development because `ASPNETCORE_ENVIRONMENT` variable is not explicitly set to "Production" when launching the application.

---

## Sprint Backlog

### Sprint Goal
Deploy Blockchain Demonstrator application to production server with proper environment configuration, enabling full login and gameplay functionality.

---

## Task Breakdown

### Epic 1: Environment Configuration ⏳
**Priority:** P0 - Critical
**Estimated Effort:** 2 hours

#### Task 1.1: Fix start.sh script to set Production environment
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Update start.sh to export ASPNETCORE_ENVIRONMENT=Production
- **Acceptance Criteria:**
  - [ ] start.sh exports ASPNETCORE_ENVIRONMENT=Production
  - [ ] Variable is available to both WebApp and API processes
- **Technical Details:**
  - Add `export ASPNETCORE_ENVIRONMENT=Production` before launching apps
  - Verify environment variable is propagated correctly

#### Task 1.2: Fix API URL configuration for production
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Ensure WebApp connects to API on correct port (8080 via nginx)
- **Acceptance Criteria:**
  - [ ] Config.ServerIp is set correctly (10.0.5.13:8080 or demonstrator.valuechainhackers.xyz)
  - [ ] WebApp can reach API endpoint
- **Technical Details:**
  - Review nginx configuration (port 8080 → 5002)
  - Update ServerIp parameter passed to applications

#### Task 1.3: Verify database connection configuration
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Ensure database connection string points to Docker container
- **Acceptance Criteria:**
  - [ ] Connection string uses correct SQL Server IP (Docker container)
  - [ ] Application can connect to database successfully
- **Technical Details:**
  - Verify Docker container IP (currently should be dynamic or use container name)
  - Test database connectivity

---

### Epic 2: Deployment Scripts Enhancement ⏳
**Priority:** P0 - Critical
**Estimated Effort:** 1 hour

#### Task 2.1: Update start.sh with production environment variables
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Modify start.sh to properly set all environment variables
- **Acceptance Criteria:**
  - [ ] Script sets ASPNETCORE_ENVIRONMENT=Production
  - [ ] Script sets CLR_ICU_VERSION_OVERRIDE=70
  - [ ] Script passes correct ServerIp to both applications
- **Files to Modify:**
  - `start.sh`

#### Task 2.2: Create environment validation script
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Create script to validate environment before deployment
- **Acceptance Criteria:**
  - [ ] Script checks Docker is running
  - [ ] Script checks database container is running
  - [ ] Script verifies ports 80, 8080, 5000, 5002, 1433 are available/configured
  - [ ] Script validates .NET Core 3.1 is installed
- **Deliverable:** `validate-environment.sh`

---

### Epic 3: Service Management ⏳
**Priority:** P1 - High
**Estimated Effort:** 1.5 hours

#### Task 3.1: Create systemd service files for auto-restart
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Create systemd service files for production deployment
- **Acceptance Criteria:**
  - [ ] Service files created for WebApp and API
  - [ ] Services start automatically on server boot
  - [ ] Services restart on failure
  - [ ] Proper logging configured
- **Deliverables:**
  - `beergame-webapp.service`
  - `beergame-api.service`

#### Task 3.2: Update install.sh to install services
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Modify install script to set up systemd services
- **Acceptance Criteria:**
  - [ ] install.sh copies service files to /etc/systemd/system/
  - [ ] Script enables services
  - [ ] Script starts services after installation

---

### Epic 4: Testing & Validation ⏳
**Priority:** P0 - Critical
**Estimated Effort:** 2 hours

#### Task 4.1: Test database connectivity
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Verify SQL Server container is running and accessible
- **Acceptance Criteria:**
  - [ ] Database container is running
  - [ ] Can connect to database from host
  - [ ] Database schema is initialized
- **Test Commands:**
  ```bash
  docker ps | grep database
  docker logs database
  ```

#### Task 4.2: Test application startup in Production mode
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Start applications and verify they run in Production mode
- **Acceptance Criteria:**
  - [ ] Applications start without errors
  - [ ] Environment is set to Production (check logs)
  - [ ] Both processes are running
  - [ ] Ports 5000 and 5002 are listening
- **Test Commands:**
  ```bash
  ps aux | grep dotnet
  netstat -tulpn | grep -E '(5000|5002)'
  curl http://localhost:5000
  curl http://localhost:5002/api/health  # if health endpoint exists
  ```

#### Task 4.3: End-to-end functionality test (AUTOMATED)
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Automated test of complete game flow - admin login, game creation, 4 players joining
- **Acceptance Criteria:**
  - [ ] Automated test script runs successfully
  - [ ] Can create admin account via API
  - [ ] Admin can log in via API
  - [ ] Can create a new game session
  - [ ] Player 1 (Retailer) can join game
  - [ ] Player 2 (Manufacturer) can join game
  - [ ] Player 3 (Processor) can join game
  - [ ] Player 4 (Farmer) can join game
  - [ ] All 4 players verified in game state
  - [ ] Database connectivity confirmed
  - [ ] No "Development mode" errors
  - [ ] Can access application via http://10.0.5.13
  - [ ] Can access API via http://10.0.5.13:8080
- **Automation Script:** `test-e2e-deployment.sh`
- **Test Flow:**
  1. ✓ Verify WebApp is accessible (HTTP 200)
  2. ✓ Verify API is accessible (HTTP 200)
  3. ✓ Check environment is Production (no "development mode" text)
  4. ✓ Create test admin account
  5. ✓ Login as admin (POST /api/BeerGame/Login)
  6. ✓ Create new game (POST /api/BeerGame/CreateGame)
  7. ✓ Join as Retailer (POST /api/BeerGame/JoinGame with role=0)
  8. ✓ Join as Manufacturer (POST /api/BeerGame/JoinGame with role=1)
  9. ✓ Join as Processor (POST /api/BeerGame/JoinGame with role=2)
  10. ✓ Join as Farmer (POST /api/BeerGame/JoinGame with role=3)
  11. ✓ Verify all 4 players in game (GET /api/BeerGame/GetGame)
  12. ✓ Verify database connectivity
- **Usage:**
  ```bash
  # Run on server
  chmod +x test-e2e-deployment.sh
  ./test-e2e-deployment.sh

  # Or with custom URLs
  API_URL=http://10.0.5.13:8080/api WEBAPP_URL=http://10.0.5.13 ./test-e2e-deployment.sh
  ```
- **Success Output:**
  ```
  ✓ ALL TESTS PASSED!
  ✓ Deployment is successful and ready for production use!
  ```

---

### Epic 5: Documentation & Cleanup ⏳
**Priority:** P2 - Medium
**Estimated Effort:** 1 hour

#### Task 5.1: Update README with production deployment instructions
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Add production-specific deployment instructions to README
- **Acceptance Criteria:**
  - [ ] README includes environment variable requirements
  - [ ] README documents systemd service usage
  - [ ] Troubleshooting section added

#### Task 5.2: Create troubleshooting guide
- **Status:** ⬜ To Do
- **Assignee:** Claude
- **Description:** Document common issues and solutions
- **Deliverable:** `TROUBLESHOOTING.md`
- **Content:**
  - Environment detection issues
  - Database connection problems
  - Port conflicts
  - Log locations

---

## Implementation Plan

### Phase 1: Pre-Deployment (Critical Path)
1. ✅ Analyze current state and identify issues
2. ✅ Create deployment plan
3. ⬜ Fix start.sh with environment variables
4. ⬜ Verify database configuration
5. ⬜ Create environment validation script

### Phase 2: Deployment
1. ⬜ Stop any running instances
2. ⬜ Pull latest code changes
3. ⬜ Run environment validation
4. ⬜ Start applications with production environment
5. ⬜ Verify production mode is active

### Phase 3: Service Hardening
1. ⬜ Create systemd service files
2. ⬜ Install and enable services
3. ⬜ Configure auto-restart on failure

### Phase 4: Testing & Validation
1. ⬜ Database connectivity test
2. ⬜ Application startup test
3. ⬜ End-to-end functionality test
4. ⬜ Load testing (optional)

### Phase 5: Documentation
1. ⬜ Update README
2. ⬜ Create troubleshooting guide
3. ⬜ Document production configuration

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| Database container not persistent | Medium | High | Verify volume mounts, create backup strategy |
| Port conflicts on server | Low | Medium | Pre-deployment port validation script |
| Environment variable not propagated | Low | High | Explicit testing in Task 4.2 |
| Nginx misconfiguration | Low | Medium | Review nginx config, test reverse proxy |
| Application crashes on startup | Medium | High | Check logs immediately, validate dependencies |

---

## Success Criteria

- [ ] Application runs in Production environment (not Development)
- [ ] Users can successfully log in
- [ ] Users can create and play games
- [ ] Application survives server restart (systemd services)
- [ ] No critical errors in logs
- [ ] All acceptance criteria for P0 and P1 tasks met

---

## Rollback Plan

If deployment fails:
1. Stop all dotnet processes: `pkill -f dotnet`
2. Restore previous start.sh: `git checkout HEAD~1 start.sh`
3. Review logs: `journalctl -u beergame-* -n 100`
4. Document errors and create new task ticket

---

## Timeline

| Phase | Estimated Duration | Target Completion |
|-------|-------------------|-------------------|
| Phase 1: Pre-Deployment | 2 hours | Day 1 |
| Phase 2: Deployment | 30 minutes | Day 1 |
| Phase 3: Service Hardening | 1.5 hours | Day 1-2 |
| Phase 4: Testing | 2 hours | Day 2 |
| Phase 5: Documentation | 1 hour | Day 2 |
| **Total** | **7 hours** | **2 days** |

---

## Progress Tracking

**Last Updated:** 2025-10-06
**Overall Progress:** 15% (Analysis complete, ready for implementation)

### Completed Tasks
- ✅ Current state analysis
- ✅ Issue identification
- ✅ Root cause analysis
- ✅ Deployment plan creation

### In Progress
- 🔄 Awaiting approval to begin implementation

### Blocked
- None

---

## Notes & Decisions

### Decision Log
1. **2025-10-06:** Decided to use systemd services instead of manual start scripts for better service management
2. **2025-10-06:** Will keep Docker for database only, not containerizing the .NET apps (matches current setup)

### Open Questions
- ❓ Should we set up HTTPS/SSL certificates? (Currently using HTTP only)
- ❓ Do we need monitoring/alerting setup?
- ❓ What is the backup strategy for the database?

---

## Appendix

### Key Configuration Files
- `start.sh` - Application startup script
- `install.sh` - Initial installation script
- `BlockchainDemonstratorApi/appsettings.json` - API configuration
- `BlockchainDemonstratorWebApp/Startup.cs` - WebApp configuration
- `/etc/nginx/sites-available/blockchain-demo.conf` - Nginx configuration

### Useful Commands
```bash
# Check running processes
ps aux | grep dotnet

# Check database container
docker ps | grep database
docker logs database

# Check nginx status
systemctl status nginx
nginx -t

# Check application logs
journalctl -u beergame-webapp -f
journalctl -u beergame-api -f

# Test ports
netstat -tulpn | grep -E '(80|8080|5000|5002|1433)'
```

### Server Details
- **IP:** 10.0.5.13
- **OS:** Linux Development-Beergame03 6.8.12-13-pve
- **Domain:** demonstrator.valuechainhackers.xyz
- **Open Ports:** 80 (WebApp), 8080 (API via nginx)
