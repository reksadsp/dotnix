#!/usr/bin/env bash

# Setup
# TODO: OScheck
#
# whoami ?

OS=Linux
echo "whoami"
ME=(whoami)
SH=(which bash)
SYS=(cat /proc/sys/kernel/hostname)
DNS="8.8.8.8"
ADROUTE="198.168.1.0/24"

#EXE
CURL=true
DOCKER=False
TSNET=False  #TODO: ADROUTES
NGROK=False #TODO: Make ngrok config independant from Hardware Target.
NAS_DOMAIN="double-chest.ainu-basilisk.ts.net"
# For Linux and without a web server or reverse proxy (like Apache, Nginx and else) already in place:
NCLOUD=False #TODO: Config DNS properly.


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

# Required pkgs
# curl, git, ssh,
#
# Check_dependencies:
check_dependencies(){
    #Declare list of dependencies
    declare -Ag deps=([curl]='curl')
    # [git]='git' [ssh]='ssh' [lsof]='lsof'
    #Declare list of package managers and their usages
    declare -Ag packman_list=([pacman]='pacman -Sy' [apt]='echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/buster-backports.list; apt update -y; apt install -y' [yum]='yum install -y epel-release; yum repolist -y; yum install -y')
    
    #Find the package manager on the system and install the package
    install_deps(){
        for packman in ${!packman_list[@]}
        do
            which $packman &>/dev/null && eval $(echo ${packman_list[$packman]} "$*")
        done
    }
    #Find the missing packages from list of dependencies
    declare -ag missing_deps=()
    for pack in ${!deps[@]}
    do
        which $pack &>/dev/null || missing_deps+=(${deps[$pack]})
    done
    #Install missing dependencies
    test -z ${missing_deps[0]} || install_deps ${missing_deps[@]} || fail "Dependencies could not provide"
}

# CURL installs
# NIX, flakes, home-manager, environment
#
# Determinate Systems NIX
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
if [[ $HAS_SUDO ]]; then 
# Enable flakes
  echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
# Switch env
  (cd ../
  nix run home-manager/master -- switch --flake .#reksa@$SYS
  nix flake update
  nix run home-manager/master -- switch --flake .#reksa@$SYS
  )
  if [[ $DOCKER  ]]; then
  # Docker
  curl -fsSL https://get.docker.com | sudo sh
  fi
fi


# Sudo RUN
# Linux init
#
if [[ $HAS_SUDO ]]; then
#SystemD
  sudo systemctl --user daemon-reload

  if [[ $TSNET]]; then
  #TailScale VPN
    sudo systemctl start tailscaled
    sudo tailscale up --accept-dns=true --dns=$DNS --accept-routes --advertise-routes=$ADROUTE
  fi
  if [[ $TSNET && $NGROK ]]; then
  #Ngrok
    systemctl --user enable --now ngrok
    systemctl --user status ngrok
    journalctl --user -u ngrok -f

  fi
  if [[ -n "$TSNET" && -n "$NGROK" && -n "$NCLOUD" ]]; then
    # Start Nextcloud AIO
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
