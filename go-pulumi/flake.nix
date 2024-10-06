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
              check-yaml.enable = true;
              yamlfmt.enable = true;
              yamllint = {
                enable = true;
                entry = "yamllint . -c .yamllint";
                pass_filenames = true;
              };
              gofmt.enable = true;
              gotest.enable = true;
              govet.enable = true;
              golangci-lint.enable = true;
              nixfmt-rfc-style.enable = true;
            };
          };
        }
      );
      devShell = forAllSystems (
        { system, pkgs }:
        pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            pulumi-bin
            pulumiPackages.pulumi-language-go
            (self.checks.${system}.pre-commit-check.enabledPackages)
          ];
        }
      );
    };
}
