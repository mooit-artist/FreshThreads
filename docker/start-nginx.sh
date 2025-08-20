#!/bin/sh

# Simple start script for nginx (removing OpenAppSec for now)
echo "Starting FreshThreads frontend..."

# Start nginx
exec nginx -g "daemon off;"
