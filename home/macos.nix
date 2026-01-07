{ pkgs, ... }:

let
    neovim-custom = import ./neovim.nix {
    inherit (pkgs) symlinkJoin neovim-unwrapped makeWrapper;
  };
in
{
  home.packages = [
	pkgs.fd
	pkgs.git
	pkgs.luajit
	pkgs.lua-language-server
	pkgs.stylua
	pkgs.fzf
	pkgs.fzf-zsh
	pkgs.ripgrep
	pkgs.luajitPackages.fzf-lua
	pkgs.vimPlugins.fzf-lua

	pkgs.neovim

	pkgs.nodejs
	pkgs.python3
    ];

  home.stateVersion = "24.05";
  programs.zsh.enable = true;
}
