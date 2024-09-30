# Nix Flake Templates 
For the common languages I write code in

## Currently supported languages
- golang

## How to use (default is golang)
Use #<languageName> at the end of the command to get different templates  
Current directory
```shell
nix flake init -t github:tonybutt/nixos-templates#go
```
or with a directory you want to create
```shell
nix flake new -t github:tonybutt/nixos-templates#go ./myApp
```