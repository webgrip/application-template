#!/bin/sh
set -e

# This script is used to set up the environment for the Docker container.
# It can be used to run any initialization commands before starting the main application.
# Check if the required environment variable is set
if [ -z "$APP_ENV" ]; then
    echo "Error: APP_ENV environment variable is not set."
    exit 1
fi