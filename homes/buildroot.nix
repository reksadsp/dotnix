{ config, pkgs, ... }:

{
  home.username = "root";
  home.homeDirectory = "/home/root";
  home.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    sshfs
    btop
    nnn
    git
  ];

  programs.ssh.enable = true;
  programs.zsh.enable = true;
  programs.git = {
    enable = true;
    userName = "reksadsp";
    userEmail = "accounts@reksa.fr";
  };

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
