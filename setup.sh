#!/bin/bash
set -e

notify() {
  # usage: notify "Title" "Message"
  osascript -e "display notification \"$2\" with title \"$1\""
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

notify "MacStats Setup" "This script will set up MacStats for you."
sleep 2
notify "Checking requirements..." "Please wait while we check your system."
# Install Python3 if missing
if ! command_exists python3; then

    notify "Python3 Installation" "Python3 is not installed. Installing now..."
    # Install Homebrew if not installed (completely non-interactive)
    if ! command_exists brew; then
        notify "Homebrew Installation" "Please install Homebrew to continue."
        # open homebrew installation page
        open "https://brew.sh/"
        exit 0
    fi
    brew install python
else
    echo "Python3 already installed."
fi

# Check pip3
if ! command_exists pip3; then
    notify "pip3 Installation" "pip3 is not installed. Installing now..."
    python3 -m ensurepip --upgrade || {
        notify "pip3 Installation Failed" "Failed to install pip3. Please install it manually."
        exit 0
    }
else
    echo "pip3 already installed."
fi

# Your script variables and arrays
baseurl="https://raw.githubusercontent.com/CyberHorizonLtd/macstats/refs/heads/main/"
files=(
    "backend.py"
    "requirements.txt"
    "run.sh"
)

templateextension="templates/pages/"
templates=(
    "storage.html"
)

notify "Cleaning up..." "Removing existing files and templates."

# Remove existing files
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Removing $file..."
        rm "$file"
    fi
done

# Remove existing templates
for template in "${templates[@]}"; do
    if [ -f "${templateextension}${template}" ]; then
        echo "Removing ${templateextension}${template}..."
        rm "${templateextension}${template}"
    fi
done

notify "Downloading files..." "Please wait while we download the necessary files."

# Download files
for file in "${files[@]}"; do
    echo "Downloading $file..."
    curl -s -O "${baseurl}${file}"
done

# Download templates
for template in "${templates[@]}"; do
    echo "Downloading ${templateextension}${template}..."
    mkdir -p "$(dirname "${templateextension}${template}")"
    curl -s -o "${templateextension}${template}" "${baseurl}${templateextension}${template}"
done

notify "Running MacStats now..." "Setting up the virtual environment and installing dependencies."

# Run your run.sh script
bash run.sh
