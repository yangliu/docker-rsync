# docker-rsync
crontab, rsync and docker

## As SSH Server
```
docker run -d --name rsync-ssh-server \
-v /your_data:/data \
-e MODE=server \
-e AUTH_KEY_1="your id_pub.rsa here" \
-e AUTH_KEY_2="your id_pub.rsa here" \
-e SSH_PORT=22222 \
yangliu/rsync
```
you can use environment varible SSH_PARAMS to specific custom sshd parameters

## As Client
```
docker run -d --name rsync-client \
-v /your_data:/data \
-v /your_scripts:/scripts \
-v /var/run/docker.sock:/var/run/docker.sock \
-e MODE=client \
-e CRON_TASK_1="*/2 * * * * /scripts/rsync1.sh" \
-e CRON_TASK_2="*/3 * * * * docker ps" \
yangliu/rsync
```
