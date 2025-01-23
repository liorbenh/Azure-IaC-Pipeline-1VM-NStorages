# Setting Up Your Personal Computer as an Azure DevOps Self-Hosted Agent

This guide will help you set up your personal computer as a self-hosted Azure DevOps agent.

## Problem: Free Grant Discontinuation
Microsoft has disabled the free grant of parallel jobs for public and certain private projects in new organizations. You can solve the problem in two ways:
1. **Request the free grant**: [Submit the request form](https://aka.ms/azpipelines-parallelism-request).
2. **Create a Self-hosted agent**: If you don't want to wait for approval, follow this guide to create your own self-hosted agent.

## Prerequisites
- **Operating System**: Windows, macOS, or Linux
- **Tools**: Git (download from [Git](https://git-scm.com/downloads)), Both PowerShell and bash
- **Azure DevOps Account**: You need an active account and proper permissions.
- **Azure CLI Installed and logged in**: 
   - You need to have Azure CLI installed on the agent machine.
   ```bash
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```
   - Before using any Azure CLI commands with a local install, you need to sign in by running:
    ```bash
    az login
    ```
    also, you need to have the following tools installed for Bash:
    1) jq
    ```bash
   sudo apt update
   sudo apt install -y jq
    ```
    2) sshpass
    ```bash
   sudo apt-get install sshpass
    ```

## Steps

### 1. Create a Personal Access Token (PAT)
1. Go to **User Settings** > **Personal Access Tokens** in Azure DevOps.
2. Click **+ New Token** and set the scope to **Agent Pools (Read & Manage)**.
3. Save the PAT securely.

### 2. Create a Self-Hosted Agent Pool
1. Go to **Project Settings** > **Pipelines** > **Agent Pools**.
2. Click **Add pool**.
3. Select pool type (Self-hosted).
4. Add a descriptive pool name (e.g., `my-personal-computer`).
5. Check the Pipeline permissions box so you do not need to grant permission manually per pipeline.
3. Click **Create**.

### 3. Download and Extract the Agent Package
1. Navigate to **Project Settings** > **Agent Pools** > **<Your Agent Pool>**.
2. Click **New Agent**, select your operating system, and download the agent package.
3. Extract the agent package to a folder.

### 4. Configure the Agent
1. In the terminal, navigate to the agent directory and run the configuration script:
   - For Windows: `config.cmd`
   - For macOS/Linux: `config.sh`
2. Enter the following details:
   - **Server URL**: Paste the organization URL (which looks like the following `https://dev.azure.com/<your-organization>`)
   - **Personal Access Token (PAT)**: Paste the previously created PAT.
   - **Agent Pool Name**: Select the pool you created (e.g., `my-personal-computer`).
   - **Agent Name**: Choose a name for your agent (e.g., `Ubuntu-Agent`).
   - **Work folder**: Press enter for the default
   - **Agent as Service**: Press enter for the default

### 5. Run the Agent
1. To start the agent manually:
   - For Windows: `run.cmd`
   - For macOS/Linux: `run.sh`
2. To run as a service:
   - **Windows**: `svc.cmd install` and `svc.cmd start`
   - **Linux/macOS**: Follow instructions to set up as a service.

### 6. Verify the Agent
- Go to **Project Settings** > **Agent Pools** in Azure DevOps to confirm the agent is listed and online.

### 7. Use the Agent in Your Pipeline
In your `azure-pipeline.yml`, configure the pipeline to use the self-hosted agent:
```yaml
trigger:
- main

pool: my-personal-computer

steps:
- task: UsePythonVersion@0
  inputs:
    versionSpec: '3.7'
  displayName: 'Use Python 3.7'

- script: |
    python -m pip install --upgrade pip
    pip install -r requirements.txt
  displayName: 'Install dependencies'
```
It will go to the pool and select an available agent.
You can go inside your self-hosted agent folder and get the logs from the _work directory. 
You can also view the output of the jobs on Azure DevOps.

## Configure Azure DevOps Organization for CLI

### Set the Default Organization for Azure CLI

1. Log in to the machine hosting the agent.
2. Run the following command to set the default organization:
   ```bash
   az devops configure --defaults organization=https://dev.azure.com/<OrganizationName>
   ```
This sets the default organization URL for Azure CLI commands executed on this agent.

### Verify Configuration
1. Run the following command on the agent machine to check the default organization:
```bash
az devops configure --list
```
2. Ensure that the organization property is set to your Azure DevOps URL.


## Configure Azure DevOps Default Project for CLI 

In Azure DevOps, you can set a default project to avoid specifying the `--project` argument in every Azure CLI command. Follow the steps below to set your default project.

### Steps to Set the Default Project

#### 1. Find Your Project Name or ID

You will need to know the **project name** or **project ID** for the project you want to set as default.

**To find the project name and ID:**
  1. Go to the [Azure DevOps portal](https://dev.azure.com).
  2. In the top left, click on your **organization name** to see the list of projects.
  3. Click on the project you want to set as default. The **project name** is displayed in the portal, and the **project ID** can be seen in the URL (e.g., `https://dev.azure.com/<organization_name>/<project_id>`).

#### 2. Set the Default Project

Once you have the project name or ID, you can set it as the default project using the following command:

```bash
az devops configure --defaults project=<YourProjectName>
```
Replace <YourProjectName> with the actual name or ID of your project.

#### 3. Verify the Default Project
To confirm that the default project has been set, you can run any Azure DevOps CLI command without specifying the --project argument. For example:
```bash
az devops project show
```
This should show the details of your default project.

#### 4. Overriding the Default Project
If you need to override the default project for a specific command, you can still use the --project argument. For example:
```bash
az devops <command> --project <AnotherProjectName>
```
This will temporarily override the default project for that command.