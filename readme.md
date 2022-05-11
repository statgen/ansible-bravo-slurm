# Deploy data prep dependencies to slurm cluster on GCP

## Requirements
```sh
ansible-galaxy install -r requirements.yml
```

## Run

Once cluster has been provisioned:
1. create an ssh config to connect to the login node.
    ```sh
    ./make_ssh_config.sh > ssh_config
    ```
1. run ansible to install pipeline requirements
    ```sh
    ansible-playbook --ssh-common-args='-F ssh_config' -i 'inventory.yml' playbook.yml
    ```

## Notes

Loftee no longer requires MySQL database running.  Uses sqlite file.
