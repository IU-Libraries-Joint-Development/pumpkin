LDAPGroupsLookup.config = {
  enabled: true,
  config: { host: ENV["PMP_LDAP_HOST"],
            port: 636,
            encryption: {
              method: :simple_tls,
              tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS,
            },
            auth: {
              method: :simple,
              username: "cn=#{ENV["PMP_LDAP_USER"]}",
              password: ENV["PMP_LDAP_PASS"],
            }
  },
  tree: ENV["PMP_LDAP_TREE"],
  account_ou: ENV["PMP_LDAP_ACCOUNT_OU"],
  group_ou: ENV["PMP_LDAP_GROUP_OU"],
  member_allowlist: YAML.safe_load(ENV["PMP_LDAP_MEMBER_WHITELIST"])
}
