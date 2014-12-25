pkgs-essential:
  pkg.installed:
    - pkgs:
      - curl
      - htop
      - git-core
      - mosh
      - mc

include:
  - pkgs.ag
  - pkgs.tx
