# PHP5 modules and configuration
php-stack:
  pkg.installed:
    - name: php5-fpm
  service.running:
    - name: php5-fpm
    - require:
      - pkg: php5-fpm
      - pkg: php5-deps
    - watch:
      - file: /etc/php5

php5-deps:
  pkg.installed:
    - pkgs:
      - php5-apcu
      - php5-gd
      - php5-mysqlnd
      - php5-mcrypt
      - php5-curl
      - php5-cli
      - php5-xdebug

# Configuration files for php5-fpm
php5-config:
  file.recurse:
    - name: /etc/php5
    - source: salt://_config/php
    - dir_mode: 755
    - file_mode: 644

{% if not salt['cmd.has_exec']('wp') %}
get-composer:
  cmd:
    - run
    - user: root
    - name: 'CURL=`which curl`; $CURL -sS https://getcomposer.org/installer | php'
    - unless: test -f /usr/bin/composer

install-composer:
  cmd.wait:
    - name: mv /root/composer.phar /usr/bin/composer
    - user: root
    - watch:
      - cmd: get-composer

wp_cli:
  git.latest:
    - name: git://github.com/wp-cli/wp-cli.git
    - rev: master
    - target: /usr/lib/wp-cli
    - runas: root
    - submodules: True
    - force: False
    - require:
      - pkg: php-stack
      - cmd: install-composer

/usr/lib/wp-cli:
  composer.installed:
    - no_dev: true

/usr/bin/wp:
  file.symlink:
    - target: /usr/lib/wp-cli/bin/wp
{% endif %}
