#!/bin/bash

# Default values for flags
storageAccountName="stgsetup"
containerName="setup"
destinationPath="."
filesToDownload=()
directoryPatterns=()
extractFlag=""

# Function to display usage
usage() {
  echo "Usage: $0 [-s storage-account-name] [-c container-name] [-d destination-path] [-b specific-blob] [-p pattern] [-e]"
  echo "  -s    Azure storage account name (default: stgsetup)"
  echo "  -c    Azure storage container name (default: setup)"
  echo "  -d    Destination path for extraction (default: current directory)"
  echo "  -b    Specific blob(s) to download (can be used multiple times)"
  echo "  -p    Pattern(s) for directory download (e.g., 'venv/*')"
  echo "  -e    Extract the downloaded blobs if they are compressed (.tar.gz)"
  exit 1
}

# Function to create directories if they don't exist
create_folder_if_not_exists() {
  local folderPath="$1"
  mkdir -p "$folderPath"
}

# Function to download a blob from the storage account
download_blob() {
  local blob="$1"
  local folderPath="$2"

  echo "Downloading blob: $blob..."
  az storage blob download --account-name "$storageAccountName" --account-key "$accountKey" \
    --container-name "$containerName" --name "$blob" --file "$folderPath/$(basename "$blob")"
}

# Function to download directory patterns
download_directory() {
  local pattern="$1"
  local folderPath="$destinationPath"

  echo "Downloading directory pattern: $pattern..."
  az storage blob download-batch --account-name "$storageAccountName" --account-key "$accountKey" \
    --source "$containerName" --destination "$folderPath" --pattern "$pattern"
}

# Function to extract a compressed blob
extract_blob() {
  local blob="$1"
  local folderPath="$2"

  if [[ "$blob" == *.tar.gz ]]; then
    echo "Extracting: $blob..."
    tar -xzf "$folderPath/$(basename "$blob")" -C "$folderPath"
    rm "$folderPath/$(basename "$blob")"  # Clean up compressed file
  fi
}

# Function to process a blob
process_blob() {
  local blob="$1"
  folderPath="$destinationPath/$(dirname "$blob")"
  create_folder_if_not_exists "$folderPath"
  download_blob "$blob" "$folderPath"
  [ "$extractFlag" == "true" ] && extract_blob "$blob" "$folderPath"
}

# Parse flags
while getopts "s:c:d:b:p:e" opt; do
  case $opt in
    s) storageAccountName="$OPTARG" ;;
    c) containerName="$OPTARG" ;;
    d) destinationPath="$OPTARG" ;;
    b) filesToDownload+=("$OPTARG") ;;
    p) directoryPatterns+=("$OPTARG") ;;
    e) extractFlag="true" ;;  # Enable extraction
    *) usage ;;
  esac
done

# Ensure destination path exists
create_folder_if_not_exists "$destinationPath"

# Get storage account key
echo "Retrieving storage account key for '$storageAccountName'..."
accountKey=$(az storage account keys list --account-name "$storageAccountName" --query "[0].value" -o tsv)
if [ -z "$accountKey" ]; then
  echo "Error: Unable to retrieve storage account key."
  exit 1
fi

# Download specified blobs
for blob in "${filesToDownload[@]}"; do
  process_blob "$blob"
done

# Download directory patterns
for pattern in "${directoryPatterns[@]}"; do
  download_directory "$pattern"
done

echo "Download and extraction completed. Files are located in: $destinationPath"