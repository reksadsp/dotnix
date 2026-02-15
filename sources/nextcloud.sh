# For Linux and without a web server or reverse proxy (like Apache, Nginx and else) already in place:
sudo docker run \
--sig-proxy=false \
--name nextcloud-aio-mastercontainer \
--restart always \
--publish 127.0.0.1:8080:8080 \
--publish 127.0.0.1:8443:8443 \
--volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
--volume /var/run/docker.sock:/var/run/docker.sock:ro \
nextcloud/all-in-one:latest

# With ngrok port tunneling
ngrok start nextcloud
sudo docker exec -it nextcloud-aio-nextcloud \
php occ config:system:set trusted_domains 1 --value="double-chest.ainu-basilisk.ts.net"

