#!/usr/bin/env bash
# Get plan outputs from Terraform Cloud and build ssh config to facilitate running ansible.
#
# Expected use:
#   ./make_ssh_config.sh > ssh_config

###################
# Config from ENV #
###################

# Terraform cloud workspace name
WORKSPACE_NAME="${WORKSPACE_NAME:=bravo-slurm}"

# Slurm login node hostname
SLURM_LOGIN_HOST="${WORKSPACE_NAME:=bravo-slurm-login}"

# Slurm path to control socket.
SLURM_SSH_CONTROL_PATH="${SLURM_SSH_CONTROL_PATH:=~/.ssh/sockets/slurm-login-node}"

# Posix account name for GCP VMs
GCP_POSIX_UNAME_GUESS=$(gcloud --format=json auth list | jq -r '.[0].account' | sed 's/[@.]/_/g')
GCP_POSIX_UNAME="${GCP_POSIX_UNAME:=${GCP_POSIX_UNAME_GUESS}}"

###################################
# Process Terraform Cloud Outputs #
###################################

# Get terraform cloud token from credentials file 
JQ_EXP='."credentials"."app.terraform.io"."token"'
TOKEN=$(jq -r ${JQ_EXP} < ~/.terraform.d/credentials.tfrc.json)

# Get Workspace Id from Name
URL_ID="https://app.terraform.io/api/v2/organizations/statgen/workspaces?search%5Bname%5D=${WORKSPACE_NAME}"
WORKSPACE_ID=$(curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "${URL_ID}" |\
  jq -r '.data[0].id')

# Get json output from terraform workspace outputs
#   Munge to similar format as terraform output -json  
URL_OUTS="https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/current-state-version?include=outputs"
TERRAFORM_JSON=$(curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "${URL_OUTS}" |\
  jq '.included | map( {(.attributes.name) : .attributes.value}) | add')

LOGIN_IP=$(echo "${TERRAFORM_JSON}" | jq -r '.login_nat_ips[0]')

###################
# Emit SSH config #
###################

cat << SSHDOC
Host bravo-slurm-login
  User ${GCP_POSIX_UNAME}
  HostName ${LOGIN_IP}
  Port 22
  ControlMaster auto
  ControlPath ${SLURM_SSH_CONTROL_PATH}
  KbdInteractiveAuthentication=no
SSHDOC
