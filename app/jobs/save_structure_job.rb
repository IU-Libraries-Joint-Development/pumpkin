class SaveStructureJob < ActiveJob::Base
  queue_as :default

  def perform(curation_concern, structure)
    return unless curation_concern.respond_to?(:logical_order)
    curation_concern.logical_order.order = structure
    curation_concern.save
  end
end
