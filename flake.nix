{
  inputs = {
    # backports needed for arouteserver
    nixpkgs.url = "github:NuschtOS/nuschtpkgs/backports-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs) { inherit system; };
          derivation = pkgs.callPackage ./derivation.nix { };
        in
        {
          packages = {
            inherit (derivation) ddix-ixp-deploy ddix-ixp-commit;
          };
        }
      ) // {
      overlays.default = _: prev: {
        inherit (self.packages."${prev.system}") ddix-ixp-deploy ddix-ixp-commit;
      };
    };
}
