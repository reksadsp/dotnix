{
  description = "Config Nix flake with Home Manager (Linux + macOS)";

  inputs = {
    # Use master for Home Manager (latest) for nixpkgs >= 25
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      # Linux configs
      "reksa@panasonic" = mkHome {
        system = "x86_64-linux";
        username = "reksa";
        homeDirectory = "/home/reksa";
        modules = [ ./home/omarchy.nix ];
      };
      # macOS config with unstable Neovim
      "reksa@macos" = mkHome {
        system = "aarch64-darwin";
        username = "reksa";
        homeDirectory = "/Users/reksa";
        modules = [ ./home/macos.nix ];
        pkgsOverride = import nixpkgs-unstable { system = "aarch64-darwin"; };
      };
      "root@stm32mp1-e1-96-2e" = mkHome {
        system "armv7l-linux";
        username = "root";
        homeDirectory = "/home/root";
        modules = [ ./home/buildroot.nix];
      };
    };
  };
}
