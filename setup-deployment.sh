#!/bin/bash
set -e

# Quick Deployment Setup Script for ZATCA App
# This script helps you set up the environment for Docker deployment

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ZATCA App - Docker Deployment Setup                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if .env already exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠  .env file already exists!${NC}"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Setup cancelled. Existing .env file preserved.${NC}"
        exit 0
    fi
fi

# Generate secrets
echo -e "${BLUE}[1/5]${NC} Generating secure secrets..."
ENCRYPTION_KEY=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -base64 32)

echo -e "${GREEN}✓ Encryption key generated (64 chars)${NC}"
echo -e "${GREEN}✓ JWT secret generated${NC}"
echo ""

# Ask for database configuration
echo -e "${BLUE}[2/5]${NC} Remote PostgreSQL Database Configuration..."
echo ""
echo -e "${YELLOW}⚠  This application requires a remote PostgreSQL database${NC}"
echo "Enter your PostgreSQL database connection details:"
echo ""
read -p "Database Host (e.g., mydb.example.com): " DB_HOST
if [ -z "$DB_HOST" ]; then
    echo -e "${RED}✗ Database host is required!${NC}"
    exit 1
fi

read -p "Database Port [5432]: " DB_PORT
DB_PORT=${DB_PORT:-5432}

read -p "Database Name [zatca]: " DB_NAME
DB_NAME=${DB_NAME:-zatca}

read -p "Database Username: " DB_USERNAME
if [ -z "$DB_USERNAME" ]; then
    echo -e "${RED}✗ Database username is required!${NC}"
    exit 1
fi

read -s -p "Database Password: " DB_PASSWORD
echo ""
if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}✗ Database password is required!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Database configuration set${NC}"
echo ""

# Ask for environment
echo -e "${BLUE}[3/5]${NC} ZATCA Environment Selection..."
echo ""
echo "Select ZATCA environment:"
echo "  1) Sandbox (Development/Testing) - Recommended for testing"
echo "  2) Simulation (Pre-Production Testing)"
echo "  3) Production - For live invoicing"
read -p "Enter choice [1]: " ENV_CHOICE
ENV_CHOICE=${ENV_CHOICE:-1}

if [ "$ENV_CHOICE" = "3" ]; then
    ZATCA_ENV="production"
    echo -e "${YELLOW}⚠  Production environment selected${NC}"
elif [ "$ENV_CHOICE" = "2" ]; then
    ZATCA_ENV="simulation"
    echo -e "${BLUE}✓ Simulation environment selected${NC}"
else
    ZATCA_ENV="sandbox"
    echo -e "${GREEN}✓ Sandbox environment selected${NC}"
fi
echo ""

# Ask for admin password
echo -e "${BLUE}[4/5]${NC} Admin User Configuration..."
echo ""
echo "Set admin password (or press Enter for default: Admin@123):"
read -s -p "Password: " ADMIN_PASSWORD
echo ""
if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD="Admin@123"
    ADMIN_HASH='$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
    echo -e "${YELLOW}Using default password: Admin@123${NC}"
else
    # Generate hash (requires Node.js)
    if command -v node &> /dev/null; then
        echo "Generating password hash..."
        ADMIN_HASH=$(node -e "const bcrypt = require('bcryptjs'); console.log(bcrypt.hashSync('$ADMIN_PASSWORD', 10));" 2>/dev/null || echo "")
        if [ -z "$ADMIN_HASH" ]; then
            echo -e "${YELLOW}⚠  Could not generate hash. Install bcryptjs: npm install -g bcryptjs${NC}"
            echo -e "${YELLOW}   Using default hash. Change password after first login.${NC}"
            ADMIN_HASH='$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
        else
            echo -e "${GREEN}✓ Custom password hash generated${NC}"
        fi
    else
        echo -e "${YELLOW}⚠  Node.js not found. Using default password hash.${NC}"
        ADMIN_HASH='$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
    fi
fi
echo ""

# Create .env file
echo -e "${BLUE}[5/5]${NC} Creating .env file..."

cat > .env << EOF
# ============================================
# ZATCA App - Docker Deployment Configuration
# ============================================
# Generated on: $(date)

# Remote Database Configuration
DATABASE_HOST=${DB_HOST}
DATABASE_PORT=${DB_PORT}
DATABASE_USERNAME=${DB_USERNAME}
DATABASE_PASSWORD=${DB_PASSWORD}
DATABASE_NAME=${DB_NAME}

# Security Configuration
ENCRYPTION_KEY=${ENCRYPTION_KEY}
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRES_IN=24h

# Admin User
ADMIN_USERNAME=admin
ADMIN_PASSWORD_HASH=${ADMIN_HASH}

# Application Configuration
NODE_ENV=production
PORT=3000
LOG_LEVEL=info

# ZATCA API Configuration (sandbox, simulation, or production)
ZATCA_ENVIRONMENT=${ZATCA_ENV}
ZATCA_SANDBOX_URL=https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal
ZATCA_PRODUCTION_URL=https://gw-fatoora.zatca.gov.sa/e-invoicing/core

# Optional
ZATCA_DEBUG_MODE=false
ENABLE_DEBUG_FILES=false
EOF

chmod 600 .env
echo -e "${GREEN}✓ .env file created and secured (chmod 600)${NC}"
echo ""

# Display summary
echo ""
echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
echo -e "${BLUE}Configuration Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Database Host:      ${GREEN}${DB_HOST}${NC}"
echo -e "Database Name:      ${GREEN}${DB_NAME}${NC}"
echo -e "Database User:      ${GREEN}${DB_USERNAME}${NC}"
echo -e "ZATCA Environment:  ${GREEN}${ZATCA_ENV}${NC}"
echo -e "Encryption Key:     ${YELLOW}${ENCRYPTION_KEY:0:20}...${NC}"
echo -e "JWT Secret:         ${YELLOW}${JWT_SECRET:0:20}...${NC}"
if [ "$ADMIN_PASSWORD" = "Admin@123" ]; then
    echo -e "Admin Password:     ${YELLOW}Admin@123 (default)${NC}"
else
    echo -e "Admin Password:     ${GREEN}Custom password set${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Important notes
echo -e "${YELLOW}📋 IMPORTANT: Save these credentials securely!${NC}"
echo ""
echo -e "${RED}⚠  BACKUP YOUR ENCRYPTION KEY:${NC}"
echo -e "   The encryption key is critical. Store it in a secure location:"
echo -e "   ${ENCRYPTION_KEY}"
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo ""
echo "1. Verify database connectivity:"
echo "   psql -h ${DB_HOST} -U ${DB_USERNAME} -d ${DB_NAME}"
echo ""
echo "2. Review the .env file (optional):"
echo "   nano .env"
echo ""
echo "3. Start the application:"
echo "   docker-compose up -d"
echo ""
echo "4. Check logs:"
echo "   docker-compose logs -f app"
echo ""
echo "5. Access the application:"
echo "   http://localhost:3000"
echo "   Username: admin"
if [ "$ADMIN_PASSWORD" = "Admin@123" ]; then
    echo "   Password: Admin@123"
else
    echo "   Password: <your custom password>"
fi
echo ""
echo -e "${GREEN}✨ Configuration saved to .env file!${NC}"
