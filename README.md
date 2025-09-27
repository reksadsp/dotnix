# dotnix – Nix + Home Manager config (Arch/Omarchy)

Personal Nix configuration for **reksa@panasonic**, based on **flakes** and **Home Manager**.

---

## 🚀 Setup after installing Arch + Nix

### 1. Enable flakes
```bash
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
```
### 2. Configure Home Manager
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
