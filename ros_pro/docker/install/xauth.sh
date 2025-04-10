#!/bin/bash

# xauth.sh - Script to set up X11 authentication for Docker containers

# Check if DISPLAY is set
if [ -z "$DISPLAY" ]; then
    echo "ERROR: DISPLAY environment variable is not set. Please ensure X11 forwarding is enabled."
    exit 1
fi

# Create a temporary file for the X11 cookie
XAUTH_TEMP=$(mktemp)
echo "Temporary X11 authority file created at: $XAUTH_TEMP"

# Extract the X11 authentication cookie from the host
echo "Extracting X11 cookie for display: $DISPLAY"
xauth_list=$(xauth nlist "$DISPLAY" | tail -n 1 | sed -e 's/^..../ffff/')

# Merge the X11 cookie into the temporary file
if [ -n "$xauth_list" ]; then
    echo "Merging X11 cookie into temporary file..."
    echo "$xauth_list" | xauth -f "$XAUTH_TEMP" nmerge -
else
    echo "WARNING: No X11 cookie found for display: $DISPLAY"
    touch "$XAUTH_TEMP"
fi

# Set the X11 authentication cookie inside the container
if [ -f "$XAUTH_TEMP" ]; then
    echo "Setting up X11 authentication..."
    xauth -f "$XAUTH_TEMP" add "$DISPLAY" . "$(xauth -f "$XAUTH_TEMP" list "$DISPLAY" | awk '{print $NF}')"
    export XAUTHORITY=$XAUTH_TEMP
    echo "X11 authentication setup complete."
else
    echo "ERROR: Failed to set up X11 authentication."
    exit 1
fi

# Debugging output
echo ""
echo "Verifying file contents:"
file "$XAUTH_TEMP"
echo "--> It should say \"X11 Xauthority data\"."
echo ""
echo "Permissions:"
ls -FAlh "$XAUTH_TEMP"
echo ""
echo "X11 authority file location: $XAUTH_TEMP"

# Keep the container running (useful for debugging)
exec "$@"