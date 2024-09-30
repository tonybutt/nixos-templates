{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = {self, nixpkgs, gomod2nix, gitignore}: 
    let
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      version = builtins.substring 0 8 lastModifiedDate;

      allSystems = [ 
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS 
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });
    in 
    {
      packages = forAllSystems ({ system, pkgs, ... }:
        let
          buildGoApplication = gomod2nix.legacyPackages.${system}.buildGoApplication;
        in
        rec {
          default = hello;
          
          docker = pkgs.dockerTools.buildLayeredImage {
            name = "registry.gamewarden.io/hello";
            tag = "${version}";
            contents = [ pkgs.cacert ];
            config = {
               Cmd = "${hello}/bin/hello";
            };
            created = "now";
          };

          hello = buildGoApplication {
            name = "hello";
            inherit version;
            src = gitignore.lib.gitignoreSource ./.;
            pwd = ./.;
            CGO_ENABLED = 0;
            ldflags = [
              "-s"
              "-w"
              "-extldflags -static"
            ];
          };
        });
      
      devShell = forAllSystems ({ system, pkgs }: 
        pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            gomod2nix.legacyPackages.${system}.gomod2nix
          ];
        });
      
      # Example usage:
      #
      # nixpkgs.overlays = [
      #   inputs.hello.overlays.default
      # ];
      overlays.default = final: prev: {
        hello = self.packages.${final.stdenv.system}.wrap;
      };
    };
}