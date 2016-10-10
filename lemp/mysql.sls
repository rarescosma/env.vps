{% if not salt['cmd.has_exec']('mysql') %}
mysql-debconf:
  debconf.set:
    - name: mysql-server
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': '{{ pillar['mysql.root.pass'] }}'}
        'mysql-server/root_password_again': {'type': 'password', 'value': '{{ pillar['mysql.root.pass'] }}'}
        'mysql-server/start_on_boot': {'type': 'boolean', 'value': 'true'}
    - require_in:
      - pkg: mysqld

mysql-install:
  pkg.installed:
    - pkgs:
      - mysql-server
      - mysql-client
      - python-mysqldb
    - watch_in:
      - service: mysql
{% endif %}

mysql-config-dir:
  file.directory:
    - name: /etc/mysql
    - dir_mode: 755
    - require_in: mysql-config

mysql-config:
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://_config/mysql/my.cnf
    - mode: 644
    - require_in: mysql

mysql:
  service.running:
    - enable: True
    - watch:
      - file: mysql-config
