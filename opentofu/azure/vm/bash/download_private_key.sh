#! /bin/bash

sshDir=$HOME/.ssh
fileName=azure_vm_personal_"${project_postfix}"

mkdir -p "$sshDir"

echo "${private_key}" > "$sshDir/$fileName"

chmod 600 "$sshDir/$fileName"