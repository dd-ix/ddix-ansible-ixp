{ lib, pkgs, arouteserver, ... }:
let
  python3 = pkgs.python3.withPackages (pp: with pp; [ matrix-client mysqlclient ]);
  ansible-general = pkgs.fetchFromGitHub {
    owner = "ansible-collections";
    repo = "community.general";
    rev = "8.3.0";
    hash = "sha256-Cv9Whp7JEVtkZ33PlkC2+kqkFMvaZq0zAeXqS/48cgY=";
  };
  ddix-ansible-ixp = pkgs.stdenv.mkDerivation {
    name = "libfoo-1.2.3";
    src = lib.cleanSource ./.;
    installPhase = ''
      mkdir -p $out
      mv ./* $out
      mkdir -p $out/collections/ansible_collections/community
      ln -s ${ansible-general} $out/collections/ansible_collections/community/general
    '';
  };
in
pkgs.writeShellApplication {
  name = "ddix-ansible-ixp";

  runtimeInputs = with pkgs; [
    arouteserver
    bgpq4
    openssh
  ];

  text = ''
    export PYTHONPATH="${python3}/${python3.sitePackages}"
    cd ${ddix-ansible-ixp}/plays
    exec ${pkgs.util-linux}/bin/flock /tmp/ddix-ansible-ixp.lock -c "${pkgs.ansible}/bin/ansible-playbook ixp.yml ''$@" 
  '';
}
