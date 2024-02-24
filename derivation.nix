{ lib, pkgs, arouteserver, ... }:
let
  self = lib.cleanSource ./.;
  python3 = pkgs.python3.withPackages (pp: with pp; [ mysqlclient ]);
in
pkgs.writeShellApplication {
  name = "ddix-ansible-ixp";

  runtimeInputs = with pkgs;[
    arouteserver
    bgpq4
  ];

  text = ''
    export PYTHONPATH="${python3}/${python3.sitePackages}"
    cd ${self}/plays
    exec ${pkgs.ansible}/bin/ansible-playbook ixp.yml "''$@" 
  '';
}
