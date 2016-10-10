mysql-debconf:
  debconf.set:
    - name: mysql-server
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': '{{ pillar['mysql.root.pass'] }}'}
        'mysql-server/root_password_again': {'type': 'password', 'value': '{{ pillar['mysql.root.pass'] }}'}
        'mysql-server/start_on_boot': {'type': 'boolean', 'value': 'true'}
    - require_in: mysqld

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
    - require_in: mysqld

mysqld:
  pkg.installed:
    - pkgs:
      - mysql-server-5.6
      - mysql-client-5.6
      - python-mysqldb
    - require:
      - debconf: mysql-debconf
  service.running:
    - name: mysql
    - enable: True
    - watch:
      - pkg: mysqld
      - file: mysql-config
