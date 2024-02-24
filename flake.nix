{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";

    arouteserver = {
      url = "github:dd-ix/arouteserver.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, arouteserver }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs) {
            inherit system;
          };
        in
        {
          packages = rec {
            ddix-ansible-ixp = pkgs.callPackage ./derivation.nix {
              arouteserver = arouteserver.packages."${system}".arouteserver;
            };
            default = ddix-ansible-ixp;
          };
        }
      ) // {
      overlays.default = _: prev: {
        ddix-ansible-ixp = self.packages."${prev.system}".default;
      };

      nixosModules = rec {
        ddix-ansible-ixp = import ./module.nix;
        default = ddix-ansible-ixp;
      };
    };
}
