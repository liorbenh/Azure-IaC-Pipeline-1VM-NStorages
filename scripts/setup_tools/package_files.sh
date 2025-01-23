#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -d destination-folder -p path-to-files-and-folders [-c]"
  echo "  -d    Destination folder for packaged files"
  echo "  -p    Paths of files or folders to package (can be specified multiple times)"
  echo "  -c    Compress the destination folder into a .tar.gz file (optional)"
  exit 1
}

# Parse flags
while getopts "d:p:c" opt; do
  case $opt in
    d) destinationFolder="$OPTARG" ;;
    p) pathsToPackage+=("$OPTARG") ;;
    c) compress=true ;;
    *) usage ;;
  esac
done

# Ensure destination folder is provided
if [ -z "$destinationFolder" ]; then
  echo "Error: Destination folder is required."
  usage
fi

# Ensure at least one path to package is provided
if [ ${#pathsToPackage[@]} -eq 0 ]; then
  echo "Error: At least one file or folder to package is required."
  usage
fi

# Create the destination folder if it doesn't exist
mkdir -p "$destinationFolder"

# Package files/folders
for path in "${pathsToPackage[@]}"; do
  if [ -e "$path" ]; then
    echo "Copying $path to $destinationFolder..."
    cp -r "$path" "$destinationFolder/"
  else
    echo "Warning: $path does not exist. Skipping..."
  fi
done

# Compress the destination folder if the -c flag is set
if [ "$compress" = true ]; then
  echo "Compressing $destinationFolder into $destinationFolder.tar.gz..."
  tar -czf "$destinationFolder.tar.gz" -C "$destinationFolder" .
  echo "Compression completed: $destinationFolder.tar.gz"
  # Clean up the uncompressed folder
  rm -r "$destinationFolder"
else
  echo "Packaging completed. Files are located in $destinationFolder."
fi
