nginx:
  pkg:
    - installed
  service.running:
    - reload: True
    - require:
      - pkg: nginx
      - file: /etc/nginx
    - watch:
      - file: nginx-config

nginx-config:
  file.recurse:
    - name: /etc/nginx
    - source: salt://_config/nginx
    - file_mode: 644
    - dir_mode: 755
