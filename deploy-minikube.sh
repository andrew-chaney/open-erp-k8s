#!/bin/sh

GREEN='\033[0;32m'
RED='\033[0;31m'
CLEAR='\033[0m'


# Check to make sure that Docker is runnning
printf "${GREEN}Checking to make sure Docker is running..."
if ! docker info >/dev/null 2>&1; then
    printf "${RED}FAILED\n"
    printf "Please ensure that Docker is running for the script to work...\n"
    exit 1
fi
printf "DONE\n\n"

# Build services' Docker images locally
printf "Building Docker images:\n"
for dir in ../*/; do
    if diff -q $dir . >/dev/null 2>&1; then
        continue
    fi

    service_name=$(basename $dir)

    printf "\tBuilding image for '${service_name}'..."

    if ! ls $dir | grep Dockerfile >/dev/null 2>&1; then
        printf "\n${RED}Failed to find a valid Dockerfile for '${service_name}'\n"
        exit 1
    fi

    if ! docker build -t $service_name $dir >/dev/null 2>&1; then
        printf "\n${RED}Failed to build image for '${service_name}'\n"
        exit 1
    fi

    printf "DONE\n"
done
printf "\n"

# Check to make sure that minikube is running
printf "Checking minikube status..."
if ! minikube status >/dev/null 2>&1; then
    printf "${RED}FAILED\n"
    printf "${GREEN}Minikube is not running. Starting now...\n${CLEAR}"

    if ! minikube start; then
        printf "${RED}There is an issue with starting minikube on your machine\n."
        printf "Please ensure that minikube and Docker are properly setup.\n"
        exit 1
    fi
    
    printf "\n"
else
    printf "DONE\n\n"
fi

printf "${GREEN}SUCCESS... finish impelementing to run services in the local cluster.\n"

# Launch services and deployments via minikube
# --- Make sure that the DB service initializes the DB via the init script

# Start pinging the health check endpoint for a certain amount of time to make
# sure that it is running
