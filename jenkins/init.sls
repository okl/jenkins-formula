{% from "jenkins/map.jinja" import jenkins with context %}

## if the user isn't defined in the users formula, this will fail

jenkins:
  {% if grains['os_family'] in ['RedHat', 'Debian'] %}
    {% set repo_suffix = '' %}
    {% if jenkins.stable %}
      {% set repo_suffix = '-stable' %}
    {% endif %}
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    {% if grains['os_family'] == 'RedHat' %}
    - baseurl: http://pkg.jenkins-ci.org/redhat{{ repo_suffix }}
    - gpgkey: http://pkg.jenkins-ci.org/redhat{{ repo_suffix }}/jenkins-ci.org.key
    {% elif grains['os_family'] == 'Debian' %}
    - file: {{jenkins.deb_apt_source}}
    - name: deb http://pkg.jenkins-ci.org/debian{{ repo_suffix }} binary/
    - key_url: http://pkg.jenkins-ci.org/debian{{ repo_suffix }}/jenkins-ci.org.key
    {% endif %}
    - require_in:
      - pkg: jenkins
  {% endif %}
    - require:
      - user: users_{{ jenkins.user }}_user
      - group: users_{{ jenkins.user }}_user
  pkg.installed:
    - pkgs: {{ jenkins.pkgs|json }}
  service.running:
    - enable: True
    - watch:
      - pkg: jenkins
