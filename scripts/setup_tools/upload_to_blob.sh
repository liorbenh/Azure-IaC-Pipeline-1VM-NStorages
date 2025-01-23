#!/bin/bash

# Default values for flags
storageAccountName="stgsetup"
containerName="setup"
compress=false
overwrite=false
blobFiles=()
blobDirectories=()

# Function to display usage
usage() {
  echo "Usage: $0 [-s storage-account-name] [-c container-name] [-b blob-file...] [-p blob-directory...] [-z] [--overwrite]"
  echo "  -s    Azure storage account name (default: stgsetup)"
  echo "  -c    Azure storage container name (default: setup)"
  echo "  -b    One or more files to upload as blobs"
  echo "  -p    One or more directories to upload as blobs"
  echo "  -z    Compress files or directories before uploading"
  echo "  --overwrite    Overwrite existing blobs in the container"
  exit 1
}

# Parse flags
while getopts "s:c:b:p:z" opt; do
  case $opt in
    s) storageAccountName="$OPTARG" ;;
    c) containerName="$OPTARG" ;;
    b) blobFiles+=("$OPTARG") ;;
    p) blobDirectories+=("$OPTARG") ;;
    z) compress=true ;;
    *) usage ;;
  esac
done

# Parse for --overwrite flag
for arg in "$@"; do
  if [ "$arg" == "--overwrite" ]; then
    overwrite=true
  fi
done

# Ensure at least one file or directory to upload is provided
if [ ${#blobFiles[@]} -eq 0 ] && [ ${#blobDirectories[@]} -eq 0 ]; then
  echo "Error: At least one file (-b) or directory (-p) to upload is required."
  usage
fi

# Get storage account key
echo "Retrieving storage account key for '$storageAccountName'..."
accountKey=$(az storage account keys list --account-name "$storageAccountName" --query "[0].value" -o tsv)
if [ -z "$accountKey" ]; then
  echo "Error: Unable to retrieve storage account key."
  exit 1
fi

# Function to compress files or directories
compress_item() {
  local itemToCompress=$1
  compressedFile="${itemToCompress}.tar.gz"
  tar -czf "$compressedFile" -C "$(dirname "$itemToCompress")" "$(basename "$itemToCompress")"
  echo "$compressedFile"
}

# Upload files
for fileToUpload in "${blobFiles[@]}"; do
  if [ "$compress" = true ]; then
    if [ -f "$fileToUpload" ]; then
      echo "Compressing $fileToUpload..."
      fileToUpload=$(compress_item "$fileToUpload")
      echo "Compression complete: $fileToUpload"
    fi
  fi

  if [ -f "$fileToUpload" ]; then
    echo "Uploading file: $fileToUpload..."
    cmd="az storage blob upload --account-name $storageAccountName --account-key $accountKey --container-name $containerName --name $(basename "$fileToUpload") --file $fileToUpload"
    if [ "$overwrite" = true ]; then
      cmd="$cmd --overwrite"
    fi
    echo "Running command: $cmd"
    eval "$cmd"
  else
    echo "Warning: $fileToUpload does not exist. Skipping..."
  fi
done

# Upload directories
for dirToUpload in "${blobDirectories[@]}"; do
  if [ "$compress" = true ]; then
    if [ -d "$dirToUpload" ]; then
      echo "Compressing $dirToUpload..."
      dirToUpload=$(compress_item "$dirToUpload")
      echo "Compression complete: $dirToUpload"
    fi
  fi

  if [ -d "$dirToUpload" ]; then
    echo "Uploading directory: $dirToUpload..."
    cmd="az storage blob upload-batch --account-name $storageAccountName --account-key $accountKey --destination $containerName --source $dirToUpload"
    if [ "$overwrite" = true ]; then
      cmd="$cmd --overwrite"
    fi
    echo "Running command: $cmd"
    eval "$cmd"
  elif [ -f "$dirToUpload" ]; then
    echo "Uploading file: $dirToUpload..."
    cmd="az storage blob upload --account-name $storageAccountName --account-key $accountKey --container-name $containerName --name $(basename "$dirToUpload") --file $dirToUpload"
    if [ "$overwrite" = true ]; then
      cmd="$cmd --overwrite"
    fi
    echo "Running command: $cmd"
    eval "$cmd"
  else
    echo "Warning: $dirToUpload does not exist or is not a directory. Skipping..."
  fi
done

echo "Upload completed."
