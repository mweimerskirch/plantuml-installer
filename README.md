# PlantUML Installation Script

This project provides a Bash script to install PlantUML on Debian or Ubuntu systems. The script checks for necessary dependencies, installs them if needed, and ensures that the latest version of PlantUML is installed.

## Prerequisites

- Debian or Ubuntu Linux distribution
- `curl` installed on your system

## Usage

1. Clone the repository or download the `install-plantuml.sh` script.
2. Make the script executable:
    ```bash
    chmod +x install-plantuml.sh
    ```
3. Run the script:
    ```bash
    ./install-plantuml.sh
    ```

## What the Script Does

1. **Checks the Linux distribution**: Ensures the script is running on Debian or Ubuntu.
2. **Checks if PlantUML is installed**: If installed, prompts the user to uninstall it.
3. **Checks if JRE is installed**: If not, prompts the user to install it.
4. **Checks if Graphviz is installed**: If not, prompts the user to install it.
5. **Checks the current version of PlantUML**: If installed, retrieves the version number.
6. **Fetches the latest version of PlantUML**: From the GitHub API.
7. **Compares versions**: Downloads and installs the latest version if it is newer.
8. **Creates a script to run PlantUML**: Places it in `/usr/bin/plantuml`.

## Notes

- The script requires `sudo` privileges to install packages and place files in system directories.
- Ensure you have an active internet connection to download dependencies and PlantUML.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.