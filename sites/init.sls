include:
  - lemp.*

sites-dir:
  file.directory:
    - name: /srv/sites
    - dir_mode: 775
    - user: karelian
    - group: www-data

rarescosma-com:
  file.directory:
    - name: /srv/sites/rarescosma.com
    - dir_mode: 775
    - file_mode: 664
    - user: karelian
    - group: www-data
    - recurse:
      - user
      - group
      - mode

rarescosma-com-config:
  file.managed:
    - name: /etc/nginx/sites/rarescosma.com.conf
    - source: salt://_config/sites/rarescosma.com/nginx.conf

rarescosma-com-sql-user:
  mysql_user.present:
    - name: rares
    - password_hash: '{{ pillar['mysql.rares.pass'] }}'
    - host: localhost
  mysql_grants.present:
    - revoke_first: True
    - grant: select
    - database: rares.*
    - user: rares
    - host: localhost

extend:
  nginx:
    service:
      - watch:
          - file: rarescosma-com-config
