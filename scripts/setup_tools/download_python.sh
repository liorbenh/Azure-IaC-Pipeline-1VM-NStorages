#!/bin/bash

# Usage: ./download_python.sh -v <version> -d <directory>

# Default values
PYTHON_VERSION=""
DESTINATION=""

# Function to display usage
usage() {
    echo "Usage: $0 -v <python-version> -d <destination-folder>"
    echo "Example: $0 -v 3.9.17 -d /path/to/download"
    exit 1
}

# Parse flags
while getopts "v:d:" opt; do
    case $opt in
        v) PYTHON_VERSION="$OPTARG" ;;
        d) DESTINATION="$OPTARG" ;;
        *) usage ;;
    esac
done

# Ensure both flags are provided
if [[ -z "$PYTHON_VERSION" || -z "$DESTINATION" ]]; then
    usage
fi

# Create destination directory if it doesn't exist
mkdir -p "$DESTINATION"

# Construct download URL
BASE_URL="https://www.python.org/ftp/python"
FILE_NAME="Python-$PYTHON_VERSION.tar.xz"
DOWNLOAD_URL="$BASE_URL/$PYTHON_VERSION/$FILE_NAME"

# Download Python
echo "Downloading Python $PYTHON_VERSION to $DESTINATION..."
if curl -o "$DESTINATION/$FILE_NAME" "$DOWNLOAD_URL"; then
    echo "Download complete: $DESTINATION/$FILE_NAME"
else
    echo "Error: Failed to download Python $PYTHON_VERSION. Please check the version and try again."
    exit 1
fi

