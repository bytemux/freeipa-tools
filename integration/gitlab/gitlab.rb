gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load_file('/etc/gitlab/ldap-freeipa.yml')
