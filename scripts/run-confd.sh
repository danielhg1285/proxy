#!/usr/bin/env bash

# Source commoun variables and functions
source common.sh

# Create sites-enabled directory
mkdir -p nginx/sites-enabled

# Remove nginx virtual hosts
rm -rf nginx/sites-enabled/*

# Create confd compose
docker-compose -f confd.yml config > confd-compose.yml

# Modify file permissions
chmod 600 confd-compose.yml

# Run confd
docker-compose -f confd-compose.yml run --rm confd