#!/bin/bash

# Configuration
SEARCH_DIR="/var/log"
SIZE_THRESHOLD="+50M"
FILE_PATTERN="*.log"

echo "Starting log cleanup audit in $SEARCH_DIR..."
echo "Targeting files larger than $SIZE_THRESHOLD matching pattern '$FILE_PATTERN'"
echo "-----------------------------------------------------------------------"

# Use find to locate files and store them in an array
# We use sudo to ensure we have access to all system logs
mapfile -t LARGE_FILES < <(sudo find "$SEARCH_DIR" -type f -size "$SIZE_THRESHOLD" -name "$FILE_PATTERN" 2>/dev/null)

if [ ${#LARGE_FILES[@]} -eq 0 ]; then
    echo "No files exceeding $SIZE_THRESHOLD were found."
    exit 0
fi

echo "The following large files were identified:"
printf '%s\n' "${LARGE_FILES[@]}"
echo "-----------------------------------------------------------------------"

for FILE in "${LARGE_FILES[@]}"; do
    # Prompt the user for confirmation
    read -p "Do you want to delete $FILE? (y/n): " CONFIRM
    
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        sudo rm -v "$FILE"
    else
        echo "Action skipped for $FILE."
    fi
done

echo "-----------------------------------------------------------------------"
echo "Cleanup audit complete."
