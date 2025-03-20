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

source "$(dirname $0)"/get_instance_path.sh

cd "${WORKSPACE_PATH}"/pro-wfm-vrs-cd || exit

if ! DEPLOYMENT_DIRECTORY_PATH=$(find_instance_path "$PROJECT_NAME" "$TENANT_ID"); then
  echo "No instance found for $PROJECT_NAME and $TENANT_ID."
  exit 1
fi

cd "$(dirname "$0")" || exit

echo "DEPLOYMENT_DIRECTORY_PATH: ${DEPLOYMENT_DIRECTORY_PATH}"
export DEPLOYMENT_DIRECTORY_PATH

SERVICE_RELEASE=$(echo "$RELEASE_BRANCH" | tr '[:upper:]' '[:lower:]' | sed -E 's/\./d/g; s/[^a-z0-9]/_/g')
export TF_VAR_GHA_SERVICE_RELEASE=${RELEASE_BRANCH}
# Function to initialize Terragrunt
terragrunt_init() {
  echo "Run Terragrunt Init"
  terragrunt init
}


# Function to run Terragrunt plan
terragrunt_plan() {
  echo "Run Terragrunt plan --destroy "
  terragrunt plan --destroy -var "SERVICE_RELEASE=${SERVICE_RELEASE}" -var "DEPLOYMENT_NAME=${TENANT_ID}"
}

# Function to run Terragrunt plan

terragrunt_destroy() {
  echo "Run Terragrunt destroy"
  terragrunt destroy -auto-approve -var "SERVICE_RELEASE=${SERVICE_RELEASE}"  -var "DEPLOYMENT_NAME=${TENANT_ID}"
}

# Function to clean statefile
terragrunt_cleanStateFile() {
  echo "Run Terragrunt cleanstatefile"
  # Source the script file
  chmod +x *
  ./cleanStateFile.sh
}

# Main function to execute deployment steps
main() {
  cd ../../
  echo "$PWD"
  #
  cd "${DEPLOYMENT_DIRECTORY_PATH}"
  # Run Terragrunt commands
  terragrunt_init
  terragrunt_plan
  terragrunt_destroy
  # cd ../../../../../
  # cd "$PWD/scripts"
  # terragrunt_cleanStateFile

  # Check service status
  echo "Checking service status:"
  for service in "${SERVICES[@]}"; do
    check_service_status "$service"
  done

}
# Execute main function
main

