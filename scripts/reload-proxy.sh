#!/usr/bin/env bash

if docker ps | grep -q nginx-proxy; then
   echo "Reloading proxy configuration ..."
   docker exec nginx-proxy nginx -s reload
fi