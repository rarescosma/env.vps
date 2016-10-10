# PHP5 modules and configuration
php-stack:
  pkg.installed:
    - name: php-fpm
  service.running:
    - name: php7.0-fpm
    - require:
      - pkg: php-fpm
    - watch:
      - file: /etc/php/7.0

php-deps:
  pkg.installed:
    - pkgs:
      - php-mysql
      - php-xml
      - php-mcrypt
      - php-curl
      - php-cli
    - require_in:
      service: php-stack

php-config:
  file.recurse:
    - name: /etc/php/7.0
    - source: salt://_config/php
    - dir_mode: 755
    - file_mode: 644
    - template: jinja

php-umask:
  file.append:
    - name: /etc/init/php7.0-fpm.conf
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
      - cmd: php-download-composer

php-wp-cli:
  git.latest:
    - name: git://github.com/wp-cli/wp-cli.git
    - rev: master
    - target: /usr/lib/wp-cli
    - submodules: True
    - force: False
    - require:
      - cmd: php-install-composer

php-wp-cli-composer-deps:
  composer.installed:
    - name: /usr/lib/wp-cli
    - no_dev: true

php-wp-cli-symlink:
  file.symlink:
    - name: /usr/local/bin/wp
    - target: /usr/lib/wp-cli/bin/wp
{% endif %}
