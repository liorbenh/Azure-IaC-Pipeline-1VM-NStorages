# Azure DevOps Pipeline Documentation

## Pipeline Architecture Overview

The following diagram illustrates the complete workflow and dependencies between pipelines:

```mermaid
flowchart TB
    subgraph Orchestrator["pipeline_orchestrator.yml (Orchestrate-Pipelines)"]
        O[Initialize Variables]
        O1[Parameters]
        O2[Variable Group Integration]
        O1 --> O
        O2 --> O
    end
    
    subgraph Infrastructure["infrastructure_deployment.yml (Infrastructure-Deployment)"]
        I[Setup Infrastructure]
        I1[Network Deployment]
        I2[Server Deployment]
        I3[Storage Deployment]
        I1 --> I2
        I2 --> I3
    end
    
    
    subgraph Blob["blob_management.yml (Manage-Blobs)"]
        B[Blob Management]
        B1[Source Storage]
        B2[Destination Storage]
        B1 --> B2
    end

    subgraph Software["vm_software_configuration.yml (Configure-VM-Software)"]
        S[Configure VM]
        S1[Python Setup]
        S2[Dependencies Installation]
        S1 --> S2
    end

    O --> I
    I --> S
    I --> B
    S --> B

    classDef pipeline fill:#f9f,stroke:#333,stroke-width:2px
    class Orchestrator,Infrastructure,Software,Blob pipeline
```

## Pipeline Descriptions

### 1. Orchestrate-Pipelines (pipeline_orchestrator.yml)
**Purpose**: Master pipeline for coordinating all deployments

**Key Features**:
- Initialization of runtime variables
- Conditional execution of dependent pipelines
- Variable group management

**Parameters**:
- `activeVariableGroupName`: Target variable group
- `InfrastructureDeploymentEnabled`: Toggle infrastructure deployment
- `VMSoftwareConfigurationEnabled`: Toggle VM configuration
- `blobManagementEnabled`: Toggle blob management
- `debug`: Enable debug mode

**Jobs**:
1. Initialize Variables
2. Infrastructure Deployment (conditional)
3. VM Software Configuration (conditional)
4. Blob Management (conditional)

### 2. Infrastructure-Deployment (infrastructure_deployment.yml)
**Purpose**: Deploys core Azure infrastructure

**Key Components**:
- Network resources deployment
- Server provisioning
- Storage account setup
- Resource group management

**Deployment Sequence**:
1. Azure CLI installation & setup
2. Resource group creation with tags
3. Network deployment
4. Server deployment
5. Storage accounts deployment
6. Variable group updates

**Important Variables**:
- Resource group naming: `<subproject>-<environment>-<location>`
- Storage account configuration
- VM credentials management

### 3. Configure-VM-Software (vm_software_configuration.yml)
**Purpose**: Manages VM software installation and configuration

**Key Features**:
- Python environment setup
- Dependencies installation
- VM name management
- SCP file transfer support

**Parameters**:
- VM name handling (default/custom)
- Debug mode
- Service connection configuration

### 4. Blob-Management (blob_management.yml)
**Purpose**: Handles blob storage operations

**Key Features**:
- Multiple storage account support
- Container management
- Upload/download operations
- VM integration for blob operations

**Parameters**:
- Source/destination storage accounts
- Container name
- Upload flag
- VM name configuration

## Pipeline Dependencies

```mermaid
sequenceDiagram
    participant O as Orchestrator
    participant I as Infrastructure
    participant S as Software Config
    participant B as Blob Management

    Note over O: Initialize Variables
    
    O->>I: Deploy Infrastructure
    Note right of I: Creates:<br/>1. Network<br/>2. Server<br/>3. Storage
    
    I->>S: Enable Software Config
    Note right of S: Setup:<br/>1. Python<br/>2. Dependencies
    
    I-->>B: Storage Ready
    S-->>B: VM Ready
    
    Note over B: Can start only after<br/>Infrastructure and Software
```

## Usage Guidelines

### First-Time Setup
1. **Variable Group Creation**:
   - Name format: `VG-<project>-<environment>-<location>`
   - Required variables:
     - subproject
     - organizationUrl
     - project
     - environment
     - location
     - owner
     - adminUsername
     - adminPassword

2. **Pipeline Creation Order**:
   1. Create infrastructure deployment pipeline
   2. Setup variable group permissions
   3. Create remaining pipelines

### Operational Guidelines
1. **Full Deployment**:
   - Use Orchestrate-Pipelines with all toggles enabled
   - Ensures proper dependency handling

2. **Partial Deployment**:
   - Use specific pipeline parameters to control execution
   - Verify dependencies are met

3. **Blob Management Operations**:
   - Requires successful infrastructure and VM configuration
   - Can specify custom storage accounts or use defaults

### Security Notes
- Ensure proper Azure service connection permissions
- VM credentials are managed through variable group
- Storage account access is controlled via private endpoints
