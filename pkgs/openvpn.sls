openvpn:
  pkg:
    - installed
  service.running:
    - reload: True
    - require:
      - pkg: openvpn
      - file: openvpn-config
    - watch:
      - file: openvpn-config

openvpn-config:
  file.recurse:
    - name: /etc/openvpn
    - source: salt://_config/openvpn
    - file_mode: 644
    - dir_mode: 755
