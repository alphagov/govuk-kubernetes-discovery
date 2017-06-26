#!/usr/bin/env bash

# Ubuntu
apt-get update -qq
apt-get -y upgrade
##############

cat <<"EOF" >> /home/${ssh_user}/.ssh/authorized_keys
${ssh_keys}
EOF
chown ${ssh_user}:${ssh_user} /home/${ssh_user}/.ssh/authorized_keys
chmod 600 /home/${ssh_user}/.ssh/authorized_keys

cat <<"EOF" > /home/${ssh_user}/.ssh/config
Host *
    StrictHostKeyChecking no
EOF
chmod 600 /home/${ssh_user}/.ssh/config
chown ${ssh_user}:${ssh_user} /home/${ssh_user}/.ssh/config

# Append addition user-data script
${additional_user_data_script}
