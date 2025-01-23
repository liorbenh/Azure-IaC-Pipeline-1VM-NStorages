#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -r requirements.txt -d destination-folder"
  echo "  -r    Path to the requirements.txt file (optional)"
  echo "  -d    Destination folder for virtual environment"
  exit 1
}

# Parse flags
while getopts "r:d:" opt; do
  case $opt in
    r) requirementsFile="$OPTARG" ;;
    d) destinationFolder="$OPTARG" ;;
    *) usage ;;
  esac
done

# Ensure destination folder is provided
if [ -z "$destinationFolder" ]; then
  echo "Error: Destination folder is required."
  usage
fi

# Create the virtual environment
echo "Creating virtual environment in $destinationFolder..."
python3 -m venv "$destinationFolder/venv"

# Install dependencies from requirements.txt if provided
if [ -n "$requirementsFile" ]; then
  echo "Installing dependencies from $requirementsFile..."
  "$destinationFolder/venv/bin/pip" install -r "$requirementsFile"
  echo "Copying requirements.txt to the destination folder..."
  cp "$requirementsFile" "$destinationFolder/"
else
  echo "No requirements.txt found. Skipping dependency installation."

fi

echo "Virtual environment created successfully in $destinationFolder/venv."

