@echo off
setlocal enabledelayedexpansion

REM Quick Deployment Setup Script for ZATCA App (Windows)
REM This script helps you set up the environment for Docker deployment

echo ================================================================
echo   ZATCA App - Docker Deployment Setup (Windows)
echo ================================================================
echo.

REM Check if .env already exists
if exist ".env" (
    echo WARNING: .env file already exists!
    set /p OVERWRITE="Do you want to overwrite it? (y/N): "
    if /i not "!OVERWRITE!"=="y" (
        echo Setup cancelled. Existing .env file preserved.
        exit /b 0
    )
)

echo.
echo [1/5] Generating secure secrets...

REM Generate encryption key (64 hex characters)
powershell -Command "$bytes = New-Object byte[] 32; (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes); -join ($bytes | ForEach-Object {$_.ToString('x2')})" > temp_key.txt
set /p ENCRYPTION_KEY=<temp_key.txt
del temp_key.txt

REM Generate JWT secret
powershell -Command "$bytes = New-Object byte[] 32; [Convert]::ToBase64String($bytes)" > temp_jwt.txt
set /p JWT_SECRET=<temp_jwt.txt
del temp_jwt.txt

echo [OK] Encryption key generated (64 chars)
echo [OK] JWT secret generated
echo.

REM Ask for database configuration
echo [2/5] Remote PostgreSQL Database Configuration...
echo.
echo WARNING: This application requires a remote PostgreSQL database
echo Enter your PostgreSQL database connection details:
echo.

set /p DB_HOST="Database Host (e.g., mydb.example.com): "
if "!DB_HOST!"=="" (
    echo ERROR: Database host is required!
    exit /b 1
)

set /p DB_PORT="Database Port [5432]: "
if "!DB_PORT!"=="" set DB_PORT=5432

set /p DB_NAME="Database Name [zatca]: "
if "!DB_NAME!"=="" set DB_NAME=zatca

set /p DB_USERNAME="Database Username: "
if "!DB_USERNAME!"=="" (
    echo ERROR: Database username is required!
    exit /b 1
)

set /p DB_PASSWORD="Database Password: "
if "!DB_PASSWORD!"=="" (
    echo ERROR: Database password is required!
    exit /b 1
)

echo [OK] Database configuration set
echo.

REM Ask for environment
echo [3/5] ZATCA Environment Selection...
echo.
echo Select ZATCA environment:
echo   1) Sandbox (Development/Testing) - Recommended for testing
echo   2) Simulation (Pre-Production Testing)
echo   3) Production - For live invoicing

set /p ENV_CHOICE="Enter choice [1]: "
if "!ENV_CHOICE!"=="" set ENV_CHOICE=1

if "!ENV_CHOICE!"=="3" (
    set ZATCA_ENV=production
    echo WARNING: Production environment selected
) else if "!ENV_CHOICE!"=="2" (
    set ZATCA_ENV=simulation
    echo [OK] Simulation environment selected
) else (
    set ZATCA_ENV=sandbox
    echo [OK] Sandbox environment selected
)
echo.

REM Ask for admin password
echo [4/5] Admin User Configuration...
echo.
echo Set admin password (or press Enter for default: Admin@123):
set /p ADMIN_PASSWORD="Password: "

if "!ADMIN_PASSWORD!"=="" (
    set ADMIN_PASSWORD=Admin@123
    set ADMIN_HASH=$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
    echo Using default password: Admin@123
) else (
    echo WARNING: Custom password set. Using default hash.
    echo Please change password after first login.
    set ADMIN_HASH=$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
)
echo.

REM Create .env file
echo [5/5] Creating .env file...

(
echo # ============================================
echo # ZATCA App - Docker Deployment Configuration
echo # ============================================
echo # Generated on: %DATE% %TIME%
echo.
echo # Remote Database Configuration
echo DATABASE_HOST=!DB_HOST!
echo DATABASE_PORT=!DB_PORT!
echo DATABASE_USERNAME=!DB_USERNAME!
echo DATABASE_PASSWORD=!DB_PASSWORD!
echo DATABASE_NAME=!DB_NAME!
echo.
echo # Security Configuration
echo ENCRYPTION_KEY=!ENCRYPTION_KEY!
echo JWT_SECRET=!JWT_SECRET!
echo JWT_EXPIRES_IN=24h
echo.
echo # Admin User
echo ADMIN_USERNAME=admin
echo ADMIN_PASSWORD_HASH=!ADMIN_HASH!
echo.
echo # Application Configuration
echo NODE_ENV=production
echo PORT=3000
echo LOG_LEVEL=info
echo.
echo # ZATCA API Configuration (sandbox, simulation, or production)
echo ZATCA_ENVIRONMENT=!ZATCA_ENV!
echo ZATCA_SANDBOX_URL=https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal
echo ZATCA_PRODUCTION_URL=https://gw-fatoora.zatca.gov.sa/e-invoicing/core
echo.
echo # Optional
echo ZATCA_DEBUG_MODE=false
echo ENABLE_DEBUG_FILES=false
) > .env

echo [OK] .env file created
echo.

REM Display summary
echo.
echo [OK] Setup complete!
echo.
echo Configuration Summary
echo ================================================================
echo Database Host:      !DB_HOST!
echo Database Name:      !DB_NAME!
echo Database User:      !DB_USERNAME!
echo ZATCA Environment:  !ZATCA_ENV!
echo Encryption Key:     !ENCRYPTION_KEY:~0,20!...
echo JWT Secret:         !JWT_SECRET:~0,20!...
if "!ADMIN_PASSWORD!"=="Admin@123" (
    echo Admin Password:     Admin@123 (default)
) else (
    echo Admin Password:     Custom password set
)
echo ================================================================
echo.

REM Important notes
echo IMPORTANT: Save these credentials securely!
echo.
echo WARNING: BACKUP YOUR ENCRYPTION KEY:
echo The encryption key is critical. Store it in a secure location:
echo !ENCRYPTION_KEY!
echo.
echo Next Steps:
echo.
echo 1. Verify database connectivity (if psql is installed):
echo    psql -h !DB_HOST! -U !DB_USERNAME! -d !DB_NAME!
echo.
echo 2. Review the .env file (optional):
echo    notepad .env
echo.
echo 3. Start the application:
echo    docker-compose up -d
echo.
echo 4. Check logs:
echo    docker-compose logs -f app
echo.
echo 5. Access the application:
echo    http://localhost:3000
echo    Username: admin
if "!ADMIN_PASSWORD!"=="Admin@123" (
    echo    Password: Admin@123
) else (
    echo    Password: ^<your custom password^>
)
echo.
echo Configuration saved to .env file!
echo.

endlocal

