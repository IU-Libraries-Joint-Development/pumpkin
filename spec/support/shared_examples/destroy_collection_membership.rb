RSpec.shared_examples "destroy_collection_membership" do
  describe "#destroy_collection_membership" do
    let(:collection) { FactoryGirl.create :collection }

    before do
      sign_in FactoryGirl.create(:admin)
      request.env['HTTP_REFERER'] = ':back'
      curation_concern.member_of_collections = [collection]
      curation_concern.save!
      patch :destroy_collection_membership, id: curation_concern.id
    end
    it "destroys collection membership" do
      expect(curation_concern.member_of_collections).not_to be_empty
      curation_concern.reload
      expect(curation_concern.member_of_collections).to be_empty
    end
    it "flashes a message" do
      expect(flash[:notice]).not_to be_empty
    end
    it "redirects to :back" do
      expect(response).to redirect_to ':back'
    end
  end
end
