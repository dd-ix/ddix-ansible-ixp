{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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
          pkgs = (import nixpkgs) { inherit system; };
          derivation = pkgs.callPackage ./derivation.nix {
            arouteserver = arouteserver.packages."${system}".arouteserver;
          };
        in
        {
          packages = {
            inherit (derivation) ddix-ixp-deploy ddix-ixp-commit;
          };
        }
      ) // {
      overlays.default = _: prev: {
        ddix-ixp-deploy = self.packages."${prev.system}".ddix-ixp-deploy;
        ddix-ixp-commit = self.packages."${prev.system}".ddix-ixp-commit;
      };
    };
}
