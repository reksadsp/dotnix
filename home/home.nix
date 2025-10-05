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
  };

  programs.ssh = {
  enable = true;
 
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
}
