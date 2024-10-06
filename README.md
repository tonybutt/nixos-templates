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

## After init or new
```shell
git init
# Nix is git aware so you need to stage files for nix to be able to see them.
git add -A
```
If you are using direnv  
```shell
cd myApp
direnv allow .
```
otherwise
```shell
nix develop
# If not using bash use the below command to launch a development shell
# nix develop -c $SHELL
```