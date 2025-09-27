{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    git zsh fzf ripgrep fd bat wget curl
  ];

  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    userName = "Reksa";
    userEmail = "reksa@example.org";
  };

  home.stateVersion = "24.05";
}

