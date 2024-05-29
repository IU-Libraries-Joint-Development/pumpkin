class SaveStructureJob < ActiveJob::Base
  prepend ::LockableJob
  queue_as :default

  # rubocop:disable Metrics/AbcSize
  def perform(curation_concern, structure)
    return unless curation_concern.respond_to?(:logical_order)
    # Remove existing logical order object to avoid accumulation of fragments.
    begin
      curation_concern.logical_order.destroy eradicate: true
    rescue ActiveFedora::ObjectNotFoundError
      begin
        logical_order = ActiveFedora::Base.id_to_uri(curation_concern.id) + "/logical_order"
        ActiveFedora.fedora.connection.head(logical_order)
      rescue Ldp::Gone
        tombstone = ActiveFedora::Base.id_to_uri(curation_concern.id) + "/logical_order/fcr:tombstone"
        ActiveFedora.fedora.connection.delete(tombstone)
      end
    end
    curation_concern.reload
    curation_concern.logical_order.order = structure
    curation_concern.save
    if !curation_concern.persisted? ||
       !curation_concern.logical_order.persisted?
      raise ActiveFedora::RecordNotSaved,
            "#{curation_concern.id} logical order not saved!"
    end
  rescue StandardError
    Rails.logger.error "SaveStructureJob failed on #{curation_concern.id}!" \
    " Following structure may not be persisted:\n#{structure}"
    raise
  end
  # rubocop:ensable Metrics/AbcSize
end
