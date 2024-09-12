#!/bin/bash

# Define the characters to be used in the key
CHARS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

# Generate a random key of 256 characters length
KEY=$(for i in {1..256}; do echo -n "${CHARS:RANDOM%${#CHARS}:1}"; done)

# Check if the .env file exists
if [ ! -f .env ]; then
    # Create the .env file if it doesn't exist
    touch .env
fi

# Check if the JWT_SECRET key already exists in the .env file
if grep -q "JWT_SECRET" .env; then
    # Remove the existing JWT_SECRET key from the .env file
    sed -i '' '/JWT_SECRET/d' .env
fi

# Write the key to the .env file
echo 'JWT_SECRET='$KEY >> .env

# Output a success message
echo "JWT_SECRET key generated and saved to .env file."
