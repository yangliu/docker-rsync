#!/bin/sh

case "${MODE}" in
  server)
          # prepare authorized_keys
          [ ! -d /root/.ssh ] && mkdir -p /root/.ssh
          [ -f /root/.ssh/authorized_keys ] && rm /root/.ssh/authorized_keys
          touch /root/.ssh/authorized_keys
          chmod 0600 /root/.ssh/authorized_keys
          
          for item in $(env); do
            case "${item}" in
              AUTH_KEY*)
                ENV_KEY=$(echo $item | cut -d \= -f 1)
                printenv $ENV_KEY >> /root/.ssh/authorized_keys
            esac
          done

          # config openssh
          sed -i "s/.*PasswordAuthentication .*/PasswordAuthentication no/g" /etc/ssh/sshd_config
          sed -i 's/root:!/root:*/' /etc/shadow
          [ ! -e /etc/ssh/ssh_host_rsa_key.pub ] && ssh-keygen -A

          # start openssh server
          AUTH=$(cat /root/.ssh/authorized_keys)
          if [ -z "$AUTH" ]; then
            echo "ERROR: No ssh pub keys provided. Please provide them with AUTH_KEY."
            exit 1
          fi
          SSH_PARAMS="-D -e -p ${SSH_PORT:-22222} $SSH_PARAMS"
          echo "Launch sshd: /usr/sbin/sshd ${SSH_PARAMS}"
          exec /usr/sbin/sshd $SSH_PARAMS
        ;;
  client)
          # prepare ssh_key
          [ ! -d /root/.ssh ] && mkdir -p /root/.ssh
          [ ! -f /root/.ssh/id_rsa.pub ] && ssh-keygen -q -N "" -f /root/.ssh/id_rsa
          
          # configure crontab
          [ -f /etc/crontabs/root ] && rm /etc/crontabs/root
          touch /etc/crontabs/root
          for item in $(env); do
            case "$item" in
              CRON_TASK*)
                ENV_CRON=$(echo $item | cut -d \= -f 1)
                printenv $ENV_CRON >> /etc/crontabs/root
                echo "root" > /etc/crontabs/cron.update
            esac
          done

          # show id_rsa.pub
          echo "Please add the following ssh key to your authorized_keys"
          echo "---"
          echo $(cat /root/.ssh/id_rsa.pub)
          echo "---"

          echo "Launching crond ..."
          echo "current cron tasks:"
          echo $(cat /etc/crontabs/root)
          exec /usr/sbin/crond -f
        ;;
  cmd)
          exec "$@"
        ;;
  *)
          # unknown mode
          echo "ERROR: Unknown mode - ${MODE}"
          exit 1
        ;;
esac