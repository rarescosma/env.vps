{% if not salt['cmd.has_exec']('ag') %}
ag-build:
  cmd.run:
    - cwd: /tmp/ag
    - name: ./build.sh && make install
    - unless: which ag

ag-build-deps:
  pkg.installed:
    - pkgs:
      - automake
      - pkg-config
      - libpcre3-dev
      - zlib1g-dev
      - liblzma-dev
    - require_in: ag-build
    - unless: which ag

ag-clone-and-build:
  git.latest:
    - name: https://github.com/ggreer/the_silver_searcher.git
    - rev: master
    - target: /tmp/ag
    - require_in: ag-build
    - unless: which ag
{% endif %}
