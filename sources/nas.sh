#!/usr/bin/env bash

# Setup
#
# whoami ?
OS=Linux
ME=(whoami)
SH=(which bash)
SYS=yocto
DNS="8.8.8.8"
ADROUTE="198.168.1.0/24"
NAS_DOMAIN="double-chest.ainu-basilisk.ts.net"

#
CURL=1
DOCKER=1
TSNET=0 #TODO: ADROUTES
NGROK=0 #TODO: Make ngrok config independant from Hardware Target.
NCLOUD=0 #TODO: Config DNS properly.

# Security checks
# root checks, pkg checks
#
# root ?
is_root () {
    return $(id -u)
}
#Sudo permission ?
has_sudo() {
    local prompt
    prompt=$(sudo -nv 2>&1)
    if [ $? -eq 0 ]; then
    echo "has_sudo__pass_set"
    elif echo $prompt | grep -q '^sudo:'; then
    echo "has_sudo__needs_pass"
    else
    echo "no_sudo"
    fi
# root access:
elevate_cmd () {
    local cmd=$@
    HAS_SUDO=$(has_sudo)
    case "$HAS_SUDO" in
    has_sudo__pass_set)
        sudo $cmd
        ;;
    has_sudo__needs_pass)
        echo "Please supply sudo password for the following command: sudo $cmd"
        sudo $cmd
        ;;
    *)
        echo "Please supply root password for the following command: su -c \"$cmd\""
        su -c "$cmd"
        ;;
    esac
}
if is_root; then
echo "Error: need to call this script as a normal user, not as root!"
exit 1
fi
elevate_cmd which adduser

# Required pkgs for docker
#
#
sudo apt-get update  # or opkg/your package manager
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  socat \
  iptables \
  libseccomp2 \
  libapparmor1

# Sudo RUN, CURL installs
# NIX, flakes, home-manager, environment
# Linux init
#
if [[ $HAS_SUDO ]]; then
  #SystemD
  sudo systemctl --user daemon-reload
  # Determinate Systems NIX
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # Enable flakes
  echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
  # Switch env
    (cd ../ &&\
    nix run home-manager/master -- switch --flake .#reksa@$SYS &&\
    nix flake update &&\
    nix run home-manager/master -- switch --flake .#reksa@$SYS)
  #TailScale VPN
  if [[ $TSNET ]]; then
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo systemctl start tailscaled
    sudo tailscale up --accept-dns=true --dns=$DNS --accept-routes --advertise-routes=$ADROUTE
  fi
  #Ngrok
  if [[ $TSNET && $NGROK ]]; then
    systemctl --user enable --now ngrok
    systemctl --user status ngrok
    journalctl --user -u ngrok -f
  fi
  #Nextcloud AIO
  if [[ -n "$TSNET" && -n "$NGROK" && -n "$NCLOUD" ]]; then
    curl -fsSL https://download.docker.com/linux/static/stable/aarch64/docker-24.0.5.tgz -o docker.tgz
    tar xzvf docker.tgz
    sudo cp docker/* /usr/local/bin/
    sudo dockerd &
    # For Linux and without a web server or reverse proxy (like Apache, Nginx and else) already in place:
    sudo docker run \
    --sig-proxy=false \
    --name nextcloud-aio-mastercontainer \
    --restart always \
    --publish 127.0.0.1:8080:8080 \
    --publish 127.0.0.1:8443:8443 \
    --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    nextcloud/all-in-one:2024.12.0   # use fixed version
    # Start ngrok tunnel
    ngrok start nextcloud
    # Add trusted domain safely
    sudo docker exec -it nextcloud-aio-nextcloud \
    php occ config:system:set trusted_domains 1 --value="$NAS_DOMAIN"
  fi
fi

