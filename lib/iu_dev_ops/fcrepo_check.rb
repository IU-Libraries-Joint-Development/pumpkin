require "open-uri"

module IuDevOps
  # Performs a Fedora health check by reading the REST API over HTTP.
  # A successful response is considered passing.
  # To implement your own pass/fail criteria, inherit from this
  # class, override #check, and call #perform_request to get the
  # response body.
  include OkComputer
  class FcrepoCheck < Check
    ConnectionFailed = Class.new(StandardError)

    attr_accessor :url, :request_timeout, :basic_auth_username, :basic_auth_password, :auth_options

    # Public: Initialize a new HTTP check.
    #
    # url - The URL to check, may also contain user:pass@ for basic auth but auth_options will override
    # request_timeout - How long to wait to connect before timing out. Defaults to 5 seconds.
    # auth_options - an ordered array containing username then password for :http_basic_authentication
    def initialize(url, request_timeout = 5, auth_options = [])
      parse_url(url)
      self.request_timeout = request_timeout.to_i
      self.auth_options = auth_options
    end

    # Public: Return the status of the HTTP check
    def check
      mark_message "HTTP on Fedora REST interface successful" if ping?
    rescue => e
      mark_message "Error: '#{e}'"
      mark_failure
    end

    # Public: Actually performs the request against the URL.
    # Returns response body if the request was successful.
    # Otherwise raises a HttpCheck::ConnectionFailed error.
    def perform_request
      Timeout.timeout(request_timeout) do
        options = { read_timeout: request_timeout }
        if basic_auth_options.any?
          options[:http_basic_authentication] = basic_auth_options
        end
        url.read(options)
      end
    rescue => e
      raise ConnectionFailed, e
    end

    def parse_url(url)
      self.url = URI.parse(URI.encode(url.strip))
      return unless self.url.userinfo
      self.basic_auth_username, self.basic_auth_password = self.url.userinfo.split(':')
      self.url.userinfo = ''
    end

    def basic_auth_options
      if auth_options.any?
        auth_options
      else
        [basic_auth_username, basic_auth_password]
      end
    end

    def ping?
      response = perform_request
      !(response =~ %r{info:fedora/fedora-system}).nil?
    end
  end
end
