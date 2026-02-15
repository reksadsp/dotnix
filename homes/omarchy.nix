{ config, pkgs, ... }:

{
  home.username = "reksa";
  home.homeDirectory = "/home/reksa";
<<<<<<< HEAD:home/linux.nix
  home.stateVersion = "25.11";

=======
  home.stateVersion = "24.05";
>>>>>>> 0148107 (clean systemd ngrok WIP):home/home.nix
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    unzip
    ngrok
    sshfs
    btop
    nnn
    vlc
    zsh
    fzf
    fd
    bat
    wget
    ripgrep
    parsec-bin
  ];
  programs.ssh.enable = true;
  programs.zsh.enable = true;
  programs.git = {
    enable = true;
    userName = "reksadsp";
    userEmail = "accounts@reksa.fr";
  };
 
 # Custom ngrok config
  xdg.configFile."ngrok/ngrok.yml".text = ''
    version: "2"
    tunnels:
      nextcloud:
        proto: http
        addr: https://localhost:8443
        schemes:
          - https
  '';

  # Custom SSH config entries go here
  extraConfig = ''
    Host gitlab.com
      IdentityFile ~/.ssh/id_ed25519_gitlab
      IdentitiesOnly yes
    Host github.com
      IdentityFile ~/.ssh/id_ed25519_github
      IdentitiesOnly yes
  '';
  };

  # Install env file (or use source = if managed elsewhere)
  xdg.configFile."ngrok/ngrok.env".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/ngrok/ngrok.env";
  # User systemd service
  systemd.user.services.ngrok = {
    Unit = {
      Description = "ngrok tunnel";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${pkgs.ngrok}/bin/ngrok start --all --config %h/.config/ngrok/ngrok.yml";
      Restart = "always";
      RestartSec = 5;
      # Load environment file
      EnvironmentFile = "%h/.config/ngrok/ngrok.env";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
