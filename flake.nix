{
  inputs = {
    # backports needed for arouteserver
    nixpkgs.url = "github:NuschtOS/nuschtpkgs/backports-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs) { inherit system; };
        in
        {
          packages = {
            inherit (pkgs.callPackage ./package.nix { }) ddix-ixp-deploy ddix-ixp-commit;
          };
        }
      ) // {
      overlays.default = _: prev: self.packages."${prev.system}";
    };
}
