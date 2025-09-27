{ config, pkgs, ... }:

{
  home.username = "reksa";
  home.homeDirectory = "/home/reksa";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    unzip btop nnn vlc sshfs git zsh fzf ripgrep fd bat wget curl
  ];

  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    userName = "reksadsp";
    userEmail = "accounts@reksa.fr";
  };

  home.stateVersion = "24.05";
}

