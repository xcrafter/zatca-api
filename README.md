# ZATCA App Deployment Guide

Complete guide to deploy and run the ZATCA API Service using Docker from Docker Hub.

## Table of Contents

- [One-Click Deploy](#one-click-deploy)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Docker Compose Deployment](#docker-compose-deployment)
- [Configuration](#configuration)
- [Health Checks](#health-checks)
- [Troubleshooting](#troubleshooting)

---

## Database Requirements

This application requires a **Remote PostgreSQL** database connection:

- ✅ Use existing database infrastructure
- ✅ Production-ready (AWS RDS, Azure Database, Google Cloud SQL, etc.)
- ✅ Supports centralized database for multiple app instances
- ✅ Better security and scalability

---

## One-Click Deploy

Deploy quickly to cloud platforms with a single click:

### Deploy to Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/YOUR_GITHUB_USERNAME/zatca-api)

**Note:** You'll need to provide your PostgreSQL database credentials during setup. Render will automatically generate secure keys for `ENCRYPTION_KEY` and `JWT_SECRET`.

### Deploy to Google Cloud Run

[![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://deploy.cloud.run/?git_repo=https://github.com/YOUR_GITHUB_USERNAME/zatca-api)

**Note:** After clicking the button:

1. Select your Google Cloud project
2. The app will deploy using the `cloudrun.yaml` configuration
3. Set your database credentials and secrets via Cloud Console or Secret Manager
4. The service will be accessible via a Cloud Run URL

**Prerequisites for Cloud Deploy:**

- A remote PostgreSQL database (AWS RDS, Google Cloud SQL, Azure Database, etc.)
- Database should be accessible from the cloud platform
- Admin password must be hashed (use bcrypt with 10 rounds)

**Alternative:** For more control, follow the [Quick Start](#quick-start) guide below for local deployment or custom cloud setup.

---

## Quick Start

Get up and running in 3 steps:

**Linux/macOS:**

```bash
# 1. Run the setup script (will prompt for database details)
chmod +x setup-deployment.sh
./setup-deployment.sh

# 2. Start the application
docker-compose up -d

# 3. Check logs
docker-compose logs -f app
```

**Windows:**

```cmd
# 1. Run the setup script (will prompt for database details)
setup-deployment.bat

# 2. Start the application
docker-compose up -d

# 3. Check logs
docker-compose logs -f app
```

Access the application at: **http://localhost:3000**

**Note:** You need a remote PostgreSQL database (AWS RDS, Azure, Google Cloud SQL, etc.) ready before starting.

---

## Application Access

After starting the application, you can access:

- **API Endpoint**: http://localhost:3000
- **Web UI**: http://localhost:3000/ui
- **API Documentation (Swagger)**: http://localhost:3000/api-docs

**⚠️ Authentication Required:** You must be authenticated to access both the UI and API documentation. Use the admin credentials you configured during setup (default: `admin` / `Admin@123`).

**📖 Getting Started:** Check the API documentation at `/api-docs` to understand how to use the service, including available endpoints, request/response formats, and integration examples.

---

## Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Remote PostgreSQL Database**: Version 12 or higher (AWS RDS, Azure Database, etc.)
- **2GB RAM**: Minimum recommended
- **Ports Available**: 3000 (app)

### Install Docker

**Windows/macOS:**

- Download Docker Desktop: https://www.docker.com/products/docker-desktop
- Ensure WSL 2 is enabled (Windows only)

**Linux (Ubuntu/Debian):**

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**Verify Installation:**

```bash
docker --version
docker-compose --version
```

---

## Environment Setup

Run the setup script to automatically configure your environment:

**Linux/macOS:**

```bash
chmod +x setup-deployment.sh
./setup-deployment.sh
```

**Windows:**

```cmd
setup-deployment.bat
```

**Note for Windows users:** The script requires PowerShell to generate secure keys. PowerShell is included by default in Windows 7 and later.

The script will:

- Generate encryption key and JWT secret automatically
- Prompt for your remote PostgreSQL database credentials
- Configure ZATCA environment (sandbox/simulation/production)
- Set admin password
- Create `.env` file with all settings

**Manual Setup (Optional):** If you prefer manual configuration, create a `.env` file with the required variables listed in the [Configuration](#configuration) section

---

## Docker Compose Deployment

Ensure your remote PostgreSQL database is accessible and configured with the credentials you provided during setup.

### Start the Application

```bash
# Start the application
docker-compose up -d

# View logs
docker-compose logs -f app
```

### Common Commands

```bash
# Stop application
docker-compose down

# Restart application
docker-compose restart app

# Update to latest version
docker-compose pull app && docker-compose up -d app

# View logs
docker-compose logs -f app
```

---

## Configuration

### Required Environment Variables

| Variable            | Description            | Example          | Required |
| ------------------- | ---------------------- | ---------------- | -------- |
| `DATABASE_HOST`     | PostgreSQL hostname    | `postgres`       | ✅ Yes   |
| `DATABASE_PORT`     | PostgreSQL port        | `5432`           | ✅ Yes   |
| `DATABASE_USERNAME` | Database username      | `postgres`       | ✅ Yes   |
| `DATABASE_PASSWORD` | Database password      | `SecurePass123!` | ✅ Yes   |
| `DATABASE_NAME`     | Database name          | `zatca`          | ✅ Yes   |
| `ENCRYPTION_KEY`    | 64-char encryption key | Generated hex    | ✅ Yes   |
| `JWT_SECRET`        | JWT signing secret     | Random string    | ✅ Yes   |

### Optional Environment Variables

| Variable            | Description       | Default      | Example                               |
| ------------------- | ----------------- | ------------ | ------------------------------------- |
| `NODE_ENV`          | Environment mode  | `production` | `development`                         |
| `PORT`              | Application port  | `3000`       | `8080`                                |
| `LOG_LEVEL`         | Logging level     | `info`       | `debug`, `error`                      |
| `ZATCA_ENVIRONMENT` | ZATCA environment | `sandbox`    | `sandbox`, `simulation`, `production` |

### ZATCA API Environments

**Sandbox (Development/Testing):**

```env
ZATCA_ENVIRONMENT=sandbox
```

**Simulation (Pre-Production Testing):**

```env
ZATCA_ENVIRONMENT=simulation
```

**Production:**

```env
ZATCA_ENVIRONMENT=production
```

---

## Health Checks

```bash
# Check application status
docker-compose ps

# Check if app is responding
curl http://localhost:3000/

# View application logs
docker-compose logs -f app
```

---

## Troubleshooting

### Common Issues

**Check logs first:**

```bash
docker-compose logs --tail=100 app
```

**Connection Issues:**

- Verify remote PostgreSQL database is accessible
- Check firewall rules allow connections
- Verify credentials in `.env` file

**Application Won't Start:**

- Ensure `ENCRYPTION_KEY` is exactly 64 characters
- Verify all required environment variables are set
- Check port 3000 is not already in use

**Reset Application:**

```bash
docker-compose down
nano .env  # Update configuration if needed
docker-compose up -d
```

---

## Maintenance

### Update Application

```bash
docker-compose pull app
docker-compose up -d app
docker-compose logs -f app
```

**Important:**

- Use `ZATCA_ENVIRONMENT=production` for live invoicing
- Secure your `.env` file: `chmod 600 .env`
- Back up your `ENCRYPTION_KEY` in a secure location
- Set up regular database backups
- Set up a new EGS for every invoicing device, else it will create issues in invoice chains due to race conditions

## Quick Reference

### Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Logs
docker-compose logs -f app

# Update
docker-compose pull app && docker-compose up -d app

# Restart
docker-compose restart app

# Status
docker-compose ps
```

### Endpoints

- **API**: http://localhost:3000
- **Web UI**: http://localhost:3000/ui
- **API Documentation**: http://localhost:3000/api-docs

**Default Login:** `admin` / `Admin@123` (or your custom password)

💡 **Tip:** Visit `/api-docs` after logging in to explore all available endpoints and learn how to integrate with the service.

---

## Support

Need help with production deployment or hosting setup?

**Email:** [manzoorsamad.in@gmail.com](mailto:manzoorsamad.in@gmail.com)

We provide assisted guidance for:

- Full Code Access
- Production environment setup and configuration
- Cloud hosting deployment (AWS, Azure, Google Cloud)
- Database setup and optimization
- SSL/HTTPS configuration
- Performance tuning and scaling
- Custom deployment requirements
- Assistance on integrating the service with your ERP
