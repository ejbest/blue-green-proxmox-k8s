  #!/bin/bash

  VAULT_ADDR=https://vault.waterskiingguy.com:8200
  VAULT_TOKEN=hvs.qYrLTZZUNlbVYj73VhdcODnm
  timestamp=$(date +%s)
  SNAPSHOT_NAME="snapshot_$timestamp.snap"

  # Prompt the user for environment variable values
  read -p "Enter the value for Destination Environment(green or blue): " ENV
  # read -p "Enter the ip address of Worker node: " WORKER
  # read -p "Enter the ip address of Controlplane: " CONTROLPLANE

  # read -p "Enter the ip address of Controlplane: " CONTROLPLANE

  echo -e "\e[32mINFO:\e[0m Configuring backup environment for $ENV"

  if [ "$ENV" == "green" ]; then
    WORKER=192.168.0.126
    CONTROLPLANE=192.168.0.125
    RESTORE_VAULT_ADDR=https://vault.advocatediablo.com
    SNAPSHOY_FILE=echo -e "\e[32mINFO:\e[0m Green environment configured"

  elif [ "$ENV" == "blue" ]; then
    WORKER=192.168.0.128
    CONTROLPLANE=192.168.0.127
    RESTORE_VAULT_ADDR=https://vault.advocatediablo.com/
    echo -e "\e[32mINFO:\e[0m Blue environment configured"

  else 
    echo -e "\e[31mERROR:\e[0m Unsupported environment"
    exit 1

  fi

  SSH_PASS=$(vault kv get -field=ssh_pass ssh_pass/ssh_pass)
  SSH_WORKER="sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no k8s@${WORKER}"
  SSH_CONTROLPLANE="sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no k8s@${CONTROLPLANE}"
  JENKINS_BACKUP_DIR="/storage/backup-data/jenkins"
  VAULT_BACKUP_DIR="/storage/backup-data/vault"
  JENKINS_BACKUP_DIR_PATTERN="backup-jenkins-*"
  VAULT_BACKUP_DIR_PATTERN="backup-vault-*"
  DESTINATION_SEARCH_DIR="/storage/volumes"
  VAULT_INIT_JSON_NAME=$VAULT_BACKUP_DIR/$ENV-vault-init-$timestamp.json
  VAULT_SNAPSHOT_NAME=$VAULT_BACKUP_DIR/$SNAPSHOT_NAME

  # Searching for the latest jenkins dir in BACKUP_DIR
  echo -e "\e[32mINFO:\e[0m Searching for the latest jenkins backup in $JENKINS_BACKUP_DIR on utility"
  latest_jenkins_dir=$(ls -t "$JENKINS_BACKUP_DIR" | grep -E "^$JENKINS_BACKUP_DIR_PATTERN" | head -n 1)

  if [ -z "$latest_jenkins_dir" ]; then
    echo -e "\e[31mERROR:\e[0mNo dirs with prefix '$JENKINS_BACKUP_DIR_PATTERN' found in $JENKINS_BACKUP_DIR"
    exit 1
  else
    echo -e "\e[32mINFO:\e[0m Latest jenkins dir '$latest_jenkins_dir'"
  fi

  # Searching for the latest vault dir in BACKUP_DIR
  echo -e "\e[32mINFO:\e[0m Searching for the latest vault backup in $VAULT_BACKUP_DIR on utility"
  latest_vault_dir=$(ls -t "$VAULT_BACKUP_DIR" | grep -E "^$VAULT_BACKUP_DIR_PATTERN" | head -n 1)

  if [ -z "$latest_vault_dir" ]; then
    echo -e "\e[31mERROR:\e[0mNo dirs with prefix '$VAULT_BACKUP_DIR_PATTERN' found in $VAULT_BACKUP_DIR"
    exit 1
  else
    echo -e "\e[32mINFO:\e[0m Latest vault dir '$latest_vault_dir'"
  fi

  # Check if any matching vault pvc is found
  # echo -e "\e[32mINFO:\e[0m Searching for vault pvc in $DESTINATION_SEARCH_DIR on $WORKER"
  # vault_pvc=$($SSH_WORKER sudo find for "$DESTINATION_SEARCH_DIR" -mindepth 1 -maxdepth 1 -type d -name '*vault*' 2>/dev/null)
  # if [ -z "$vault_pvc" ]; then
    # echo -e "\e[31mERROR:\e[0m pvc not found"
    # exit 1
  # else
    # echo -e "\e[32mINFO:\e[0m vault pvc found"
    # echo -e "$vault_pvc"

    # Ownership update
    # echo -e "\e[32mINFO:\e[0m updating vault ownership"
    # $SSH_WORKER sudo chown -R systemd-network:k8s $vault_pvc/* 2>/dev/null
    # $SSH_WORKER sudo chmod -R 777 $vault_pvc/* 2>/dev/null

    # Statefulset scale down
    # echo -e "\e[32mINFO:\e[0m Scaling down vault statefulset for seamless restore"

    # $SSH_CONTROLPLANE kubectl scale statefulset vault -n vault --replicas=0  2>/dev/null

  # Data restore
  echo -e "\e[32mINFO:\e[0m Anchor Vault raft backup"

  # Backup Anchor vault
  VAULT_ADDR=$VAULT_ADDR VAULT_TOKEN=$VAULT_TOKEN vault operator raft snapshot save $VAULT_SNAPSHOT_NAME

  # Init and unseal Vault
  echo -e "\e[32mINFO:\e[0m Init and Unseal $ENV vault"

  # Initialize Vault and retrieve unseal keys and root token
  VAULT_ADDR=$RESTORE_VAULT_ADDR vault operator init -format=json > $VAULT_INIT_JSON_NAME
  
  sleep 10

  # Extract unseal keys and root token
  UNSEAL_KEYS=$(cat $VAULT_INIT_JSON_NAME | jq -r .unseal_keys_b64[])
  ROOT_TOKEN=$(cat $VAULT_INIT_JSON_NAME | jq -r .root_token)

  # Unseal Vault using the unseal keys
  for key in $UNSEAL_KEYS; do
    vault operator unseal -address=$RESTORE_VAULT_ADDR $key
  done

  sleep 10
  
  echo -e "\e[32mINFO:\e[0m Vault data restore in progress"
  VAULT_ADDR=$RESTORE_VAULT_ADDR VAULT_TOKEN=$ROOT_TOKEN vault operator raft snapshot restore -force $VAULT_SNAPSHOT_NAME
  # sshpass -p $SSH_PASS scp -rv -o StrictHostKeyChecking=no $SNAPSHOT_NAME  $SSH_WORKER:$vault_pvc

  # echo -e "\e[32mINFO:\e[0m Delete Snapshot file"
  # rm $SNAPSHOT_NAME

  # Ownership update
  # echo -e "\e[32mINFO:\e[0m updating vault ownership"
  # $SSH_WORKER sudo chown -R systemd-network:k8s $vault_pvc/* 2>/dev/null
  # $SSH_WORKER sudo chmod -R 777 $vault_pvc/* 2>/dev/null

  # Statefulset scale up
  # echo -e "\e[32mINFO:\e[0m Scaling up vault statefulset for seamless restore"
  # $SSH_CONTROLPLANE kubectl scale statefulset vault -n vault --replicas=1  2>/dev/null

  # fi

  # Check if any matching jenkins pvc is found
  echo -e "\e[32mINFO:\e[0m Searching for jenkins pvc in $DESTINATION_SEARCH_DIR on $WORKER"
  jenkins_pvc=$($SSH_WORKER sudo find for "$DESTINATION_SEARCH_DIR" -mindepth 1 -maxdepth 1 -type d -name '*jenkins*' 2>/dev/null)
  if [ -z "$jenkins_pvc" ]; then
    echo -e "\e[31mERROR:\e[0m pvc not found in $DESTINATION_SEARCH_DIR."
    exit 1
  else
    echo -e "\e[32mINFO:\e[0m Pvc found:"
    echo -e "$jenkins_pvc"

    echo -e "\e[32mINFO:\e[0m updating jenkins pvc ownership"
    $SSH_WORKER sudo chown -R 1001:k8s $jenkins_pvc/* 2>/dev/null
    $SSH_WORKER sudo chmod -R 777 $jenkins_pvc/* 2>/dev/null

    echo -e "\e[32mINFO:\e[0m Scaling down Jenkins deployment for seamless restore"
    $SSH_CONTROLPLANE kubectl scale deployment jenkins -n jenkins --replicas=0  2>/dev/null

    echo -e "\e[32mINFO:\e[0m Data restore in progress"
    # sshpass -p $SSH_PASS scp -rv -o StrictHostKeyChecking=no  $JENKINS_BACKUP_DIR/$latest_jenkins_dir/* $SSH_WORKER:$jenkins_pvc/

    echo -e "\e[32mINFO:\e[0m updating jenkins pvc ownership"
    $SSH_WORKER sudo chown -R 1001:k8s $jenkins_pvc/* 2>/dev/null
    $SSH_WORKER sudo chmod -R 777 $jenkins_pvc/* 2>/dev/null

    echo -e "\e[32mINFO:\e[0m Scaling Up Jenkins deployment"
    $SSH_CONTROLPLANE kubectl scale deployment jenkins -n jenkins  --replicas=1  2>/dev/null
    
  fi
