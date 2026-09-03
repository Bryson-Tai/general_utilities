#! /bin/bash

sshDir=$HOME/.ssh
fileName=azure_vm_personal_"${project_postfix}"

mkdir -p "$sshDir"

sshKeyPath="$sshDir/$fileName"


if [ -n "$CREATE_PRIVATE_KEY" ]; then
    echo "${private_key}" > "$sshKeyPath"

    chmod 600 "$sshKeyPath"
elif [ -n "$DELETE_PRIVATE_KEY" ]; then
    rm -f "$sshKeyPath"
fi
