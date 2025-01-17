#!/bin/bash

# Variables
WORDPRESS_API_URL="https://api.wordpress.org/core/version-check/1.7/"
CURRENT_VERSION_FILE="$PWD/wp-includes/version.php"
DEST_DIR="$PWD" # Current directory

# Function to extract WordPress version from version.php
get_wp_version() {
  local version_file="$1"
  if [[ -f "$version_file" ]]; then
    grep "\$wp_version =" "$version_file" | awk -F "'" '{print $2}'
  else
    echo ""
  fi
}

# Function to fetch the latest WordPress version from the API
get_latest_wp_version() {
  curl -s "$WORDPRESS_API_URL" | jq -r '.offers[0].version'
}

# Check if WordPress is already installed
if [[ -f "$CURRENT_VERSION_FILE" ]]; then
  echo "WordPress installation detected. Checking for updates..."

  # Get the current and latest WordPress versions
  CURRENT_VERSION=$(get_wp_version "$CURRENT_VERSION_FILE")
  LATEST_VERSION=$(get_latest_wp_version)

  if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo "WordPress is up-to-date (version $CURRENT_VERSION). No action needed."
    exit 0
  fi

  echo "Newer WordPress version detected (current: $CURRENT_VERSION, latest: $LATEST_VERSION). Updating..."
else
  echo "No WordPress installation detected. Proceeding with download and setup..."
  LATEST_VERSION=$(get_latest_wp_version)
fi

# Variables for downloading and extracting WordPress
WORDPRESS_LATEST_URL="https://wordpress.org/latest.tar.gz"
TEMP_DIR="wordpress_temp"

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
rsync -aq $TEMP_DIR/ $DEST_DIR/ --exclude "wp-content"

# Clean up
echo "Cleaning up temporary files..."
rm -rf $TEMP_DIR latest.tar.gz

echo "WordPress updated successfully, excluding wp-content!"
