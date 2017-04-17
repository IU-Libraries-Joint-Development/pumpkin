# If PMP_OK_URL set, then OkComputer will mount a route at that location, otherwise it is effectively disabled
OkComputer.mount_at = ENV["PMP_OK_URL"] || false

# For built-in checks, see https://github.com/sportngin/okcomputer/tree/master/lib/ok_computer/built_in_checks
redis_url = ENV['PLUM_REDIS_URL'] || 'localhost'
redis_port = ENV['PLUM_REDIS_PORT'] || '6379'
OkComputer::Registry.register "redis", OkComputer::RedisCheck.new(host: redis_url, port: redis_port)

iiif_url = ENV["PMP_IIIF_URL"] || "http://localhost/imagesrv"
OkComputer::Registry.register "iiif", OkComputer::HttpCheck.new(iiif_url)

solr_url = ENV["PMP_SOLR_URL"] || 'http://localhost:8983/solr/hydra-development'
OkComputer::Registry.register "solr", OkComputer::SolrCheck.new(solr_url)

# FcrepoCheck is example of a custom check that includes OkComputer and extends the Check class
fcrepo_url = ENV["PMP_FEDORA_URL"] || 'http://localhost:8984/rest'
fedora_pass = ENV["PMP_FEDORA_PASS"] || 'fedoraAdmin'
fedora_user = ENV["PMP_FEDORA_USER"] || 'fedoraAdmin'
auth_options = [fedora_user, fedora_pass]
OkComputer::Registry.register "fcrepo", IuDevOps::FcrepoCheck.new(fcrepo_url, 10, auth_options)
