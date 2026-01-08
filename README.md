# dotnix – Nix + Home Manager config (Arch/Omarchy)

Personal Nix & Neovim configuration for **reksadsp**, based on **flakes** and **Home Manager**.

## 🚀 Setup after installing Determinate Nix on Macos:
### 1. Switch the flake to nix-darwin
```bash
nix run nix-darwin -- switch --flake github:lnl7/nix-darwin
```
### 2. Configure Home Manager
```bash
git clone git@github.com:reksadsp/dotnix.git ~/dotnix
cd ~/dotnix && git pull
nix run home-manager/release-24.05-- switch --flake .#reksa@macos
```

### 2. Configure Lazyvim (optional)
```bash
git status
git rm -r --cached . && git ls-files
git add . && git commit -am "wip"
sudo chown -R reksa:staff ~/.cache/nvim

git clone https://github.com/LazyVim/starter ~/.config/nvim
ls -a .config/nvim
```
then in Neovim:
```nvim
:Lazy update
:luafile ~/.config/nvim/lua/config/options.lua
```
---
## 🚀 Setup after installing Arch + Nix:
### 1. Enable flakes
```bash
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
```
## 2. Configure Home Manager
```bash
git clone git@github.com:reksadsp/dotnix.git ~/dotnix
cd ~/dotnix
nix run home-manager/master -- switch --flake .#reksa@panasonic
```
### 3. Update Dependencies
```bash
nix flake update
nix run home-manager/master -- switch --flake .#reksa@panasonic
```
