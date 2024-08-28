#!/usr/bin/env bash

# Check the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" != "debian" && "$ID" != "ubuntu" ]]; then
        echo "Error: This script only supports Debian or Ubuntu."
        exit 1
    fi
else
    echo "Error: Cannot determine the Linux distribution."
    exit 1
fi

# Check if PlantUML is installed
if dpkg-query -W -f='${Status}' plantuml 2>/dev/null | grep -q "install ok installed"; then
    read -p "The plantuml package is already installed through the package manager. Do you want to uninstall it? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        sudo apt-get remove --purge plantuml
        echo "PlantUML has been uninstalled."
    else
        echo "PlantUML will not be uninstalled."
        exit 1
    fi
else
    echo "PlantUML is not installed through the package manager."
fi

# Check if JRE is installed
if ! java -version &> /dev/null; then
    echo "JRE is not installed. Would you like to install it?"
    read -p "Do you want to install JRE? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "JRE is required to run PlantUML. Please install JRE and run this script again."
        exit 1
    fi
    sudo apt-get update
    sudo apt-get install -y default-jre
    echo "JRE has been installed."
else
    echo "JRE is already installed."
fi

# Check if Graphviz is installed
if ! command -v dot &> /dev/null; then
    echo "Graphviz is not installed. Would you like to install it?"
    read -p "Do you want to install Graphviz? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Graphviz is required to generate diagrams. Please install Graphviz and run this script again."
        exit 1
    fi
    sudo apt-get update
    sudo apt-get install -y graphviz
    echo "Graphviz has been installed."
else
    echo "Graphviz is already installed."
fi

# Check if PlantUML command works and get the version number
installed_version="0.0.0"
if command -v plantuml &> /dev/null; then
    installed_version=$(plantuml --version 2>&1 | grep -oP 'PlantUML version \K[^\s]+')
    echo "PlantUML is installed and the version is $installed_version."
else
    echo "PlantUML is not yet installed."
fi

# Get the latest version number from GitHub API
latest_version=$(curl -s https://api.github.com/repos/plantuml/plantuml/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')
echo "The latest available version of PlantUML is $latest_version."

# Compare versions and download if the latest version is greater
if [ "$(printf '%s\n' "$latest_version" "$installed_version" | sort -V | head -n1)" != "$latest_version" ]; then
    echo "Downloading the latest version of PlantUML..."
    sudo mkdir -p /opt/plantuml
    sudo curl -L --output /opt/plantuml/plantuml.jar "https://github.com/plantuml/plantuml/releases/download/v$latest_version/plantuml.jar"
    echo "PlantUML has been downloaded to /opt/plantuml/plantuml.jar."
else
    echo "The current version of PlantUML is up to date."
fi

# Create a script to run PlantUML
echo "(Re)creating the script to run PlantUML..."

sudo tee /usr/bin/plantuml > /dev/null <<EOF
#!/usr/bin/env bash
exec java -Djava.awt.headless=true -jar /opt/plantuml/plantuml.jar "\$@"
EOF

sudo chmod +x /usr/bin/plantuml
echo "The script has been created at /usr/bin/plantuml."

# Check if plantuml --version returns the correct version
if plantuml --version 2>&1 | grep -q "PlantUML version $latest_version"; then
    echo "PlantUML has been installed successfully."
else
    echo "Error: PlantUML installation failed."
    exit 1
fi