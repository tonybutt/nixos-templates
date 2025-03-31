{
  description = "A collection of flake templates that I use commonly";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      systems,
    }:
    let
      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = forEachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          buildInputs = [
            treefmtEval.${pkgs.system}.config.build.wrapper
          ];
        };
      });
      templates = {
        go = {
          path = ./go;
          description = "A basic go application with docker container building";
        };
        rust = {
          path = ./rust;
          description = "A starter pulumi golang flake with baked in pre-commit";
        };
      };

      defaultTemplate = self.templates.go;
    };
}
