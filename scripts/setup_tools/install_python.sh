#!/bin/bash

# Default Python version and installation directory
PYTHON_VERSION="3.9.17"
INSTALL_DIR="python-$PYTHON_VERSION"
SOURCE_DIR="/path/to/your/downloaded/package"
ADD_TO_ENV=false

# Usage function
usage() {
    echo "Usage: $0 [-v version] [-d destination] [-s source-folder] [-e]"
    echo "  -v version        Specify the Python version to install (default: $PYTHON_VERSION)"
    echo "  -d destination    Specify the installation directory (default: $INSTALL_DIR)"
    echo "  -s source-folder  Specify the folder where the Python source package is located (default: $SOURCE_DIR)"
    echo "  -e                Add Python to the environment and .bashrc (if exists)"
    exit 1
}

# Parse command line arguments
while getopts "v:d:s:e" opt; do
    case $opt in
        v) PYTHON_VERSION="$OPTARG" ;;
        d) INSTALL_DIR="$OPTARG" ;;
        s) SOURCE_DIR="$OPTARG" ;;
        e) ADD_TO_ENV=true ;;
        *) usage ;;
    esac
done

# Resolve the relative path to an absolute path
INSTALL_DIR="$(cd "$INSTALL_DIR" && pwd)"

# Ensure the source directory exists and contains the Python source package
if [ ! -d "$SOURCE_DIR" ] || [ ! -f "$SOURCE_DIR/Python-$PYTHON_VERSION.tar.xz" ]; then
    echo "Error: Python source package not found in the specified source folder."
    exit 1
fi

# Extract the downloaded file
echo "Extracting Python $PYTHON_VERSION from $SOURCE_DIR..."
tar -xf "$SOURCE_DIR/Python-$PYTHON_VERSION.tar.xz" -C /tmp
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract the Python source code."
    exit 1
fi

# Navigate to the extracted directory
cd "/tmp/Python-$PYTHON_VERSION"

# Configure the installation
echo "Configuring Python installation in $INSTALL_DIR..."
./configure --prefix="$INSTALL_DIR/python-$PYTHON_VERSION"

# Build Python from source
echo "Building Python $PYTHON_VERSION..."
make
if [ $? -ne 0 ]; then
    echo "Error: Failed to build Python."
    exit 1
fi

# Install Python
echo "Installing Python $PYTHON_VERSION to $INSTALL_DIR/python-$PYTHON_VERSION..."
sudo make install
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Python."
    exit 1
fi

# Clean up the temporary files
echo "Cleaning up..."
rm -rf "/tmp/Python-$PYTHON_VERSION"

# Verify the installation
echo "Python $PYTHON_VERSION installed successfully!"
$INSTALL_DIR/python-$PYTHON_VERSION/bin/python3 --version

# If the -e flag was specified, add Python to the environment and .bashrc
if [ "$ADD_TO_ENV" = true ]; then
    echo "Adding Python $PYTHON_VERSION to the environment..."

    # Add Python to the PATH
    echo "export PATH=$INSTALL_DIR/python-$PYTHON_VERSION/bin:\$PATH" >> ~/.bashrc
    if [ $? -eq 0 ]; then
        echo "Python added to .bashrc. Please run 'source ~/.bashrc' to update the environment."
    else
        echo "Error: Failed to add to .bashrc."
    fi

    # Check if .bashrc exists before adding to it
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
        echo "Environment updated. You can now use 'python3' and 'python3.9' from the terminal."
    else
        echo "No .bashrc file found. Please manually add '$INSTALL_DIR/python-$PYTHON_VERSION/bin' to your PATH."
    fi
fi
