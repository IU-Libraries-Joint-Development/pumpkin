# unmodified from IIIF::Presentation::ImageResource
module Extensions
  module IIIF
    module Presentation
      module ImageResource
        module GetInfoRetry
          def self.included(base)
            base.class_eval do
              protected
              def self.get_info(svc_id)
                conn = Faraday.new("#{svc_id}/info.json") do |c|
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
