# Deploy data prep dependencies to slurm cluster on GCP

## Dependencies
- GCP Account
- Ansible
- Terraform
    \* Only required to pull config details from terraform cloud

## Ansible Requirements File
If a requirements file is present, install ansible galaxy collections:
```sh
ansible-galaxy install -r requirements.yml
```
## Run
Once cluster has been provisioned:
1. create an ssh config for connecting to the login node.
    ```sh
    ./make_ssh_config.sh > ssh_config
    ```
1. run ansible to install pipeline requirements
    ```sh
    ansible-playbook --ssh-common-args='-F ssh_config' -i 'inventory.yml' playbook.yml
    ```

## SSH Config
The `make_ansible_files.sh` emits an ssh config as a convenience for connecting to the login node.
To eshew the terraform cloud depenency, an appriopriate ssh\_config file can be produce by other means.
```
Host example-slurm-login
  User ${GCP_POSIX_UNAME}
  Hostname ${LOGIN_IP}
  Port 22
  ControlMaster auto
  ControlPath ${SLURM_SSH_CONTROL_PATH}
  KbdInteractiveAuthentication=no
```

## Notes
- Loftee no longer requires MySQL database running.  Uses sqlite file.
- Downloading data from Ensembl when cached copy isn't available takes a **long time**.
