{ config, pkgs, ... }:

{
  home.username = "reksa";
  home.homeDirectory = "/home/reksa";
  home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    unzip btop nnn vlc sshfs git zsh fzf ripgrep fd bat wget curl
    parsec-bin 
  ];

  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    userName = "reksadsp";
    userEmail = "accounts@reksa.fr";

  extraConfig = ''
    [credential "https://github.com"]
      helper = store
    [credential "https://gitlab.com"]
      helper = store
  '';
  };


