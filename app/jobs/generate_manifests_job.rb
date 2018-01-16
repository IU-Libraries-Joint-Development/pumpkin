class GenerateManifestsJob < ActiveJob::Base
  def perform(scanned_resource_ids = [], user = User.first)
    @user = user
    if scanned_resource_ids.empty?
      ActiveFedora::Base.search_in_batches('state_ssim': 'complete') do |record|
        record.each do |x|
          scanned_resource_ids << x['id']
        end
      end
    end
    scanned_resource_ids.each do |id|
      begin
        Rails.logger.debug "Generating manifest for #{id}"
        doc = SolrDocument.new(ActiveFedora::Base.search_by_id(id))
        presenter = ::MultiVolumeWorkShowPresenter.work_presenter_class.new(doc, Ability.new(@user))
        manifest = PolymorphicManifestBuilder.new(presenter, ssl: true).to_json
        Rails.cache.write("manifest/#{presenter.id}/#{ResourceIdentifier.new(presenter.id)}", manifest)
      rescue Exception => e
        msg = "ERROR for #{id}: #{e.message}"
        print msg
        Rails.logger.error msg
      end
    end
  end
end
