#!/bin/bash

# Define the services to check
SERVICES=("nginx" "opensearch" "tomcat" "")

# Function to check the status of a service
check_service_status() {
  local service_name="$1"

  # Attempt to get the service status using systemctl
  if command -v systemctl &> /dev/null; then
    if systemctl is-active --quiet "$service_name"; then
      echo "$service_name: Running"
    else
      echo "$service_name: Stopped"
    fi

  # if systemctl is not available try service command.
  elif command -v service &> /dev/null; then
      if service "$service_name" status &> /dev/null ; then
        echo "$service_name: Running"
      else
        echo "$service_name: Stopped"
      fi

  # If neither systemctl nor service is available, try a process check (less reliable)
  elif pgrep -x "$service_name" > /dev/null; then
    echo "$service_name: Running (process check)"
  else
    echo "$service_name: Not found"
  fi
}



