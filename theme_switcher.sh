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

# This script is a comprehensive theme switcher for Hyprland, designed to manage
# and apply consistent theming across various applications and components.
#
# It streamlines the process of switching between different "dark-only" themes
# by copying configuration files to their respective locations and reloading
# relevant services.
#
# Features:
# - Interactive theme selection via Wofi.
# - Manages configurations for: Hyprland, Waybar, Wofi (main & standard paths),
#   Kitty, Dunst, NeoVim, and rmpc.
# - Automatically updates rmpc theme settings.
# - Reloads Hyprland and restarts Waybar/Dunst for instant theme application.
# - Handles optional wallpaper changes.
#
# Usage:
#   Run the script without arguments to select a theme via Wofi:
#     ./theme-switcher.sh
#   Or, provide a theme name as an argument for direct application:
#     ./theme-switcher.sh <theme_name>
#
# Theme Structure:
#   Themes should be organized in subdirectories within ~/.config/hypr/themes/,
#   each containing application-specific configuration files (e.g., hyprland.conf,
#   waybar/config.ini, wofi/style.css, kitty/kitty.conf, kitty/current-theme.conf,
#   dunst/dunstrc, neovim_colors.lua, rmpc_theme.ron, wallpaper.jpg/png).

# --- Variable Setup ---
# The root directory where your themes are located.
THEME_DIR="$HOME/.config/hypr/themes"

# Destination directories where theme files should be copied.
HYPRLAND_CONFIG_PATH="$HOME/.config/hypr/hyprland.conf"
WAYBAR_CONFIG_PATH="$HOME/.config/hypr/waybar" # As requested, this is the Waybar directory
WOFI_CONFIG_PATH="$HOME/.config/hypr/wofifullt" # Path for Hyprland-specific Wofi config
WOFI_STANDARD_CONFIG_PATH="$HOME/.config/wofi" # Path for standard Wofi config
KITTY_CONFIG_PATH="$HOME/.config/kitty/kitty.conf"
KITTY_THEME_PATH="$HOME/.config/kitty/current-theme.conf" # Path for Kitty's current theme file
DUNST_CONFIG_PATH="$HOME/.config/dunst/dunstrc"
NEOVIM_CONFIG_DIR="$HOME/.config/nvim/lua/config" # This is where the NeoVim theme file goes
RMPC_THEME_DIR="$HOME/.config/rmpc/themes" # This is where the rmpc theme file goes
RMPC_MAIN_CONFIG="$HOME/.config/rmpc/config.ron" # The main rmpc config file

# --- Functions ---

# Checks if a theme exists in the theme directory.
check_theme_exists() {
    local theme_name="$1"
    if [ ! -d "$THEME_DIR/$theme_name" ]; then
        echo "Error: Theme '$theme_name' not found in $THEME_DIR."
        exit 1
    fi
}

# Copies theme files to their respective destination directories.
apply_theme() {
    local theme_name="$1"
    local selected_theme_path="$THEME_DIR/$theme_name"

    echo "Applying theme: $theme_name"

    # Copy Hyprland config
    if [ -f "$selected_theme_path/hyprland.conf" ]; then
        cp "$selected_theme_path/hyprland.conf" "$HYPRLAND_CONFIG_PATH"
        echo "  - Hyprland config copied."
    else
        echo "  - Warning: hyprland.conf not found in theme."
    fi

    # Copy Waybar configs (config.ini, style.css, modules)
    if [ -d "$selected_theme_path/waybar" ]; then
        # Delete existing content to ensure a clean target directory
        rm -rf "$WAYBAR_CONFIG_PATH"/*
        
        # Copy config.ini
        if [ -f "$selected_theme_path/waybar/config.ini" ]; then
            cp "$selected_theme_path/waybar/config.ini" "$WAYBAR_CONFIG_PATH/config.ini"
            echo "  - Waybar config.ini copied."
        else
            echo "  - Warning: config.ini not found in Waybar theme directory."
        fi

        # Copy style.css (if it exists)
        if [ -f "$selected_theme_path/waybar/style.css" ]; then
            cp "$selected_theme_path/waybar/style.css" "$WAYBAR_CONFIG_PATH/style.css"
            echo "  - Waybar style.css copied."
        else
            echo "  - Warning: style.css not found in Waybar theme directory."
        fi

        # Copy modules file (IF IT EXISTS)
        if [ -f "$selected_theme_path/waybar/modules" ]; then
            cp "$selected_theme_path/waybar/modules" "$WAYBAR_CONFIG_PATH/modules"
            echo "  - Waybar modules file copied."
        else
            echo "  - Warning: 'modules' file not found in Waybar theme directory."
        fi
    else
        echo "  - Warning: Waybar config directory (waybar/) not found in theme."
    fi

    # Copy Wofi config
    if [ -d "$selected_theme_path/wofi" ]; then
        # Copy to the primary Hyprland-specific Wofi directory
        mkdir -p "$WOFI_CONFIG_PATH" # Create if it doesn't exist
        rm -rf "$WOFI_CONFIG_PATH"/* # Delete existing content
        cp -r "$selected_theme_path/wofi/." "$WOFI_CONFIG_PATH/"
        echo "  - Wofi config copied to $WOFI_CONFIG_PATH."

        # NEW: Also copy to the standard Wofi directory
        mkdir -p "$WOFI_STANDARD_CONFIG_PATH" # Create if it doesn't exist
        rm -rf "$WOFI_STANDARD_CONFIG_PATH"/* # Delete existing content
        cp -r "$selected_theme_path/wofi/." "$WOFI_STANDARD_CONFIG_PATH/"
        echo "  - Wofi config also copied to $WOFI_STANDARD_CONFIG_PATH."
    else
        echo "  - Warning: Wofi config directory (wofi/) not found in theme."
    fi

    # Copy Kitty config
    if [ -f "$selected_theme_path/kitty/kitty.conf" ]; then
        cp "$selected_theme_path/kitty/kitty.conf" "$KITTY_CONFIG_PATH"
        echo "  - Kitty config (kitty.conf) copied."
    else
        echo "  - Warning: kitty.conf not found in theme."
    fi

    # NEW SECTION: Copy Kitty theme file (current-theme.conf)
    if [ -f "$selected_theme_path/kitty/current-theme.conf" ]; then
        cp "$selected_theme_path/kitty/current-theme.conf" "$KITTY_THEME_PATH"
        echo "  - Kitty theme config (current-theme.conf) copied."
    else
        echo "  - Warning: current-theme.conf not found in Kitty theme directory."
    fi

    # Copy Dunst config
    if [ -f "$selected_theme_path/dunst/dunstrc" ]; then
        cp "$selected_theme_path/dunst/dunstrc" "$DUNST_CONFIG_PATH"
        echo "  - Dunst config copied."
    else
        echo "  - Warning: dunstrc not found in theme."
    fi

    # Handle NeoVim theme file
    if [ -f "$selected_theme_path/neovim_colors.lua" ]; then
        mkdir -p "$NEOVIM_CONFIG_DIR" # Create if it doesn't exist
        cp "$selected_theme_path/neovim_colors.lua" "$NEOVIM_CONFIG_DIR/current_theme_colors.lua"
        echo "  - NeoVim theme file copied to $NEOVIM_CONFIG_DIR/current_theme_colors.lua."
        echo "  - Reminder: Ensure ~/.config/nvim/init.lua loads this file!"
    else
        echo "  - Warning: neovim_colors.lua not found in theme."
    fi

    # Handle Rmpc theme file
    if [ -f "$selected_theme_path/rmpc_theme.ron" ]; then
        mkdir -p "$RMPC_THEME_DIR" # Create if it doesn't exist
        cp "$selected_theme_path/rmpc_theme.ron" "$RMPC_THEME_DIR/$theme_name.ron"
        echo "  - Rmpc theme file copied to $RMPC_THEME_DIR/$theme_name.ron."
        if [ -f "$RMPC_MAIN_CONFIG" ]; then
            # Attempt to update the 'theme' field in the rmpc config.ron file.
            sed -i "s|theme: \".*\"|theme: \"$theme_name\"|" "$RMPC_MAIN_CONFIG"
            # If the sed command fails to find the pattern (e.g., if config.ron has a different format),
            # ensure rmpc loads the new theme manually.
            if ! grep -q "theme: \"$theme_name\"" "$RMPC_MAIN_CONFIG"; then
                echo "  - Warning: Rmpc main config file ($RMPC_MAIN_CONFIG) was not updated automatically."
                echo "    Please ensure the 'theme' field is manually set to '$theme_name' or your rmpc config loads themes dynamically."
            else
                echo "  - Rmpc config ($RMPC_MAIN_CONFIG) updated to '$theme_name' theme."
            fi
        else
            echo "  - Warning: Rmpc main config file ($RMPC_MAIN_CONFIG) not found, could not update theme."
        fi
    else
        echo "  - Warning: rmpc_theme.ron not found in theme."
    fi

    # Set wallpaper (optional)
    if [ -f "$selected_theme_path/wallpaper.jpg" ]; then
        swww img "$selected_theme_path/wallpaper.jpg" --transition-type grow --transition-duration 0.7
        echo "  - Wallpaper set."
    elif [ -f "$selected_theme_path/wallpaper.png" ]; then
        swww img "$selected_theme_path/wallpaper.png" --transition-type grow --transition-duration 0.7
        echo "  - Wallpaper set."
    else
        echo "  - Warning: Wallpaper (wallpaper.jpg or .png) not found in theme."
    fi

    echo "Theme applied."
}

# Reload system components
reload_components() {
    echo "Reloading components..."
    # Reload Hyprland
    # 'hyprctl reload' is the correct command to reload Hyprland's configuration.
    hyprctl reload
    echo "  - Hyprland reloaded."

    # Restart Waybar
    pkill waybar
    sleep 1 # Give Waybar a moment to shut down
    # Launch Waybar with the precise configuration files
    waybar -c "$WAYBAR_CONFIG_PATH/config.ini" -s "$WAYBAR_CONFIG_PATH/style.css" & disown
    echo "  - Waybar restarted."

    # Restart Dunst (if running and Mako is not running instead)
    # Only restart Dunst if no Mako instance is currently running
    if ! pgrep -x mako > /dev/null; then
        pkill dunst
        dunst & disown
        echo "  - Dunst restarted."
    else
        echo "  - Dunst not restarted as Mako is already running."
    fi
}

# --- Main Logic ---

# If no theme is provided as a parameter, prompt with Wofi.
if [ -z "$1" ]; then
    themes=($(find "$THEME_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n"))

    if [ ${#themes[@]} -eq 0 ]; then
        echo "No themes found in $THEME_DIR. Please create subdirectories for your themes."
        exit 1
    fi

    # Display Wofi menu
    selected_theme=$(printf "%s\n" "${themes[@]}" | wofi --dmenu --prompt "Select a theme:")

    if [ -z "$selected_theme" ]; then
        echo "No theme selected. Exiting."
        exit 0
    fi
else
    # If theme is passed as a parameter
    selected_theme="$1"
    check_theme_exists "$selected_theme"
fi

apply_theme "$selected_theme"
reload_components

echo "Script finished."
