{
  description = "Config Nix flake with Home Manager (Linux + macOS)";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Use master for Home Manager (latest) for nixpkgs >= 25
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }:

  let
    mkHome = { system, username, homeDirectory, modules, pkgsOverride ? null }: 
      home-manager.lib.homeManagerConfiguration {
        pkgs = if pkgsOverride == null then import nixpkgs-stable { inherit system; }
               else pkgsOverride;

        modules = modules ++ [
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
          }
        ];
      };
  in
  {
    homeConfigurations = {
      # Linux config
      "reksa@panasonic" = mkHome {
        system = "x86_64-linux";
        username = "reksa";
        homeDirectory = "/home/reksa";
        modules = [ ./home/linux.nix ];
      };

      # macOS config with unstable Neovim
      "reksa@macos" = mkHome {
        system = "aarch64-darwin";
        username = "reksa";
        homeDirectory = "/Users/reksa";
        modules = [ ./home/macos.nix ];
        pkgsOverride = import nixpkgs-unstable { system = "aarch64-darwin"; };
      };
    };
  };
} 

