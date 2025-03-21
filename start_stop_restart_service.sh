#!/bin/bash

# Function to start a service
start_service() {
  local service_name="$1"
  echo "Starting $service_name..."
  if command -v systemctl &> /dev/null; then
    if systemctl start "$service_name"; then
      echo "$service_name: Started successfully."
    else
      echo "$service_name: Failed to start."
    fi
  elif command -v service &> /dev/null; then
    if service "$service_name" start; then
      echo "$service_name: Started successfully."
    else
      echo "$service_name: Failed to start."
    fi
  else
    echo "$service_name: Start not supported on this system."
  fi
}

# Function to stop a service
stop_service() {
  local service_name="$1"
  echo "Stopping $service_name..."
  if command -v systemctl &> /dev/null; then
    if systemctl stop "$service_name"; then
      echo "$service_name: Stopped successfully."
    else
      echo "$service_name: Failed to stop."
    fi
  elif command -v service &> /dev/null; then
    if service "$service_name" stop; then
      echo "$service_name: Stopped successfully."
    else
      echo "$service_name: Failed to stop."
    fi
  else
    echo "$service_name: Stop not supported on this system."
  fi
}

# Function to restart a service
restart_service() {
  local service_name="$1"
  echo "Restarting $service_name..."
  if command -v systemctl &> /dev/null; then
    if systemctl restart "$service_name"; then
      echo "$service_name: Restarted successfully."
    else
      echo "$service_name: Failed to restart."
    fi
  elif command -v service &> /dev/null; then
    if service "$service_name" restart; then
      echo "$service_name: Restarted successfully."
    else
      echo "$service_name: Failed to restart."
    fi
  else
    echo "$service_name: Restart not supported on this system."
  fi
}

# Main script logic
while true; do
  echo "Available services: (Use the service name as shown in your system)"
  # List services -  This is system specific.  The script doesn't know *which* services
  # are relevant to the user.  A common approach is to provide a list of
  # commonly managed services, or to rely on the user to know the service name.
  #  For example, if you wanted to list all systemd services you could use:
  # systemctl list-unit-files --type=service | grep .service | awk '{print $1}'
  #  However, that might be overwhelming.  For this example, I will not list any services.
  echo " "
  read -p "Enter service name: " service_name
  echo " "
  echo "Choose an action:"
  echo "1. Start"
  echo "2. Stop"
  echo "3. Restart"
  echo "4. Exit"
  read -p "Enter your choice (1-4): " choice

  case "$choice" in
    1)
      start_service "$service_name"
      ;;
    2)
      stop_service "$service_name"
      ;;
    3)
      restart_service "$service_name"
      ;;
    4)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac
  echo " "
done
