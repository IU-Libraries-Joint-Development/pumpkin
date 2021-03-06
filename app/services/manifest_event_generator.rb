class ManifestEventGenerator
  attr_reader :rabbit_exchange
  def initialize(rabbit_exchange)
    @rabbit_exchange = rabbit_exchange
  end

  delegate :enabled?, to: :rabbit_exchange

  def record_created(record)
    return false unless enabled?
    publish_message(
      message_with_collections("CREATED", record)
    )
  end

  def record_deleted(record)
    return false unless enabled?
    publish_message(
      message("DELETED", record)
    )
  end

  def record_updated(record)
    return false unless enabled?
    publish_message(
      message_with_collections("UPDATED", record)
    )
  end

  private

    def message(type, record)
      {
        "id" => record.id,
        "event" => type,
        "manifest_url" =>
        helper.polymorphic_url([:manifest,
                                :curation_concerns,
                                record.model_name.singular.to_sym],
                               id: record.id)
      }
    end

    def message_with_collections(type, record)
      message(type, record).merge(
        "collection_slugs" => record.member_of_collections.map(&:exhibit_id)
      )
    end

    def publish_message(message)
      rabbit_exchange.publish(message.to_json)
    end

    def helper
      @helper ||= ManifestBuilder::ManifestHelper.new
    end
end
