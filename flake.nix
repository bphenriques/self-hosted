{
  description = "bphenriques's home-server";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    in {
      devShells = forAllSystems (system: {
        default = import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; };
      });
    };
}
