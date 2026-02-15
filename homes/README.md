### homes Directory – dotnix

This directory contains Home-Manager / user environment configurations for multiple UNIX-based systems. Each system has its own .nix configuration file. These are used to declaratively manage your dotfiles, tools, and environment settings using Nix.

# Supported Systems
# File	Target System	Description
## macos.nix	
macOS	Configurations for Apple macOS laptops or desktops. Includes Homebrew packages, macOS-specific tools, and UI tweaks.
## yocto.nix	
STM32MP157F-DK1 (aka double-chest)	Embedded Linux configuration for STM32MP1-based development boards. Uses minimal packages for Yocto / cross-compilation environments.
## omarchy.nix	
Panasonic notebook	Desktop/laptop configuration for Linux-based Panasonic notebooks. May include GUI tweaks, hardware-specific packages, and productivity tools.
# Shared / Common Configs
# File	Purpose
## neovim.nix	
Common Neovim configuration applied across all systems. Installs plugins, LSPs, and editor settings.
## default.nix	Base/default Home-Manager configuration. Can be imported by system-specific configs to avoid repetition.
# TODO
# File	Notes
windows.nix	Planned Windows (WSL2 / native) configuration for future support.
**Usage:**

To apply a specific system configuration:

nix-shell -p home-manager --run "home-manager switch -f ./homes/<system>.nix"


**Example:**

home-manager switch -f ./homes/macos.nix


**To include common configurations:**

{ config, pkgs, ... }:

let
  defaults = import ./default.nix { inherit config pkgs; };
in {
  imports = [ defaults ./neovim.nix ];
}

# Notes

Each configuration assumes the corresponding system architecture (e.g., armv7l-linux for STM32MP1, x86_64-darwin for macOS).

Cross-system compatibility is handled via imports from default.nix and neovim.nix.

This setup is fully declarative: running home-manager switch will bring your environment in sync with the .nix files.
