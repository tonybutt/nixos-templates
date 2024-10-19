{
  description = "Pulumi project in golang";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      pre-commit-hooks,
    }:
    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs allSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      checks = forAllSystems (
        { system, pkgs }:
        {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              yamlfmt = rec {
                enable = true;
                settings.configPath = "yamlfmt.yaml";
                entry = "${pkgs.yamlfmt}/bin/yamlfmt -conf ${settings.configPath}";
              };
              yamllint = {
                enable = true;
                settings.configPath = "yamllint.yaml";
              };
              gofmt.enable = true;
              gotest.enable = true;
              golangci-lint = {
                files = ".go$";
                entry = "${pkgs.golangci-lint}/bin/golangci-lint run --new-from-rev HEAD --fix --timeout 5m";
              };
              nixfmt-rfc-style.enable = true;
            };
          };
        }
      );
      devShells = forAllSystems (
        { system, pkgs }:
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = with pkgs; [
              go
              gopls
              gotools
              pulumi-bin
              self.checks.${system}.pre-commit-check.enabledPackages
            ];
          };
        }
      );
    };
}
