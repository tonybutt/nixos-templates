# Dependencies
- [Nix](https://nixos.org/nix/)
- [Direnv](https://direnv.net/)

Requires experimental features of nix to be enabled.

```bash
mkdir -p ~/.config/nix && grep -q "^experimental-features = nix-command flakes$" ~/.config/nix/nix.conf || echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

# Init Ephemeral Dev Shell
_With direnv_
```bash
direnv allow
```
_Without direnv_
```bash
nix develop
```

# Format
```bash
nix fmt
```
