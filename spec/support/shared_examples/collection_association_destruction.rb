RSpec.shared_examples 'collection association destruction' do
  let(:collection) { FactoryGirl.create :collection }
  describe '#collection_membership' do
    it 'returns an Array of ActiveFedora::Aggregation::Proxy' do
      curation_concern.member_of_collections = [collection]
      curation_concern.save!
      expect(curation_concern.collection_membership.last).to be_a ActiveFedora::Aggregation::Proxy
    end
  end
  describe '#destroy_collection_membership' do
    it 'destroys association nodes' do
      curation_concern.member_of_collections = [collection]
      curation_concern.save!
      curation_concern.destroy_collection_membership
      expect(curation_concern.collection_membership).to be_empty
    end
  end
end
