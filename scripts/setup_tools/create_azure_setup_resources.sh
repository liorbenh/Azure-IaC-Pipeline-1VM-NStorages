#!/bin/bash

# Default values for flags
location="israelcentral"
resourceGroupName="Setup"
storageAccountName="stgsetup"
containerName="setup"

# Function to display the usage
usage() {
  echo "Usage: $0 [-l location] [-r resource-group-name] [-s storage-account-name] [-c container-name]"
  echo "  -l    Set the Azure location (default: israelcentral)"
  echo "  -r   Set the resource group name (default: Setup)"
  echo "  -s    Set the storage account name (default: stgsetup)"
  echo "  -c    Set the container name (default: setup)"
  exit 1
}

# Parse flags
while getopts "l:r:s:c:" opt; do
  case $opt in
    l) location="$OPTARG" ;;
    r) resourceGroupName="$OPTARG" ;;
    s) storageAccountName="$OPTARG" ;;
    c) containerName="$OPTARG" ;;
    *) usage ;;
  esac
done

# Step 1: Create Resource Group
echo "Creating resource group '$resourceGroupName' in location '$location'..."
az group create --name "$resourceGroupName" --location "$location"
if [ $? -ne 0 ]; then
  echo "Error: Failed to create resource group."
  exit 1
fi

# Step 2: Create Storage Account
echo "Creating storage account '$storageAccountName' in resource group '$resourceGroupName'..."
az storage account create --name "$storageAccountName" --resource-group "$resourceGroupName" --location "$location" --sku Standard_LRS
if [ $? -ne 0 ]; then
  echo "Error: Failed to create storage account."
  exit 1
fi

# Step 3: Create Storage Container
echo "Creating container '$containerName' in storage account '$storageAccountName'..."
containerConnectionString=$(az storage account show-connection-string --name "$storageAccountName" --resource-group "$resourceGroupName" --query connectionString --output tsv)
az storage container create --name "$containerName" --connection-string "$containerConnectionString"
if [ $? -ne 0 ]; then
  echo "Error: Failed to create storage container."
  exit 1
fi

# Output success
echo "Setup completed successfully!"
echo "Resource group: $resourceGroupName"
echo "Storage account: $storageAccountName"
echo "Container: $containerName"
echo "Location: $location"
