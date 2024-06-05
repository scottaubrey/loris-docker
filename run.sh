#!/bin/bash
set -e

# Build the Docker image
docker build -t elifesciences/loris:${IMAGE_TAG:-latest} .

# Run the Docker container
docker run \
    --rm \
    --name loris \
    --publish 5004:5004 \
    elifesciences/loris:${IMAGE_TAG:-latest} 

# Stop and remove with:
# docker rm -f loris

