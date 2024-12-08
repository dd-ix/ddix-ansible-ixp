{ lib, python3, fetchFromGitHub, stdenv, writeShellApplication, arouteserver, openssh, util-linux, ansible }:
let
  python = python3.withPackages (pp: with pp; [ matrix-client mysqlclient ]);
  ansible-general = fetchFromGitHub {
    owner = "ansible-collections";
    repo = "community.general";
    rev = "10.1.0";
    hash = "sha256-6AE5msRvzwl2MupQmi+tcet+67sVe5nh2XUEsBbSu8U=";
  };
  ddix-ansible-ixp = stdenv.mkDerivation {
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
  ddix-ixp-deploy = writeShellApplication {
    name = "ddix-ixp-deploy";

    runtimeInputs = [
      arouteserver
      openssh
    ];

    text = ''
      export PYTHONPATH="${python}/${python.sitePackages}"
      cd ${ddix-ansible-ixp}/plays
      exec ${util-linux}/bin/flock /tmp/ddix-ansible-ixp.lock -c "${ansible}/bin/ansible-playbook deploy.yml ''$*" 
    '';
  };
  ddix-ixp-commit = writeShellApplication {
    name = "ddix-ixp-commit";

    runtimeInputs = [
      openssh
    ];

    text = ''
      export PYTHONPATH="${python}/${python.sitePackages}"
      cd ${ddix-ansible-ixp}/plays
      exec ${util-linux}/bin/flock /tmp/ddix-ansible-ixp.lock -c "${ansible}/bin/ansible-playbook commit.yml ''$*" 
    '';
  };
}
