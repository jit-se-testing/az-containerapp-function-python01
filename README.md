# Azure Container Apps & Functions Demo for Jit

This repository demonstrates deploying applications to Azure, focusing on integrating security scanning with Jit. It includes:

1. **Vulnerable Flask App to Azure Container Apps:** A Python Flask application with numerous deliberate vulnerabilities deployed to Azure Container Apps via GitHub Actions.
2. **Vulnerable Azure Function:** A simple Azure Function (Python) with commented vulnerable code patterns, deployed with a public API endpoint using GitHub Actions.

## Resource Group Structure

- The main application resources (Container Apps, Function App, Log Analytics, Storage) are created in one resource group (e.g., `k8s-demo-rg`).
- The Azure Container Registry (ACR) is created in a separate resource group (e.g., `k8s-demo-acr-rg`).

## Architecture Diagram

```mermaid
flowchart TD
    A[Push to main branch]
    
    subgraph Deploy1[Container Apps Workflow]
        B1[Checkout Code]
        B2[Configure Azure]
        B3[Login to ACR]
        B4[Build Image]
        B5[Push Image]
        B6[Deploy to Container Apps]
        B7[Deploy Jit Agent]
    end
    
    subgraph Deploy2[Function App Workflow]
        C1[Checkout Code]
        C2[Configure Azure]
        C3[Setup Python]
        C4[Deploy Function App]
    end
    
    subgraph Azure[Azure Resources]
        D1[ACR Repository (separate RG)]
        D2[Container Apps Environment]
        D3[Function App]
        D4[API Management]
        D5[Jit Agent]
    end
    
    A --> B1
    A --> C1
    
    B1 --> B2 --> B3 --> B4 --> B5
    B5 --> D1
    B2 --> B6
    B6 --> D2
    B6 --> B7
    B7 --> D5
    
    C1 --> C2 --> C3 --> C4
    C4 --> D3
    C4 --> D4
    
    style D1 fill:#f9f,stroke:#333
    style D2 fill:#f9f,stroke:#333
    style D3 fill:#f9f,stroke:#333
    style D4 fill:#f9f,stroke:#333
    style D5 fill:#ccf,stroke:#333
```

## Components

### 1. Flask Application (Container Apps Deployment)

- **`app/`**: Contains the Python Flask application source code (`app/src/app.py`) with over 20 deliberately introduced vulnerabilities (SQLi, XSS, Command Injection, SSRF, Hardcoded Secrets, etc.) for SAST/DAST demonstration.
- **`container-apps/`**: Azure Container Apps configuration files:
  - `container-app.yaml`: Defines the Container App configuration for the Flask app.
  - `environment.yaml`: Defines the Container Apps Environment.
- **`.github/workflows/deploy-container-app.yaml`**: GitHub Actions workflow that:
  - Builds the Flask app Docker image.
  - Pushes the image to Azure Container Registry (ACR).
  - Deploys the application to Azure Container Apps.
  - Installs/updates the Jit Container Apps Agent.

### 2. Azure Function (Function App Deployment)

- **`function-app/`**: Contains the Azure Function code with vulnerability patterns.
  - `function_app.py`: The Python code for the Azure Function, including comments highlighting potential vulnerability patterns.
  - `host.json`: Function App host configuration.
  - `local.settings.json`: Local development settings (not deployed).
- **`.github/workflows/deploy-function-app.yaml`**: GitHub Actions workflow that:
  - Deploys the Azure Function App to Azure.
  - Configures the API Management integration.

## Setup & Deployment

**Prerequisites:**

- Azure Subscription
- Azure CLI configured locally (optional, for manual setup/testing)
- Jit Account & Credentials

**Steps:**

1. **Fork this repository.**
2. **Configure GitHub Secrets:** Navigate to your forked repository -> Settings -> Secrets and variables -> Actions. Add the following secrets:
   - `AZURE_CLIENT_ID`: Service Principal Client ID for Azure authentication.
   - `AZURE_CLIENT_SECRET`: Service Principal Client Secret.
   - `AZURE_SUBSCRIPTION_ID`: Your Azure Subscription ID.
   - `RESOURCE_GROUP`: Name of your main Azure Resource Group.
   - `ACR_RESOURCE_GROUP`: Name of your ACR Resource Group.
   - `LOCATION`: Azure region for deployment (e.g., `eastus`).
   - `ACR_NAME`: Name of your Azure Container Registry.
   - `ACR_USERNAME`: Username for your ACR (from setup script output).
   - `ACR_PASSWORD`: Password for your ACR (from setup script output).
   - `STORAGE_ACCOUNT_NAME`: Name of your Storage Account.
   - `LOG_ANALYTICS_WORKSPACE_ID`: Log Analytics Workspace ID.
   - `JIT_CLIENT_ID`: From your Jit account (for the Container Apps deployment).
   - `JIT_CLIENT_SECRET`: From your Jit account.
3. **Create Azure Infrastructure:**
   - **Container Registry:** Create an ACR instance in your chosen region and resource group.
   - **Resource Groups:** Create a main resource group for the demo resources and a separate one for ACR.
   - **Container Apps Environment:** The workflow will create this automatically.
   - **Function App:** The workflow will create this automatically.
   - **Service Principal:** Create a service principal with sufficient permissions (ACR push/pull, Container Apps management, Function App management, etc.).
4. **Push to `main` Branch:** Committing and pushing changes to the `main` branch will trigger both GitHub Actions workflows:
   - `deploy-container-app.yaml` will deploy the Flask app to Container Apps.
   - `deploy-function-app.yaml` will deploy the Azure Function.

## Security Issues & Purpose

This repository contains **deliberately introduced vulnerabilities** in both the Flask application and the Azure Function patterns for demonstration purposes, primarily for security scanning tools like Jit.

**Key vulnerabilities demonstrated:**

- **Flask App:** SQL Injection, Cross-Site Scripting (Reflected & Stored), OS Command Injection, Path Traversal, Server-Side Request Forgery (SSRF), Insecure Deserialization, XXE, Insecure File Upload, IDOR, Open Redirect, Missing Access Control, Weak Hashing, CSRF (conceptual), Hardcoded Credentials, Security Misconfiguration (Debug Mode, Headers, Binding).
- **Azure Function (Patterns):** Potential for NoSQL Injection, Information Leakage, Insecure Environment Variable Handling, Hardcoded Secrets, Unvalidated Input, Insecure Data Handling, Missing Security Headers.

**DO NOT USE THIS CODE OR THESE CONFIGURATIONS IN PRODUCTION ENVIRONMENTS!** It is designed solely for educational and security testing purposes.

## Azure Services Used

- **Azure Container Registry (ACR)**: For storing Docker images (in a separate resource group)
- **Azure Container Apps**: For running the Flask application
- **Azure Functions**: For serverless function execution
- **Azure API Management**: For API gateway functionality
- **Azure Resource Manager**: For infrastructure management 