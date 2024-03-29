{ lib, pkgs, arouteserver, ... }:
let
  python3 = pkgs.python3.withPackages (pp: with pp; [ matrix-client mysqlclient ]);
  ansible-general = pkgs.fetchFromGitHub {
    owner = "ansible-collections";
    repo = "community.general";
    rev = "8.5.0";
    hash = "sha256-LAGu+LbGH8jvMmGO9NoTL5UKAxDd85vNDrCQQEVMQ0M=";
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
