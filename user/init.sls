{% set user  = pillar.get('unix.user') %}
{% set shell = pillar.get('unix.user.shell', '/bin/bash') %}

user-ssh-service:
  pkg.installed:
    - name: openssh-server
  service.running:
    - name: ssh
    - require:
      - pkg: openssh-server
{% if pillar['install.ssh'] %}
      - ssh_auth: 'user-ssh-auth'

user-ssh-auth:
  ssh_auth.present:
    - user: {{ user }}
    - source: salt://_config/user/authorized_keys
    - require:
      - user: user-{{ user }}
{% endif %}

user-www-group:
  group.present:
    - name: www-pub

user-www-data:
  user.present:
    - name: www-data
    - optional_groups:
      - www-pub
    - require:
      - group: user-www-group

user-{{ user }}:
  group.present:
    - name: {{ user }}
  user.present:
    - name: {{ user }}
    - fullname: {{ user }}
    - home: /home/{{ user }}
    - shell: {{ shell }}
    - optional_groups:
      - www-pub
    - require:
      - group: {{ user }}
      - group: user-www-group

{% if '/bin/bash' == shell %}
user-enhance-bash-profile:
  file.append:
    - name: /home/{{ user }}/.bashrc
    - text:
      - "umask 002"
      - "shopt -s autocd"
      - "alias _='sudo'"
      - "alias l='ls -lah'"
{% endif %}
