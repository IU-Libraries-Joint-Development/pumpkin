require 'rails_helper'

RSpec.describe "ScannedResourcesController", type: :feature do
  let(:user) { FactoryGirl.create(:image_editor) }
  let(:open_resource) {
    FactoryGirl.create(:open_scanned_resource, user: user)
  }
  let(:private_resource) {
    FactoryGirl.create(:private_scanned_resource, user: user)
  }

  context "when as an anonymous user" do
    it "views a public manifest" do
      visit manifest_curation_concerns_scanned_resource_path open_resource
      expect(page.status_code).to eq 200
    end

    it "views a private manifest" do
      visit manifest_curation_concerns_scanned_resource_path private_resource
      expect(page.status_code).to eq 401
    end
  end

  context "when as an authenticated user" do
    before do
      sign_in user
    end

    it "views a public manifest" do
      visit manifest_curation_concerns_scanned_resource_path open_resource
      expect(page.status_code).to eq 200
    end

    it "views a private manifest" do
      visit manifest_curation_concerns_scanned_resource_path private_resource
      expect(page.status_code).to eq 200
    end
  end
end
