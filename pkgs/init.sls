pkgs-essential:
  pkg.installed:
    - pkgs:
      - curl
      - htop
      - git-core
      - mosh
      - mc
      - silversearcher-ag

include:
  - pkgs.openvpn
  - pkgs.tx
