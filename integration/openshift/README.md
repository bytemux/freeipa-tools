# ldap auth
[source](https://docs.openshift.com/container-platform/3.11/install_config/configuring_authentication.html#ldap-url)

```bash
# get users
oc get users
oc get identity
```
# okd auth setup
```bash
# test
list="host1 host2 host3"

## APPLY CHANGES
for i in $list; do scp ldap-ca.crt $i:/etc/origin/master/ldap-ca.crt; done
for i in $list; do scp ldap-auth.yaml $i:/etc/origin/master/ldap-auth.yaml; done
for i in $list; do ssh $i cp -v /etc/origin/master/master-config.yaml{,.bak}; done
for i in $list; do ssh $i "sed -i '/kind: HTPasswdPasswordIdentityProvider/ r /etc/origin/master/ldap-auth.yaml' /etc/origin/master/master-config.yaml"; done
for i in $list; do ssh $i "hostname; sudo master-restart api; sudo master-restart controllers"; sleep 30; done

# manual changes
for i in $list; do ssh -t $i "sudo nano /etc/origin/master/master-config.yaml"; done

```

[authorization roles](https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/authorization.html#roles)
[rbac](https://docs.openshift.com/container-platform/3.11/admin_guide/manage_rbac.html)

# okd sync groups
[sync-ldap-groups](https://docs.okd.io/latest/install_config/syncing_groups_with_ldap.html#sync-ldap-rfc-2307)

```bash
# sync test
oc adm groups sync --sync-config=ldap-group-manual.yaml
# sync
oc adm groups sync --sync-config=ldap-group-manual.yaml --confirm
# sync only already existing OC groups
oc adm groups sync --type=openshift --sync-config=config.yaml --confirm
```

# sync groups cronjob
[source](https://github.com/redhat-cop/openshift-management/blob/master/jobs/cronjob-ldap-group-sync-secure.yml)

```bash
cluster_name="prod"

# prepare ns
new_ns="support-cronjobs"
src_ns="ns1"
oc new-project $new_ns;
oc get secret imagepullsecret -n $src_ns -oyaml | sed -e "s/namespace: ${src_ns}/namespace: $new_ns/" | oc apply -n $new_ns -f -
oc secrets link --for=pull ldap-group-syncer imagepullsecret -n support-cronjobs

oc process -f ldap-group-cronjob.yaml \
  -p NAMESPACE="support-cronjobs" \
  -p IMAGE="docker.domainname.com/jeeves-deployer" \
  -p IMAGE_TAG="1.0-release" \
  -p SCHEDULE="*/10 * * * *" \
  -p LDAP_URL="ldaps://ipa-01.int.domainname.com:636" \
  -p LDAP_BIND_DN="uid=binduser,cn=users,cn=accounts,dc=int,dc=domainname,dc=com" \
  -p LDAP_CA_CERT="$(cat ../ldap-ca.crt)" \
  -p LDAP_BIND_PASSWORD="INSERT_PASSWORD" \
  -p LDAP_USER_UID_ATTRIBUTE="dn" \
  -p LDAP_GROUP_UID_ATTRIBUTE="dn" \
  -p LDAP_GROUPS_SEARCH_BASE="cn=groups,cn=accounts,dc=int,dc=domainname,dc=com" \
  -p LDAP_GROUPS_FILTER="(&(objectClass=ipausergroup)(memberOf=cn=okd-${cluster_name}-all,cn=groups,cn=accounts,dc=int,dc=domainname,dc=com))" \
  -p LDAP_USERS_SEARCH_BASE="cn=users,cn=accounts,dc=int,dc=domainname,dc=com" \
| oc create -f-

# trigger cron job
oc create job test-job --from=cronjob.batch/cronjob-ldap-group-sync
```

# okd roles setup
```bash
# disable self-provision https://docs.openshift.com/container-platform/3.11/admin_guide/managing_projects.html#disabling-self-provisioning
oc describe clusterrolebinding.rbac self-provisioners
oc patch clusterrolebinding.rbac self-provisioners -p '{"subjects": null}'
oc patch clusterrolebinding.rbac self-provisioners -p '{ "metadata": { "annotations": { "rbac.authorization.kubernetes.io/autoupdate": "false" } } }'

## cluster-wide roles
cluster_name="cluster1"
oc adm policy add-cluster-role-to-group cluster-admin okd-${cluster_name}-clusteradmin

## namespace-wide roles
ns_list="ns1 ns2 ns3"

for i in $ns_list; do oc adm policy add-role-to-group edit okd-${cluster_name}-edit -n $i; done
for i in $ns_list; do oc adm policy add-role-to-group view okd-${cluster_name}-view -n $i; done

```

# okd roles debug
```bash
# get role members
## local
oc describe rolebinding.rbac -n arch-1
## cluster
oc get clusterrolebindings
```


