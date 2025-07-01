#!/bin/bash

# Azure Infrastructure Setup Script for k8s-demo-pr-agent
# This script creates the necessary Azure resources for the demo

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Azure Infrastructure Setup for k8s-demo-pr-agent${NC}"
echo "=================================================="

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo -e "${RED}Please login to Azure first: az login${NC}"
    exit 1
fi

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo -e "${GREEN}Using subscription: $SUBSCRIPTION_ID${NC}"

# Prompt for main resource group name
read -p "Enter main resource group name (default: k8s-demo-rg): " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-k8s-demo-rg}

# Prompt for location
read -p "Enter Azure location (default: eastus): " LOCATION
LOCATION=${LOCATION:-eastus}

# Prompt for ACR resource group name
read -p "Enter ACR resource group name (default: k8s-demo-acr-rg): " ACR_RESOURCE_GROUP
ACR_RESOURCE_GROUP=${ACR_RESOURCE_GROUP:-k8s-demo-acr-rg}

# Prompt for ACR name
read -p "Enter Azure Container Registry name (default: k8sdemoacr): " ACR_NAME
ACR_NAME=${ACR_NAME:-k8sdemoacr}

# Prompt for storage account name
read -p "Enter Storage Account name (default: k8sdemostorage): " STORAGE_ACCOUNT
STORAGE_ACCOUNT=${STORAGE_ACCOUNT:-k8sdemostorage}

echo -e "${YELLOW}Creating main resource group...${NC}"
az group create --name $RESOURCE_GROUP --location $LOCATION

echo -e "${YELLOW}Creating ACR resource group...${NC}"
az group create --name $ACR_RESOURCE_GROUP --location $LOCATION

echo -e "${YELLOW}Creating Azure Container Registry in $ACR_RESOURCE_GROUP...${NC}"
az acr create \
    --resource-group $ACR_RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled true

echo -e "${YELLOW}Creating Storage Account in $RESOURCE_GROUP...${NC}"
az storage account create \
    --resource-group $RESOURCE_GROUP \
    --name $STORAGE_ACCOUNT \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2

echo -e "${YELLOW}Creating Log Analytics Workspace in $RESOURCE_GROUP...${NC}"
az monitor log-analytics workspace create \
    --resource-group $RESOURCE_GROUP \
    --workspace-name k8s-demo-workspace \
    --location $LOCATION

# Get ACR credentials
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --query passwords[0].value -o tsv)

# Get Log Analytics Workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
    --resource-group $RESOURCE_GROUP \
    --workspace-name k8s-demo-workspace \
    --query customerId -o tsv)

echo -e "${GREEN}Infrastructure created successfully!${NC}"
echo ""
echo -e "${YELLOW}Required GitHub Secrets:${NC}"
echo "=================================="
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "ACR_RESOURCE_GROUP: $ACR_RESOURCE_GROUP"
echo "LOCATION: $LOCATION"
echo "ACR_NAME: $ACR_NAME"
echo "ACR_USERNAME: $ACR_USERNAME"
echo "ACR_PASSWORD: $ACR_PASSWORD"
echo "STORAGE_ACCOUNT_NAME: $STORAGE_ACCOUNT"
echo "LOG_ANALYTICS_WORKSPACE_ID: $WORKSPACE_ID"
echo ""
echo -e "${YELLOW}To create Azure credentials for GitHub Actions:${NC}"
echo "az ad sp create-for-rbac --name k8s-demo-sp --role contributor --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$ACR_RESOURCE_GROUP --sdk-auth"
echo ""
echo -e "${GREEN}Setup complete!${NC}" 