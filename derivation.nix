{ lib, pkgs, arouteserver, ... }:
let
  python3 = pkgs.python3.withPackages (pp: with pp; [ matrix-client mysqlclient ]);
  ansible-general = pkgs.fetchFromGitHub {
    owner = "ansible-collections";
    repo = "community.general";
    rev = "9.0.1";
    hash = "sha256-3lAzegva3j1wy21d9xdWfXBXUjCVOrjYPU1jSRSg/E4=";
  };
  ddix-ansible-ixp = pkgs.stdenv.mkDerivation {
    name = "ddix-ansible-ixp";
    src = lib.cleanSource ./.;
    installPhase = ''
      mkdir -p $out
      mv ./* $out
      mkdir -p $out/collections/ansible_collections/community
      ln -s ${ansible-general} $out/collections/ansible_collections/community/general
    '';
  };
in
{
  ddix-ixp-deploy = pkgs.writeShellApplication {
    name = "ddix-ixp-deploy";

    runtimeInputs = with pkgs; [
      arouteserver
      bgpq4
      openssh
    ];

    text = ''
      export PYTHONPATH="${python3}/${python3.sitePackages}"
      cd ${ddix-ansible-ixp}/plays
      exec ${pkgs.util-linux}/bin/flock /tmp/ddix-ansible-ixp.lock -c "${pkgs.ansible}/bin/ansible-playbook deploy.yml ''$*" 
    '';
  };
  ddix-ixp-commit = pkgs.writeShellApplication {
    name = "ddix-ixp-commit";

    runtimeInputs = with pkgs; [
      openssh
    ];

    text = ''
      export PYTHONPATH="${python3}/${python3.sitePackages}"
      cd ${ddix-ansible-ixp}/plays
      exec ${pkgs.util-linux}/bin/flock /tmp/ddix-ansible-ixp.lock -c "${pkgs.ansible}/bin/ansible-playbook commit.yml ''$*" 
    '';
  };
}
