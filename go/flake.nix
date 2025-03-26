{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
      pre-commit-hooks,
      gitignore,
    }:
    let
      # lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      # version = builtins.substring 0 8 lastModifiedDate;

      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = forEachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix);
    in
    {
      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = forEachSystem (pkgs: {
        pre-commit-check = pkgs.callPackage ./nix/pre-commit.nix {
          inherit pre-commit-hooks treefmtEval;
        };
      });

      devShell = forEachSystem (pkgs:
        pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            (self.checks.${pkgs.system}.pre-commit-check.enabledPackages)
            treefmtEval.${pkgs.system}.config.build.wrapper
          ];
        }
      );

      # Example usage:
      #
      # nixpkgs.overlays = [
      #   inputs.hello.overlays.default
      # ];
      overlays.default = final: prev: { hello = self.packages.${final.stdenv.system}.wrap; };
    };
}
