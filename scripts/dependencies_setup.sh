# Define color codes
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if the requirements file path is provided
if [ -z "$1" ]; then
  scriptDir=$(dirname "$0")
  requirementsFilePath="$scriptDir/requirements.txt"
  echo -e "${YELLOW}No requirements file path provided. Assuming $requirementsFilePath${NC}"
else
  requirementsFilePath=$1
fi

# Check if the virtual environment directory is provided
if [ -z "$2" ]; then
  venvDir=$(dirname "$0")/venv
  echo -e "${YELLOW}No virtual environment directory provided. Assuming $venvDir${NC}"
else
  venvDir=$2
fi

# Update package lists
echo -e "${YELLOW}Updating package lists...${NC}"
if ! sudo apt update; then
  echo -e "${RED}Failed to update package lists. Exiting.${NC}"
  exit 1
fi

# Install python3.8-venv
echo -e "${YELLOW}Installing python3.8-venv...${NC}"
if ! sudo apt install -y python3.8-venv; then
  echo -e "${RED}Failed to install python3.8-venv. Exiting.${NC}"
  exit 1
fi

echo -e "${YELLOW}Creating virtual environment...${NC}"
if ! python3.8 -m venv $venvDir; then
  echo -e "${RED}Failed to create virtual environment. Exiting.${NC}"
  exit 1
fi

echo -e "${YELLOW}Activating virtual environment...${NC}"
source $venvDir/bin/activate

# Install Python3 if not already installed
if ! command -v python3 &>/dev/null; then
  echo -e "${YELLOW}Python3 not found. Installing Python3...${NC}"
  if ! sudo apt install -y python3; then
    echo -e "${RED}Failed to install Python3. Exiting.${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}Python3 is already installed.${NC}"
fi

# Install pip3 if not already installed
if ! command -v pip3 &>/dev/null; then
  echo -e "${YELLOW}pip3 not found. Installing pip3...${NC}"
  if ! sudo apt install -y python3-pip; then
    echo -e "${RED}Failed to install pip3. Exiting.${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}pip3 is already installed.${NC}"
fi

# Install setuptools-rust
echo -e "${YELLOW}Installing setuptools-rust...${NC}"
if ! pip3 install setuptools-rust; then
  echo -e "${RED}Failed to install setuptools-rust. Exiting.${NC}"
  exit 1
fi

# Install testresources
echo -e "${YELLOW}Installing testresources...${NC}"
if ! pip3 install testresources; then
  echo -e "${RED}Failed to install testresources. Exiting.${NC}"
  exit 1
fi

# Install Rust and Cargo
echo -e "${YELLOW}Installing Rust and Cargo...${NC}"
if ! sudo apt install -y rustc cargo; then
  echo -e "${RED}Failed to install Rust and Cargo. Exiting.${NC}"
  exit 1
fi

# Upgrade pip and setuptools
echo -e "${YELLOW}Upgrading pip and setuptools...${NC}"
if ! pip3 install --upgrade pip setuptools; then
  echo -e "${RED}Failed to upgrade pip and setuptools. Exiting.${NC}"
  exit 1
fi

# Install pkg-config and libcairo2-dev
echo -e "${YELLOW}Installing pkg-config and libcairo2-dev${NC}"
if ! sudo apt install -y pkg-config libcairo2-dev; then
  echo -e "${RED}Failed to install pkg-config and libcairo2-dev. Exiting.${NC}"
  exit 1
fi

# Install dependencies from the requirements file
echo -e "${YELLOW}Installing dependencies from $requirementsFilePath...${NC}"
if ! pip3 install -r $requirementsFilePath; then
  echo -e "${RED}Failed to install dependencies from $requirementsFilePath. Exiting.${NC}"
  exit 1
fi

echo -e "${GREEN}Dependencies setup completed.${NC}"
