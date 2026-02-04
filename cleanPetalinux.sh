# Script to search in the workstation for projects that has a very large size and probably we cannot work in it for some time
# Script developed by Christian Rangel Torres @ Gradiant
# 04/02/2026

#!/bin/bash

PROJECTS_ROOT="$HOME/projects"
SETTINGS_PATH="/opt/pkg/petalinux/2023.2/settings.sh"
DAYS_THRESHOLD=4

echo "Searching projects in: $PROJECTS_ROOT"

# Checking if the folder exists before continue
if [ ! -d "$PROJECTS_ROOT" ]; then
    echo "Error: We cannot find the projects folder in $HOME."
    echo "Ensure the correct path."
    exit 1
fi

echo "--- Starting the maintaining disk space ---"

# Uploading the Petalinux environment
if [ -f "$SETTINGS_PATH" ]; then
    echo "Uploading the environment for PetaLinux 2023.2..."
    source "$SETTINGS_PATH" > /dev/null 2>&1
else
    echo "ERROR: We don't find any environment in $SETTINGS_PATH"
    exit 1
fi

# 2. Searching the file 'project-spec' with 4 deep level
# Expect structure: /home/crangel/projects/Name_A/petalinux/Name_B/project-spec
echo "Starting the Petalinux cleaning project process not used by $DAYS_THRESHOLD days..."
find "$PROJECTS_ROOT" -maxdepth 4 -name "project-spec" -type d -mtime +$DAYS_THRESHOLD | while read spec_dir; do

    # The Petalinux project is the parent of the project-spec folder
    petalinux_dir=$(dirname "$spec_dir")

    echo "----------------------------------------------------------"
    echo "Petalinux directory detected: $petalinux_dir"

    # Enters into the Petalinux directory
    cd "$petalinux_dir" || continue
    
    # Checking if the 'build' folder exists before removes
    if [ -d "build" ]; then
        echo "Cleaning heavy files: $(basename $(dirname "$petalinux_dir"))"
        
        # We try the official clean way
        petalinux-build -x mrproper 2>/dev/null
        
        # If it fails or the environment is not loaded, we will remove manually
        if [ $? -ne 0 ]; then
            echo "Warning: Forcing manual remove of build/ and sstate-cache/..."
            rm -rf build/ components/ sstate-cache/
        else
            echo "Cleaning complete for Petalinux."
        fi
    else
        echo "Build folder clean or remove"
    fi
done

echo "----------------------------------------------------------"
echo "Cleaning completed, currently space in disk is:"
df -h "$HOME" | grep '/'
