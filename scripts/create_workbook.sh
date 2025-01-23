#!/bin/bash

# Default paths
STORAGE_TEMPLATE_PATH="../monitoring/templates/storage.json"
SERVER_TEMPLATE_PATH="../monitoring/templates/server.json"

# Function to display help
usage() {
    echo "Usage: $0 -r <resource-group> -t <resource-type> [additional options]"
    echo ""
    echo "Common options:"
    echo "  -r <resource-group>    : Azure resource group name"
    echo "  -t <resource-type>     : Resource type to monitor (storage|vm)"
    echo "  -n <workbook-name>     : Display name for the workbook"
    echo ""
    echo "Storage workbook options:"
    echo "  -s <subscription-id>   : Subscription ID (optional, will be detected from resource group)"
    echo ""
    echo "VM workbook options:"
    echo "  -m <vm-name>          : Name of the VM to monitor"
    echo ""
    echo "Example for storage: $0 -r myResourceGroup -t storage -n 'Storage Overview'"
    echo "Example for VM: $0 -r myResourceGroup -t vm -m myVM -n 'VM Monitor'"
    exit 1
}

# Parse command-line arguments
while getopts ":r:t:n:s:m:h" opt; do
    case $opt in
        r) RESOURCE_GROUP="$OPTARG" ;;
        t) RESOURCE_TYPE="$OPTARG" ;;
        n) WORKBOOK_NAME="$OPTARG" ;;
        s) SUBSCRIPTION_ID="$OPTARG" ;;
        m) VM_NAME="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

# Validate required parameters
if [ -z "$RESOURCE_GROUP" ] || [ -z "$RESOURCE_TYPE" ]; then
    echo "Error: Resource group and resource type are required."
    usage
fi

# Get the subscription ID from the resource group if not provided
if [ -z "$SUBSCRIPTION_ID" ]; then
    SUBSCRIPTION_ID=$(az group show --name "$RESOURCE_GROUP" --query id -o tsv | cut -d'/' -f3)
    if [ -z "$SUBSCRIPTION_ID" ]; then
        echo "Error: Could not determine subscription ID for resource group $RESOURCE_GROUP"
        exit 1
    fi
    echo "Using subscription ID: $SUBSCRIPTION_ID"
fi

# Handle storage workbook
if [ "$RESOURCE_TYPE" == "storage" ]; then
    # Set default workbook name if not provided
    WORKBOOK_NAME=${WORKBOOK_NAME:-"${RESOURCE_GROUP} - Storage accounts Overview"}
    
    # Get the storage account IDs in the resource group
    STORAGE_ACCOUNT_IDS=$(az storage account list --resource-group "$RESOURCE_GROUP" --query "[].id" --output tsv | jq -R -s -c 'split("\n")[:-1]')
    
    if [ -z "$STORAGE_ACCOUNT_IDS" ]; then
        echo "No storage accounts found in resource group $RESOURCE_GROUP"
        exit 1
    fi
    
    # Deploy storage workbook
    echo "Deploying storage workbook..."
    az deployment group create \
        --name "storageWorkbookDeployment" \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$STORAGE_TEMPLATE_PATH" \
        --parameters subscriptionId="$SUBSCRIPTION_ID" \
                     storageAccountIds="$STORAGE_ACCOUNT_IDS" \
                     workbookDisplayName="$WORKBOOK_NAME"

# Handle VM workbook
elif [ "$RESOURCE_TYPE" == "vm" ]; then
    # Validate VM name
    if [ -z "$VM_NAME" ]; then
        echo "Error: VM name is required for VM workbook"
        usage
    fi
    
    # Get VM resource ID
    VM_RESOURCE_ID=$(az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --query id -o tsv)
    if [ -z "$VM_RESOURCE_ID" ]; then
        echo "Error: Could not find VM '$VM_NAME' in resource group '$RESOURCE_GROUP'"
        exit 1
    fi
    
    # Set default workbook name if not provided
    WORKBOOK_NAME=${WORKBOOK_NAME:-"$VM_NAME - Monitoring"}
    
    echo "Retrieved VM resource ID: $VM_RESOURCE_ID"
    echo "Deploying VM workbook..."
    az deployment group create \
        --name "vmWorkbookDeployment" \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$SERVER_TEMPLATE_PATH" \
        --parameters vmResourceId="$VM_RESOURCE_ID" \
                     workbookDisplayName="$WORKBOOK_NAME"

else
    echo "Error: Invalid resource type. Must be 'storage' or 'vm'"
    usage
fi

# Check deployment status
if [ $? -eq 0 ]; then
    echo "Workbook deployment successful!"
else
    echo "Error: Workbook deployment failed."
    exit 1
fi
