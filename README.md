# Azure Container Apps & Functions Demo for Jit

This repository demonstrates deploying applications to Azure, focusing on integrating security scanning with Jit. It includes:

1. **Vulnerable Flask App to Azure Container Apps:** A Python Flask application with numerous deliberate vulnerabilities deployed to Azure Container Apps via GitHub Actions.
2. **Vulnerable Azure Function:** A simple Azure Function (Python) with commented vulnerable code patterns, deployed with a public API endpoint using GitHub Actions.

## Resource Group Structure

- The main application resources (Container Apps, Function App, Log Analytics, Storage) are created in one resource group (e.g., `k8s-demo-rg`).
- The Azure Container Registry (ACR) is created in a separate resource group (e.g., `k8s-demo-acr-rg`).

## Architecture Diagram

> **Note:** The following diagram uses [Mermaid](https://mermaid-js.github.io/mermaid/#/) syntax. It is rendered automatically on GitHub.com and some Markdown viewers. If you do not see a diagram below, view this file on GitHub or a compatible viewer.

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

## Deployment Steps

You can deploy both the Container App and the Function App using GitHub Actions. Here is a summary:

1. **Fork this repository.**
2. **Set up GitHub Secrets** as described above (see 'Setup & Deployment').
3. **Create Azure resources** using the provided `setup-azure.sh` script or manually via the Azure Portal/CLI.
4. **Push to `main` branch** to trigger deployments:
   - The Flask app will be built and deployed to Azure Container Apps.
   - The Azure Function will be deployed to Azure Functions.
5. **Monitor GitHub Actions** for deployment status and logs.

For more details, see the `.github/workflows/` directory and the 'Setup & Deployment' section above.

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

---

## Troubleshooting

### Mermaid Diagram Not Rendering
- Ensure you are viewing this file on GitHub.com or a Markdown viewer that supports Mermaid diagrams.
- If you see only the code block and not a rendered diagram, try refreshing the page or viewing the file directly on GitHub.
- For more information, see [GitHub's documentation on Mermaid diagrams](https://github.blog/changelog/2022-02-14-include-diagrams-in-your-markdown-files-with-mermaid/).

### Deployment Issues
- Double-check that all required GitHub secrets are set.
- Ensure your Azure resources are created and accessible.
- Review the logs in GitHub Actions for any errors during deployment. 