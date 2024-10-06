# Nix Flake Templates 
For the common languages and stacks I write code in

## Currently supported languages
- go
- go-pulumi

## How to use (default is golang)
Use #<TemplateName> at the end of the `nix flake init` command to get different templates  
Current directory
```shell
nix flake init -t github:tonybutt/nixos-templates#go
```
or with a directory you want to create
```shell
nix flake new -t github:tonybutt/nixos-templates#go ./myApp
```