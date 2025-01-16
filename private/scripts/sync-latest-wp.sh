#!/bin/bash

# Variables
WORDPRESS_LATEST_URL="https://wordpress.org/latest.tar.gz"
TEMP_DIR="wordpress_temp"
DEST_DIR="$PWD" # Current directory

# Download the latest WordPress tarball
echo "Downloading the latest WordPress release..."
curl -o latest.tar.gz $WORDPRESS_LATEST_URL

# Extract the tarball to a temporary directory
echo "Extracting WordPress..."
mkdir -p $TEMP_DIR
tar --strip-components=1 -xzf latest.tar.gz -C $TEMP_DIR

# Remove the wp-content directory from the extracted files
echo "Excluding wp-content directory..."
rm -rf $TEMP_DIR/wp-content

# Sync the remaining files to the current directory (non-destructive)
echo "Syncing WordPress files to the current directory..."
rsync -av $TEMP_DIR/ $DEST_DIR/ --exclude "wp-content"

# Clean up
echo "Cleaning up temporary files..."
rm -rf $TEMP_DIR latest.tar.gz

echo "WordPress updated successfully, excluding wp-content!"
