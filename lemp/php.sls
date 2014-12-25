# PHP5 modules and configuration
php-stack:
  pkg.installed:
    - name: php5-fpm
  service.running:
    - name: php5-fpm
    - require:
      - pkg: php5-fpm
      - pkg: php-deps
    - watch:
      - file: /etc/php5

php-deps:
  pkg.installed:
    - pkgs:
      - php5-apcu
      - php5-gd
      - php5-mysqlnd
      - php5-mcrypt
      - php5-curl
      - php5-cli
      - php5-xdebug

php-config:
  file.recurse:
    - name: /etc/php5
    - source: salt://_config/php
    - dir_mode: 755
    - file_mode: 644
    - template: jinja

php-umask:
  file.append:
    - name: /etc/init/php-fpm.conf
    - text:
      - "umask 0002"

{% if pillar['php.install.wp'] and not salt['cmd.has_exec']('wp') %}
php-download-composer:
  cmd.run:
    - user: root
    - name: 'CURL=`which curl`; $CURL -sS https://getcomposer.org/installer | php'
    - unless: test -f /usr/bin/composer

php-install-composer:
  cmd.wait:
    - name: mv /root/composer.phar /usr/bin/composer
    - user: root
    - watch:
      - cmd: get-composer

php-wp-cli:
  git.latest:
    - name: git://github.com/wp-cli/wp-cli.git
    - rev: master
    - target: /usr/lib/wp-cli
    - runas: root
    - submodules: True
    - force: False
    - require:
      - pkg: php-stack
      - cmd: php-install-composer

php-wp-cli-composer-deps:
  composer.installed:
    - no_dev: true

php-wp-cli-symlink:
  file.symlink:
    - target: /usr/lib/wp-cli/bin/wp
{% endif %}
