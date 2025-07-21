#!/bin/bash
#
#  ░▒▓████████▓▒░▒▓███████▓▒░░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░       ░▒▓████████▓▒░▒▓█▓▒░▒▓███████▓▒░  
#  ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░       ░▒▓██████▓▒░ ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#                                                                                                            
# Year: 2025.

# Fuzzy-search and remove installed Arch packages, including orphaned dependencies

# Request sudo password before starting fzf
sudo -v

# Check if sudo authentication was successful
if [ $? -ne 0 ]; then
    echo "Sudo authentication failed. Exiting."
    exit 1
fi

# Use fzf to select installed packages for removal
# -Q: Query installed packages
# -q: Query only package names
# fzf options:
#   --multi: Allow multiple selections
#   --preview: Show package info in a preview window
# xargs options:
#   -r: Do not run if input is empty
#   -o: Run command once for each line of input
selected_packages=$(sudo pacman -Qq | fzf --multi --preview 'pacman -Qi {1}')

if [ -z "$selected_packages" ]; then
    echo "No packages selected for removal. Exiting."
    exit 0
fi

# Remove selected packages and their unnecessary dependencies
echo "Attempting to remove selected packages and their dependencies..."
echo "$selected_packages" | xargs -ro sudo pacman -Rns

# Check if the removal was successful before trying to remove orphans
if [ $? -ne 0 ]; then
    echo "Error during package removal. Orphan cleanup skipped."
    exit 1
fi

echo "Searching for orphaned packages..."

# Find orphaned packages
# -Q: Query installed packages
# -t: List explicitly installed packages (not dependencies)
# -d: List packages that are no longer required by any explicitly installed package (orphans)
orphans=$(pacman -Qtdq)

if [ -z "$orphans" ]; then
    echo "No orphaned packages found."
else
    echo "The following orphaned packages were found:"
    echo "$orphans"

    # Offer to remove orphaned packages using fzf
    echo "Select orphaned packages to remove (press Enter to confirm, ESC to skip):"
    selected_orphans=$(echo "$orphans" | fzf --multi --preview 'pacman -Qi {1}')

    if [ -z "$selected_orphans" ]; then
        echo "No orphaned packages selected for removal. Orphan cleanup skipped."
    else
        echo "Attempting to remove selected orphaned packages..."
        echo "$selected_orphans" | xargs -ro sudo pacman -Rns
        if [ $? -eq 0 ]; then
            echo "Selected orphaned packages successfully removed."
        else
            echo "Error during orphaned package removal."
        fi
    fi
fi

echo "Script finished."
