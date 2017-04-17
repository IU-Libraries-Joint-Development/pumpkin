# If PMP_OK_URL set, then OkComputer will mount a route at that location, otherwise it is effectively disabled
OkComputer.mount_at = ENV["PMP_OK_URL"] || false

# For built-in checks, see https://github.com/sportngin/okcomputer/tree/master/lib/ok_computer/built_in_checks

# Following checks execute after full initialization so that backend configuration values are available
Rails.application.configure do
  config.after_initialize do
    redis_url = Redis.current.client.options[:host]
    redis_port = Redis.current.client.options[:port]
    OkComputer::Registry.register "redis", OkComputer::RedisCheck.new(host: redis_url, port: redis_port)

    iiif_url = Plum.config[:iiif_url]
    OkComputer::Registry.register "iiif", OkComputer::HttpCheck.new(iiif_url)

    solr_url = ActiveFedora.solr_config[:url]
    OkComputer::Registry.register "solr", OkComputer::SolrCheck.new(solr_url)

    fcrepo_url = ActiveFedora.fedora_config.credentials[:url]
    fedora_user = ActiveFedora.fedora_config.credentials[:user]
    fedora_password = ActiveFedora.fedora_config.credentials[:password]
    auth_options = [fedora_user, fedora_password]
    OkComputer::Registry.register "fcrepo", IuDevOps::FcrepoCheck.new(fcrepo_url, 10, auth_options)
  end
end
