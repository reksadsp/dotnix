# Home Manager config

## Usefull commands

### 1. Declare a dotfile

```nix
programs.zsh.initExtra = ''
  alias ll="ls -la"
  export EDITOR=nvim
'';
```

### 2. Import a dotfile

```nix
home.file.".tmux.conf".text = ''
  set -g mouse on
  bind r source-file ~/.tmux.conf \; display "Reloaded!"
'';
home.file.".config/nvim/init.lua".source = ./dotfiles/init.lua;
```

### 3. Apply changes
```bash
home-manager switch
```

### 4. Go back to previous version
```bash
home-manager rollback
```
