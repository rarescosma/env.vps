include:
  - lemp.*

sites-dir:
  file.directory:
    - name: /srv/sites
    - dir_mode: '2775'
    - file_mode: 664
    - user: {{ pillar.get('unix.user') }}
    - group: www-pub
    - recurse:
      - user
      - group
      - mode

{% for domain, props in pillar.get('sites', {}).items() %}
sites-{{domain}}-root:
  file.directory:
    - name: /srv/sites/{{domain}}

sites-{{domain}}-htdocs:
  file.directory:
    - name: /srv/sites/{{domain}}/htdocs

sites-{{domain}}-error-page:
  file.symlink:
    - name: /srv/sites/{{domain}}/htdocs/golden.html
    - target: /etc/nginx/golden.html
    - user: {{ pillar.get('unix.user') }}
    - group: www-pub

sites-{{domain}}-config:
  file.managed:
    - name: /etc/nginx/sites/{{domain}}.conf
    - source: salt://_config/sites/nginx.conf.jj
    - template: jinja
    - watch_in:
      - service: nginx
    - defaults:
      domain: {{domain}}
      use_www: {{ props.get('use_www', False) }}
      wp: {{ props.get('wp', False) }}
      ssl: {{ props.get('ssl', False) }}
      new_relic: {{ props.get('new_relic', False) }}
{% if props.get('extra', False) %}
      extra: /etc/nginx/sites/{{domain}}/extra.conf

sites-{{domain}}-extra-config:
  file.managed:
    - name: /etc/nginx/sites/{{domain}}/extra.conf
    - source: salt://_config/sites/{{domain}}.conf
    - makedirs: True
    - watch_in:
      - service: nginx
{% endif %}

{% if props.get('ssl', False) %}
sites-{{domain}}-cert:
  file.managed:
    - name: /etc/nginx/ssl/{{domain}}/combined.pem
    - source: salt://_config/sites/{{domain}}.pem
    - makedirs: True

sites-{{domain}}-key:
  file.managed:
    - name: /etc/nginx/ssl/{{domain}}/combined.key
    - source: salt://_config/sites/{{domain}}.key
    - makedirs: True
{% endif %}

{% if props.get('mysql_user', False) %}
sites-{{domain}}-sql-user:
  mysql_user.present:
    - name: {{ props['mysql_user'] }}
    - password_hash: "{{ props['mysql_pass'] }}"
    - host: localhost
  mysql_grants.present:
    - revoke_first: True
    - grant: select
    - database: {{ props['mysql_user'] }}.*
    - user: {{ props['mysql_user'] }}
    - host: localhost
{% endif %}
{% endfor %}
