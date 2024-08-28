#!/usr/bin/env bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" != "debian" && "$ID" != "ubuntu" ]]; then
        echo -e "${RED}Error: This script only supports Debian or Ubuntu.${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: Cannot determine the Linux distribution.${NC}"
    exit 1
fi

# Check if PlantUML is installed
if dpkg-query -W -f='${Status}' plantuml 2>/dev/null | grep -q "install ok installed"; then
    read -p "The plantuml package is already installed through the package manager. Do you want to uninstall it? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        sudo apt-get remove --purge plantuml
        echo -e "${GREEN}PlantUML has been uninstalled.${NC}"
    else
        echo -e "${YELLOW}PlantUML will not be uninstalled.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}PlantUML is not installed through the package manager.${NC}"
fi

# Check if JRE is installed
if ! java -version &> /dev/null; then
    echo -e "${YELLOW}JRE is not installed. Would you like to install it?${NC}"
    read -p "Do you want to install JRE? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo -e "${RED}JRE is required to run PlantUML. Please install JRE and run this script again.${NC}"
        exit 1
    fi
    sudo apt-get update
    sudo apt-get install -y default-jre
    echo -e "${GREEN}JRE has been installed.${NC}"
else
    echo -e "${GREEN}JRE is already installed.${NC}"
fi

# Check if Graphviz is installed
if ! command -v dot &> /dev/null; then
    echo -e "${YELLOW}Graphviz is not installed. Would you like to install it?${NC}"
    read -p "Do you want to install Graphviz? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo -e "${RED}Graphviz is required to generate diagrams. Please install Graphviz and run this script again.${NC}"
        exit 1
    fi
    sudo apt-get update
    sudo apt-get install -y graphviz
    echo -e "${GREEN}Graphviz has been installed.${NC}"
else
    echo -e "${GREEN}Graphviz is already installed.${NC}"
fi

# Check if PlantUML command works and get the version number
installed_version="0.0.0"
if command -v plantuml &> /dev/null; then
    installed_version=$(plantuml --version 2>&1 | grep -oP 'PlantUML version \K[^\s]+')
    echo -e "${GREEN}PlantUML is installed and the version is $installed_version.${NC}"
else
    echo -e "${YELLOW}PlantUML is not yet installed.${NC}"
fi

# Get the latest version number from GitHub API
latest_version=$(curl -s https://api.github.com/repos/plantuml/plantuml/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')
echo -e "${GREEN}The latest available version of PlantUML is $latest_version.${NC}"

# Compare versions and download if the latest version is greater
if [ "$(printf '%s\n' "$latest_version" "$installed_version" | sort -V | head -n1)" != "$latest_version" ]; then
    echo -e "${YELLOW}Downloading the latest version of PlantUML...${NC}"
    sudo mkdir -p /opt/plantuml
    sudo curl -L --output /opt/plantuml/plantuml.jar "https://github.com/plantuml/plantuml/releases/download/v$latest_version/plantuml.jar"
    echo -e "${GREEN}PlantUML has been downloaded to /opt/plantuml/plantuml.jar.${NC}"
else
    echo -e "${GREEN}The current version of PlantUML is up to date.${NC}"
fi

# Create a script to run PlantUML
echo -e "${YELLOW}(Re)creating the script to run PlantUML...${NC}"

sudo tee /usr/bin/plantuml > /dev/null <<EOF
#!/usr/bin/env bash
exec java -Djava.awt.headless=true -jar /opt/plantuml/plantuml.jar "\$@"
EOF

sudo chmod +x /usr/bin/plantuml
echo -e "${GREEN}The script has been created at /usr/bin/plantuml.${NC}"

# Check if plantuml --version returns the correct version
if plantuml --version 2>&1 | grep -q "PlantUML version $latest_version"; then
    echo -e "${GREEN}PlantUML has been installed successfully.${NC}"
else
    echo -e "${RED}Error: PlantUML installation failed.${NC}"
    exit 1
fi