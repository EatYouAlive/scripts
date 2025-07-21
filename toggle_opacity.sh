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

### Script to toggle global opacity in Hyprland ###
# bind = $mainMod, o, exec, ~/.config/hypr/scripts/toggle_opacity.sh


# ---- Customizable values ----
# How transparent the active window should be (e.g., 0.85 in your case)
TRANSPARENT_ACTIVE_VALUE="0.85"
# How transparent the inactive window should be (e.g., 0.75)
TRANSPARENT_INACTIVE_VALUE="0.85" # Can be the same as active, or different

# Fully opaque values
OPAQUE_ACTIVE_VALUE="1.0"
OPAQUE_INACTIVE_VALUE="1.0"
# ---------------------------------

# Get current 'active_opacity' value
CURRENT_ACTIVE_OPACITY_OUTPUT=$(hyprctl getoption decoration:active_opacity)
# Extract value (e.g., "0.850000") - CORRECTED LINE
CURRENT_ACTIVE_OPACITY=$(echo "$CURRENT_ACTIVE_OPACITY_OUTPUT" | awk '/float:/ {print $2}')

# --- Debugging lines (you can delete them if it works well) ---
echo "DEBUG: Hyprland raw output: [$CURRENT_ACTIVE_OPACITY_OUTPUT]"
echo "DEBUG: Processed current 'active_opacity': [$CURRENT_ACTIVE_OPACITY]"
echo "DEBUG: Comparing with this transparent value: [$TRANSPARENT_ACTIVE_VALUE]"
# --- End of debugging ---

# Check if the current 'active_opacity' matches the SET TRANSPARENT value.
# The awk command will exit with code 0 if they are equal (which means 'true' for the shell 'if').
# It will exit with code 1 if they are not equal (which means 'false').
awk -v current="$CURRENT_ACTIVE_OPACITY" -v transparent_target="$TRANSPARENT_ACTIVE_VALUE" \
    'BEGIN {
        if (current == transparent_target) {
            exit 0 # Equal -> 0 (true)
        } else {
            exit 1 # Not equal -> 1 (false)
        }
    }'

# The '$?' variable contains the exit code of the last executed command (i.e., awk).
# If $? equals 0, then the current state is already our defined TRANSPARENT state.
if [ $? -eq 0 ]; then
    # Currently TRANSPARENT, so let's make it OPAQUE
    echo "Info: Current state is transparent. Switching to opaque..."
    hyprctl --batch "\
        keyword decoration:active_opacity $OPAQUE_ACTIVE_VALUE;\
        keyword decoration:inactive_opacity $OPAQUE_INACTIVE_VALUE"
else
    # Currently NOT TRANSPARENT (i.e., opaque, or another value), so let's make it TRANSPARENT
    echo "Info: Current state is not (the target) transparent. Switching to transparent..."
    hyprctl --batch "\
        keyword decoration:active_opacity $TRANSPARENT_ACTIVE_VALUE;\
        keyword decoration:inactive_opacity $TRANSPARENT_INACTIVE_VALUE"
fi

