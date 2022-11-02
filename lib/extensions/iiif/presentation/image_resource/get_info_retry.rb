# modified from IIIF::Presentation::ImageResource
module Extensions
  module IIIF
    module Presentation
      module ImageResource
        module GetInfoRetry
          def self.included(base)
            base.class_eval do
              protected
              # modified from original to add retry settings
              def self.get_info(svc_id)
                conn = Faraday.new("#{svc_id}/info.json") do |c|
                  c.request :retry, max: 2, interval: 0.05,
                            interval_randomness: 0.5, backoff_factor: 2,
                            exceptions: [Faraday::Error]
                  c.use Faraday::Response::RaiseError
                  c.use Faraday::Adapter::NetHttp
                end
                resp = conn.get # raises exceptions that indicate HTTP problems
                JSON.parse(resp.body)
              end
            end
          end
        end
      end
    end
  end
end
